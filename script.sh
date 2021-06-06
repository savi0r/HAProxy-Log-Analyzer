#!/bin/bash
counter=1
logFileCount=$(ls |grep ".log.gz" | wc -l)

printf "%s \t %s \t %s \t %s \t %-10s \t %-10s \t %-10s \t %-10s \t %-10s\n" "startDate:" "endDate:" "#4XX:" "#5XX:" "#emerg:" "#alert:" "#err:" "#warning:" "Avg server response time:"
error4XX=0
error5XX=0
emerg=0
alert=0
err=0
warning=0
trAvg=0
echo $logFileCount
for f in *.log.gz
#for f in tes*
do
#saving the start date of the first file out of ten
if [ $(($counter % 10)) -eq 1 ]
then
d_s=$(echo $f | grep -Eo "[0-9]{8}")
startDate=$(date -d $d_s "+%Y-%m-%d")
fi
#if (( $(echo "$counter / 10" |bc -l) ))
 
input=$f

#Number of 5XX status 
err5=$(gunzip<$input | grep "[[:digit:]] 5[0-9][0-9] [[:digit:]]"| wc -l )
error5XX=$(($err5 + $error5XX))
#echo $error5XX

#Number of 4XX status 
err4=$(gunzip<$input | grep "[[:digit:]] 4[0-9][0-9] [[:digit:]]"| wc -l )
error4XX=$(($err4 + $error4XX))
#echo $error4XX

#Number of emergency log levels
emerg_tmp=$(gunzip<$input | grep "\"log_level\":\"emerg\"" | wc -l)
emerg=$(($emerg_tmp + $emerg))

#Number of alert log levels
alert_tmp=$(gunzip<$input | grep "\"log_level\":\"alert\"" | wc -l)
alert=$(($alert_tmp + $alert))

#Number of error log levels
err_tmp=$(gunzip<$input | grep "\"log_level\":\"err\"" | wc -l)
err=$(($err_tmp + $err))

#Number of warning log levels
warning_tmp=$(gunzip<$input | grep "\"log_level\":\"warning\"" | wc -l)
warning=$(($warning_tmp + $warning))

#check for num/num/num/the server response/num num/num pattern and then
#calculate the average server response time
trAvg=$(zgrep -Eo "[[:digit:]]+/[[:digit:]]+/[[:digit:]]+/[[:digit:]]+/[[:digit:]]+ [[:digit:]]+/[[:digit:]]+" $input | awk -F '/' '{sum += $4} END {print sum/NR}')


#echo "Number of 2XX status : "
if [ $(($counter % 10 ))  -eq 0 ] || [ $counter -eq $logFileCount ]
then
d_e=$(echo $f | grep -Eo "[0-9]{8}")
endDate=$(date -d $d_e "+%Y-%m-%d")
#endDate=$(echo $f|grep -Eo "[0-9]{8}" | date -d - '+%Y-%m-%d')

echo -e "$startDate \t $endDate \t $error4XX \t $error5XX \t $emerg \t $alert \t $err \t $warning"
printf "%s \t %s \t %s \t %s \t %-10s \t %-10s \t %-10s \t %-10s \t %-10s\n" "$startDate" "$endDate" "$error4XX" "$error5XX" "$emerg" "$alert" "$err" "$warning" "$trAvg"

#reset counters for next series
error4XX=0
error5XX=0
emerg=0
alert=0
err=0
warning=0
trAvg=0
fi

#gunzip<$input | grep "[[:digit:]] 2[0-9][0-9] [[:digit:]]"| wc -l  
echo "done the first part,going to do the next"
((counter++))
done
