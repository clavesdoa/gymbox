#!/bin/bash

class=${1:?'bad string'}
instance=${2:-1}
scriptdir=`dirname $0`
date=`date --date="tomorrow" +%A\ -\ %d\ %B\ %Y`
echo "Booking $class on $date"
perl -w "$scriptdir/gymbox.pl" "$date" "$class" "$instance"
