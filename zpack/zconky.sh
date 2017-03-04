#!/bin/bash

#jba/zf120522.1803

RET=1
while [[ $RET -ne 0 ]]; do
    RET=$(pgrep xfdesktop > /dev/null; echo $?)
    if [[ $RET -eq 0 ]]; then
        sleep 5
        conky &
    fi
done
