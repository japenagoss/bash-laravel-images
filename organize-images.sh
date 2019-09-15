#!/bin/bash
inotifywait -m -r -e move /photomanager/originals | while read line;
do
    if ! echo "$line" | grep -q 'ISDIR'; then
        # line = /home/user/dir CREATE file.ext

        # Get file name
        dire=$(echo "$line" | cut -d " " -f1)
        file=$(echo "$line" | cut -d " " -f3)
        file=$dire$file
        ext="${file##*.}"

        if [ "$ext" == "JPG" ] || [ "$ext" == "PNG" ] || [ "$ext" == "jpg" ] || [ "$ext" == "png" ] || [ "$ext" == "JPEG" ] || [ "$ext" == "jpeg" ]
        then
            # Get user name
            user=$(echo "$file" | cut -d "/" -f4)

            # If the file exists it have to continue
            if [ -f  $file ]
            then
                # # Get Name
                name=$(identify -verbose $file | grep "Image:")
                name=$(echo "$name" | cut -d " " -f2)
                name=$(echo $file | rev | cut -d "/" -f1 | rev)

                # Get Date
                date=$(echo "$name" | cut -d "." -f1)
                year=$(echo ${date:0:4})
                month=$(echo ${date:4:2})
                day=$(echo ${date:6:2})
                hour=$(echo ${date:8:2})
                minute=$(echo ${date:10:2})
                second=$(echo ${date:12:2})

                timestamp=$(date "+%s" -d "$month/$day/$year $hour:$minute:$second" 2>&1)

                re='^[0-9]+$'
                if [[ $timestamp =~ $re ]] ; then
                    # Create dir to save the new file
                    if [ ! -d "/photomanager" ]
                    then
                        cd /home
                        mkdir photomanager
                    fi

                    if [ ! -d "/photomanager/$user" ]
                    then
                        cd /photomanager
                        mkdir $user
                    fi

                    if [ ! -d "/photomanager/$user/optimized" ]
                    then
                        cd /photomanager/$user
                        mkdir optimized
                    fi

                    if [ ! -d "/photomanager/$user/optimized/$year" ]
                    then
                        cd /photomanager/$user/optimized
                        mkdir $year
                    fi

                    if [ ! -d "/photomanager/$user/optimized/$year/$month" ]
                    then
                        cd /photomanager/$user/optimized/$year
                        mkdir $month
                    fi

                   if [ ! -d "/photomanager/$user/optimized/$year/$month/$day" ]
                   then
                        cd /photomanager/$user/optimized/$year/$month
                        mkdir $day
                   fi

                    if [ ! -d "/photomanager/$user/optimized/$year/$month/$day/$hour" ]
                    then
                        cd /photomanager/$user/optimized/$year/$month/$day
                        mkdir $hour
                    fi

                    if [ -d "/photomanager/$user/optimized/$year/$month/$day/$hour" ]
                    then
                        # copy image to new dir
                        cp $file /photomanager/$user/optimized/$year/$month/$day/$hour/$name
                    fi

                     # # Create dir to save the new file (tablet)
                    # # ---------------------------------------------------------------
                    if [ ! -d "/photomanager/tablets" ]
                    then
                        cd /photomanager
                        mkdir tablets
                    fi

                    if [ ! -d "/photomanager/tablets/$user" ]
                    then
                        cd /photomanager/tablets
                        mkdir $user
                    fi

                    if [ ! -d "/photomanager/tablets/$user/$year" ]
                    then
                        cd /photomanager/tablets/$user/
                        mkdir $year
                    fi

                    if [ ! -d "/photomanager/tablets/$user/$year/$month" ]
                    then
                        cd /photomanager/tablets/$user/$year
                        mkdir $month
                    fi

                    if [ ! -d "/photomanager/tablets/$user/$year/$month/$day" ]
                    then
                        cd /photomanager/tablets/$user/$year/$month
                        mkdir $day
                    fi

                    if [ ! -d "/photomanager/tablets/$user/$year/$month/$day/$hour" ]
                    then
                        cd /photomanager/tablets/$user/$year/$month/$day
                        mkdir $hour
                    fi

                    if [ -d "/photomanager/tablets/$user/$year/$month/$day/$hour" ]
                    then
                        # copy image to new dir
                        cp $file /photomanager/tablets/$user/$year/$month/$day/$hour/$name
                    fi

                    # Create dir to save the new file (phones)
                    # ---------------------------------------------------------------
                    if [ ! -d "/photomanager/smartphones" ]
                    then
                        cd /photomanager
                        mkdir smartphones
                    fi
                    
                    if [ ! -d "/photomanager/smartphones/$user" ]
                    then
                        cd /photomanager/smartphones
                        mkdir $user
                    fi

                    if [ ! -d "/photomanager/smartphones/$user/$year" ]
                    then
                        cd /photomanager/smartphones/$user/
                        mkdir $year
                    fi

                    if [ ! -d "/photomanager/smartphones/$user/$year/$month" ]
                    then
                        cd /photomanager/smartphones/$user/$year
                        mkdir $month
                    fi

                    if [ ! -d "/photomanager/smartphones/$user/$year/$month/$day" ]
                    then
                        cd /photomanager/smartphones/$user/$year/$month
                        mkdir $day
                    fi

                    if [ ! -d "/photomanager/smartphones/$user/$year/$month/$day/$hour" ]
                    then
                        cd /photomanager/smartphones/$user/$year/$month/$day
                        mkdir $hour
                    fi

                    if [ -d "/photomanager/smartphones/$user/$year/$month/$day/$hour" ]
                    then
                        # copy image to new dir
                        cp $file /photomanager/smartphones/$user/$year/$month/$day/$hour/$name
                    fi
                fi
            fi
        fi
    fi
done
