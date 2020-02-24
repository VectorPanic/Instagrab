#!/bin/bash

clear;

EXIT_CODE=0;

C='cache.log';
D='users/%U%';
N='%N%';
U='henkelunchar';

print_usage() {
  echo "usage: Instagrab [-c] [-d] [-h] [-n] [-u]"
  echo " "
  echo "options:"
  echo "-c, Cache file"
  echo "-d, Destination path"
  echo "-h, Help"
  echo "-n, Filename"
  echo "-u, User"
  echo " "
  exit 0
}

while getopts 'c:d:h:n:u:' flag; do
  case "${flag}" in
    c) C="${OPTARG}" ;;
    d) D="${OPTARG}" ;;
    h) print_usage ;;
    n) N="${OPTARG}" ;;
    u) U="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

echo "";
echo -e "\033[1m[ INSTAGRAB ]\033[0m\033[2m[ Grab content from Instagram ] 2.0.0\033[0m";
echo "";

if [ $EXIT_CODE == 0 ] || [ command -v curl >/dev/null 2>&1 ];
then

    TIMESTAMP_START=$SECONDS;

    NUM_PICS_PASS=0;
    NUM_PICS_FAIL=0;
    NUM_VIDS_PASS=0;
    NUM_VIDS_FAIL=0;

    echo -e "Looking for new content of \033[1m$U\033[0m, please wait...";
    echo "";

    D=$(echo $D | sed "s/%U%/$U/g");
    C=$(echo $C | sed "s/%U%/$U/g");

    mkdir -p "$D";
    cd "$D";
    touch "$C";

    RESPONSE=$(curl -s "https://www.instagram.com/$U/?__a=1" 2>/dev/null);
    RESPONSE=$(echo $RESPONSE | grep -E -o '"shortcode":"(.*?)"');
    RESPONSE=$(echo $RESPONSE | grep -E -o '".*"');
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
            MEDIA=$(curl -s "https://www.instagram.com/p/$SHORT/?__a=1" 2>/dev/null);
            if [[ $MEDIA =~ '"is_video":true,"' ]]
            then

                VIDEO_PATH=$(echo $MEDIA | sed -e 's/.*video_url":"//g' -e 's/".*//g');
                VIDEO_FILE=$(basename "$VIDEO_PATH" | cut -d'?' -f1);

                if ! grep -q "^$VIDEO_FILE" "$C";
                then

                    echo -en "\033[1m\033[43m  RUNS  \033[0m";
                    echo -e  " \033[2m$SRC/\033[0m$(basename "$VIDEO_FILE")\033[0m";

                    #
                    # Avoid stress (sleep between 1 - 5 seconds)
                    #
                    sleep $(( $RANDOM % 5 + 1 ));

                    VIDEO_FILE_NAME=$(echo $N | sed "s/%N%/$VIDEO_FILE/g");
                    VIDEO_FILE_NAME=$(echo $VIDEO_FILE_NAME | sed "s/%U%/$U/g");

                    if curl -sLf -o "$VIDEO_FILE_NAME" "$VIDEO_PATH" 2>/dev/null;
                    then
                        echo -en "\033[1A";
                        echo -en "\033[1m\033[42m  PASS  \033[0m";
                        echo -en "\033[8D";
                        echo -en "\033[1B";

                        echo "$VIDEO_FILE" >> "$C";

                        NUM_VIDS_PASS=$((NUM_VIDS_PASS+1));
                    else
                        echo -en "\033[1A";
                        echo -en "\a\033[1m\033[101m  FAIL  \033[0m";
                        echo -en "\033[8D";
                        echo -en "\033[1B";

                        echo "$VIDEO_PATH" >> ./error.log; #TODO: ...

                        NUM_VIDS_FAIL=$((NUM_VIDS_FAIL+1));
                        EXIT_CODE=1;
                    fi
                fi
            fi

            #
            # Fetch pictures
            #
            IMAGE_PATHS=$(echo $MEDIA | grep -E -o '"display_url":"(.*?)"');
            IMAGE_PATHS=$(echo $IMAGE_PATHS | grep -E -o '"http(s{0,1})://(.*?)"');
            IMAGE_PATHS=$(echo $IMAGE_PATHS | sed 's/\"//g');

            for IMAGE_PATH in $IMAGE_PATHS
            do
                IMAGE_FILE=$(basename "$IMAGE_PATH" | cut -d'?' -f1);

                if ! grep -q "^$IMAGE_FILE" "$C";
                then

                    echo -en "\033[1m\033[43m  RUNS  \033[0m";
                    echo -e  " \033[2m$SRC/\033[0m$(basename "$IMAGE_FILE")\033[0m";

                    #
                    # Avoid stress (sleep between 1 - 5 seconds)
                    #
                    sleep $(( $RANDOM % 5 + 1 ));

                    IMAGE_FILE_NAME=$(echo $N | sed "s/%N%/$IMAGE_FILE/g");
                    IMAGE_FILE_NAME=$(echo $IMAGE_FILE_NAME | sed "s/%U%/$U/g");
                    
                    if curl -sLf -o "$IMAGE_FILE_NAME" "$IMAGE_PATH" 2>/dev/null;
                    then
                        echo -en "\033[1A";
                        echo -en "\033[1m\033[42m  PASS  \033[0m";
                        echo -en "\033[8D";
                        echo -en "\033[1B";

                        echo "$IMAGE_FILE" >> "$C";

                        NUM_PICS_PASS=$((NUM_PICS_PASS+1));
                    else
                        echo -en "\033[1A";
                        echo -en "\a\033[1m\033[101m  FAIL  \033[0m";
                        echo -en "\033[8D";
                        echo -en "\033[1B";

                        echo "$IMAGE_PATH" >> ./error.log; #TODO: ...

                        NUM_PICS_FAIL=$((NUM_PICS_FAIL+1));
                        EXIT_CODE=1;
                    fi
                fi
            done
        done <<< "$RESPONSE";

        if [ $(($NUM_PICS_PASS + $NUM_PICS_FAIL + $NUM_VIDS_PASS + $NUM_VIDS_FAIL)) -eq 0 ]
        then
            echo -e "\033[1m\033[104m  Nothing new by $U  \033[0m";
        fi

        cd - > /dev/null

        DURATION=$(($SECONDS - $TIMESTAMP_START));

        echo -e "";
        echo -e "\033[1mNumber of Pictures:\033[0m\t$NUM_PICS_PASS\033[2m/$(($NUM_PICS_PASS + $NUM_PICS_FAIL))\033[0m";
        echo -e "\033[1mNumber of Videos:\033[0m\t$NUM_VIDS_PASS\033[2m/$(($NUM_VIDS_PASS + $NUM_VIDS_FAIL))\033[0m";
        echo -e "\033[1mDuration:\033[0m\t\t$DURATION seconds";
        echo -e "";
    fi
fi

exit $EXIT_CODE;