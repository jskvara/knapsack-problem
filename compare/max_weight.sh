#!/bin/bash

values=(50 100 250 500 1000 2000)
mkdir resources/
touch results/tmp
for item in ${values[*]}
	do
		source_file="resources/max_weight_${item}"
		destination_file="results/tmp"
		./generate.sh -W $item $source_file $destination_file
		for i in {1..4}
			do
				final_output="results/max_weight_${i}.csv"
				./launch.sh $i $source_file $destination_file
				./add_header.sh $final_output
				echo "max weight ${item} " >> $final_output
				cat $destination_file >> $final_output
				rm $destination_file
			done
	done
