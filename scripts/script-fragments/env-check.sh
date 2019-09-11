#!/bin/bash

################################################################################################################################################################################

#Script Description : setup each peer ,let each peer join business channel ,and set anchor peers

#$1 ${CPU_MIN}                   minimum cpus needed
#$2 ${MEMORY_MIN}                minimum memory needed (Gigabytes)
#$3 ${DISK_SIZE_MIN}             minimum disk space needed (Megabytes)
#$4 ${OPEN_FILES_MIN}            minimum open files

###############################################################################################################################################################################

#cpu check
cpu_min=$1
cpu_num=`cat /proc/cpuinfo|grep 'processor'|sort|uniq|wc -l`
echo "cpu num:$cpu_num"
 if [ $cpu_num -lt $cpu_min ]; then
  echo "CPU core less then required!"
  exit
fi

#memory check
memory_min=$2
memory_free=`free -m|grep 'Mem'|awk '{print $4}'`
echo "memory free:" $memory_free
if [ $memory_free -lt $memory_min  ]; then
  echo "memory less then required!"
  exit
fi

#check disk
disk_size_min=$3
disk_size=`df / | awk 'NR==2{print}' | awk '{print $2}' |grep '[0-9]'`
echo "disk size:$disk_size"
if [ $disk_size -lt $disk_size_min ]; then
   echo "disk size less then required!"
   exit
fi

#check open files num
open_file_min=$4
open_files=`ulimit -a | grep "open files" | awk '{print $4}'`
echo "open files:" ${open_files}
if [[ $open_files -lt $open_file_min ]]; then
 echo "open files less then required!"
 exit
fi
