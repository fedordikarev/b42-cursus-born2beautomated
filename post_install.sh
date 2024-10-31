#!/bin/sh

apt update
apt install -y tmux libpam-pwquality ufw

cat <<'EOF' | tee /etc/sudoers.d/sudo_config
Defaults	passwd_tries=3
Defaults	badpass_message="I dont think so, try again"
Defaults	logfile="/var/log/sudo/sudo.log"
Defaults	log_input, log_output
Defaults	iolog_dir="/var/log/sudo"
Defaults	requiretty
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
EOF

sed -i \
	-e 's/PASS_MAX_DAYS.*/PASS_MAX_DAYS 30/' \
	-e 's/PASS_MIN_DAYS.*/PASS_MIN_DAYS 2/' \
	-e 's/PASS_WARN_AGE.*/PASS_WARN_AGE 7/' \
	/etc/login.defs

chage -m 2 -M 30 fdikarev
chage -m 2 -M 30 root

sed -i \
	-e 's/.*pam_pwquality.*/password	requisite	pam_pwquality.so retry=3 minlen=10 ucredit=-1 dcredit=-1 lcredit=-1 maxrepeat=3 reject_username difok=7 enforce_for_root/' \
	/etc/pam.d/common-password

sed -i \
	-e 's/#Port 22/Port 4242/' \
	-e 's/#PermitRootLogin .*/PermitRootLogin no/' \
	/etc/ssh/sshd_config

ufw allow 4242
ufw enable

cat <<'EOF' | tee /usr/local/bin/monitoring.sh
#!/bin/bash

# ARCH
arch=$(uname -a)

# CPU PHYSICAL
cpuf=$(grep "physical id" /proc/cpuinfo | wc -l)

# CPU VIRTUAL
cpuv=$(grep "processor" /proc/cpuinfo | wc -l)

# RAM
ram_total=$(free --mega | awk '$1 == "Mem:" {print $2}')
ram_use=$(free --mega | awk '$1 == "Mem:" {print $3}')
ram_percent=$(( ram_use * 100 / ram_total ))

# DISK
disk_total=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_t += $2} END {print disk_t}')
disk_use=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} END {print disk_u}')
disk_percent=$(( disk_use * 100 / disk_total ))

# CPU LOAD
cpul=$(vmstat 1 2 | tail -1 | awk '{printf $15}')
cpu_op=$(expr 100 - $cpul)
cpu_fin=$(printf "%.1f" $cpu_op)

# LAST BOOT
lb=$(uptime --since)

# LVM USE
lvmu=$(if [ $(lsblk | grep "lvm" | wc -l) -gt 0 ]; then echo yes; else echo no; fi)

# TCP CONNEXIONS
tcpc=$(ss -ta | grep -c ESTAB )

# USER LOG
ulog=$(users | wc -w)

# NETWORK
ip=$(hostname -I)
mac=$(ip link | grep "link/ether" | awk '{print $2}')

# SUDO
cmnd=$(journalctl _COMM=sudo | grep -c COMMAND)

wall "	Architecture: $arch
	CPU physical: $cpuf
	vCPU: $cpuv
	Memory Usage: $ram_use/${ram_total}MB ($ram_percent%)
	Disk Usage: $disk_use/${disk_total} ($disk_percent%)
	CPU load: $cpu_fin%
	Last boot: $lb
	LVM use: $lvmu
	Connections TCP: $tcpc ESTABLISHED
	User log: $ulog
	Network: IP $ip ($mac)
	Sudo: $cmnd cmd"
EOF
chmod a+x /usr/local/bin/monitoring.sh
