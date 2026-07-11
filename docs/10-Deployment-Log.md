# Deployment Log — Getting the First Real EKS Deploy Working

A record of the one-time, mostly-manual actions taken against the real
Jenkins host and AWS account to get `project-02-cd-eks` running end to
end for the first time. Unlike the rest of `docs/`, this isn't a generic
walkthrough anyone can follow blind — it's what actually happened to
*this* deployment, kept here because most of it (AWS/Jenkins state) isn't
visible anywhere else in git.

## 1. Jenkins host ran out of disk space

`/var/lib/jenkins` alerted below 1GiB free on a 6.7GB root volume.
Diagnosis and fixes:

- An old, non-running kernel (`7.0.0-1006-aws`, superseded by `-1008`)
  plus its headers/modules were still installed — purged via
  `apt-get purge` + `apt-get autoremove` (~300MB).
- `apt-get clean` cleared the package cache.
- Jenkins' **ThinBackup** plugin had no retention limit configured and
  had been running daily FULL+DIFF backups since the install date,
  accumulating unbounded (512MB and growing). Trimmed to the newest 3;
  **still needs a retention limit set in Manage Jenkins → ThinBackup →
  Settings** or this recurs.
- Freed 574MB → 1.6GB, above the alert threshold.
- Separately, the EBS volume was resized 6.7GB → 20GB in the AWS
  Console. That alone doesn't grow the filesystem — ran `growpart` +
  `resize2fs` on the root partition to actually use the new space
  (19GB available afterward, no reboot needed).
- The disk alert had taken the Jenkins node offline; `systemctl restart
  jenkins` cleared it (confirmed no build was running first).

## 2. Jenkins agent was missing `aws` and `kubectl`

`jenkins/README.md` step 9 always documented this requirement, but it
had never actually been done on this host — first real "Deploy to EKS"
run failed with `aws: not found`. Installed `unzip`, `kubectl`
(v1.36.2), and AWS CLI v2 (v2.35.21) system-wide; confirmed both are on
the `jenkins` user's `PATH` (`/usr/local/bin`).

## 3. `BACKEND_IMAGE` was still the template placeholder

The Jenkinsfile shipped with `BACKEND_IMAGE = 'yourdockerhubuser/...'` —
`jenkins/README.md` step 6 always said to edit this before real runs,
but it hadn't been done. Docker login succeeded (as `devopstraining064`)
but push failed with `insufficient_scope: authorization failed` since
that account has no access to a `yourdockerhubuser/...` repo. Fixed to
`devopstraining064/enterprise-devops-backend`.

## 4. EBS CSI driver wasn't installed on the cluster

Once the image pushed and `Deploy to EKS` ran, `mysql-pvc` sat in
`Pending` forever: "waiting for external provisioner ebs.csi.aws.com".
The cluster had no EBS CSI driver addon and no IAM OIDC provider
(IRSA had never been set up on this cluster at all). Created, in order:

1. IAM OIDC identity provider for the cluster's OIDC issuer
2. IAM role `AmazonEKS_EBS_CSI_DriverRole`, trusting that provider,
   scoped to the `ebs-csi-controller-sa` service account, with the
   AWS-managed `AmazonEBSCSIDriverPolicy` attached
3. The `aws-ebs-csi-driver` EKS addon, using that role

Full commands now live in `docs/03-Installation.md` step 2 so this is
reproducible without re-deriving it.

## 5. Application/MySQL secrets didn't exist yet

First deploy to a brand-new namespace — `backend-secret` and
`mysql-secret` had never been created (`docs/03-Installation.md` step 5
covers this, but it's a manual one-time step, easy to skip). Created
both with freshly generated credentials. Matching values were also
stored in Jenkins Credentials as `mysql-app-credentials` (Username with
password) and `mysql-root-password` (Secret text) for reference —
**actual values are not reproduced here**; see either store if you need
them. Nothing in the pipeline currently syncs Jenkins Credentials into
the K8s Secret automatically — they're two independently-maintained
copies of the same values.

## 6. `application-prod.yml` couldn't actually start

With MySQL finally reachable, the backend crashed on startup:
`Schema-validation: missing table [departments]`. `ddl-auto: validate`
expects a pre-existing schema, but this project has no Flyway/Liquibase
migration tool to create one — the `prod` profile had simply never been
exercised against a real, empty database before. Changed to
`ddl-auto: update` (matches `application-dev.yml`) until a real
migration tool is introduced — see the comment in that file. Committed
as `ee3ab07`.

## Net result

A first-time real deploy touches far more than application code: host
disk management, missing CLI tooling, a placeholder never swapped out,
a cluster-level addon + IAM/IRSA setup, manual one-time secrets, and a
config default nobody had tested end to end. None of steps 1–3 or 5–6
should recur once fixed; step 4 (EBS CSI driver) is now documented as a
proper prerequisite in `docs/03-Installation.md` for anyone else
standing this up against a fresh cluster.
