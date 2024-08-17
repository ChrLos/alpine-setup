#!/bin/sh

apk add distrobox podman podman-compose
rc-update add cgroups
rc-service cgroups start
modprobe tun
echo tun >>/etc/modules
echo $user:100000:65536 >/etc/subuid
echo $user:100000:65536 >/etc/subgid

cat > /etc/local.d/mount-rshared.start << EOF
#!/bin/sh
mount --make-rshared /
EOF

chmod +x /etc/local.d/mount-rshared.start
rc-update add local default
rc-service local start

