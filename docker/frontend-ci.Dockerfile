# Used by the Jenkins "Docker Build" stage - mirrors backend-ci.Dockerfile's
# reasoning: the "Frontend Install & Test" stage already ran `npm run build`
# on the Jenkins agent, so this Dockerfile just serves that already-built,
# already-tested bundle instead of re-running npm inside Docker.
#
# Build context is the repo root (see Jenkinsfile "Docker Build" stage).

FROM nginx:1.27-alpine

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY frontend/build /usr/share/nginx/html

EXPOSE 80
# 127.0.0.1, not localhost - see docker/frontend.Dockerfile's comment,
# same root cause (this nginx.conf binds IPv4 only; "localhost" resolves
# to ::1 first in this image and wget doesn't fall back to IPv4).
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD wget -qO- http://127.0.0.1:80/health || exit 1
CMD ["nginx", "-g", "daemon off;"]
