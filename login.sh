#!/usr/bin/env bash
# One-time Proton login for the bridge on Project.Manager. Run on the PC; needs `ssh pm`.
# Stops the running bridge container, opens the bridge CLI on the same volume, you type:  login  (email, password, 2FA),
# then  info  (shows the bridge IMAP/SMTP username and password: copy the password),  then  exit.  Then it starts the
# container again. The bridge password goes into the gateway with coolify/gateway-secret-set.sh MAIL_PASSWORD.
set -euo pipefail
ssh -t pm 'set -e
C=$(docker ps -a --format "{{.Names}}" | grep -E "^proton-bridge|^'"${BRIDGE_UUID:-}"'" | head -1)
[ -n "$C" ] || { echo "no bridge container found"; exit 1; }
IMG=$(docker inspect "$C" --format "{{.Config.Image}}")
VOL=$(docker inspect "$C" --format "{{range .Mounts}}{{if eq .Destination \"/root\"}}{{.Name}}{{end}}{{end}}")
[ -n "$VOL" ] || { echo "bridge container has no /root volume"; exit 1; }
echo "container $C, volume $VOL"; docker stop "$C" >/dev/null
docker run --rm -it -v "$VOL":/root "$IMG" bash /protonmail/entrypoint.sh init || true
docker start "$C" >/dev/null && echo "bridge started again"'
