# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    test_philo_data_race.sh                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: lmonsat <lmonsat@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/07/18 15:36:34 by nfordoxc          #+#    #+#              #
#    Updated: 2024/11/25 16:19:19 by lmonsat          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash

not_valid_arg=(
	""
	"toto"
	"300 200 100 50"
	"300 toto 542 35"
	"12 toto 452 652"
	"3 2147483647 2147483648 2"
	"4 500 -54 50"
	"6 500 64 -32 60"
	"1 100 200 100"
	"2147483648 2147483648 2147483648 2147483648"
	"-2147483648 -2147483648 -2147483648 -2147483648"
	"4 4 4 7 19"
	"9 50 100 100"
)

die=(
	"1 400 100 100"
	"1 800 200 200"
	"15 350 200 200"
	"1 800 200 200"
	"4 310 200 100"
	"5 410 200 200"
	"1 400 100 100 2"
	"2 300 200 100 3"
	"6 310 100 200 12"
	"154 400 200 200 20"
)

live_end=(
	"2 400 100 100 12"
	"5 800 200 200 7"
	"8 410 200 200 5"
	"8 410 200 200 1"
	"12 500 100 100 50"
	"50 410 200 100 2"
	"22 410 200 200 2"
	"22 410 200 200 1"
)

live_end_limit=(
	"3 310 100 100 5"
	"5 610 200 200 5"
	"9 610 200 200 5"
	"11 310 100 100 5"
	"13 905 300 200 5"
	"21 605 200 100 5"
	"51 610 200 200 1"
	"155 910 300 300 1"
)

never_die=(
	"2 400 100 100"
	"8 410 200 200"
	"4 410 200 200"
	"12 500 100 100"
	"50 410 200 100"
	"5 800 200 200"
	"4 410 200 100"
	"8 405 200 200"
)

error_count=0

make
clear

echo ""
echo -e "\033[1;94m _______   ______   _______    _______       __        __  _\033[0m"
echo -e "\033[1;94m|__   __| |  ____| |   ____|  |__   __|      \\ \\      / / | |\033[0m"
echo -e "\033[1;94m   | |    | |___   |  |____      | |          \\ \\    / /  | |\033[0m"
echo -e "\033[1;94m   | |    |  ___|  |_____  |     | |           \\ \\  / /   | |\033[0m"
echo -e "\033[1;94m   | |    | |____   _____| |     | |            \\ \\/ /    | |\033[0m"
echo -e "\033[1;94m   |_|    |______| |_______|     |_|             \\__/     |_|\033[0m"
echo ""
echo -e "\t\t\033[1;93mNOT VALID ARGS.\033[0m"
echo ""

for i in "${!not_valid_arg[@]}"
do
	TEMPFILE=$(mktemp)

	echo -e "\033[1;94mTEST $((i + 1)): valgrind --tool=helgrind ./philo ${not_valid_arg[i]}\033[1;93m"
	valgrind --tool=helgrind ./philo ${not_valid_arg[i]} &> $TEMPFILE

	if grep -q "violated" $TEMPFILE; then
		echo -e "\033[1;91m\tKO => Mutex violation detected.\033[0m"
		((error_count++))
	else
		echo -e "\033[1;92m\tOK => No mutex violation detected.\033[0m"
	fi

	if grep -q "data race" $TEMPFILE; then
		echo -e "\033[1;91m\tKO => Data race detected.\033[0m"
		((error_count++))
	else
		echo -e "\033[1;92m\tOK => No data race detected.\033[0m"
	fi

	ERROR_SUMMARY=$(grep -E "ERROR SUMMARY:" $TEMPFILE)
	if [ -n "$ERROR_SUMMARY" ]; then
		echo -e "\033[1;94mERROR SUMMARY:\033[0m"
		echo "$ERROR_SUMMARY"
	fi

	rm $TEMPFILE
done

echo ""
echo -e "\t\t\033[1;93mMUST DIE.\033[0m"
echo ""

for i in "${!die[@]}"
do
	TEMPFILE=$(mktemp)

	echo -e "\033[1;94mTEST $((i + 1)): valgrind --tool=helgrind ./philo ${dead[i]}\033[1;93m"
	valgrind --tool=helgrind ./philo ${die[i]} &> $TEMPFILE

	if grep -q "violated" $TEMPFILE; then
		echo -e "\033[1;91m\tKO => Mutex violation detected.\033[0m"
		((error_count++))
	else
		echo -e "\033[1;92m\tOK => No mutex violation detected.\033[0m"
	fi

	if grep -q "data race" $TEMPFILE; then
		echo -e "\033[1;91m\tKO => Data race detected.\033[0m"
		((error_count++))
	else
		echo -e "\033[1;92m\tOK => No data race detected.\033[0m"
	fi

	ERROR_SUMMARY=$(grep -E "ERROR SUMMARY:" $TEMPFILE)
	if [ -n "$ERROR_SUMMARY" ]; then
		echo -e "\033[1;94mERROR SUMMARY:\033[0m"
		echo "$ERROR_SUMMARY"
	fi

	rm $TEMPFILE
done

echo ""
echo -e "\t\t\033[1;93mMUST END.\033[0m"
echo ""

for i in "${!live_end[@]}"
do
	TEMPFILE=$(mktemp)

	echo -e "\033[1;94mTEST $((i + 1)): valgrind --tool=helgrind ./philo ${live_end[i]}\033[1;93m"
	valgrind --tool=helgrind ./philo ${live_end[i]} &> $TEMPFILE

	if grep -q "violated" $TEMPFILE; then
		echo -e "\033[1;91m\tKO => Mutex violation detected.\033[0m"
		((error_count++))
	else
		echo -e "\033[1;92m\tOK => No mutex violation detected.\033[0m"
	fi

	if grep -q "data race" $TEMPFILE; then
		echo -e "\033[1;91m\tKO => Data race detected.\033[0m"
		((error_count++))
	else
		echo -e "\033[1;92m\tOK => No data race detected.\033[0m"
	fi

	ERROR_SUMMARY=$(grep -E "ERROR SUMMARY:" $TEMPFILE)
	if [ -n "$ERROR_SUMMARY" ]; then
		echo -e "\033[1;94mERROR SUMMARY:\033[0m"
		echo "$ERROR_SUMMARY"
	fi

	rm $TEMPFILE
done

echo ""
echo -e "\t\t\033[1;93mNEVER DIE.\033[0m"
echo ""

for i in "${!never_die[@]}"
do
	TEMPFILE=$(mktemp)

	echo -e "\033[1;94mTEST $((i + 1)): valgrind --tool=helgrind timeout 10s ./philo ${never_die[i]}\033[1;93m"
	valgrind --tool=helgrind timeout 10s ./philo ${never_die[i]} &> $TEMPFILE

	if grep -q "violated" $TEMPFILE; then
		echo -e "\033[1;91m\tKO => Mutex violation detected.\033[0m"
		((error_count++))
	else
		echo -e "\033[1;92m\tOK => No mutex violation detected.\033[0m"
	fi

	if grep "data race" $TEMPFILE; then
		echo -e "\033[1;91m\tKO => Data race detected.\033[0m"
		((error_count++))
	else
		echo -e "\033[1;92m\tOK => No data race detected.\033[0m"
	fi

	ERROR_SUMMARY=$(grep -E "ERROR SUMMARY:" $TEMPFILE)
	if [ -n "$ERROR_SUMMARY" ]; then
		echo -e "\033[1;94mERROR SUMMARY:\033[0m"
		echo "$ERROR_SUMMARY"
	fi

	rm $TEMPFILE
done

echo -e "\n\033[1;93mNombre total d'erreurs détectées : $error_count\033[0m"

echo ""
echo -e "\033[1;94m _______  _   ___    _\033[0m"
echo -e "\033[1;94m|  ____| |_| |   \  | |\033[0m"
echo -e "\033[1;94m| |__     _  | |\ \ | |\033[0m"
echo -e "\033[1;94m|  __|   | | | | \ \| |\033[0m"
echo -e "\033[1;94m| |      | | | |  \ | |\033[0m"
echo -e "\033[1;94m|_|      |_| |_|   \__|\033[0m"
echo ""
