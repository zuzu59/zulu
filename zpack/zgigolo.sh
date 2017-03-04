#!/bin/bash

#jba/zf120611.1158

RET=1
while [[ $RET -ne 0 ]]; do
    IP=$(ip route list scope global | awk '{print $3}')
    RET=$(ping -c 3 $IP > /dev/null; echo $?)
    if [[ $RET -eq 0 ]]; then
        sleep 4
        gigolo &
    fi
    sleep 4
done
