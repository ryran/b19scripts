#!/bin/bash
# add-file-trans-rule.sh v0.1 last mod 2016/04/05
# Latest version at <https://github.com/ryran/b19scripts>
# Copyright 2016 Ryan Sawhill Aroha <rsaw@redhat.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#    General Public License <gnu.org/licenses/gpl.html> for more details.
#
#-------------------------------------------------------------------------------

show_usage() {
cat <<\EOF
Usage: add-file-trans-rule.sh <TARGET_FILE> <TARGET_FILE_CLASS>

Where TARGET_FILE is the file to get auto-labeled without requiring restorecon.
Where TARGET_FILE_CLASS is most likely "file" or "dir" but could be anything
returned by "seinfo --class" command.

Example:

1. Add a rule to fcontext db first, e.g.:
   
  * semanage fcontext -a -t httpd_sys_rw_content_t \
      "/var/www/html(/.*)?/rwstoragedir"
   
  * semanage fcontext -a -t httpd_sys_rw_content_t \
      "/var/www/html/[^/]*/rwstoragefile"

2. Then execute this script, e.g.:

    add-file-trans-rule.sh /var/www/html/vhost1/bak/rwstoragedir dir
    add-file-trans-rule.sh /var/www/html/vhost2/rwstoragefile file

Note that by default this will set the source process domain to "unconfined_t",
which is suitable for triggering on actions that normal unconfined users make.
This can be overridden by changing the "PROCESS_DOMAIN" environment variable.

Note that the script will prompt for a module name unless the environment
variable "NEW_MODULE_NAME" is set. It will also prompt if "NEW_MODULE_NAME" is
set to the name of a currently loaded module, as listed by "semodule -l".
EOF
}

if [[ ${#} -ne 2 || ${1} =~ ^(-h|--help)$ ]]; then
    # Exit with help page if -h/--help or improper number of cmdline args
    show_usage
    exit
elif ! rpm -q selinux-policy-devel setools-console >/dev/null; then
    echo -e "Missing packages\nTry: yum install selinux-policy-devel setools-console"
    exit 1
fi

# Cmdline args
: ${PROCESS_DOMAIN:="unconfined_t"}
TARGET_FILE=${1}
TARGET_FILE_CLASS=${2}

# Validate input
seinfo --type="${PROCESS_DOMAIN}" >/dev/null || exit
seinfo --class="${TARGET_FILE_CLASS}" >/dev/null || exit

# Determine target context along with parent dir context
TARGET_BASENAME=$(basename "${TARGET_FILE}")
TARGET_TYPE=$(matchpathcon "${TARGET_FILE}" | cut -d: -f3)
PARENT_DIR_TYPE=$(matchpathcon "$(dirname "${TARGET_FILE}")" | cut -d: -f3)

# Be nice and verbose
cat <<EOF
Source process domain: "${PROCESS_DOMAIN}"
Parent directory type: "${PARENT_DIR_TYPE}"
Target file: "${TARGET_BASENAME}"
Target class: "${TARGET_FILE_CLASS}"

About to create a file name transition policy module based on above specs.
Cancel now if any of them are empty or incorrect.

The new module will need a name.
Names for loaded modules can be seen with the "semodule -l" command.
Example: "my-filetrans-${TARGET_BASENAME}"

EOF

# Get a module name
while [[ -z ${NEW_MODULE_NAME} ]] || semodule -l | grep -q "^${NEW_MODULE_NAME}\s"; do
    echo "Enter a unique name for this new filetrans module:"
    read -ep "> " NEW_MODULE_NAME
done

# Create & goto tmpdir
tmpDir=$(mktemp -p /tmp -d tmp.addfiletrans.XXXXXXXXXX)
echo "Creating module files in tempdir: ${tmpDir}"
cd ${tmpDir}

# Create te file
cat > "${NEW_MODULE_NAME}.te" <<EOF
policy_module(${NEW_MODULE_NAME}, 1.0)
gen_require(\`
    type ${PROCESS_DOMAIN}, ${PARENT_DIR_TYPE}, ${TARGET_TYPE};
')
filetrans_pattern(${PROCESS_DOMAIN}, ${PARENT_DIR_TYPE}, ${TARGET_TYPE}, ${TARGET_FILE_CLASS}, "${TARGET_BASENAME}")
EOF

# Make everything
echo "Executing: 'make -f /usr/share/selinux/devel/Makefile ${NEW_MODULE_NAME}.pp'"
make -f /usr/share/selinux/devel/Makefile "${NEW_MODULE_NAME}.pp"

# Explain it all
cat <<EOF

Assuming the above command finished without issue ...
The final step requires you to manually install the module yourself
Execute the following command:

  semodule -i ${tmpDir}/${NEW_MODULE_NAME}.pp

After that you should see your module in "semodule -l"
You can then disable it with "semodule -d ${NEW_MODULE_NAME}"
Or re-enable it with "semodule -e ${NEW_MODULE_NAME}"
You can also uninstall (remove) it with "semodule -r ${NEW_MODULE_NAME}"
EOF
