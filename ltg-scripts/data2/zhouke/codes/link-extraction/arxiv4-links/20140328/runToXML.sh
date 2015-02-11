#!/bin/bash
THREAD_NUM=24

mkfifo tmp
exec 9<>tmp

for ((i=0;i<$THREAD_NUM;i++))
do
	echo -ne "\n" 1>&9
done


if [ $# != 2 ] ;then
        echo "The parameters you enter is not correct !";
        exit -1;
fi


count=0
paths=" "
xmlPath=$2

while read LINE
do
{
	count=$((count+1))
	read -u 9
	{		
		paths=$LINE
		fileName=$(basename "$paths")
		prefix=$(echo "$paths" | awk -F"/" '{print $7}')
		fileName="$prefix""|""$fileName"
		echo "proc" "$fileName"
		echo "processing"" ""$paths"" to output ""$xmlPath""/""$fileName"" ""$count"
		START=`date +%s%N`;
		timeout 600s ./pdftohtml -xml "$paths" "$xmlPath""/""$fileName"
		END=`date +%s%N`;
		time=$((END-START))
		time=`expr $time / 1000000000`
		echo "processed"" "$paths"" "$count"" elasped ""$time""seconds"
		paths=" "
		echo -ne "\n" 1>&9
	}&
}
done < $1
wait
echo "done for all pdf processing""\n"
rm tmp





