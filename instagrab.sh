#!/bin/bash

clear;

USR=${1:-"henkelunchar"};

EXIT_CODE=0;

echo "";
echo -e "\033[1m[ INSTAGRAB ]\033[0m\033[2m[ Grab content from Instagram ] 1.0.0\033[0m";
echo "";

if [ $EXIT_CODE == 0 ] || [ command -v curl >/dev/null 2>&1 ];
then

    TIMESTAMP_START=$SECONDS;

    NUM_PICS_PASS=0;
    NUM_PICS_FAIL=0;
    NUM_VIDS_PASS=0;
    NUM_VIDS_FAIL=0;
    
    echo -e "Looking for new content of \033[1m$USR\033[0m, please wait...";
    echo "";

    mkdir -p "$USR";
    cd "$USR";

    RESPONSE=$(curl -s "https://www.instagram.com/$USR/?__a=1");
    RESPONSE=$(echo $RESPONSE | egrep -o '"shortcode":"(.*?)"');
    RESPONSE=$(echo $RESPONSE | egrep -o '".*"');
    RESPONSE=$(echo $RESPONSE | sed 's/"//g');
    RESPONSE=$(echo $RESPONSE | sed 's/shortcode://g');
    RESPONSE=$(echo $RESPONSE | tr " " "\n");

    if [ ! -z "$RESPONSE" ]
    then
        while read SHORT;
        do
            #
            # Fetch video
            #
            MEDIA=$(curl -s "https://www.instagram.com/p/$SHORT/?__a=1");
            if [[ $MEDIA =~ '"is_video":true,"' ]]
            then

                VIDEO_PATH=$(echo $MEDIA | sed -e 's/.*video_url":"//g' -e 's/".*//g');
                VIDEO_FILE=$(basename "$VIDEO_PATH" | cut -d'?' -f1);

                if [ ! -f $VIDEO_FILE ]
                then

                    NUM_VIDS_PASS=$((NUM_VIDS_PASS+1));

                    echo -en "\033[1m\033[43m  RUNS  \033[0m";
                    echo -e  " \033[2m$USR/\033[0m$(basename "$VIDEO_FILE")\033[0m";

                    EXEC=$(curl -s -L -o "$VIDEO_FILE" $VIDEO_PATH 2>&1);

                    if [ -z "$EXEC" ]
                    then
                        echo -en "\033[1A";
                        echo -en "\033[1m\033[42m  PASS  \033[0m";
                        echo -en "\033[8D";
                        echo -en "\033[1B";

                        NUM_VIDS_PASS=$((NUM_VIDS_PASS+1));
                    else
                        echo -en "\033[1A";
                        echo -en "\a\033[1m\033[101m  FAIL  \033[0m";
                        echo -en "\033[8D";
                        echo -en "\033[1B";

                        NUM_VIDS_FAIL=$((NUM_VIDS_FAIL+1));
                        EXIT_CODE=1;
                    fi
                fi
            fi

            #
            # Fetch picture
            #
            IMAGE_PATH=$(echo $MEDIA | egrep -o '"display_url":"(.*?)"');
            IMAGE_PATH=$(echo $IMAGE_PATH | egrep -o '"http(s{0,1})://(.*?)"');
            IMAGE_PATH=$(echo $IMAGE_PATH | sed 's/\"//g');
            IMAGE_FILE=$(basename "$IMAGE_PATH" | cut -d'?' -f1);

            if [ ! -f $IMAGE_FILE ]
            then

                echo -en "\033[1m\033[43m  RUNS  \033[0m";
                echo -e  " \033[2m$USR/\033[0m$(basename "$IMAGE_FILE")\033[0m";

                EXEC=$(curl -s -L -o "$IMAGE_FILE" $IMAGE_PATH 2>&1);

                if [ -z "$EXEC" ]
                then
                    echo -en "\033[1A";
                    echo -en "\033[1m\033[42m  PASS  \033[0m";
                    echo -en "\033[8D";
                    echo -en "\033[1B";

                    NUM_PICS_PASS=$((NUM_PICS_PASS+1));
                else
                    echo -en "\033[1A";
                    echo -en "\a\033[1m\033[101m  FAIL  \033[0m";
                    echo -en "\033[8D";
                    echo -en "\033[1B";

                    NUM_PICS_FAIL=$((NUM_PICS_FAIL+1));
                    EXIT_CODE=1;
                fi
            fi
        done <<< "$RESPONSE";

        if [ $(($NUM_PICS_PASS + $NUM_PICS_FAIL + $NUM_VIDS_PASS + $NUM_VIDS_FAIL)) -eq 0 ]
        then
            echo -e "\033[1m\033[104m  Nothing new by $USR  \033[0m";
        fi
    fi

    cd - > /dev/null

    DURATION=$(($SECONDS - $TIMESTAMP_START));

    echo -e "";
    echo -e "\033[1mNumber of Pictures:\033[0m\t$NUM_PICS_PASS\033[2m/$(($NUM_PICS_PASS + $NUM_PICS_FAIL))\033[0m";
    echo -e "\033[1mNumber of Videos:\033[0m\t$NUM_VIDS_PASS\033[2m/$(($NUM_VIDS_PASS + $NUM_VIDS_FAIL))\033[0m";
    echo -e "\033[1mDuration:\033[0m\t\t$DURATION seconds";
    echo -e "";

else
    EXIT_CODE=1;
fi

exit $EXIT_CODE;