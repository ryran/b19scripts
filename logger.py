#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Copyright 2016 Ryan Sawhill Aroha rsaw@redhat.com
# See https://github.com/ryran/b19scripts/ for latest version
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Modules from standard library
from __future__ import print_function
import argparse, logging, logging.handlers
from sys import exit, stdin, stderr
from os import getuid
from pwd import getpwuid

user = getpwuid(getuid()).pw_name

syslogPriorityToLoggerLevel = {
    'debug': 10,
    'info': 20,
    'notice': 25,
    'warning': 30,
    'warn': 30,
    'error': 40,
    'err': 40,
    'critical': 50,
    'crit': 50,
    'alert': 60,
    'emerg': 70,
    'panic': 70,
    }

loggerSyslogHandlerPriorityMap = {
    'DEBUG': 'debug',
    'INFO': 'info',
    'NOTICE': 'notice',
    'WARNING': 'warning',
    'ERROR': 'error',
    'CRITICAL': 'critical',
    'ALERT': 'alert',
    'EMERG': 'emerg',
    }

def parse_args():
    prog = 'logger.py'
    fmt = lambda prog: CustomFormatter(prog)
    p = argparse.ArgumentParser(
        prog=prog,
        description="A simplistic logger clone",
        add_help=True,
        epilog="Questions/issues to rsaw@redhat.com",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    p.add_argument('--id', action='store_true', help="log the process ID too")
    p.add_argument('--priority', default='user.info', help="mark given message with this priority")
    # p.add_argument('--stderr', action='store_true', help="output message to standard error as well")
    p.add_argument('--tag', default=user, help="mark every line with this tag")
    p.add_argument('--socket', default='/dev/log', help="write to this Unix socket")
    return p.parse_args()

def main():
    opts = parse_args()
    try:
        facility = opts.priority.split('.')[0]
        logging.handlers.SysLogHandler.facility_names[facility]
        priority = opts.priority.split('.')[1]
        logging.handlers.SysLogHandler.priority_names[priority]
        level = syslogPriorityToLoggerLevel[priority]
    except:
        print("Improper 'priority' specified")
        print("Must be <facility>.<priority> as described in logger(1) man page\n")
        raise
    logging.addLevelName(25, 'NOTICE')
    logging.addLevelName(60, 'ALERT')
    logging.addLevelName(70, 'EMERG')
    myLogger = logging.getLogger(opts.tag)
    myLogger.setLevel(logging.DEBUG)
    myHandler = logging.handlers.SysLogHandler(address=opts.socket, facility=facility)
    myHandler.priority_map = loggerSyslogHandlerPriorityMap
    if opts.id:
        myFormatter = logging.Formatter('%(name)s[%(process)s]: %(message)s')
    else:
        myFormatter = logging.Formatter('%(name)s: %(message)s')
    myHandler.setFormatter(myFormatter)
    myLogger.addHandler(myHandler)
    while 1:
        line = stdin.readline()
        if not line:
            break
        # if opts.stderr:
        #     print(line, file=stderr)
        myLogger.log(level, line)

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\nReceived KeyboardInterrupt. Exiting.")
        exit()
