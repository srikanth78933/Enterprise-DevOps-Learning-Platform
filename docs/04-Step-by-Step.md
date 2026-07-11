# Step-by-Step Walkthrough — Project 4: GitOps with Argo CD

## 1. Trigger the backend pipeline and watch it stop short of deploying

Push a trivial backend change. Watch the Jenkins console — after "Update
GitOps Values," it just shows a git push, then "Wait for Argo CD Sync"
polling. No `kubectl`, no `helm`, anywhere in the log.

```bash
git log --oneline -3   # should show the "chore(gitops): bump backend image tag..." commit
```

## 2. Watch Argo CD pick it up independently

```bash
kubectl get application enterprise-app -n argocd -w
```

You'll see `SYNC STATUS` flip to `OutOfSync` right after the Jenkins
commit lands, then back to `Synced` once Argo CD reconciles — this happens
whether or not Jenkins' `Wait for Argo CD Sync` stage is even running;
Argo CD doesn't know or care that Jenkins exists.

## 3. Prove self-healing actually works

```bash
./scripts/simulate-self-heal.sh
```

Or by hand: `kubectl scale deployment/backend -n enterprise-devops
--replicas=5`, then watch `kubectl get deployment backend -n
enterprise-devops -w` — it reverts to the Git-declared replica count
without anyone running `kubectl` again.

## 4. Prove rollback works — via Git, not `helm rollback`

```bash
# find the commit that bumped the tag you want to undo
git log --oneline -- helm/enterprise-app/values-images/backend.yaml

git revert <that-commit-sha>
git push origin project-04-gitops-argocd
```

Watch Argo CD deploy the reverted (older) image automatically. This is
the GitOps answer to "how do I roll back" — `git revert`, not a special
deploy-tool command. (Argo CD also supports rolling back via its own UI/
CLI to a previous *sync* — try `argocd app history enterprise-app` and
`argocd app rollback enterprise-app <id>` too, and think about how that
differs from a Git revert in terms of what's actually recorded as truth.)

## 5. Trigger a scan failure on purpose

Temporarily downgrade a backend dependency in `backend/pom.xml` to a
version with a known critical CVE (check the NVD database for an example),
push, and watch the **OWASP Dependency Check** or **Trivy Scan** stage
fail the build before an image ever reaches Docker Hub. Revert afterward.

## Next

Continue to [05-Flow.md](./05-Flow.md).
