#!/bin/bash


echo '''
 ██████╗ ██╗  ██╗ ██████╗ ███████╗████████╗███████╗██╗   ██╗██████╗
██╔════╝ ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝██╔════╝██║   ██║██╔══██╗
██║  ███╗███████║██║   ██║███████╗   ██║   ███████╗██║   ██║██████╔╝
██║   ██║██╔══██║██║   ██║╚════██║   ██║   ╚════██║██║   ██║██╔══██╗
╚██████╔╝██║  ██║╚██████╔╝███████║   ██║   ███████║╚██████╔╝██████╔╝
 ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝ ╚═════╝ ╚═════╝
                                              A tool by INNOCENTx0
'''

today=$(date '+%Y-%m-%d')
yesterday=$(date -d "yesterday" '+%Y-%m-%d')
dir='./loots'
today_results=$dir/$today'.vuln.results'
yesterday_results=$dir/$yesterday'.vuln.results'

cnameDirTod=$dir/$today'.cname'
cnameDirYes=$dir/$yesterday'.cname'

cnameFindingYes=$dir/$yesterday'.cname.results'
cnameFindingTod=$dir/$today'.cname.results'

list='./sublist.txt'


set -a
source ../../.env
set +a


fin_list=(
    "The specified bucket does not exist"
    "Sorry, this page is no longer available."
    "NXDOMAIN"
    "Ошибка 402. Сервис Айри.рф не оплачен"
    "The page you were looking for does not exist."
    "Repository not found"
    "404 Blog is not found"
    "We could not find what you're looking for."
    "No settings were found for this company:"
    "HTTP_STATUS=301"
    "This job board website is either expired or its domain name is invalid."
    "PAGE NOT FOUND."
    "project not found"
    "Account not found."
    "The URL you've accessed does not provide a hub."
    "Do you want to register .*.wordpress.com?"
    "Hello! Sorry, but the website you&rsquo;re looking for doesn&rsquo;t exist."
    "There isn't a GitHub Pages site here."
    "404 - Page Not Found Oops… looks like you got lost"
    "Uh oh. That page doesn't exist."
    "It looks like you’re lost..."
    "Unrecognized domain"
    "Not Found - Request ID:"
    "Sorry, this shop is currently unavailable."
    "Domain is not configured"
    "Please renew your subscription"
    "Whatever you were looking for doesn't currently exist at this address"
    "DEPLOYMENT_NOT_FOUND."
    "The page you are looking for doesn't exist or has been moved."
    "Looks Like This Domain Isn't Connected To A Website Yet!"
    "Trying to access your account?"
    "Company Not Found"
    "There is no such company. Did you enter the right URL?"
    "Domain uses DO name servers with no records in DO."
    "404: This page could not be found."
    "With GetResponse Landing Pages, lead generation has never been easier"
    "Site unavailable"
    "Failed to resolve DNS path for this host"
    "HTTP_STATUS=500"
    "is not a registered InCloud YouTrack"
    "Tunnel .*.ngrok.io not found"
    "404 error unknown site!"
    "Sorry, couldn't find the status page"
    "The creators of this project are still working on making everything perfect!"
    "The link you have followed or the URL that you entered does not exist."
    "Link does not exist"
    "page not found"
)



RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[0;37m'
ORANGE='\033[0;33m'
BRED='\033[1;31m'
BGREEN='\033[1;32m'
BWHITE='\033[1;37m'


dir_scan(){
    if [ -d $dir ];then
        echo -e $BGREEN '   [OK] directory already exists ≧◡≦'
    else
        echo -e $BGREEN '    [OK] creating dir for today ◎[▪‿▪]◎'
        mkdir -p $dir
    fi
}

fingerprint(){
    mkfifo /tmp/pipe_$$
    exec 3<>/tmp/pipe_$$
    rm /tmp/pipe_$$
    for((i=0;i<50;i++)); do echo >&3; done
    
    while read -r DOMAIN;do
        read -u 3 x
        (
            echo -e $GREEN "   [YAY] SENDIN REQUESTS to $DOMAIN" 
            content=$(curl -X GET "$DOMAIN" -k -s --connect-timeout 5 --max-time 10 -L)
            for fin in "${fin_list[@]}";do
                if [[ "$content" == *"$fin"* ]];then
                    echo -e $ORANGE "   [!] Vulnerable subdomain found! = $DOMAIN" | gobelly
                    echo "vulnerable subdomain = $DOMAIN" | anew $today_results
                fi
            done
            echo >&3
        ) &
    done < $list
    wait
}

vuln_detection(){
    if [ -e $yesterday_results ];then
        echo -e $BGREEN '   [OK] Reading scan from yesterday v( ‘.’ )v'
        difference=$(diff  $today_results  $yesterday_results | grep '>')
        if [ -n "$difference" ];then
            echo -e $ORANGE '   [!] New findings found'
            while read -r vuln;do
                echo -e $BGREEN "   [OK] NEW FINDING: "$vuln"   "
                echo $vuln | notify -pc ./provider-config.yaml -bulk -silent 
            done <<< "$difference"
        else
            echo "    [!] No new vulnerable domains found o(╥﹏╥)o"
        fi
    else
        if [ -e $today_results ];then
            echo -e $BGREEN '[OK] This is the first scan! Congrats'
            while read -r VULNODM;
                do echo -e $ORANGE"    [!] New finding: $VULNODM "
                echo I found a new vuln domain for you! $VULNODM  | notify -pc ./provider-config.yaml -bulk -silent
            done < $today_results
        else
            echo "    [!] No results for today!"
        fi
    fi

}

detectCNAME(){
    while read -r subdomain; do
        (
            host=$(echo "$subdomain" \
                | sed -E 's#https?://##' \
                | cut -d/ -f1)  
            echo $host
            cname=$(dig CNAME +short "$host" | sed 's/\.$//' )
            [ -n "$cname" ] && echo "$host --> $cname" | anew  $cnameDirTod
        ) &
    done < "$list"
    wait
}

fingerprintCname(){
    if [ -e $cnameDirTod ];then
        mkfifo /tmp/pipe2_$$
        exec 4<>/tmp/pipe2_$$
        rm /tmp/pipe2_$$
        for((i=0;i<50;i++)); do echo >&4; done

        while IFS= read -r line; do
            subdomain=$(echo "$line" | awk -F' --> ' '{print $1}')
            cname=$(echo "$line" | awk -F' --> ' '{print $2}')
            read -u 4 x
            (
                content=$(curl -X GET "$cname" -k -s --connect-timeout 5 --max-time 10 -L) 
                for fin in "${fin_list[@]}"; do
                    if [[ "$content" == *"$fin"* ]];then
                        echo "vulnerable CNAME = $subdomain --> $cname" | anew $cnameFindingTod
                    fi
                done
                echo >&4
            ) &
        done < "$cnameDirTod"
        wait
    else
        echo -e $GREEN "    [!] No CNAME records found for today!"
    fi
}

cnameCompCheck(){
    if [ -e $cnameFindingYes ];then
        echo -e $GREEN 'Reading scan from yesterday..'
        difference=$(diff $cnameFindingTod $cnameFindingYes  | grep '>')
            if [ -n "$difference" ];then
                echo -e $ORANGE '   [!] Vulnerable cname found'

                while read -r vuln;do
                    #echo -e $BGREEN "   [OK] NEW FINDING (CNAME): "$vuln"   "
                    echo I found a vulnerable CNAME for you! $vuln | notify -pc ./provider-config.yaml -bulk -silent
                done <<< "$difference"
            else
                echo "    [!] No new vulnerable domains found o(╥﹏╥)o"
            fi
    else 
        if [ -e $cnameFindingTod ];then
            echo -e $BGREEN '[OK] first cname scan!' $ORANGE 
            while read -r VULNODM;
                do 
                echo I found a NEW CNAME vulnerable for you! $VULNODM  | notify -pc ./provider-config.yaml -bulk -silent
            done < $cnameFindingTod 
        else
            echo "    [!] No vulnerable CNAMES found on first time o(╥﹏╥)o"
        fi
    fi

}




# if [ -e $list ];then
#     echo -e $BWHITE "[1/4] Directory check.."
    # dir_scan
    # echo -e $BWHITE "[2/4] Finger print analysis.."
    # echo -e $BGREEN "   [OK] Reading list (づ｡◕‿‿◕｡)づ"
    # fingerprint
    # wait
    # echo -e $BWHITE "[3/4] Detecting vulnerable domains.."
    vuln_detection
   # echo -e $BWIITE "[4/4] Resolving CNAMES and detecting misconfigurations"
    #detectCNAME
    wait
    #fingerprintCname
    wait
   # cnameCompCheck
# else
#     echo "make sure to place a file called $list"
# fi
