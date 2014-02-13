#!/bin/bash

this=`basename $(readlink -f $0)`

function usage {
	echo "usage: $this url component"
	echo "	url        - the url to parse"
	echo "	component  - any one of the following: proto, user, pass, port, host, path"
	echo
	exit 1
}

if [[ ( "$1" == "" ) || ( "$2" == "" ) ]]; then
	usage
fi

url=$1
component=$2

if [[ \
	( "$component" != "host" ) && \
	( "$component" != "pass" ) && \
	( "$component" != "path" ) && \
	( "$component" != "port" ) && \
	( "$component" != "proto") && \
	( "$component" != "user" ) ]]; then
	usage
fi

# Thank you http://stackoverflow.com/a/17287984

# extract the protocol
if [[ $(echo $url |grep '://') == "" ]]; then
	echo "I expected url to contain '://', exiting..." && exit 1
fi

proto="`echo $url | grep '://' | sed -e's,^\(.*://\).*,\1,g'`"
# remove the protocol
url=`echo $url | sed -e s,$proto,,g`

# remove '://' from proto
proto="`echo $proto | sed -e 's,://,,'`"

# extract the user and password (if any)
userpass="`echo $url | grep @ | cut -d@ -f1`"
pass=`echo $userpass | grep : | cut -d: -f2`
if [ -n "$pass" ]; then
    user=`echo $userpass | grep : | cut -d: -f1`
else
    user=$userpass
fi

# extract the host -- updated
hostport=`echo $url | sed -e s,$userpass@,,g | cut -d/ -f1`
port=`echo $hostport | grep : | cut -d: -f2`
if [ -n "$port" ]; then
    host=`echo $hostport | grep : | cut -d: -f1`
else
    host=$hostport
fi

# extract the path (if any)
path="`echo $url | grep / | cut -d/ -f2-`"

echo "${!component}"
