# list var path
list_tables=./show_num_parition/tables.txt
list_partitions=./show_num_parition/list_column_partition.txt
output=./statistics_partitions.txt 
name_database=$1

# dump list tables into tables.txt
hive --showHeader=false --outputformat=tsv2 -f ./show_num_parition/command.sql > $list_tables

# dump list partitions into output.txt
rm -rf $list_partitions
while read line
do
	echo "$line" >> $list_partitions
	eval "hive --showHeader=false --outputformat=tsv2 -e 'desc $name_database.$line'  | awk '/Partition/ {p=1}; p; /Detailed/ {p=0}'" >> $list_partitions
	echo "----" >> $list_partitions
done < "$list_tables"

# result number of table is partitioned
rm -rf $output
string="#"
count=0
count_continue=0
while read line 
do
	if [[ $count -eq 0 ]]; then
		name_table=$line
		# continue
	fi
	if [ "$line" == "----" ]; then
		count=$((count-1))
		echo "$name_table, $count column is partition." >> $output
		count=0
		continue
	fi
	if [[ "$line" == *$string* ]]; then
		continue
	fi
	count=$((count+1))
done < "$list_partitions"

# show name and type list column is partitioned
list_column_paritions=./list_column_partitions.txt
string="#"
rm -rf $list_column_partitions.txt
while read line 
do
	if [[ "$line" == *$string* ]]; then
		continue
	fi
	echo $line >> $list_column_paritions
done < "$list_partitions"
