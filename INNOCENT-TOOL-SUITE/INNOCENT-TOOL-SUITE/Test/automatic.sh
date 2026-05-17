#!/bin/bash
#set -x

#echo 'Verifying that every tools is present'
#COLOR
GREEN='\033[0;32m'
WHITE='\033[1;37m'
RED='\033[0;31m'
ORANGE='\033[0;33m'


#VARIABLES
today=$(date +"%d-%m-%Y")
yesterday=$(date -d "yesterday" +"%d-%m-%Y")
domain=$1
tool_list=("subfinder" "nuclei" "httpx" "gobelly" "anew" "amass" "paramspider" "notify")

directory="./loots/$domain"
subdomain_file=$directory/$domain-$today.subs.txt
subdomain_file_yesterday=$directory/$domain-$yesterday.subs.txt
subdomain_temp=$directory/$domain.$today.subs.temp
httpx_file=$directory/$domain.$today.httpx
httpx_file_forb=$directory/$domain.$today.httpx.forb
httpx_file_forb_yesterday=$directory/$domain.$yesterday.httpx.forb
httpx_file_forb_BYPASSED=$directory/$domain.$today.httpx.BYPASSED
wayback_file=$directory/$domain.$today.wayback
paramspider_directory=$directory/param/$domain.$today.param
ip_dir=$directory/ips
ips_directory=$directory/ips/$domain.$today.ips
ips_directory_yesterday=$directory/ips/$domain.$yesterday.ips
parameter_file=$directory/ips/$domain.$today.param.txt
port_dir_today=$directory/ips/$domain.$today.ports.txt
nuclei_dir=$directory/ips/$domain.$today.nuclei.txt

tool_valid () {
    for tool in "${tool_list[@]}";do
        if [ $(which $tool) != "not found" ]; then   
            echo -e $GREEN[OK] $tool found  $WHITE 

        else
            echo -e $RED[!] $tool not found  $WHITE
            
            echo Please install it and then launch the script again
            exit 
        fi
    done 2>/dev/null
}

dir_validation() {
    if [ -e $directory ]; then
        :
    else
        echo -e Creating loot folder in $(pwd)
        mkdir $directory
    fi

    if [ -e $ip_dir ]; then
        :
    else
        echo -e Creating ips folder in $(pwd)
        mkdir $ip_dir
    fi
}


echo -e Starting recon on: $domain


subdomain () {
  echo -e $GREEN [!] Enumerating subdomains + httpx..
  subfinder -d $domain -all -silent | httpx -silent -fc 404,503 >> $subdomain_file
  if [ -f "$subdomain_file_yesterday" ];then
        sub_difference=$(diff $subdomain_file $subdomain_file_yesterday )
        if [ -n "$sub_difference" ];then 
            notify-send "$sub_difference"   #Change with projectdiscovery notify
            echo $sub_difference
            echo -e $GREEN '[!] Running HTTPX again for forbidden pages (For 401/403 bypass)'
            cat $sub_difference | httpx -mc 403,401 -silent | anew $httpx_file_forb
        fi
  else
            notify-send "$subdomain_file" 
            cat $subdomain_file
            echo -e $GREEN '[!] Running HTTPX again for forbidden pages (For 401/403 bypass)'
            cat $subdomain_file | httpx -mc 403,401 -silent | anew $httpx_file_forb
        
  fi



 
  echo -e $ORANGE All valid subdomains were saved in  $(pwd)$subdomain_file
  echo -e $ORANGE All unauthorized subdomains were saved in $(pwd)$httpx_file_forb
}


get_ips () {
    echo 'Getting every node..'
    for ip in $(cat $subdomain_file | sed -r 's\https://\\g');do
        host $ip | grep "has address" | awk '{print $4}' | anew "$ips_directory"
        echo Grabbed ip for : $ip | sed -r 's|https\?://||g'
    done
        
        if [ -f "$ips_directory_yesterday" ];then 
            ip_difference=$(diff "$ips_directory_yesterday"  "$ips_directory" )
            notify-send "$ip_difference"   #Change with projectdiscovery notify
            echo $ip_difference
        else
            #notify-send $ips_directory (ADD NOTIFY)
            echo found: $(cat $ips_directory)
        fi
}

port_scan() {
    if [ -f "$ips_directory_yesterday" ];then
        ip_difference=$(diff "$ips_directory_yesterday" "$ips_directory" )
        if [ -n $ip_difference ];then
            echo 'Starting port scan over new ips..'
        sudo masscan -iL $(cat $ip_difference) --ports 80,443 --rate 1000 -oL "$port_dir_today"
        fi
    else
        echo 'Starting port scan over all ips..'
        sudo masscan -v -iL $ips_directory --ports 80,443 --rate 1000 -oL "$port_dir_today"
        
    fi
}

common_nuclei() {
    if [ -f "$ips_directory_yesterday" ];then
        ip_difference=$(diff "$ips_directory_yesterday" "$ips_directory" )
        if [ -n $ip_difference ];then
            echo -e $GREEN 'Starting nuclei scan over new ips..'
        nuclei -l $ip_difference  -tags cve,exposure,panel -silent -es low,info  -rl 60 -nmhe -o $nuclei_dir | Notify "CONFIGURE NOTIFY PROJECT"
        fi
    else
        echo -e $GREEN 'Starting nuclei scan over all ips..'
        nuclei -l $ips_directory  -tags cve,exposure,panel -silent -es low,info -rl 60 -nmhe -o $nuclei_dir | Notify "CONFIGURE NOTIFY PROJECT"
        
    fi
}


wayback_assets () {
    echo 'Finding cached domains..'
    cat $subdomain_file | waybackurls | anew $wayback_file 
}

param_finder () {
    paramspider -L $subdomain_file -o $paramspider_directory
}

vuln_analysis () {
    param=./
}



401_fuzzer() {
    if [ -f "$httpx_file_forb_yesterday" ];then
        auth_difference=$(diff $httpx_file_forb_BYPASSED $httpx_file_forb_yesterday )
        echo Starting 401/403 bypass on new domains..
        for i in $(cat $auth_difference);do
            python3 ./assets/authslicer.py -u $i --nw >> $httpx_file_forb_BYPASSED
            results=$(cat $httpx_file_forb_BYPASSED | grep "with") 
            if [ -f "$results" ]; then
                echo $results | grep "with"
                
            else
                echo -e $RED "no results"
            fi
        done
    else
        echo "Starting new scan on domain"
        for i in $(cat $httpx_file_forb);do
            python3 ./assets/authslicer.py -u $i --nw >> $httpx_file_forb_BYPASSED
            results=$(cat $httpx_file_forb_BYPASSED | grep -i "with" ) 
            if echo $results | grep "with"; then
                echo Bypass found for $results | grep with
            else
                echo -e $RED "no results"
            fi
        done
    fi
}


if [ -z "$1" ];then
    echo 'Usage: ./automatic.sh domain.com'
else
    tool_valid
    dir_validation
    subdomain
    get_ips   
    ommon_nuclei
    port_scan
    
    wayback_assets
    401_fuzzer
    #vuln_analysis
fi

#Gowitness
#Prendere da api hackerone domain in scope
#Open Redirect 
#Notify (nuclei)
#Gobelly
#Js files

#Aprire molteplici terminali con gnome-terminal -- bash -c "funzione1; exec bash"
#Validazio gnome-terminal o konsole ( o shell in uso )

#Oppure con xterm -e "bash -c 'funzione1; exec bash'" &
#subfinder -d intigriti.com | httpx | nuclei -tags exposure -o output.txt; notify -bulk -data output.txt
