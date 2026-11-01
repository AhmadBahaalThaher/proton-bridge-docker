# proton-bridge (second brain)
Headless Proton Mail Bridge image for Coolify. No secrets in this repo: the account is added once, interactively,
with `login.sh`; the state lives in the `/root` volume. IMAP 143 / SMTP 25 are reachable only on the Coolify docker
network (no published ports, no domain). Based on shenxn/protonmail-bridge-docker (MIT). Bridge version: see PACKAGE.
