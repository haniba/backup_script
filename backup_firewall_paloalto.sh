#!/usr/bin/bash
#
#
# Product       :       Firewall Paloalto
# Action        :       backup firewall 
#
#               Mr.Sirawit Aujitarree
# ____  _                    _ _
#/ ___|(_)_ __ __ ___      _(_) |_
#\___ \| | '__/ _` \ \ /\ / / | __|
# ___) | | | | (_| |\ V  V /| | |_
#|____/|_|_|  \__,_| \_/\_/ |_|\__|
# Base on redhat or centos
# Test on firewall Paloalto model PA-5220,PA-850
# before use install  xmlstarlet
# yum install xmlstarlet
yy=`date +%Y`
dd=`date +%d`
mm=`date +%m`
hh=`date +%H%M%S`
#change keep backup (days)
keepbackup=90
#path for textfile
homepath=/data/scripts
backuppath=/data/backup/Firewall
list_device=list_firewall_paloalto.csv
#Format file 
#ip,hostname,username,password
which xmlstarlet
if [ $? = 1 ] ; then 
	yum install -y xmlstarlet

fi
 for ii in `cat ${homepath}/${list_device}`
 do		
         ip=`echo ${ii}|cut -d ',' -f 1`
         hostname=`echo ${ii}|cut -d ',' -f 2`
         username=`echo ${ii}|cut -d ',' -f 3`
         password=`echo ${ii}|cut -d ',' -f 4`
		 echo clear old file config more than ${keepbackup} days ago.
		 echo firewall name ${hostname}
		 find ${backuppath}/${zone}/ -name running-config_${hostname}_*.xml -ctime +${keepbackup} -exec rm -rf {} \;
		 curl -k "https://${ip}/api/?type=keygen&user=${username}&password=${password}" > ${homepath}/key_${hostname}.xml
		 key=$(xmlstarlet sel -t -v '//key' ${homepath}/key_${hostname}.xml)
		 cat ${homepath}/key_${hostname}.xml		 
		 mkdir -p ${backuppath}/${zone}/$yy/$mm/$dd
		 curl -k "https://${ip}/api/?type=export&category=configuration&key=${key}" > ${backuppath}/$yy/$mm/$dd/running-config_${hostname}_$yy$mm$dd.xml
		 rm -f ${homepath}/key_${hostname}.xml
 done
