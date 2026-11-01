# Proton Mail Bridge, headless, for the second brain's mail gateway on Project.Manager (Coolify, Dockerfile build pack).
# Repacks the official .deb (version in PACKAGE) with fewer dependencies. Based on shenxn/protonmail-bridge-docker (MIT).
# IMAP on 143 and SMTP on 25 inside the container (socat in front of the bridge's 1143/1025, which only accept 127.0.0.1).
# Account state lives in /root (persistent volume). First login is interactive: see login.sh.
FROM debian:sid-slim AS build
COPY install.sh PACKAGE /
RUN apt-get update && apt-get install -y --no-install-recommends wget binutils ca-certificates && bash /install.sh

FROM debian:sid-slim
EXPOSE 25/tcp 143/tcp
WORKDIR /protonmail
COPY gpgparams entrypoint.sh PACKAGE /protonmail/
COPY --from=build /protonmail.deb /tmp/protonmail.deb
RUN apt-get update \
    && apt-get install -y --no-install-recommends /tmp/protonmail.deb socat pass libsecret-1-0 libfido2-1 ca-certificates procps \
    && rm -rf /var/lib/apt/lists/* /tmp/protonmail.deb \
    && if ldd /usr/lib/protonmail/bridge/bridge | grep -q "not found"; then ldd /usr/lib/protonmail/bridge/bridge | grep "not found"; exit 1; fi
HEALTHCHECK --interval=30s --timeout=5s --start-period=90s CMD bash -c 'exec 3<>/dev/tcp/127.0.0.1/1143' || exit 1
CMD ["bash", "/protonmail/entrypoint.sh"]
