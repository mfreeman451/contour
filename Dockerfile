# syntax=docker/dockerfile:1
FROM debian:trixie-20260918-slim@sha256:a99cfc517144bc59b1978475ec53b46ecabec7e43635402ee5b77cc54cd1b20a
RUN apt-get update && apt-get install -y --no-install-recommends libstdc++6 libncurses6 libssl3t64 ca-certificates locales && rm -rf /var/lib/apt/lists/* && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen && useradd --uid 10001 --create-home app
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 HOME=/home/app
WORKDIR /app
COPY contour-release.tar.gz /tmp/contour-release.tar.gz
RUN tar -xzf /tmp/contour-release.tar.gz -C /app && rm /tmp/contour-release.tar.gz && chown -R 10001:10001 /app
USER 10001:10001
EXPOSE 4000 4001 4369 9100
CMD ["/app/bin/contour", "start"]
