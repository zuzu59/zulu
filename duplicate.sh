#!/bin/bash

EXCLUDE="--exclude=Downloads/ --exclude=mnt/ --exclude=media/ --exclude=lost+found --exclude=proc/ --exclude=dev/ --exclude=sys/ --exclude=tmp/ --exclude=var/cache/apt/archives"
RSYNC_OPT="-aix $EXCLUDE"
VERSION="0.9.120703.1833.120711.1700 zf ajout JFS"
dev_src_type='block'
dev_dst_type='block'
tstart=0
RED='\033[1;31m'
NC='\033[0m'

echo ''
echo '-------------------------------------'
echo "Duplicate Zulu ($VERSION)"
echo '-------------------------------------'

echo 
echo "[*] Usage: $0 [<source> <destination>]"

exec 2> errors.log 3>&1

if [ "$USER" != "root" ]; then
    echo -e "${RED}[!] You must be root$NC"
    exit
fi

echo -n '[*] Installing dependencies ... '
apt-get -qq -y install extlinux parted pv bc rsync 1> /dev/null
echo 'done.'

#
# List and choose devices
#

if [ $# -eq 2 ]; then
    DEV_ORIG="$1"
    DEV_DEST="$2"
else
    echo '[*] Devices:'
    for d in `ls -d /sys/block/sd*`; do
        DEV_NAME=`cat $d/uevent | grep DEVNAME | cut -c 9-`
        DEV_DESC=`cat $d/device/model`
        DEV_SIZE=$(echo "scale=2;`sfdisk /dev/$DEV_NAME -s`/1024/1024" | bc -l)
        echo ''
        echo -e "\t /dev/$DEV_NAME\t $DEV_DESC\t ${DEV_SIZE} GB"
        if [ -d "/sys/block/$DEV_NAME/${DEV_NAME}1" ]; then # The devices has at least a partition
            for p in `ls -d /sys/block/$DEV_NAME/$DEV_NAME*`; do
                PART_NAME=${p##*/}
                PART_SIZE=`sfdisk /dev/$PART_NAME -s`
                PART_TYPE=0
                if [ $PART_SIZE -gt 1048576 ]; then
                    PART_SIZE="$(echo "scale=2;$PART_SIZE/1024/1024" | bc -l) GB"
                else
                    if [ $PART_SIZE -eq 1 ] ; then
                        PART_TYPE=1
                    fi
                    PART_SIZE="$(echo "scale=4;$PART_SIZE/1024" | bc -l) MB"
                fi
                if [ $PART_TYPE -eq 1 ] ; then
                    echo -e "\t    \_ $PART_NAME\t extended"
                else
                    PART_FS=`df -a -T /dev/$PART_NAME | grep $PART_NAME | awk '{ print $2}'`
                    if [ "$PART_FS" == "" ]; then
                        PART_FS=`fdisk -l /dev/$DEV_NAME |grep $PART_NAME | awk '{print $7}'`
                    fi
                    echo -e "\t    \_ $PART_NAME\t $PART_FS\t\t\t $PART_SIZE" 
                fi
            done
        else
            echo -e "\t    \_ Unallocated"
        fi
    done

    echo ''
    echo '[?] Can be a device (/dev/sdx), a partition (/dev/sdx1), a folder (/tmp/dir), a live system (/), an iso9660 (/tmp/file.iso) or a tgz archive (/tmp/file.tar.gz).'
    echo ''
    read -e -p '    Source: ' -i '/dev/sdb' DEV_ORIG 2>&3
    read -e -p '    Destination: ' -i '/dev/sdc' DEV_DEST 2>&3
fi


#
# Check devices type
#

# Source
if [ "$DEV_ORIG" == "/" ]; then
    dev_src_type='live'
elif [ -b "$DEV_ORIG" ]; then
    dev_src_type='block'
elif [ -d "$DEV_ORIG" ]; then
    dev_src_type='folder'
elif [ $(file $DEV_ORIG | grep gzip > /dev/null; echo $?) -eq 0 -a $(gzip -l $DEV_ORIG | grep tar > /dev/null; echo $?) -eq 0 ]; then
    dev_src_type='gunzip'
elif [ $(file $DEV_ORIG | grep 'ISO 9660' > /dev/null; echo $?) -eq 0 ]; then
    dev_src_type='iso'
else
    echo ''
    echo -e "$RED[!] Source: \"$DEV_ORIG\" does not exist or is not supported$NC"
    echo -e "$RED[!] Cancelled$NC"
    exit
fi
# Destination
if [ -b "$DEV_DEST" ]; then
    dev_dst_type='block'
elif [ "${DEV_DEST##*.}" == "tgz" -o "${DEV_DEST##*.}" == "gz" ]; then
    dev_dst_type='gunzip'
else
    if [ "${DEV_DEST%/*}" == "/dev" ]; then
        echo ''
        echo -e "$RED[!] $DEV_DEST is not a valid device$NC"
        echo -e "$RED[!] Cancelled$NC"
        exit
    fi
    echo "[+] Assuming $DEV_DEST is a folder."
    dev_dst_type='folder'
fi

#
# Summary and confirmation
#

echo ''
echo '    Summary:'
echo -e "\tUsing origin: $DEV_ORIG ($dev_src_type)"
echo -e "\tUsing destination: $DEV_DEST ($dev_dst_type)"
echo ''
echo -n "[?] Are you sure you want to destroy $DEV_DEST? [yes/NO]: "
read confirm 2>&3
if [ "`echo $confirm | tr A-Z a-z`" != "yes" ]; then
    echo -e "$RED[!] Cancelled$NC"
    exit
fi

#
# Prepare source/destination
#

echo '[*] Prepare source and destination ...'
# Source
mkdir -p /mnt/usb_orig
SRC='/mnt/usb_orig'
if [ "$dev_src_type" == "live" ]; then
    if [ "$(mount | grep 'on / type' | cut -f5 -d' ' | tail -n 1)" == "aufs" -a -f "/live/image/live/root.squashfs" ]; then
        mount -o loop -t squashfs /live/image/live/root.squashfs /mnt/usb_orig
    else
        mount --bind / /mnt/usb_orig
    fi
elif [ "$dev_src_type" == "iso" ]; then
    mount -o loop -t iso9660 "$DEV_ORIG" /mnt/usb_orig 1>&2
elif [ "$dev_src_type" == "block" ]; then
    if [ -d "/sys/block/${DEV_ORIG##*/}" ]; then
        DEV_ORIG_PART="${DEV_ORIG}1"
    else 
        DEV_ORIG_PART="$DEV_ORIG"
    fi
    umount $DEV_ORIG_PART
    mount -t ext4 $DEV_ORIG_PART /mnt/usb_orig
else
    SRC="$DEV_ORIG"
fi

# Source is Zulu
# FIXME: Only for zulu user
if [ "$dev_src_type" == "live" -a -f "/etc/init.d/ramfs" ]; then
    /etc/init.d/ramfs stop 1>&2
fi

# Destination
if [ "$dev_dst_type" == "block" ]; then
    DST='/mnt/usb_dest'
    umount -f -l $DEV_DEST
    if [ -d "/sys/block/${DEV_DEST##*/}" ]; then
        echo -ne "\t$DEV_DEST: partitioning... "
        DEV_DEST_PART="${DEV_DEST}1"
        umount -f -l $DEV_DEST_PART
        # Destroy partition table so parted doesn't crash 
        # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=620273
        dd if=/dev/zero of=$DEV_DEST bs=512 count=1
        parted -s -- $DEV_DEST mklabel msdos
        partprobe
        parted -s --align minimal -- $DEV_DEST mkpart primary ext4 0% 100%
        echo 'done.'
    else
        DEV_DEST_PART="$DEV_DEST"
        DEV_DEST="${DEV_DEST_PART%[0-9]}"
        umount -f -l $DEV_DEST_PART
        START=$(cat /sys/block/${DEV_DEST##*/}/${DEV_DEST_PART##*/}/start)
        if [ $START -ne 1 -a $(cat /sys/block/${DEV_DEST##*/}/removable) -eq 1 ]; then
            echo -e "\t${RED}[!] Partition is aligned to 2048 sectors, this may not work with all disks.$NC"
            read -p '[?] Do you want to re-align and format the partiton ? [NO/yes]: ' confirm 2>&3
            if [ "`echo $confirm | tr A-Z a-z`" == "yes" ]; then
                PARTNUM=$(parted -m -s -- $DEV_DEST_PART print | tail -n 1 | awk -F: '{print $1}')
                END=$(echo "$(cat /sys/block/${DEV_DEST##*/}/${DEV_DEST_PART##*/}/size) + $START - 1"  | bc)
                parted -s -- $DEV_DEST rm $PARTNUM
                parted -s -- $DEV_DEST mkpart primary ext4 1s ${END}s
                #e2fsck -f -y $DEV_DEST_PART
                #resize2fs $DEV_DEST_PART
#                mkfs.ext4 -O ^has_journal $DEV_DEST_PART
                mkfs.ext4 -O has_journal $DEV_DEST_PART
            fi
        fi
    fi
    parted -s -- $DEV_DEST set 1 boot on
    mkdir -p $DST
    mount $DEV_DEST_PART $DST
    PART_FS=`df -a -T $DEV_DEST_PART | grep ${DEV_DEST_PART##*/} | awk '{print $2}'`
    if [ "$PART_FS" != "ext4" ]; then
        echo -ne "\t$DEV_DEST_PART: ext4 not detected, formatting... "
#        mkfs.ext4 -O ^has_journal $DEV_DEST_PART 1>&2
        mkfs.ext4 -O has_journal $DEV_DEST_PART 1>&2
        umount $DEV_DEST_PART
        echo 'done.'
    else
        echo -ne "\t$DEV_DEST_PART: ext4 detected, removing content..."
        chattr -i $DST/ldlinux.sys
        chattr -i $DST/home/*/.xsession-errors
        rm -fr $DST/*
        umount $DEV_DEST_PART
#        tune2fs -O ^has_journal $DEV_DEST_PART 1>&2
        tune2fs -O has_journal $DEV_DEST_PART 1>&2
        echo "done."
    fi
    echo -ne "\t$DEV_DEST_PART: Configure ext4 and install bootloader... "
    tune2fs -c 5 -i 7d $DEV_DEST_PART 1>&2
    dd bs=440 count=1 conv=notrunc if=/usr/lib/extlinux/mbr.bin of=$DEV_DEST_PART
    mount -t ext4 $DEV_DEST_PART $DST
    echo "done."
elif [ "$dev_dst_type" == "folder" ]; then
    rm -fr $DEV_DEST
    mkdir $DEV_DEST
    DST="$DEV_DEST"
elif [ "$dev_dst_type" == "gunzip" ]; then
    DST="$DEV_DEST"
fi
echo 'done.'

#
# Copy
#
echo -n "[*] Copy to $DEV_DEST_PART "
tstart=`date +%s`
if [ "$dev_src_type" == "gunzip" ]; then
    echo -n 'using tar...'
    cd $DST
    tar --numeric-owner -xzpsf $SRC
elif [ "$dev_dst_type" == "gunzip" ]; then
    echo -n 'using tar...'
    cd $SRC
    tar --numeric-owner -czpsf $DST .
else
    echo 'using rsync...'
    NB=`find $SRC | wc -l`
    rsync $RSYNC_OPT "$SRC/" "$DST/" | pv -w 80 -fltps $NB > /dev/null 2>&3
fi
echo 'done.'

if [ "$dev_dst_type" != "gunzip" ]; then
    mkdir $DST/dev
    mkdir $DST/proc
    mkdir $DST/sys
    mkdir $DST/tmp
    mkdir $DST/var/tmp
    mkdir $DST/media
    mkdir $DST/mnt
fi

#
# Post-copy
#

echo -n '[*] Finishing... '
# Source is Zulu
# FIXME: Only for zulu user
if [ "$dev_src_type" == "live" -a -f "/etc/init.d/ramfs" ]; then
    /etc/init.d/ramfs start 1>&2
fi

# Destination
if [ "$dev_dst_type" != "gunzip" ]; then
    # Regenerate ssh host keys
    mount -o bind /dev $DST/dev
    rm $DST/etc/ssh/ssh_host_*
    chroot $DST dpkg-reconfigure openssh-server
    umount -f -l $DST/dev
    # Allow eth to change mac addr
    touch $DST/etc/udev/rules.d/70-persistent-net.rules
fi
if [ "$dev_dst_type" == "block" ]; then
    if [ "$dev_src_type" == "iso" ]; then
        echo 'default linux
        prompt 1
        timeout 300
        display isolinux.txt
        label linux
            kernel /live/vmlinuz
            append initrd=/live/initrd.gz boot=live' > $DST/isolinux/extlinux.conf
        extlinux -i $DST/isolinux
    else
        chattr +i $DST/home/*/.xsession-errors
        extlinux -i $DST
        UUID=$(blkid -o list -c /dev/null -o value $DEV_DEST_PART | head -n 1)
        sed -i "s/UUID=.*\//UUID=$UUID\t\//" $DST/etc/fstab
        echo -e "PROMPT 1
        TIMEOUT 5
        DEFAULT Debian
        LABEL Debian
                LINUX vmlinuz
                APPEND root=UUID=$UUID ro initrd=/initrd.img
                INITRD initrd.img" > $DST/extlinux.conf
    fi
fi

sync; sync; sync;

sleep 5

umount $DEV_ORIG
umount $DEV_ORIG_PART
umount -f -l $DEV_DEST
umount -f -l $DEV_DEST_PART
rm -rf /mnt/usb_orig
rm -rf /mnt/usb_dest
echo 'done.'

seconds=$(echo "$(date +%s)-$tstart" | bc)
echo "[*] Duration: $seconds seconds"
exec 3>&-

