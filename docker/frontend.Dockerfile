# Multi-stage build: compiles the React app, then serves the static bundle with NGINX.

FROM node:20-alpine AS build
WORKDIR /build
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ .
RUN npm run build

FROM nginx:1.27-alpine AS runtime

# The nginx:1.27-alpine tag itself lags behind Alpine's own package repo for
# security patches (e.g. openssl/libssl3 CVEs fixed upstream in Alpine days
# before nginx rebuilds the image) - pull current packages at build time
# instead of trusting the base image snapshot.
RUN apk update && apk upgrade --no-cache

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /build/build /usr/share/nginx/html
EXPOSE 80
# 127.0.0.1, not localhost: this nginx.conf binds IPv4 only, but "localhost"
# resolves to ::1 first in this image, so wget tried IPv6 and got connection
# refused even though nginx was healthy - reproduced against a real container.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD wget -qO- http://127.0.0.1:80 || exit 1
CMD ["nginx", "-g", "daemon off;"]
