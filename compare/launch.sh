# algorithm infile outfile
#java -jar "knappsack.jar" $1 $2 $3

if [ -z $1 ]; then
	echo "Usage: ${0} algorithm input_file output_file"
	exit;
fi

case $1 in
	1)
		ruby bb.rb $2 $3
		;;
	2)
		ruby dyn.rb $2 $3
		;;
	3)
		ruby greedy.rb $2 $3
		;;
	4)
		ruby brute.rb $2 $3
		;;
	:)
		echo "Bad argument ${1}"
esac
