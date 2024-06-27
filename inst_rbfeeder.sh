#!/bin/sh
#

RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
LGREEN='\033[1;32m'
BOLD='\033[1m'
RESET_BOLD='\033[2m'


if [ "$(id -u)" != "0" ]; then
	echo -e "You must run this script with root privileges" 1>&2
	exit 1
fi

VERS=`lsb_release -c | awk -F ':' '{print $2}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`


# Install packages needed by script
apt-get update -y
apt-get install dirmngr -y

# Import our key to apt-key
#apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 1D043681
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 1D043681

# Move old source
/bin/rm -f /etc/apt/sources.list.d/rb24.list

# Create a new debian repository source file
case "$VERS" in

     buster)
        echo 'deb https://apt.rb24.com/ buster main' > /etc/apt/sources.list.d/rb24.list
        ;;

     bullseye)
        echo 'deb https://apt.rb24.com/ bullseye main' > /etc/apt/sources.list.d/rb24.list
        ;;

     bookworm)
        echo 'deb https://apt.rb24.com/ bookworm main' > /etc/apt/sources.list.d/rb24.list
        ;;




     *)
        echo "Don't know how to install for a distribution named $DIST" >&2
        exit 1
esac



# Update apt and install software
apt-get update -y
apt-get install rbfeeder -y




echo -e "\033c"

echo -e ""
echo -e "${RED}!!!! ${BOLD}IMPORTANT${RESET_BOLD} !!!!${NC}"
echo -e ""
echo -e "${WHITE}By default, RBFeeder is configured to connect to your local dump1090 instance (localhost,"
echo -e "port 30005). If you want to use a USB RTL-SDR dongle instead, please run this command:"
echo -e ""
echo -e "${LGREEN}sudo rbfeeder --set-network-mode off --no-start${WHITE}"
echo -e ""
echo -e "Then, restart the daemon:"
echo -e ""
echo -e "${LGREEN}sudo systemctl restart rbfeeder${WHITE}"
echo -e ""
echo -e "After a few seconds, RBFeeder will connect to the AirNav servers and you can view your"
echo -e "sharing-key with this command:"
echo -e ""
echo -e "${LGREEN}sudo rbfeeder --showkey${WHITE}"
echo -e ""
echo -e "If you already have a sharing-key from previous a installation, you can set the same"
echo -e "key using this command:"
echo -e ""
echo -e "${LGREEN}sudo rbfeeder --setkey ‹your sharing key›${WHITE}"
echo -e ""
echo -e ""
echo -e "Installation finished."
echo -e ""
echo -e "${NC}"


