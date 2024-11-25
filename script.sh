#!/bin/bash

cat /etc/hosts | while read ip dom
do
        if [ "ip" = "#" ];then
                break
        fi
        if [[ "$dom" = "localhost" || "$dom" = "`hostname`" ]];then
                continue
        fi

        ipCorect=`dig +short "$dom" @"8.8.8.8" | tail -n 1`

        if [[ "$ip" != "$ipCorect" ]];then
                echo "Bogus IP for $dom in /etc/hosts"
        fi
done

exit 0

