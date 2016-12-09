#!/bin/bash

# Determine Script Location

SOURCE="${BASH_SOURCE[0]}"
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Source the functions needed

. ${DIR}/lib/xml/xmlfuncs.sh


getCreds () {

  # If the Credentials weren't populated in the configuration.prop file, then ask for them here
  if [ -z ${SSM_USERNAME+x} ];then

     read -p "Please enter the Layer7 Username: " USERNAME
     read -s -p "Please enter the Layer7 Password: " PASSWORD
     echo

   else

    USERNAME=${SSM_USERNAME}
    PASSWORD=`echo ${SSM_PW} | base64 --decode`


  fi

} 

getListenPortID () {

echo "Getting ListenPort(8443) ID for $1"

curl -s -u $USERNAME:$PASSWORD -k -X GET https://$1:9443/restman/1.0/listenPorts -H "Content-Type: text/xml" >> $$_GETALL_LP_RESPONSE.xml

LISTEN_PORT_XPATH="/l7:List/l7:Item[l7:Name='Default HTTPS (8443)']/l7:Id"

LISTEN_PORT_ID=`xpath $$_GETALL_LP_RESPONSE.xml "$LISTEN_PORT_XPATH"`

rm $$_GETALL_LP_RESPONSE.xml

echo "Recieved ID: $LISTEN_PORT_ID"

}

modifyListenPorts () {

  while IFS='' read -r line || [[ -n "$line" ]]; do

	getListenPortID $line

	echo "----- $line -----"
	echo "Modifying Listen port [ $LISTEN_PORT_ID ] on cluster $line"

	curl -u $USERNAME:$PASSWORD -k -X PUT https://$line:9443/restman/1.0/listenPorts/$LISTEN_PORT_ID -H "Content-Type: text/xml" --data-binary "@listenPortRequest.xml"




echo
echo "-----"
echo

done < "targetClusters.txt"

}

# MAIN

getCreds
modifyListenPorts
