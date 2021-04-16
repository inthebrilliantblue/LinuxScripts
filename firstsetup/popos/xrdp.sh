#!/bin/bash
echo "Installing xrdp..."
sudo apt install xrdp -y

#Now setup the ubuntu color profile rules
echo "Setting up color profile rules..."
sudo bash -c "cat >/etc/polkit-1/localauthority/50-local.d/45-allow.colord.pkla" <<EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF
#End of paste

echo 'Adding changes to /etc/xrdp/startwm.sh due to name changes in GDM for PopOS...'
sed -i '4 i export GNOME_SHELL_SESSION_MODE=pop;' /etc/xrdp/startwm.sh
sed -i '5 i export GDMSESSION=pop' /etc/xrdp/startwm.sh
sed -i '6 i export XDG_CURRENT_DESKTOP=pop:GNOME' /etc/xrdp/startwm.sh

echo 'Installing XRDP - Done!'
