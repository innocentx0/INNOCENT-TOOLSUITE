#!/bin/bash

# subfinder
# scraping
# censys (OSINT font)
# massdns


echo '''
 ██████╗ ███████╗████████╗███████╗██╗   ██╗██████╗ 
██╔════╝ ██╔════╝╚══██╔══╝██╔════╝██║   ██║██╔══██╗
██║  ███╗█████╗     ██║   ███████╗██║   ██║██████╔╝
██║   ██║██╔══╝     ██║   ╚════██║██║   ██║██╔══██╗
╚██████╔╝███████╗   ██║   ███████║╚██████╔╝██████╔╝
 ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝ ╚═════╝ ╚═════╝ 
                               A tool by INNOCENTx0
'''

domains=$1
lootFolder=../Ghostsub/

RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[0;37m'
ORANGE='\033[0;33m'
BRED='\033[1;31m'
BGREEN='\033[1;32m'
BWHITE='\033[1;37m'


dirValidation(){
    if [ -d "$lootFolder" ];then
        echo -e $BGREEN 'Dir already exists! starting with recon ☆(❁‿❁)☆'
    else
        echo 'creating dir.. ✿◕ ‿ ◕✿'
        mkdir -p "$lootFolder"
    fi
}
recon(){
    mkfifo /tmp/pipe2_$$
    exec 4<>/tmp/pipe2_$$
    rm /tmp/pipe2_$$
    for((i=0;i<50;i++)); do echo >&4; done

    
    while IFS= read -r DOMAIN || [[ -n "$DOMAIN" ]]; do
    read -u 4 x 
    (
        echo "[!] Starting recon.. on $DOMAIN + httpx"
        subfinder -d "$DOMAIN" -all --silent | httpx -silent >>"$lootFolder/sublist.txt"
        ) &
    done < "$domains"
}
scrape_sub(){
    base=$(head -1 "$lootFolder/sublist.txt" | sed 's|https\?://||' | rev | cut -d'.' -f1,2 | rev)
    gospider -S "$lootFolder/sublist.txt" -d 2 --js -t 50 -c 50  --timeout 10  | grep -oP '([a-zA-Z0-9_-]+\.)+'"$base" | sed 's|^|https://|' | anew "$lootFolder/sublist.txt"
    echo "Results in $lootFolder/sublist.txt"
}
if [ -z $1 ];then
    echo -e $RED [!] Usage: ./getsub.sh domain.txt
else
    if [ -f "$domains" ]; then
        dirValidation
        echo -e $BWHITE [OK] Starting recon..
        recon
        echo -e $BWHITE [OK] Scraping..
    
        scrape_sub
    else
        echo "Make sure the file $1 exists 	(╥﹏╥) "
    fi
fi

