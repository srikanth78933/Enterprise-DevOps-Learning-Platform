# Interview Questions — Project 5: Centralized Logging (ELK)

## ELK fundamentals

1. What's the specific job of each of the four components (Elasticsearch,
   Logstash, Filebeat, Kibana)? Which one(s) could you remove and still
   have a (lesser) working pipeline, and what would you lose?
2. Why ship logs via a sidecar/DaemonSet log shipper (Filebeat) reading
   files, rather than having the application push logs directly to
   Logstash or Elasticsearch over the network?
3. What does Logstash's `json` filter actually do to a raw log line, and
   why does this project apply it conditionally (only when a Kubernetes
   label matches), not to every incoming event?

## Kubernetes specifics

4. Why does Elasticsearch use a StatefulSet with `volumeClaimTemplates`
   while this repo's MySQL (Projects 2-4) uses a plain Deployment with a
   single shared PVC? What would break if you swapped them?
5. Why does Filebeat need a ClusterRole (cluster-scoped), not just a
   namespaced Role, even though it only ships logs from one namespace by
   configuration (`watchNamespace`)?
6. Explain what `tolerations: - operator: Exists` on the Filebeat
   DaemonSet does, and why a log shipper specifically needs it when most
   of this repo's other workloads don't.

## This project's design choices

7. Why is `logging-stack` a separate Argo CD Application instead of a
   fourth subchart inside `enterprise-app`?
8. Why does `logging-stack`'s Application omit `selfHeal: true` while
   `enterprise-app`'s Application has it?
9. Why does `logback-spring.xml` only emit JSON in non-dev profiles
   instead of always emitting JSON (which would also work with the ELK
   pipeline, just be harder to read locally)?
10. Walk through why `RequestLoggingFilter` uses MDC for `requestId`
    instead of passing it explicitly through method calls. What would you
    lose by choosing thread-local MDC over explicit parameter-passing in a
    reactive (non-blocking) application, if this were ever migrated to
    WebFlux?

## Log design

11. Why does `GlobalExceptionHandler` log `ResourceNotFoundException` at
    WARN without a stack trace, but generic `Exception` at ERROR with one?
    What operational problem does logging every 404 at ERROR create at
    scale?
12. What's the tradeoff of tagging log events at ingestion time (Logstash,
    this project's approach) versus tagging them at query time (a saved
    Kibana search with the same filter criteria, applied only when
    someone looks)?
