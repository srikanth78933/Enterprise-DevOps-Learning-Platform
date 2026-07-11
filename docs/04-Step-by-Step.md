# Step-by-Step Walkthrough — Project 5: Centralized Logging (ELK)

## 1. Confirm raw logs look right before trusting the pipeline

```bash
./scripts/tail-logs.sh
```

You should see one JSON object per line, each with `level`, `logger_name`,
`message`, and (during an active request) `requestId`. If this looks like
plain text instead of JSON, `SPRING_PROFILES_ACTIVE` isn't set to
anything other than `dev` for this pod — check
`helm/enterprise-app/charts/backend/values.yaml`'s
`config.springProfilesActive`.

## 2. Find the five log categories in Kibana

After running `scripts/generate-test-traffic.sh`, in Kibana's Discover
tab:

- **Application logs**: search `app.logger_name: *` (everything has this)
- **Request logs**: search `tags: request_log`
- **Error logs**: search `app.level: ERROR` or `tags: error_log`
- **Exception logs**: same as error logs — open one and expand
  `app.stack_trace` to see the full trace
- **Slow requests**: search `tags: slow_request` (see step 3 to actually
  produce one)

## 3. Produce a slow-request log entry on purpose

The default threshold (`SLOW_REQUEST_THRESHOLD_MS=1000`) is unlikely to
trigger under normal local traffic. Lower it temporarily:

```bash
helm upgrade enterprise-app helm/enterprise-app -n enterprise-devops \
  --reuse-values --set backend.config.slowRequestThresholdMs=1
```

(This is a direct Helm upgrade for a quick demo, bypassing GitOps — revert
it via a Git-tracked change afterward, not another direct `helm upgrade`,
to avoid leaving your `enterprise-app` release drifted from what Argo CD's
`selfHeal` expects to find.)

Then re-run `./scripts/generate-test-traffic.sh` — every request now
exceeds 1ms and logs as `slow_request`.

## 4. Trace one request end-to-end via `requestId`

```bash
curl -sD - -H "Host: enterprise-devops.example.com" "http://<lb-hostname>/api/employees/999999" -o /dev/null | grep -i x-request-id
```

Copy the `X-Request-Id` value, then in Kibana search
`app.requestId: "<that-value>"` — you should see both the `request_log`
line (WARN or INFO, status 404) and the corresponding warn-level
`resource_not_found` application log from `GlobalExceptionHandler`, tied
together by that one field.

## 5. Build a simple Kibana dashboard

Create a visualization counting log volume by `tags` over time, and a
second one counting by `app.level`. Save both to a dashboard named
"Enterprise DevOps — Log Overview." This is what `docs/08-Assignments.md`
builds on.

## Next

Continue to [05-Flow.md](./05-Flow.md).
