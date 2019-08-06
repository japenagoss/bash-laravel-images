#!/bin/bash
while IFS= read -r file
do
    # Get user name
    user=$(echo "$file" | cut -d "/" -f3)

    # If the file exists it have to continue
    if [ -f  $file ]
    then
        # Get Name
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

        #echo "$year-$month-$day $hour:$minute:$second"

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
                # copye image to new dir
                cp $file /photomanager/$user/optimized/$year/$month/$day/$hour/$name
            fi

            if [ -f "/photomanager/$user/optimized/$year/$month/$day/$hour/$name" ]
            then
                # Optimize final image
                cd /photomanager/$user/optimized/$year/$month/$day/$hour/
                sudo convert $name -quality 70 -resize 3000 -strip -set comment "photomanager" $name

                # Know if the file was optimized
                comment=$(identify -verbose $name | grep 'comment: photomanager')
                comment=$(echo "$comment" | cut -d ":" -f2)
                comment=$(echo "${comment/ /}")

                if [ "$comment" == "photomanager" ]; then
                    cd  /var/www/html/photomanager
                    #file=$(echo $file | rev | cut -d "/" -f1 | rev)
                    finalDate="$year-$month-$day $hour:$minute:$second"
                    artisan=$(php artisan image:save $user "/photomanager/$user/optimized/$year/$month/$day/$hour/$name" "/photomanager/originals/$user/$name" "$finalDate" 2>&1)

                    if [ "$artisan" == "1" ]; then
                        sed -i "/$name/d" /photomanager/photomanager.log
                        if [ ! -d "/photomanager/originals/$user" ]; then
                            cd /photomanager/originals
                            mkdir $user
                            sudo mv /home/$user/$name /photomanager/originals/$user/$name
                        else
                            sudo mv /home/$user/$name /photomanager/originals/$user/$name
                        fi
                    fi
                fi
            fi
        fi
    fi

done < "/photomanager/photomanager.log"
