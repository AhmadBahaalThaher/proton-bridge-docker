#!/bin/bash
set -e
# `init`: one-time interactive login (run with docker exec -it ... bash /protonmail/entrypoint.sh init while the
# service is stopped, or via login.sh). Otherwise: run the bridge headless behind socat.
if [[ $1 == init ]]; then
    if ! pass ls >/dev/null 2>&1; then
        gpg --generate-key --batch /protonmail/gpgparams
        pass init pass-key
    fi
    exec protonmail-bridge --cli
fi
# The bridge only accepts connections from 127.0.0.1; socat makes container-network clients look local.
socat TCP-LISTEN:25,fork,reuseaddr TCP:127.0.0.1:1025 &
socat TCP-LISTEN:143,fork,reuseaddr TCP:127.0.0.1:1143 &
rm -f faketty; mkfifo faketty
# A fake terminal keeps the CLI from exiting on EOF.
cat faketty | protonmail-bridge --cli
