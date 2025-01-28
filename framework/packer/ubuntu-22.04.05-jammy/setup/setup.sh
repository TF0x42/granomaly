#!/bin/bash

echo '> Cleaning all audit logs ...'
if [ -f /var/log/audit/audit.log ]; then
cat /dev/null > /var/log/audit/audit.log
fi
if [ -f /var/log/wtmp ]; then
cat /dev/null > /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
cat /dev/null > /var/log/lastlog
fi
# Cleans SSH keys.
echo '> Cleaning SSH keys ...'
rm -f /etc/ssh/ssh_host_*
# Sets hostname to localhost.
echo '> Setting hostname to localhost ...'
cat /dev/null > /etc/hostname
hostnamectl set-hostname localhost
# Cleans apt-get.
echo '> Cleaning apt-get ...'
apt-get clean
# Cleans the machine-id.
echo '> Cleaning the machine-id ...'
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# make it so ctrl+alt+del doesn't cause a reboot
systemctl mask ctrl-alt-del.target

# optional: cleaning cloud-init
# echo '> Cleaning cloud-init'
# rm -rf /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
# rm -rf /etc/cloud/cloud.cfg.d/99-installer.cfg
# echo 'datasource_list: [ VMware, NoCloud, ConfigDrive ]' | tee /etc/cloud/cloud.cfg.d/90_dpkg.cfg
# /usr/bin/cloud-init clean

#curl https://github.com/schwankner.keys > ~/.ssh/authorized_keys
mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && curl https://github.com/schwankner.keys >> ~/.ssh/authorized_keys

sudo tee /etc/rc.local << EOF
#!/bin/bash
test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
test -f /var/lib/dbus/machine-id || systemd-machine-id-setup
exit 0
EOF
sudo chmod +x /etc/rc.local
