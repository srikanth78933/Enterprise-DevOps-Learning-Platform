# Student Assignments — Project 5: Centralized Logging (ELK)

## Beginner

1. Add a sixth log category: **audit logs** for every Employee/Department/
   Project create/update/delete (who, what, when — "who" can be a
   placeholder like `"system"` until auth exists in a later project). Tag
   it distinctly in the Logstash pipeline (`audit_log`) and confirm it
   shows up separately from `request_log` in Kibana.
2. Finish the dashboard started in `docs/04-Step-by-Step.md` step 5: add a
   third visualization showing the top 10 slowest endpoints by average
   `app.durationMs`, grouped by `app.uri`.

## Intermediate

3. Add an Elasticsearch Index Lifecycle Management (ILM) policy that rolls
   indices over after 7 days or 5GB and deletes anything older than 30
   days — right now, `enterprise-devops-logs-*` grows forever. Apply it via
   a Kibana Dev Tools call or a Logstash pipeline addition, and document
   how you verified it actually rolls over (you don't have to wait 7 real
   days — simulate with a shorter policy first).
4. Add resource-based alerting: a Kibana alert (or a simple script polling
   the ES query API) that fires when `error_log`-tagged documents exceed
   some rate in a rolling window. This is a preview of what Project 6's
   Alertmanager formalizes for metrics — implement the logs-based
   equivalent here first.
5. Extend Filebeat's `watchNamespace` filter (currently just
   `enterprise-devops`) to also ship `argocd` namespace logs, so Argo CD's
   own sync failures show up in the same Kibana instance. Consider (and
   document) whether that's actually a good idea, or whether platform logs
   deserve their own separate index/retention policy.

## Advanced

6. Replace the self-signed Kibana TLS cert with a real one issued by
   cert-manager (install cert-manager, create a self-signed or
   Let's-Encrypt-staging `ClusterIssuer`, and point Kibana's Ingress at it
   via annotations instead of a manually-created Secret). Document exactly
   what changes in `logging/elk-stack/charts/kibana/templates/ingress.yaml`.
7. Scale Elasticsearch from single-node to a real 3-node cluster: update
   `discovery.type` away from `single-node` to proper
   `discovery.seed_hosts` + `cluster.initial_master_nodes` pointed at the
   StatefulSet's stable pod DNS names (`elasticsearch-0.elasticsearch-headless`,
   etc. — see the comment in `charts/elasticsearch/templates/configmap.yaml`
   for exactly what has to change), and verify a real cluster forms via
   `_cluster/health`.

## Submission

Open a PR against `project-05-logging-elk`. Include a screenshot of your
Kibana dashboard and the Elasticsearch `_cat/indices?v` output.
