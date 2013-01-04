#!/bin/bash

values=(1 2 3 5)
mkdir resources/
touch results/tmp

for item in ${values[*]}
	do
		source_file="resources/granularity_small_${item}"
		destination_file="results/tmp"
		./generate.sh -d -1 -k $item $source_file
		for i in {1..4}
			do
				final_output="results/granularity_small_${i}.csv"
				./launch.sh $i $source_file $destination_file
				./add_header.sh $final_output
				echo "granularity ${item} " >> $final_output
				cat $destination_file >> $final_output
				rm $destination_file
			done
	done

touch results/tmp
for item2 in ${values[*]}
	do
		source_file="resources/granularity_high_${item2}"
		destination_file="results/tmp"
		./generate.sh -d 1 -k $item2 $source_file
		for i in {1..4}
			do

				final_output="results/granularity_high_${i}.csv"
				./launch.sh $i $source_file $destination_file
				./add_header.sh $final_output
				echo "granularity ${item2} " >> $final_output
				cat $destination_file >> $final_output
				rm $destination_file
			done
	done
