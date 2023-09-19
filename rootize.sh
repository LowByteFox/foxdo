#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

chown root:root ./zig-out/bin/foxdo
chmod ugo= ./zig-out/bin/foxdo
chmod +s ./zig-out/bin/foxdo
chmod u+rwx,g=rx,o=rx ./zig-out/bin/foxdo
