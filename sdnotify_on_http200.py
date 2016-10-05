#!/usr/bin/python2
# -*- coding: utf-8 -*-
# Latest version at <http://github.com/ryran/b19scripts>
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

# CUSTOMIZE URL LIST, ENSURING THERE IS AT LEAST ONE VALID URL
URLS = [
    'http://localhost:8080',
    'https://www.redhat.com/en',
     ]

# CUSTOMIZE THESE MESSAGES IF DESIRED
INITIAL_MSG = "Checking site availability"
WAITING_MSG = "Still waiting on"
SUCCESS_MSG = "Completed startup; all sites returned HTTP 200 OK"

# CUSTOMIZE THE SLEEP CHECK INTERVAL IF DESIRED
SLEEP_INTERVAL = 0.2

# ================================== #
# NO NEED TO CUSTOMIZE ANYTHING ELSE #
# ================================== #

from socket import socket, AF_UNIX, SOCK_DGRAM
from os import getenv
from requests import head
from time import sleep
from sys import exit

class systemdNotify:
    """Barebones sd_notify functionality."""
    
    def __init__(self, mainpid=None, notify_sock=None):
        self.s = socket(AF_UNIX, SOCK_DGRAM)
        if not notify_sock:
            notify_sock = getenv('NOTIFY_SOCKET')
        if not notify_sock:
            print("Unable to get $NOTIFY_SOCKET; are we running inside service cgroup?")
            raise()
        self.s.connect(notify_sock)
        if not mainpid:
            mainpid = getenv('MAINPID')
        if mainpid:
            self.s.sendall("MAINPID={}\n".format(mainpid))
    
    def status(self, msg):
        self.s.sendall("STATUS={}\n".format(msg))
    
    def ready(self, msg=None):
        if msg:
            self.status(msg)
        self.s.sendall("READY=1\n")
        self.s.close()

def url_is_up(u):
    try:
        r = head(u)
    except:
        return False
    return r.status_code == 200

def check_url_list(ulist):
    for u in ulist:
        if not url_is_up(u):
            return False, u
    return True, None

if __name__ == '__main__':
    sdn = systemdNotify()
    sdn.status(INITIAL_MSG)
    while 1:
        success, url = check_url_list(URLS)
        if success:
            break
        else:
            sdn.status("{} {}".format(WAITING_MSG, url))
            sleep(SLEEP_INTERVAL)
    sdn.ready(SUCCESS_MSG)