#!/bin/bash
# display menu
# $1: u.item, $2: u.data, $3: u.user
echo "--------------------------"
echo "User Name: Choi Kee-Weon"
echo "Student Number: 12201811"
echo "--------------------------"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------"

# loop
stop="N"
until [ $stop = "Y" ]
do
	# get input from the user
	read -p "Enter your choice [ 1-9 ] " choice
	case $choice in
	1)
		echo ""
		read -p "Please enter the 'movie id'(1~1682):" num
		echo ""
		cat $1 | awk -F\| -v movie_id=$num '$1==movie_id{print}'
		echo ""
		;;
	2)
		echo ""
		read -p "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n):" var
		echo ""
		if [ "$var" == "y" ]
		then
			cnt=0
			cat $1 | awk -F\| '$7==1 && cnt<10 {print $1, $2; cnt+=1}'
			echo ""
		fi
		;;
	3)
		echo ""
		read -p "Please enter the 'movie id'(1~1682): " num
		
		echo ""
		res=$(cat $2 | awk -v movie_id=$num '$2==movie_id {sum+=$3; cnt+=1} END {print sum/cnt}')
		if [[ $res =~ ^-?[0-9]+$ ]]
		then
			printf "average rating of %d: %d\n" $num $res
		else
			printf "average rating of %d: %.5f\n" $num $res
		fi
		echo ""
		;;
	4)
		echo ""
		read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n):" var
		echo ""
		if [ "$var" == "y" ]
		then
			cat $1 | sed -n '1,10p' | sed -E 's/http[^\|]*\)//g'
			echo ""
		fi
		;;
	5)
		echo ""
		read -p "Do you want to get the data about users from 'u.user'?(y/n):" var
		echo ""
		if [ "$var" == "y" ]
		then
			cat $3 | sed -n '1,10p' | awk -F\| '$3=="M" {sex="male"} $3=="F" {sex="female"} {printf("user %d is %d years old %s %s\n", $1, $2, sex, $4)}'
			echo ""
		fi
		;;
	6)
		echo ""
		read -p "Do you want to Modify the format of 'release data' in 'u.item'?(y/n):" var
		echo ""
		if [ "$var" == "y" ]
		then
			cat $1 | sed -n '1673,1682p' | sed -e 's/Jan/01/g' -e 's/Feb/02/g' -e 's/Mar/03/g' -e 's/Apr/04/g' -e 's/May/05/g' -e 's/Jun/06/g' -e 's/Jul/07/g' -e 's/Aug/08/g' -e 's/Sep/09/g' -e 's/Oct/10/g' -e 's/Nov/11/g' -e 's/Dec/12/g' -Ee 's/([0-9]{2})-([0-9]{2})-([0-9]{4})/\3\2\1/'
			echo ""
		fi
		;;
	7)
		echo ""
		read -p "Please enter the 'user id'(1~943):" id
		echo ""
		res=$(cat $2 | awk -v user_id=$id '$1==user_id {print $2}' | sort -n | tr '\n' '|')
		echo $res
		echo ""
		id_list=$(echo $res | awk -F\| '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}')
		for var in $id_list
		do
			cat $1 | awk -F\| -v movie_id=$var '$1==movie_id {printf("%d|%s\n", $1, $2)}'
		done
		echo ""
		;;
	8)
		echo ""
		read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n):" var
		echo ""
		if [ "$var" == "y" ]
		then
			id_list=$(cat $3 | awk -F\| '$2>20 && $2<30 && $4=="programmer"{print $1}' | sed 's/\n/\s/g')
			
			for var in $id_list
			do
				cat $2 | awk -v user_id=$var '$1==user_id {print $2, $3}' | sort -n >> rated_output.txt
			done
			id=0
			cat rated_output.txt | sort -n | awk -v movie_id=$id 'movie_id==0{movie_id=$1} movie_id!=$1{printf "%d %s\n", movie_id, sum/cnt; sum=0; cnt=0; movie_id=$1} movie_id==$1{sum+=$2; cnt+=1} END {printf "%d %s\n", movie_id, sum/cnt}'
			echo ""
		fi
		;;
	9)
		echo -e "Bye!"
		echo ""
		stop="Y"
		;;
	*)
		echo "Error: Invalid option..."
		echo ""
		;;
	esac
done

