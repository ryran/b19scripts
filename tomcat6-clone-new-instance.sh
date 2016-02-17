#!/bin/bash

c_CYAN='\033[1;36m'
c_cyan='\033[0;36m'
c_PURPLE='\033[1;35m'
c_GREEN='\033[1;32m'
c_green='\033[0;32m'
c_YELLOW='\033[1;33m'
c_reset='\033[0;0m'

print() {
	echo -e "${@}"
}
header() {
	echo -e "\n${c_GREEN}${@}${c_reset}"
}
err() {
	echo -e "${c_YELLOW}${@}${c_reset}"; exit 1
}
prompt() {
	echo -e "${c_CYAN}${@}${c_reset}"
	unset REPLY
	until [[ -n ${REPLY} ]]; do
		printf "${c_cyan}"
		read -ep "> "
	done
	printf "${c_reset}"
}
print_usage() {
	cat <<-EOF
	tomcat6-clone-new-instance.sh INSTANCE
	Creates a clone service of name "tomcat-INSTANCE by doing the following:
	
	  /etc/init.d/tomcat6    =>  /etc/init.d/tomcat6-INSTANCE
	  /etc/sysconfig/tomcat6 =>  /etc/sysconfig/tomcat6-INSTANCE
	  /usr/share/tomcat6     =>  /usr/share/tomcat6-INSTANCE
	  /etc/tomcat6           =>  /etc/tomcat6-INSTANCE
	  /var/log/tomcat6       =>  /var/log/tomcat6-INSTANCE
	  /var/cache/tomcat6     =>  /var/cache/tomcat6-INSTANCE
	  /var/lib/tomcat6       =>  /var/lib/tomcat6-INSTANCE
	
	Then the service is added:
	  chkconfig --add tomcat6-INSTANCE
	
	Then the /etc/sysconfig/INSTANCE file has the following appended to it:
	  CATALINA_PID="/var/run/tomcat6-INSTANCE.pid"
	  CATALINA_BASE="/usr/share/tomcat6-INSTANCE"
	  CATALINA_HOME="/usr/share/tomcat6-INSTANCE"
	  JASPER_HOME="/usr/share/tomcat6-INSTANCE"
	  CATALINA_TMPDIR="/var/cache/tomcat6-INSTANCE/temp"
	
	Then you are prompted to input port numbers to change the values in the
	/etc/tomcat6-INSTANCE/server.xml file
	
	Extra notes:
	  - This assumes a default unmodified tomcat6 install in RHEL6
	  - All commands print verbose output but there is no error checking
	
	License:
	    This program is free software: you can redistribute it and/or modify
	    it under the terms of the GNU General Public License as published by
	    the Free Software Foundation, either version 3 of the License, or
	    (at your option) any later version.
	
	    This program is distributed in the hope that it will be useful,
	    but WITHOUT ANY WARRANTY; without even the implied warranty of
	    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	    General Public License <gnu.org/licenses/gpl.html> for more details.
	EOF
	exit 1
}

[[ -z ${1} || -n ${2} || ${1} == -h || ${1} == --help ]] && print_usage
for rpm in tomcat6 tomcat6-webapps; do
	rpm -q ${rpm} >/dev/null || err "${rpm} is missing"
done
[[ $(id -u) != 0 ]] && err "Must be run as root"

INSTANCE=${1}
instance=tomcat6-${INSTANCE}

echo -e "${c_PURPLE}New instance will be called '${instance}'${c_reset}"

header "INFO: Symlinking sysv initscript ..."
ln -sv tomcat6 /etc/rc.d/init.d/${instance}

header "INFO: Adding & enabling with chkconfig ..."
chkconfig --add ${instance}
chkconfig ${instance} on
chkconfig --list ${instance}

header "INFO: Copying /etc/sysconfig/tomcat6 and making modifications ..."
cp -av /etc/sysconfig/tomcat6 /etc/sysconfig/${instance}
cat >>/etc/sysconfig/${instance} <<-EOF
	CATALINA_PID="/var/run/${instance}.pid"
	CATALINA_BASE="/usr/share/${instance}"
	CATALINA_HOME="/usr/share/${instance}"
	JASPER_HOME="/usr/share/${instance}"
	CATALINA_TMPDIR="/var/cache/${instance}/temp"
EOF

: ${SKIP_SELINUX:=""}
if [[ -z ${SKIP_SELINUX} ]] && selinuxenabled; then
	header "INFO: Adding entries to SELinux fcontext database ..."
	set -x
	semanage fcontext -a -t tomcat_cache_t "/var/cache/${instance}?(/.*)?"
	semanage fcontext -a -t tomcat_var_lib_t "/var/lib/${instance}?(/.*)?"
	semanage fcontext -a -t tomcat_log_t "/var/log/${instance}?(/.*)?"
	semanage fcontext -a -t tomcat_var_run_t "/var/run/${instance}?\.pid"
	set +x
fi

header "INFO: Creating directories with proper permissions, ownership, SELinux ..."
for dir in /var/log/tomcat6 /var/cache/tomcat6/{,temp,work}; do
	newdir=${dir/tomcat6/$instance}
	mkdir -vp $newdir
	chmod -v --reference=$dir $newdir
	chown -v --reference=$dir $newdir
	[[ -z ${SKIP_SELINUX} ]] && selinuxenabled && restorecon -vRF $newdir
done
cp -av /var/lib/tomcat6 /var/lib/${instance}

header "INFO: Copying /etc/tomcat6 ..."
cp -av /etc/tomcat6 /etc/${instance}

header "INFO: Time to modify /etc/${instance}/server.xml ..."
prompt "Changing 'Server port=8005'; Enter new port number ..."
set -x
sed -ri -e "/^\s*<Server port=/s|8005|${REPLY}|" /etc/${instance}/server.xml
set +x
prompt "Changing 'Connector port=8080'; Enter new port number ..."
set -x
sed -ri -e "/^\s*<Connector port=/s|8080|${REPLY}|" /etc/${instance}/server.xml
set +x
prompt "Changing 'Connector port=8443'; Enter new port number ..."
set -x
sed -ri -e "/^\s*<Connector port=/s|8443|${REPLY}|" /etc/${instance}/server.xml
set +x
prompt "Changing 'Connector port=8009'; Enter new port number ..."
set -x
sed -ri -e "/^\s*<Connector port=/s|8009|${REPLY}|" /etc/${instance}/server.xml
set +x

header "INFO: Copying /usr/share/tomcat6 ..."
cp -av /usr/share/tomcat6 /usr/share/${instance}
header "INFO: Modifying symlinks in /usr/share/${instance} ..."
for symlink in conf logs temp webapps work; do
	rm -v /usr/share/${instance}/${symlink}
done
ln -sfv /etc/${instance} /usr/share/${instance}/conf
ln -sfv /var/log/${instance} /usr/share/${instance}/logs
ln -sfv /var/cache/${instance}/temp /usr/share/${instance}/temp
ln -sfv /var/lib/${instance}/webapps /usr/share/${instance}/webapps
ln -sfv /var/cache/${instance}/work /usr/share/${instance}/work
