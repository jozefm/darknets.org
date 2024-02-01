#!/bin/bash


ETC_HOSTS=/etc/hosts

#########################
# Darkweb.sh            #
#########################
display_help() {
    echo "DarkNet.org Lab Management Script (Docker based)"
    echo
    echo "Usage: $0 {list|status|info|start|stop} [projectname]" >&2
    echo
    echo "  This script uses docker and hosts alias to make web apps available on localhost"
    echo "  make sure you setup all ports/ip's"
    echo "  Dockerfiles from:      - Respective Distro Source"
    echo "  DVWA                   - Ryan Dewhurst (vulnerables/web-dvwa)"
    echo "  MutillidaeII           - OWASP Project (citizenstig/nowasp)"
    echo "  bWapp                  - BWapp project (raesene/bwapp)"
    echo "  Webgoat(s)             - OWASP Prject (webgoat/webgoat-7)"
    echo "  Juice Shop             - OWASP Project (bkimminich/juice-shop)"

    exit 1
}


############################################
# Check if docker is installed and running #
############################################
if ! [ -x "$(command -v docker)" ]; then
  echo
  echo "Docker was not found. Please install docker before running this script."
  echo "On debian systems sudo apt install docker.io"
  echo "You can try the script: install_evil_kali_x64.sh"
  exit
fi

if sudo service docker status | grep inactive > /dev/null
then
	echo "Docker is not running."
	echo -n "Do you want to start docker now (y/n)?"
	read answer
	if echo "$answer" | grep -iq "^y"; then
		sudo service docker start
	else
		echo "Not starting. Script will not be able to run applications."
	fi
fi

##############################
# List Darknets.org Lab apps #
##############################
list() {
    echo "Available pentest applications" >&2
    echo "  bwapp 		- bWAPP PHP/MySQL"
    echo "  webgoat7		- OWASP WebGoat 7.1"
    echo "  webgoat8		- OWASP WebGoat 8.0"
    echo "  dvwa     		- Damn Vulnerable Web Application"
    echo "  mutillidae		- OWASP Mutillidae II"
    echo "  juiceshop		- OWASP Juice Shop"
    echo
    exit 1

}

#########################
# Info dispatch         #
#########################
info () {
  case "$1" in
    bwapp)
      project_info_bwapp
      ;;
    webgoat7)
      project_info_webgoat7
      ;;
    webgoat8)
      project_info_webgoat8
      ;;
    dvwa)
      project_info_dvwa
      ;;
    mutillidae)
      project_info_mutillidae
    ;;
    juiceshop)
      project_info_juiceshop
    ;;
    *)
      echo "Unknown project name"
      list
      ;;
  esac
}



#########################
# hosts file Management #
#########################
function removehost() {
    if [ -n "$(grep $1 /etc/hosts)" ]
    then
        echo "Removing $1 from $ETC_HOSTS";
        sudo sed -i".bak" "/$1/d" $ETC_HOSTS
    else
        echo "$1 was not found in your $ETC_HOSTS";
    fi
}

function addhost() { # ex.   127.5.0.1	bwapp
    HOSTS_LINE="$1\t$2"
    if [ -n "$(grep $2 /etc/hosts)" ]
        then
            echo "$2 already exists in /etc/hosts"
        else
            echo "Adding $2 to your $ETC_HOSTS";
            sudo -- sh -c -e "echo '$HOSTS_LINE' >> /etc/hosts";

            if [ -n "$(grep $2 /etc/hosts)" ]
                then
                    echo -e "$HOSTS_LINE was added succesfully to /etc/hosts";
                else
                    echo "Failed to Add $2, Try again!";
            fi
    fi
}


##########################
# PROJECT INFO & STARTUP #
##########################
project_info_bwapp ()
{
echo "repo pull"
}

project_startinfo_bwapp ()
{
  echo "Remember to run install.php before using bwapp the first time."
  echo "at http://bwapp/install.php"
  echo "Default username/password:  bee/bug"
  echo "bWAPP will then be available at http://bwapp"
}

project_info_webgoat7 ()
{
echo "https://www.owasp.org/index.php/Category:OWASP_WebGoat_Project"
}

project_startinfo_webgoat7 ()
{
  echo "WebGoat 7.1 now available at http://webgoat7/WebGoat"
}

project_info_webgoat8 ()
{
echo "  https://www.owasp.org/index.php/Category:OWASP_WebGoat_Project"
}

project_startinfo_webgoat8 ()
{
  echo "WebGoat 8.0 now available at http://webgoat8/WebGoat"
}

project_info_dvwa ()
{
echo "dvwa"
}

project_startinfo_dvwa ()
{
  echo "Damn Vulnerable Web Application now available at http://dvwa"
  echo "Default username/password:   admin/password"
  echo "docker run --name dvna-mysql --env-file vars.env -d mysql:5.7"
  echo "Remember to click on the CREATE DATABASE Button before you start"
}

project_info_mutillidae ()
{
echo "https://www.owasp.org/index.php/OWASP_Mutillidae_2_Project"
}

project_startinfo_mutillidae ()
{
  echo "OWASP Mutillidae II now available at http://mutillidae"
  echo "Remember to click on the create database link before you start"
}

project_info_juiceshop ()
{
echo "https://owasp-juice.shop"
}

project_startinfo_juiceshop ()
{
  echo "OWASP Juice Shop now available at http://juiceshop"
}

#########################
# Common start          #
#########################
project_start ()
{
  fullname=$1		# ex. WebGoat 7.1
  projectname=$2     	# ex. webgoat7
  dockername=$3  	# ex. bwapp
  ip=$4   		# ex. 127.5.0.1
  port=$5		# ex. 80
  port2=$6		# optional second port binding

  echo "Starting $fullname"
  addhost "$ip" "$projectname"


  if [ "$(sudo docker ps -aq -f name=$projectname)" ];
  then
    echo "Running command: docker start $projectname"
    sudo docker start $projectname
  else
    if [ -n "${6+set}" ]; then
      echo "Running command: docker run --name $projectname -d -p $ip:80:$port -p $ip:$port2:$port2 $dockername"
      sudo docker run --name $projectname -d -p $ip:80:$port -p $ip:$port2:$port2 $dockername
    else echo "not set";
      echo "Running command: docker run --name $projectname -d -p $ip:80:$port $dockername"
      sudo docker run --name $projectname -d -p $ip:80:$port $dockername
    fi
  fi
  echo "DONE!"
  echo
  echo "Docker mapped to http://$projectname or http://$ip"
  echo
}


#########################
# Common stop           #
#########################
project_stop ()
{
  fullname=$1	# ex. WebGoat 7.1
  projectname=$2     # ex. webgoat7

  echo "Stopping... $fullname"
  echo "Running command: docker stop $projectname"
  sudo docker stop $projectname
  removehost "$projectname"
}

project_status()
{
  if [ "$(sudo docker ps -q -f name=bwapp)" ]; then
    echo "bWaPP				running at http://bwapp"
  else
    echo "bWaPP				not running"
  fi
  if [ "$(sudo docker ps -q -f name=webgoat7)" ]; then
    echo "WebGoat 7.1			running at http://webgoat7/WebGoat"
  else
    echo "WebGoat 7.1			not running"
  fi
  if [ "$(sudo docker ps -q -f name=webgoat8)" ]; then
    echo "WebGoat 8.0			running at http://webgoat8/WebGoat"
  else
    echo "WebGoat 8.0			not running"
  fi
  if [ "$(sudo docker ps -q -f name=dvwa)" ]; then
    echo "DVWA				running at http://dvwa"
  else
    echo "DVWA				not running"
  fi
  if [ "$(sudo docker ps -q -f name=mutillidae)" ]; then
    echo "Mutillidae II			running at http://mutillidae"
  else
    echo "Mutillidae II			not running"
  fi
  if [ "$(sudo docker ps -q -f name=juiceshop)" ]; then
    echo "OWASP Juice Shop 		running at http://juiceshop"
  else
    echo "OWASP Juice Shop 		not running"
  fi
}


project_start_dispatch()
{
  case "$1" in
    bwapp)
      project_start "bWAPP" "bwapp" "raesene/bwapp" "127.5.0.1" "80"
      project_startinfo_bwapp
    ;;
    webgoat7)
      project_start "WebGoat 7.1" "webgoat7" "webgoat/webgoat-7.1" "127.6.0.1" "8080"
      project_startinfo_webgoat7
    ;;
    webgoat8)
      project_start "WebGoat 8.0" "webgoat8" "webgoat/webgoat-8.0" "127.7.0.1" "8080"
      project_startinfo_webgoat8
    ;;
    dvwa)
      project_start "Damn Vulnerable Web Appliaction" "dvwa" "vulnerables/web-dvwa" "127.8.0.1" "80"
      project_startinfo_dvwa
    ;;
    mutillidae)
      project_start "Mutillidae II" "mutillidae" "citizenstig/nowasp" "127.9.0.1" "80"
      project_startinfo_mutillidae
    ;;
    juiceshop)
      project_start "OWASP Juice Shop" "juiceshop" "bkimminich/juice-shop" "127.10.0.1" "3000"
      project_startinfo_juiceshop
    ;;
    *)
    echo "ERROR: Project dispatch doesn't recognize the project name"
    ;;
  esac
}

project_stop_dispatch()
{
  case "$1" in
    bwapp)
      project_stop "bWAPP" "bwapp"
    ;;
    webgoat7)
      project_stop "WebGoat 7.1" "webgoat7"
    ;;
    webgoat8)
      project_stop "WebGoat 8.0" "webgoat8"
    ;;
    dvwa)
      project_stop "Damn Vulnerable Web Appliaction" "dvwa"
    ;;
    mutillidae)
      project_stop "Mutillidae II" "mutillidae"
    ;;
    juiceshop)
      project_stop "OWASP Juice Shop" "juiceshop"
    ;;
    *)
    echo "ERROR: Project dispatch doesn't recognize the project name"
    ;;
  esac
}


#########################
# Main switch case      #
#########################
case "$1" in
  start)
    if [ -z "$2" ]
    then
      echo "ERROR: Option start needs project name in lowercase"
      echo
      list # call list ()
      break
    fi
    project_start_dispatch $2
    ;;
  stop)
    if [ -z "$2" ]
    then
      echo "ERROR: Option stop needs project name in lowercase"
      echo
      list # call list ()
      break
    fi
    project_stop_dispatch $2
    ;;
  list)
    list # call list ()
    ;;
  status)
    project_status # call project_status ()
    ;;
  info)
    if [ -z "$2" ]
    then
      echo "ERROR: Option info needs project name in lowercase"
      echo
      list # call list ()
      break
    fi
    info $2
    ;;
  *)
    display_help
;;
esac
