#!/bin/bash
clear
shopt -s extglob

echo -e "      ___       ___           ___           ___           ___     \n\
     /\__\     /\__\         /\  \         /\__\         /\  \    \n\
    /:/  /    /:/  /        /::\  \       /:/  /        /::\  \   \n\
   /:/  /    /:/  /        /:/\:\  \     /:/  /        /:/\ \  \  \n\
  /:/  /    /:/  /  ___   /::\~\:\  \   /:/  /  ___   _\:\~\ \  \ \n\
 /:/__/    /:/__/  /\__\ /:/\:\ \:\__\ /:/__/  /\__\ /\ \:\ \ \__\ \n\
 \:\  \    \:\  \ /:/  / \/__\:\ \/__/ \:\  \ /:/  / \:\ \:\ \/__/ \n\
  \:\  \    \:\  /:/  /       \:\__\    \:\  /:/  /   \:\ \:\__\  \n\
   \:\  \    \:\/:/  /         \/__/     \:\/:/  /     \:\/:/  /  \n\
    \:\__\    \::/  /                     \::/  /       \::/  /   \n\
     \/__/     \/__/                       \/__/         \/__/    "

echo -e "
+----------------------------------------------------------------+
|                    QUICK TIPS & USAGE GUIDE                    |
+----------------------------------------------------------------+
| 1. Disk Selection:                                             |
|    - Use raw disk name only (e.g., sdb) - NEVER use sdb1/sdb2. |
|    - WARNING: All data on the target disk will be wiped!       |
| 2. Boot Methods:                                               |
|    - Live Boot: Run the OS directly from USB (RAM-based).      |
|    - Installation Media: Standard OS installer (Recommended).  |
| 3. ISO Path & Privileges:                                      |
|    - Tilde (~) shortcut is supported (e.g., ~/Downloads/os.iso)|
|    - Root privileges (sudo) are required for writing raw data. |
+----------------------------------------------------------------+
"
read -rsn1 -t 30 -p "Press any key to continue "
clear
echo "
=========== Drives & Partitions ===========
"
lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE
echo "
===========================================
"
read -rp "Select the exact name of Disk : " disk
if ! lsblk -dno NAME | grep -qw "^$disk$"; then
    echo "[-] Error: '$disk' is not a valid disk (or it might be a partition)!"
    exit 1
fi
echo "[+] Disk '$disk' confirmed!"
sleep 2
clear

array=("Live Boot" "Installation Media (recommended)")
up_down=0
while true; do
    clear
    for n in ${!array[@]}; do
        if [[ $n -eq $up_down ]]; then
            echo -e " \e[1;32m[*] ${array[$up_down]}\e[0m"
        else
            echo -e " [-] ${array[$n]}"
        fi
    done

    read -srn1 key
    if [[ "$key" == $'\e' ]]; then
        read -srn2 -t 0.1 key
        case "$key" in
            "[A")
                if [[ $up_down -gt 0 ]]; then
                    ((up_down-=1))
                fi
                ;;
            "[B")
                if [[ $up_down -lt $((${#array[@]} - 1)) ]]; then
                    ((up_down+=1))
                fi
                ;;
        esac
    elif [[ "$key" == "" ]]; then
        x=${array[$up_down]}
        break
    fi
done
clear
echo ""
read -e -rp "Write ISO file location correctly: " location
location="${location/#~/$HOME}"
loc2=${location##*/}

if [ ! -f "$location" ]; then 
    echo "[-] Error: No such file exists."
    exit 1
fi

if [[ ${loc2##*.} != "iso" ]]; then 
    echo "[-] Error: File is not an ISO image."
    exit 1
fi

case $x in 
    "${array[0]}")
        read -rp "Do you want to bootable $disk from $loc2 with ${array[0]} method? [y/N]: " agreement
        if [[ ${agreement,,} == @(y|yes) ]]; then
            sudo umount /dev/${disk}* 2>/dev/null
            sudo dd if="$location" of="/dev/$disk" bs=4M status=progress conv=fsync
            echo "[✔] Done!"
        else
            echo "[-] Operation cancelled."
        fi
        ;;
    "${array[1]}")
        read -rp "Do you want to bootable $disk from $loc2 with ${array[1]} method? [y/N]: " agreement
        if [[ ${agreement,,} == @(y|yes) ]]; then
            sudo umount /dev/${disk}* 2>/dev/null
            sudo dd if="$location" of="/dev/$disk" bs=4M status=progress conv=fsync
            echo "[✔] Done!"
        else
            echo "[-] Operation cancelled."
        fi
        ;;
esac
