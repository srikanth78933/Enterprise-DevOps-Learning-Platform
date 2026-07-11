# Log Pipeline Flow — Project 5

Full diagram: [`/architecture/log-flow.md`](../architecture/log-flow.md).

## End-to-end, one request

1. A client calls `GET /api/employees/999999`
2. `RequestLoggingFilter` assigns a `requestId`, lets the request proceed
3. `EmployeeServiceImpl` throws `ResourceNotFoundException`
4. `GlobalExceptionHandler.handleNotFound` logs at WARN:
   `resource_not_found uri=/api/employees/999999 message=...`
   (with `requestId` attached via MDC, no stack trace — this is expected
   client behavior, not a system failure)
5. `RequestLoggingFilter`'s `finally` block logs the request line:
   `request method=GET uri=/api/employees/999999 status=404 durationMs=12`
   (same `requestId`)
6. Both lines are written as JSON to stdout by `logback-spring.xml`'s
   non-dev appender
7. The container runtime captures stdout to
   `/var/log/containers/backend-<pod>-<container>.log` on the node
8. Filebeat (already tailing that file via Kubernetes autodiscover) ships
   both lines to Logstash over the beats protocol
9. Logstash's `json` filter parses `message` into the `app.*` fields, adds
   the `error_log` tag if `app.level == ERROR` (not triggered here — WARN
   isn't ERROR) or matches `slow_request`/`request_log` patterns
10. Elasticsearch indexes both documents into
    `enterprise-devops-logs-2026.07.11`
11. Kibana's Discover, searching `app.requestId: "<the-id>"`, shows both

## Why request logging happens in a Filter, not an Interceptor

A `Filter` runs before Spring's `DispatcherServlet` and wraps the *entire*
request lifecycle, including cases that never reach a controller method at
all (404s for unmapped routes, requests rejected by CORS). A
`HandlerInterceptor` only fires once a handler is resolved — it would miss
exactly the kind of "this route doesn't exist" traffic that's often the
most useful to see in a request log.

## Why MDC instead of just including requestId in every log call manually

`MDC.put("requestId", ...)` (in `RequestLoggingFilter`) makes every log
statement *anywhere* in the call stack for that request — including ones
in code that has no idea a request is even in flight, like a repository or
service method — automatically carry that field once
`logstash-logback-encoder` picks it up. Threading a `requestId` parameter
through every method signature by hand would be significantly more
invasive for the same result.

## Next

Continue to [06-Troubleshooting.md](./06-Troubleshooting.md).
