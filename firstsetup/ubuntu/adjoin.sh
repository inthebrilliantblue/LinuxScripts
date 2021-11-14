#Followed instructions Here:
#https://docs.microsoft.com/en-us/azure/active-directory-domain-services/active-directory-ds-join-ubuntu-linux-vm

#Set colors!
RED="\033[0;31m"
NC="\033[0m" # No Color

#Check for the software-properties-common package
sudo apt install software-properties-common -y

#Update system
echo 'Updating your system...'
sudo apt-get update
sudo apt-get upgrade -y --allow-downgrades

#Get some input on the domain we are joining
read -p "Enter domain name (EX: example.com): " DOMAIN
LCDOMAIN=${DOMAIN,,}
UCDOMAIN=${DOMAIN^^}
read -p "Enter workgroup name (EX: example): " WORKGROUP
UCWORKGROUP=${WORKGROUP^^}
read -p "Enter primary DC Name (Without $LCDOMAIN, EX: ns1): " DC
read -p "Enter primary DC IPv4 address (EX: 192.168.2.2): " DCIP
read -p "Enter username to use to join domain (EX: username): " USERNAME
read -p "Enter hostname you wish to use for this computer (This will change /etc/hostname and /etc/hosts): " HOSTNAME

#Change the localhost names
echo "Changing hosts file to point to hostname and localhost..."
#sed -i "1s/.*/127.0.0.1	${HOSTNAME}.${LCDOMAIN} ${HOSTNAME} localhost/" /etc/hosts
echo "127.0.0.1	localhost" > /etc/hosts

#Check if we want a static IPv4 address in /etc/hosts
read -p "Are you going to use a static IPv4 on this box? (y/n)" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
	read -p "    Input IPv4 address: " STATICIP
	echo "$STATICIP	$HOSTNAME.$LCDOMAIN $HOSTNAME" >> /etc/hosts
else
	echo "127.0.1.1 $HOSTNAME.$LCDOMAIN $HOSTNAME" >> /etc/hosts
fi

#Change the hostname of computer
echo "Changing hostname..."
echo "${HOSTNAME}" > /etc/hostname
sudo hostname $HOSTNAME

#Edit DNS resolver
echo "nameserver ${DCIP}" > /etc/resolv.conf
echo "search ${LCDOMAIN}" >> /etc/resolv.conf

#Now we need to install everything needed to join Active Directory Domain
echo "Installing everything needed to join to an Active Directory Domain"
sudo apt-get install acl attr krb5-user samba samba-common-bin sssd sssd-tools libnss-sss libpam-sss ntp ntpdate realmd adcli policykit-1 packagekit samba-vfs-modules samba-libs samba-dsdb-modules ssh winbind -y

#Add the domain name to the ntp servers list
echo "Adding 'server ${LCDOMAIN}' to /etc/ntp.conf"
sed -i "1i server ${LCDOMAIN}" /etc/ntp.conf

#Do a system time update
sudo echo "Stopping ntp..."
systemctl stop ntp
echo "Updating system time from the domain..."
sudo ntpdate $LCDOMAIN
echo "Starting ntp..."
sudo systemctl start ntp

#Now discover the realm
echo "Discovering realm ${UCDOMAIN}..."
sudo realm discover "${UCDOMAIN}"

#KINIT the user to join the domain
echo -e "\n${RED}!!!${NC} Please provide password for KINIT Ticket ${RED}!!!${NC}"
kinit "${USERNAME}@${UCDOMAIN}"

#Now join the domain
echo -e "\n${RED}!!!${NC} Join the Realm, input ${USERNAME}@${UCDOMAIN}'s password ${RED}!!!${NC}"
sudo realm join --verbose "${UCDOMAIN}" -U "${USERNAME}@${UCDOMAIN}" --install=/

#Create the realmd.conf file
echo '[users]' > /etc/realmd.conf
echo '	default-home = /home/%u@%d' >> /etc/realmd.conf
echo '	default-shell = /bin/bash' >> /etc/realmd.conf
echo '' >> /etc/realmd.conf
echo '[active-directory]' >> /etc/realmd.conf
echo '	default-client = sssd' >> /etc/realmd.conf
echo '	os-name = Ubuntu server' >> /etc/realmd.conf
echo '	os-version = 18.04' >> /etc/realmd.conf
echo '' >> /etc/realmd.conf
echo '[service]' >> /etc/realmd.conf
echo '	automatic-install = yes' >> /etc/realmd.conf
echo '' >> /etc/realmd.conf
echo "[$LCDOMAIN]" >> /etc/realmd.conf
echo '	fully-qualified-names = no' >> /etc/realmd.conf
echo '	automatic-id-mapping = yes' >> /etc/realmd.conf
echo '	user-principal = yes' >> /etc/realmd.conf
echo '	manage-system = yes' >> /etc/realmd.conf

#Change the sssd.conf file
echo "Modifying /etc/sssd/sssd.conf file..."
echo '[nss]' > /etc/sssd/sssd.conf
echo '	filter_groups = root' >> /etc/sssd/sssd.conf
echo '	filter_users = root' >> /etc/sssd/sssd.conf
echo '	reconnection_retries = 3' >> /etc/sssd/sssd.conf
echo '' >> /etc/sssd/sssd.conf
echo '[pam]' >> /etc/sssd/sssd.conf
echo '	reconnection_retries = 3' >> /etc/sssd/sssd.conf
echo '' >> /etc/sssd/sssd.conf
echo "[sssd]" >> /etc/sssd/sssd.conf
echo "	domains = $LCDOMAIN" >> /etc/sssd/sssd.conf
echo "	config_file_version = 2" >> /etc/sssd/sssd.conf
echo "	services = nss, pam, ssh" >> /etc/sssd/sssd.conf
echo "" >> /etc/sssd/sssd.conf
echo "[domain/$LCDOMAIN]" >> /etc/sssd/sssd.conf
echo "	default_shell = /bin/bash" >> /etc/sssd/sssd.conf
echo "	krb5_store_password_if_offline = True" >> /etc/sssd/sssd.conf
echo "	cache_credentials = True" >> /etc/sssd/sssd.conf
echo "	krb5_realm = $UCDOMAIN" >> /etc/sssd/sssd.conf
echo "	realmd_tags = manages-system joined-with-samba" >> /etc/sssd/sssd.conf
echo "	id_provider = ad" >> /etc/sssd/sssd.conf
echo "	fallback_homedir = /home/%u@%d" >> /etc/sssd/sssd.conf
echo "	ad_domain = $LCDOMAIN" >> /etc/sssd/sssd.conf
echo "#	use_fully_qualified_names = True" >> /etc/sssd/sssd.conf
echo "	ldap_id_mapping = True" >> /etc/sssd/sssd.conf
echo "	access_provider = ad" >> /etc/sssd/sssd.conf
echo "	ad_gpo_access_control = permissive" >> /etc/sssd/sssd.conf
echo "	enumerate = True" >> /etc/sssd/sssd.conf
echo "	ad_gpo_ignore_unreadable = True" >> /etc/sssd/sssd.conf
echo '' >> /etc/sssd/sssd.conf
echo '	auth_provider = ad' >> /etc/sssd/sssd.conf
echo '	chpass_provider = ad' >> /etc/sssd/sssd.conf
echo '	access_provider = ad' >> /etc/sssd/sssd.conf
echo '	ldap_schema = ad' >> /etc/sssd/sssd.conf
echo '	dyndns_update = true' >> /etc/sssd/sssd.conf
echo '	dyndns_refresh_interval = 43200' >> /etc/sssd/sssd.conf
echo '	dyndns_update_ptr = true' >> /etc/sssd/sssd.conf
echo '	dyndns_ttl = 3600' >> /etc/sssd/sssd.conf

#Restart the sssd service
echo "Restarting sssd..."
service sssd restart

#Change the pam.d common-sessions
echo "Adding 'session required pam_mkhomedir.so skel=/etc/skel/ umask=0077' to /etc/pam.d/common-session"
sed -i "/.*pam_sss.so/a session required pam_mkhomedir.so skel=\/etc\/skel\/ umask=0077" /etc/pam.d/common-session

#Add Domain Admins to sudoers
echo "Adding Domain Admins to sudoers..."
echo "%domain\ admins@buchanan.rocks ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "%domain\ admins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

#Setup samba config file
echo "Setting up Samba config..."
mv /etc/samba/smb.conf /etc/samba/smb.conf.default
echo "#======================= Global Settings =======================" > /etc/samba/smb.conf
echo "[global]" >> /etc/samba/smb.conf
echo "#Domain Config" >> /etc/samba/smb.conf
echo '	idmap config *:backend = tdb' >> /etc/samba/smb.conf
echo '	idmap config *:range = 70001-80000' >> /etc/samba/smb.conf
echo "	idmap config ${UCWORKGROUP}:backend = ad" >> /etc/samba/smb.conf
echo "	idmap config ${UCWORKGROUP}:schema_mode = rfc2307" >> /etc/samba/smb.conf
echo "	idmap config ${UCWORKGROUP}:range = 3000000-4000000" >> /etc/samba/smb.conf
echo "	workgroup = ${UCWORKGROUP}" >> /etc/samba/smb.conf
echo "	realm = ${UCDOMAIN}" >> /etc/samba/smb.conf
echo "	security = ads" >> /etc/samba/smb.conf
echo "	netbios name = ${HOSTNAME}" >> /etc/samba/smb.conf
echo "	server role = member server" >> /etc/samba/smb.conf
echo '	map acl inherit = Yes' >> /etc/samba/smb.conf
echo '	store dos attributes = Yes' >> /etc/samba/smb.conf
echo '	dedicated keytab file = /etc/krb5.keytab' >> /etc/samba/smb.conf
echo '	kerberos method = secrets and keytab' >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf

echo "#Other" >> /etc/samba/smb.conf
echo "	log file = /var/log/samba/log.%m" >> /etc/samba/smb.conf
echo "	map to guest = bad user" >> /etc/samba/smb.conf
echo "	server string = ${HOSTNAME} server" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf

echo "#Tweaks" >> /etc/samba/smb.conf
echo "	allocation roundup size = 4096" >> /etc/samba/smb.conf
echo "	server multi channel support = yes" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf

echo "#Add useful vfs objects" >> /etc/samba/smb.conf
echo "	vfs objects = acl_xattr recycle aio_pthread" >> /etc/samba/smb.conf
echo "#	vfs objects = recycle aio_pthread" >> /etc/samba/smb.conf
echo "	recycle:repository = recyclebin" >> /etc/samba/smb.conf
echo "	recycle:keeptree = yes" >> /etc/samba/smb.conf
echo "	recycle:versions = yes" >> /etc/samba/smb.conf
echo "	recycle:touch = yes" >> /etc/samba/smb.conf
echo "	recycle:touch_mtime = yes" >> /etc/samba/smb.conf
echo "	aio read size = 1" >> /etc/samba/smb.conf
echo "	aio write size = 1" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo '#Disable printing' >> /etc/samba/smb.conf
echo '	load printers = no' >> /etc/samba/smb.conf
echo '	printing = bsd' >> /etc/samba/smb.conf
echo '	printcap name = /dev/null' >> /etc/samba/smb.conf
echo '	disable spoolss = yes' >> /etc/samba/smb.conf

echo "#======================= Share Definitions =======================" >> /etc/samba/smb.conf
echo "#Home Drive" >> /etc/samba/smb.conf
echo "[homes]" >> /etc/samba/smb.conf
echo "comment = Home Directory" >> /etc/samba/smb.conf
echo "read only = no" >> /etc/samba/smb.conf
echo "browseable = no" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf

echo "#Static Shares" >> /etc/samba/smb.conf
echo "[Test]" >> /etc/samba/smb.conf
echo "comment = Test Setup Share" >> /etc/samba/smb.conf
echo "path = /test" >> /etc/samba/smb.conf
echo "read only = no" >> /etc/samba/smb.conf
echo "browseable = yes" >> /etc/samba/smb.conf

#Setup that test share folder
echo "Setting up test share..."
mkdir /test
chown "$USERNAME:domain users" /test
chmod 0775 /test

#Join again for samba
echo 'Now join again for ads/samba...'
sudo net ads join -k

#Restart all services needed
echo 'Restart services realmd sssd smbd...'
sudo systemctl restart realmd sssd smbd
sudo systemctl enable realmd sssd smbd

#Allow all users from the domain to login
echo 'Allow all domain users to access this server.'
sudo realm permit --all

#Now try to ssh to localhost with the user to test the join
echo "Now SSHing to localhost using ${USERNAME}..."
ssh "${USERNAME}@${UCDOMAIN}@localhost"
