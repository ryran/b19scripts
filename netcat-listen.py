#!/usr/bin/python
# -*- coding: utf-8 -*-
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

from __future__ import print_function
from sys import stdout, stderr, argv
import socket

def netcat_listen(localAddr, localPort):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((localAddr, localPort))
    s.listen(1)
    print("INFO: Listening on {}:{}/tcp for one connection ...".format(localAddr, localPort), file=stderr)
    connection, address = s.accept()
    print("INFO: Incoming connection from {}:{}/tcp established!\nINFO: Reading data ...".format(*address), file=stderr)
    while True:
        data = connection.recv(65536)
        if len(data):
            stdout.write(data)
        else:
            break
    print("INFO: Done. Connection closed.", file=stderr)
    s.close()

def main():
    if len(argv) != 3:
        print("Usage: {} <ListenAddress> <ListenTcpPort>".format(argv[0]))
        print("Binds to ListenAddress:ListenTcpPort and waits for 1 connection")
        print("When connection is made, all data (binary or otherwise) is written to stdout")
        print("INFO messages go to stderr; use shell stdout redirection to save to file")
        exit()
    else:
        netcat_listen(argv[1], int(argv[2]))

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print()
        exit()
