#!/bin/bash
# Repack the official deb: drop the desktop dependencies the headless bridge does not need.
set -ex
mkdir /deb
wget -q -i /PACKAGE -O /deb/protonmail.deb
cd /deb
ar x protonmail.deb
mkdir control
tar zxf control.tar.gz -C control
sed -i "s/^Depends: .*$/Depends: libgl1, libc6, libsecret-1-0, libstdc++6, libgcc-s1, libfido2-1/" control/control
cd control && tar zcf ../control.tar.gz . && cd ..
ar rcs /protonmail.deb debian-binary control.tar.gz data.tar.gz
