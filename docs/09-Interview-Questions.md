# Interview Questions — Project 4: GitOps with Argo CD

## GitOps fundamentals

1. Define GitOps in one sentence that distinguishes it from "we deploy via
   CI/CD." What's the actual difference if both end up running `kubectl
   apply` eventually?
2. What does "desired state" mean concretely in this project — point at
   the specific files that constitute it.
3. Explain "self-healing" using this project's `selfHeal: true` setting.
   What class of incident does this prevent that a traditional CD pipeline
   doesn't?
4. Why is `git revert` the correct way to roll back in this project,
   rather than re-running an old Jenkins build?

## Argo CD specifics

5. What's the difference between an Argo CD `AppProject` and an
   `Application`? Why does a single-app learning cluster still benefit
   from having both instead of using the `default` AppProject?
6. Walk through what `syncPolicy.automated.prune: true` actually does, and
   describe a scenario where it could delete something you didn't intend.
7. Why does `gitops/applications/enterprise-app.yaml` have a
   `resources-finalizer.argocd.argoproj.io` finalizer? What would deleting
   the Application look like without it?
8. What's the practical difference between Argo CD's default Git polling
   interval and a configured webhook, in terms of both latency and load?

## This project's design choices

9. Why do `helm/enterprise-app/values-images/backend.yaml` and
   `frontend.yaml` live inside the Helm chart directory instead of under
   `gitops/`, given that `gitops/` is conceptually where "things Argo CD
   watches" belong?
10. Why did Jenkins lose its AWS/kubectl credentials entirely in this
    project, when Project 3's Jenkins had them? What's the actual security
    benefit, concretely (not just "least privilege" as a slogan)?
11. `argocd app wait --health --sync` in both Jenkinsfiles — what does
    this stage actually verify, and what does it *not* verify that
    Project 3's `kubectl rollout status` did check?

## Security scanning

12. Why does Trivy block the pipeline while Docker Scout only marks it
    `UNSTABLE`? Is running both actually redundant, or do they check
    meaningfully different things?
13. What does `--ignore-unfixed` on the Trivy scan trade away, and why is
    that an acceptable tradeoff for a CI gate specifically (as opposed to,
    say, a periodic audit report)?
