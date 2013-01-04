#!/bin/bash

#velikost instance -n
number_of_things=15

#pocet instanci -N
number_of_instances=50

#promenna
#pomer kapacity k sumarni vaze -m
capacity_to_sum_weight=0.6

#promenna
#maximalni vaha veci -W
max_weight=100

#promenna
#maximalni cena veci -C
max_price=250

#promenna
#exponent k -k
k_exponent=1

#kolik kterych veci -d
d_option=0 #rovnovaha

#dvojtecka na zacatku znamena ze ne nebudou hlasit chyby
#dvojtecka za kazdym pismenem znamena ze se za nim ceka argument
#opt je promenna do ktere se ulozi prepinac
#v promenne $OPTARG je pote umisten parametr
while  getopts "d:m:W:C:k:" opt ; do
	case $opt in
		m )
			echo "-m was triggered! $OPTARG" >&2
			capacity_to_sum_weight=$OPTARG
			;;
		W )
			echo "-W was triggered! $OPTARG" >&2
			max_weight=$OPTARG
			;;
		C )
			echo "-C was triggered! $OPTARG" >&2
			max_price=$OPTARG
			;;
		k )
			echo "-k was triggered! $OPTARG" >&2
			k_exponent=$OPTARG
			;;
		d )
			echo "-d was triggered! $OPTARG" >&2
			d_option=$OPTARG
			;;
		\?)
			echo "Invalid option -$OPTARG" >&2
			;;
		:)
			echo "Option -$OPTARG requires an argument"
	esac
done
#posuneme argumenty za posledni rozpoznany predchozim prikazem
#k dalsim argumentum muzem pristupovat klasicky pomoci $1 $2 atd.
shift $(( OPTIND - 1 ))

source_file=$1

echo "capacity_to_sum_weight = $capacity_to_sum_weight
max_weight = $max_weight
max_price = $max_price
k_exponent = $k_exponent
zdroj = $source_file"

if [ -f $source_file ];
then
    exit 0;
fi

#"./knapgen -n ${number_of_things} -N ${number_of_instances} -m ${capacity_to_sum_weight} -W ${max_weight} -C ${max_price} -k ${k_exponent} -d ${d_option} > ${source_file}"
./knapgen -n $number_of_things -N $number_of_instances \
		  -m $capacity_to_sum_weight -W $max_weight \
		  -C $max_price -k $k_exponent -d $d_option \
		  > $source_file
