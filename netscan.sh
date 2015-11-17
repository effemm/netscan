#!/bin/bash          
#

echo "Hello World" 
echo "school,prefix,ip,model,sysname,location,MAC,serial"

file=$1
echo Using $file
OLDIFS=$IFS
IFS=","

while read sector school prefix ou dc iprange
do
	echo ======= $school
#	echo $school
#	echo $sector
#	echo $prefix
#	echo $ou
#	echo $dc
#	echo $iprange

	baseip=`echo $iprange | cut -d: -f2`
#	echo $baseip
	stub=`echo $baseip | cut -d. -f1-3`
#	echo $stub

	for octet in {1..254}
	do
   		ip=$stub.$octet
		echo Trying $ip

# This bit nicked from Stuart's TFTPGET script
		if ping -c 1 -t 1 -o $ip 2>&1 >/dev/null ; then
#			echo Woohoo, got a response from $ip
			title=`curl -m 5 -s $ip | grep -a -i \<title\>`
			# echo $title
			model="Unknown"
			sysname="Unknown"
			serial="Unknown"
			location="Unknown"
			MAC="Unknown"
			ip_addr=$ip
			if [[ $title == *724* ]] ; then
#  				echo "Appears to be a GS724T - nothing more we can do";
				model="GS724T"
			else	
				if [[ $title == *title* ]] ; then
#  					echo "Appears to be a FS750T2 - might be able to get more";
					model="FS750T2"
					sysname=`curl -s $ip/cgi_device | grep -a System | cut -d: -f2`
					location=`curl -s $ip/cgi_device | grep -a Location | cut -d: -f2`
					MAC=`curl -s $ip/cgi_device | grep -a MAC | cut -d: -f2`
				fi	

				if [[ $title == *TITLE* ]] ; then
#  					echo "Appears to be a FS726T - might be able to get more";
					model="FS726T"
					sysname=`curl -s $ip/cgi/device | grep -a System |cut -d: -f2`
					location=`curl -s $ip/cgi/device | grep -a Location | cut -d: -f2`
					MAC=`curl -s $ip/cgi/device | grep -a MAC | cut -d: -f2`
				fi
			fi	
			# On the other hand, it might be a Cisco
#			echo "Trying telnet on $ip"
			showver=`./getcisco.sh $ip`
			if [[ $showver == *Cisco* ]] ; then
#				echo "It's a Cisco"
				model=`echo $showver | grep "Model number" | tr -d " \r" | cut -d: -f2`
				sysname=`echo $showver | grep "uptime" | tr " " ":" | cut -d: -f1`
				MAC=`echo $showver | grep "Base ethernet" | tr -d " \r" | cut -d: -f2-7`
				serial=`echo $showver | grep "System serial" | tr -d " \r" | cut -d: -f2`
#				echo ==== $model ====
#				echo ==== $sysname ====
#				echo ==== $MAC ====
#				echo ==== $serial ====

			fi
			echo $school,$prefix,$ip,$model,$sysname,$location,$MAC,$serial
		fi



	done

done < $file

IFS=$OLDIFS

