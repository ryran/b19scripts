hhwchk - Summarize hardware info on local & remote systems
===============================================================

The purpose of `hhwchk` (originally called `host-hwcheck`) is to gather the most important details of a system's hardware and print it out in a concise summary.

An integral part of the original design was for it to be able to run on remote systems via `ssh` (without being present on remote systems or leaving any trace). Accordingly, from the beginning, `hhwchk` has not only accepted hostnames as arguments to check, but also has had special options for hostname sequencing.

Jump to ...

* [EXAMPLES IN ACTION](/ryran/hhwchk#examples-in-action)
* [REQUIREMENTS](/ryran/hhwchk#requirements)
* [THINGS THAT MIGHT SURPRISE YOU](/ryran/hhwchk#things-that-might-surprise-you)
* [AUTHORS](/ryran/hhwchk#authors)
* [LICENSE](/ryran/hhwchk#license)


EXAMPLES IN ACTION
-------

To give you an idea of what it's capable of, check it out in action.

```
[rsaw@sawzall~]$ hhwchk
Usage: hhwchk [-xbcdeghmnr|-Nv] SSH_HOST...|--localhost
  or:  hhwchk -?|--help
{hhwchk v2.3.0 last mod 2012/07/29}

[rsaw@sawzall~]$ hhwchk -?
Usage: hhwchk [-xbcdeghmnr|-Nv] SSH_HOST...|--localhost
  or:  hhwchk -?|--help
Use proc & standard tools to report hw info on localhost or ssh hosts

Host-selection options:
 -P, --prefix=PREFIX  where PREFIX is text to be prepended to SSH_HOST
 -S, --suffix=SUFFIX  where SUFFIX is text to be appended to SSH_HOST
 -L, --localhost      operate on localhost instead of SSH_HOST via ssh

Display options:
 -x, --nocolor    disable coloring of output
 -b, --bios       use dmidecode to query the bios for extra info
 -c, --cpu        show info on detected cpus
 -d, --disks      show info on block devices
 -e, --ethtool    show net interface details, via ethtool
 -g, --graphics   show info on vga adapters, via lspci
 -h, --hostname   show uname and (with -b) system info
 -m, --multipath  show info on multipath storage devices
 -n, --net        list detected wifi/ethernet devices, via lspci
 -r, --ram        show info on system ram
 -v, --verbose    show as much information as possible

Examples:
  hhwchk --localhost
  hhwchk -Lv
  hhwchk --cpu dev.b19.org prod.b19.org web.b19.org
  hhwchk -c dev prod web --suffix=.b19.org
  hhwchk --ram --bios station5 station6 station7
  hhwchk -rb --prefix station 5 6 7
  hhwchk -P root@station -S .example.com -v 5 6 7

Version info: hhwchk v2.3.0 last mod 2012/07/29
Report bugs or suggestions to <rsaw@redhat.com>
Or see <github.com/ryran/hhwchk> for bug tracker & latest version
Alternatively, run hhwchk with '--update'

[rsaw@sawzall~]$ hhwchk -L
1 Intel Core i5-2540M CPU @ 2.60GHz, 2 cores/ea
  (4 logical cpus; flags:ht,lm,pae,vmx)
RAM: 3837 MB (3.7 GB) 
DISKS: 3, totaling 1285 GiB (1.26 TiB)

[rsaw@sawzall~]$ sudo hhwchk -L
LENOVO 4174AQ5
1 Intel Core i5-2540M CPU @ 2.60GHz, 2 cores/ea
  (4 logical cpus; flags:ht,lm,pae,vmx)
RAM: 3837 MB (3.7 GB) <bios: 4096 MB>
DISKS: 3, totaling 1285 GiB (1.26 TiB)

[rsaw@sawzall~]$ sudo hhwchk -Lcb
CPU: 4 logical cpus (ht,lm,pae,vmx)
  1 Intel Core i5-2540M CPU @ 2.60GHz, 2 cores/ea
  <bios: Intel(R) Corporation Core i5 @ 2600 MHz>
  <bios: 1 of 1 sockets populated, with 2 cores/cpu, 2 total cores>

[rsaw@sawzall~]$ sudo hhwchk -Lrb
RAM: 3837 MB (3.7 GB)
  <bios: 4096 MB total, 1 of 2 DIMMs populated (16 GB max capacity)>

[rsaw@sawzall~]$ hhwchk -Ld
DISKS: 3, totaling 1285 GiB (1.26 TiB)
  sda   298.1 G
  sdb   55.9 G
  sdc   931.5 G

[rsaw@sawzall~]$ sudo hhwchk -Le
ETHTOOL:
  em1         link=DOWN                        drv e1000e v1.9.5-k / fw 0.13-3
  tun0        link=UP 10Mb/s full (autoneg=N)  drv tun v1.6
  virbr0      link=DOWN                        drv bridge v2.3 / fw N/A
  virbr0-nic  link=DOWN                        drv tun v1.6
  wlan0       link=UP                          drv iwlwifi v3.4.6-2.fc17.x86_64 / fw 9.221.4.1

[rsaw@sawzall~]$ hhwchk -vL
HOST: sawzall 3.4.6-2.fc17.x86_64
CPU: 4 logical cpus (ht,lm,pae,vmx)
  1 Intel Core i5-2540M CPU @ 2.60GHz, 2 cores/ea
RAM: 3837 MB (3.7 GB)
DISKS: 3, totaling 1285 GiB (1.26 TiB)
  sda   298.1 G
  sdb   55.9 G
  sdc   931.5 G
NETDEVS:
  1 Intel Corporation Centrino Ultimate-N 6300 (rev 3e)
  1 Intel Corporation 82579LM Gigabit Network Connection (rev 04)
VGA:
  Intel Corporation 2nd Generation Core Processor Family Integrated Graphics Controller (rev 09)
[ Note: Some of requested information requires root-access ]

[rsaw@sawzall~]$ sudo hhwchk -vL
HOST: sawzall 3.4.6-2.fc17.x86_64
  LENOVO 4174AQ5
CPU: 4 logical cpus (ht,lm,pae,vmx)
  1 Intel Core i5-2540M CPU @ 2.60GHz, 2 cores/ea
  <bios: Intel(R) Corporation Core i5 @ 2600 MHz>
  <bios: 1 of 1 sockets populated, with 2 cores/cpu, 2 total cores>
RAM: 3837 MB (3.7 GB)
  <bios: 4096 MB total, 1 of 2 DIMMs populated (16 GB max capacity)>
DISKS: 3, totaling 1285 GiB (1.26 TiB)
  sda   298.1 G
  sdb   55.9 G
  sdc   931.5 G
NETDEVS:
  1 Intel Corporation Centrino Ultimate-N 6300 (rev 3e)
  1 Intel Corporation 82579LM Gigabit Network Connection (rev 04)
ETHTOOL:
  em1         link=DOWN                        drv e1000e v1.9.5-k / fw 0.13-3
  tun0        link=UP 10Mb/s full (autoneg=N)  drv tun v1.6
  virbr0      link=DOWN                        drv bridge v2.3 / fw N/A
  virbr0-nic  link=DOWN                        drv tun v1.6
  wlan0       link=UP                          drv iwlwifi v3.4.6-2.fc17.x86_64 / fw 9.221.4.1
VGA:
  Intel Corporation 2nd Generation Core Processor Family Integrated Graphics Controller (rev 09)

[rsaw@sawzall~]$ hhwchk -hbdne 49-up a 58-up root@10.12.53.99
  operating on: {49-up,a,58-up,root@10.12.53.99}
------------------------------------------------{49-up
HOST: dhcp53-54.gsslab.rdu.redhat.com 2.6.9-103.EL
  Red Hat KVM
DISKS: 1, totaling 6 GiB (0.01 TiB)
  hda   6.0 G
NETDEVS:
  1 Realtek Semiconductor Co., Ltd. RTL-8139/8139C/8139C+ (rev 20)
ETHTOOL:
  eth0  link=UP 100Mb/s full (autoneg=Y)  drv 8139cp v1.2-rh1
------------------------------------------------{a
HOST: arenero 2.6.32-279.1.1.el6.x86_64
  Dell Inc. Precision WorkStation T3500  
DISKS: 0, totaling 0 GiB (0.00 TiB)
NETDEVS:
  1 Broadcom Corporation NetXtreme BCM5761 Gigabit Ethernet PCIe (rev 10)
ETHTOOL:
  br0         link=UP                            drv bridge v2.3 / fw N/A
  eth0        link=UP 1000Mb/s full (autoneg=Y)  drv tg3 v3.122 / fw 5761-v3.68
  virbr0      link=UP                            drv bridge v2.3 / fw N/A
  virbr0-nic  link=DOWN                          drv tun v1.6 / fw N/A
  virbr1      link=UP                            drv bridge v2.3 / fw N/A
  virbr1-nic  link=DOWN                          drv tun v1.6 / fw N/A
  virbr2      link=UP                            drv bridge v2.3 / fw N/A
  virbr2-nic  link=DOWN                          drv tun v1.6 / fw N/A
  vnet0       link=UP 10Mb/s full (autoneg=N)    drv tun v1.6 / fw N/A
  vnet1       link=UP 10Mb/s full (autoneg=N)    drv tun v1.6 / fw N/A
  vnet2       link=UP 10Mb/s full (autoneg=N)    drv tun v1.6 / fw N/A
------------------------------------------------{58-up
HOST: 58-up 2.6.18-308.11.1.el5
  Red Hat KVM
DISKS: 2, totaling 10 GiB (0.01 TiB)
  vda   0.5 G
  vdb   10.0 G
NETDEVS:
  1 Red Hat, Inc Virtio network device
ETHTOOL:
  eth0  link=UP  drv virtio_net
------------------------------------------------{root@10.12.53.99
HOST: dhcp53-99.gsslab.rdu.redhat.com 2.6.32-279.el6.x86_64
  Red Hat KVM
DISKS: 2, totaling 10 GiB (0.01 TiB)
  [Multipath and/or software raid components hidden]
  md0   0.5 G
  md1   9.5 G
NETDEVS:
  1 Red Hat, Inc Virtio network device
ETHTOOL:
  eth0  link=UP  drv virtio_net
```


REQUIREMENTS
-------

* The script doesn't use absolute paths for cmd names
* The script will gracefully report as much of what's requested as possible when running as non-root
* There is transparent error-checking to account for the following commands being missing:
  - `dmidecode`
  - `ethtool`
  - `multipath`
* There is no error-checking for anything else, so standard coreutils and the util-linux commands must be available via `$PATH`, plus the following:
  - `gawk`
  - `xargs`
  - `sed`
  - `lspci`, if you use `-v`, `-n`, or `-g`


THINGS THAT MIGHT SURPRISE YOU
-------

* The script can update itself via the internet if run with `--update`.
* When run with `-b/--bios` or in verbose mode, the script adds additional information (gleaned via `dmidecode`) to the host, cpu, and ram sections.
* When printing disk info, the script automatically detects linux software raid (md) devices and hides their components.
* When run with `-m/--multipath`, the script consults the `multipath` command to print info about native multipathd devices. If using this option in concert with `-d/--disks`, the script also detects all multipath device slave paths and hides those device nodes from the disk output.
* When printing info on net devices (`-n/--net` or `-v`), the script simplifies the output. Instead of trying to explain, I'll give an example.

```
[root@localhost]# lspci | grep Eth
04:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet (rev 12)
0b:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (rev 06)
0b:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (rev 06)
42:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet (rev 12)
43:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (rev 06)
43:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (rev 06)

[root@localhost]# hhwchk -Ln
NETDEVS:
  2 Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet (rev 12)  {2 x 1-port}
  4 Intel Corporation 82571EB Gigabit Ethernet Controller (rev 06)  {2 x 2-port}
```


AUTHORS
-------

As far as direct contributions go, so far it's just me, [ryran](/ryran), aka rsaw, aka [Ryan Sawhill](http://b19.org).

However, people rarely accomplish things in a vacuum... I am very thankful to StackOverflow and a couple prolific users over there. [Dennis Williamson](http://stackoverflow.com/users/26428/dennis-williamson) and [ghostdog74](http://stackoverflow.com/users/131527/ghostdog74) both offered answers containing pieces of code that were instrumental in teaching me how to do what I wanted to do with `awk`.

Please contact me if you have ideas, suggestions, questions, or want to collaborate on this or something similar. For specific bugs and feature-requests, you can [post a new issue on the tracker](/ryran/hhwchk/issues).


LICENSE
-------

Copyright (C) 2010, 2011, 2012 [Ryan Sawhill](http://b19.org)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License @[gnu.org/licenses/gpl.html](http://gnu.org/licenses/gpl.html>) for more details.

