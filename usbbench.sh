#!/bin/bash

VERSION=0.1.120601.1611

echo ''
echo '-------------------------------------'
echo "Bench en écriture pour clef USB ($VERSION)"
echo "Dure entre 20 et 100 secondes !"
echo "Utilisation: $0 path"
echo '-------------------------------------'

RED='\033[1;31m'
NOCOL='\033[0m'

DST=$1 ;if [ "$1" == "" ];then DST=. ;fi
DST=$DST/'zbench'
NB=`find $SRC | wc -l`

#sudo bash -c "sync && echo 3 > /proc/sys/vm/drop_caches"
sync
mkdir $DST

tstart=`date +%s`

SIZE=1       #en MB
NB=100
for i in $(seq 1 1 $NB); do
    echo -n ${i}, 
    dd if=/dev/zero bs=1M count=$SIZE of=$DST/$FILE_TEST${i} 2>/dev/null
done

echo ""
echo 'Clear cache'
sync

size=$(du -m $DST |cut -f1)
seconds=$(echo "$(date +%s)-$tstart" | bc)
speed=$(echo "$size/$seconds" | bc -l)
speed=$(printf "%.2f" $speed)

echo''
echo "${size} MB copiés en $seconds seconds"
echo -e "Vitesse réel ${RED}$speed${NOCOL} MB/s"

rm -rf $DST
#echo 'Clear cache'
#sync




#Ancien script
#dd if=/dev/zero bs=1M count=$SIZE | pv -pr -s $SIZE'm' > $FILE_TEST 
#    dd if=/dev/zero bs=1M count=$SIZE | pv -pr -s $SIZE'm' > $DST/$FILE_TEST${i}
#rsync $RSYNC_OPT "$SRC/" "$DST/" | pv -fltps $NB > /dev/null
#SRC='/opt/java'
#RSYNC_OPT="-ai"
#FILE_TEST='./bench.nul'




