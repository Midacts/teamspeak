#!/bin/bash
# Teamspeak Server Setup Script
# Date: 10th of July, 2014
# Version 1.0
#
# Author: John McCarthy
# Email: midactsmystery@gmail.com
# <http://www.midactstech.blogspot.com> <https://www.github.com/Midacts>
#
# To God only wise, be glory through Jesus Christ forever. Amen.
# Romans 16:27, I Corinthians 15:1-4
#---------------------------------------------------------------
######## VARIABLES ########
ver=3.0.10.3
prefix=/home/teamspeak
######## FUNCTIONS ########
function configure_iptables(){
	# Creates the /etc/iptables.rules file
		echo
		echo -e '\e[01;34m+++ Creating the iptables.rules file...\e[0m'
		cat << EOB > /etc/iptables.rules
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -d 127.0.0.0/8 ! -i lo -j REJECT --reject-with icmp-port-unreachable
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -p udp --dport 9987 -j ACCEPT
-A INPUT -p udp --sport 9987 -j ACCEPT
-A INPUT -p tcp --dport 30033 -j ACCEPT
-A INPUT -p tcp --sport 30033 -j ACCEPT
-A INPUT -p tcp --dport 10011 -j ACCEPT
-A INPUT -p tcp --sport 10011 -j ACCEPT
-A INPUT -p icmp --icmp-type 8 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-port-unreachable
-A FORWARD -j REJECT --reject-with icmp-port-unreachable
-A OUTPUT -j ACCEPT
COMMIT
EOB
		echo -e '\e[01;37;42mThe iptables.rules file has been successfully created!\e[0m'

	# Enables the iptables' rules to start when the network service starts
		echo "        pre-up iptables-restore < /etc/iptables.rules" >> /etc/network/interfaces

	# Restarts the networking service
		echo
		echo -e '\e[01;34m+++ Restarting the networking service...\e[0m'
		service networking restart
		echo -e '\e[01;37;42mThe networking service has been successfully restarted!\e[0m'
}
function install_teamspeak(){
	# Creates the teamspeak user and group
		echo
		echo -e '\e[01;34m+++ Creating the teamspeak user and group...\e[0m'
		groupadd teamspeak
		useradd -g teamspeak teamspeak -s /sbin/nologin
		echo -e '\e[01;37;42mThe teamspeak user and group has been successfully created!\e[0m'

	# Downloads the latest version of Teamspeak 3 server
		echo
		echo -e '\e[01;34m+++ Downloading the latest Teamspeak installation media...\e[0m'
		wget http://dl.4players.de/ts/releases/3.0.10.3/teamspeak3-server_linux-amd64-$ver.tar.gz
		echo -e '\e[01;37;42mThe latest Teamspeak server installation media has been successfully downloaded!\e[0m'

	# Creates the teamspeak directory
		mkdir $prefix

	# Untars the teamspeak installation files
		tar xzf teamspeak3-server_linux-amd64-$ver.tar.gz -C $prefix --strip-components=1

	# Changes to the teamspeak installation files directory
		cd $prefix

	# Starts the teamspeak server (generates the ServerAdmin token)
	# To change the ServerAdmin's password run: ./ts3server_startscript.sh start serveradmin_password="$pass"
		./ts3server_startscript.sh start
		sleep 4

	# Stores the ServerAdmin's token in a variable
		get=$(grep -R "token=" /home/teamspeak/logs/)
		token=$(echo "${get##*=}")

	# Enables the teamspeak server to start on reboot
		echo
		echo -e '\e[01;34m+++ Creating the teamspeak cronjob and init file...\e[0m'
		ln -s $prefix/ts3server_startscript.sh /etc/init.d/teamspeak
		echo "@reboot /etc/init.d/teamspeak start" >> /var/spool/cron/crontabs/teamspeak
		chmod 600 /var/spool/cron/crontabs/teamspeak
		echo -e '\e[01;37;42mThe teamspeak cronjob and init file have been successfully created!\e[0m'

	# Sets folder and file permissions
		echo
		echo -e '\e[01;34m+++ Setting permissions...\e[0m'
		chown -R teamspeak:teamspeak $prefix
		chown -R teamspeak:teamspeak /etc/init.d/teamspeak
		echo -e '\e[01;37;42mThe permissions have been successfully set!\e[0m'
}
function doAll(){
	# Calls Function 'configure_iptables'
		echo
		echo
		echo -e "\e[33m=== Configure Iptables ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			configure_iptables
		fi

	# Calls Function 'install_teamspeak'
		echo
		echo -e "\e[33m=== Install Teamspeak ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			install_teamspeak
		fi

	# End of Script Congratulations, Farewell and Additional Information
		clear
		farewell=$(cat << EOZ


          \e[01;37;42mWell done! You have successfully setup your Teamspeak server! \e[0m

                       \e[01;33mHere is your ServerAdmin token:\e[0m
                   \e[01;39m$token\e[0m

    \e[0;31mRECOMMENDED: Reboot to ensure the server is running as the teamspeak user\e[0m

  \e[30;01mCheckout similar material at midactstech.blogspot.com and github.com/Midacts\e[0m

                            \e[01;37m########################\e[0m
                            \e[01;37m#\e[0m \e[31mI Corinthians 15:1-4\e[0m \e[01;37m#\e[0m
                            \e[01;37m########################\e[0m
EOZ
)

		#Calls the End of Script variable
		echo -e "$farewell"
		echo
		echo
		exit 0
}

# Check privileges
	[ $(whoami) == "root" ] || die "You need to run this script as root."

# Welcome to the script
	clear
	welcome=$(cat << EOA


          \e[01;37;42mWelcome to Midacts Mystery's Teamspeak Installation Script!\e[0m


EOA
)

# Calls the welcome variable
	echo -e "$welcome"

# Calls the doAll function
	case "$go" in
		* )
			doAll ;;
	esac

exit 0
