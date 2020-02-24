#!/bin/bash

clear;

SRC=${1:-""};
PRE=${2:-""};
LST=${3:-"users.txt"};

EXIT_CODE=0;

echo "";
echo -e "\033[1m[ INSTAGRAB BATCH ]\033[0m\033[2m[ Grab content from Instagram ] 1.0.0\033[0m";
echo "";

TIMESTAMP_START=$SECONDS;
NUM_USERS=0;

while IFS= read -r USR || [ -n "$USR" ];
do
    NUM_USERS=$((NUM_USERS+1));

    echo -en "\033[1m\033[43m  RUNS  \033[0m";
    echo -e  " \033[2mGrabbing: \033[0m$USR\033[0m";

    DIR=${SRC:-"users/$USR"};
    
    EXEC=$(./instagrab.sh $USR $DIR $PRE);

    if [ "$#" -eq 0 ]
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
done < $LST

DURATION=$(($SECONDS - $TIMESTAMP_START));

echo -e "";
echo -e "\033[1mNumber of Users:\033[0m\t$NUM_USERS";
echo -e "\033[1mDuration:\033[0m\t\t$DURATION seconds";
echo -e "";

exit $EXIT_CODE;