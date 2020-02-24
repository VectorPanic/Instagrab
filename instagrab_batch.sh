#!/bin/bash

clear;

EXIT_CODE=0;

C='cache.log';
D='users/%U%';
L='users.txt';
N='%N%';

print_usage() {
  echo "usage: Instagrab_batch [-c] [-d] [-h] [-l] [-n]"
  echo " "
  echo "options:"
  echo "-c, Cache file"
  echo "-d, Destination path"
  echo "-h, Help"
  echo "-l, List of users"
  echo "-n, Filename"
  echo " "
  exit 0
}

while getopts 'c:d:h:l:n:' flag; do
  case "${flag}" in
    c) C="${OPTARG}" ;;
    d) D="${OPTARG}" ;;
    h) print_usage ;;
    l) L="${OPTARG}" ;;
    n) N="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

echo "";
echo -e "\033[1m[ INSTAGRAB BATCH ]\033[0m\033[2m[ Grab content from Instagram ] 2.0.0\033[0m";
echo "";

TIMESTAMP_START=$SECONDS;
NUM_USERS=0;

touch "$L";

while IFS= read -r U || [ -n "$U" ];
do
    NUM_USERS=$((NUM_USERS+1));

    echo -en "\033[1m\033[43m  RUNS  \033[0m";
    echo -e  " \033[2mGrabbing: \033[0m$U\033[0m";
    
    EXEC=$(./instagrab.sh -c "$C" -d "$D" -n "$N" -u $U);

    if [ "$?" -eq 0 ]
    then
        echo -en "\033[1A";
        echo -en "\033[1m\033[42m  PASS  \033[0m";
        echo -en "\033[8D";
        echo -en "\033[1B";
    else
        echo -en "\033[1A";
        echo -en "\a\033[1m\033[101m  FAIL  \033[0m";
        echo -en "\033[8D";
        echo -en "\033[1B";
        EXIT_CODE=1;
    fi
done < $L

DURATION=$(($SECONDS - $TIMESTAMP_START));

echo -e "";
echo -e "\033[1mNumber of Users:\033[0m\t$NUM_USERS";
echo -e "\033[1mDuration:\033[0m\t\t$DURATION seconds";
echo -e "";

exit $EXIT_CODE;