#!/bin/bash

if [ ! -f "`which mkisofs`" ]; then
    echo 'You must install mkisofs'
    exit 1
fi

dd if=/dev/zero of=/tmp/boot.img bs=512 count=4194304

