#!/bin/bash

values=(0.2 0.4 0.6 0.8 1.0)
mkdir resources/
touch results/tmp
for item in ${values[*]}
	do
		source_file="resources/ratio_${item}"
		destination_file="results/tmp"
		./generate.sh -m $item $source_file $destination_file
		for i in {1..4}
			do
				final_output="results/ratio_${i}.csv"
				./launch.sh $i $source_file $destination_file
				./add_header.sh $final_output
				echo "ratio ${item} " >> $final_output
				cat $destination_file >> $final_output
				rm $destination_file
			done
	done
