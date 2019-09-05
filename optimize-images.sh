#!/bin/bash
inotifywait -m -r -e close_write /photomanager | while read line;
do
    if ! echo "$line" | grep -q 'ISDIR'; then

        # Get file name
        dire=$(echo "$line" | cut -d " " -f1)
        file=$(echo "$line" | cut -d " " -f3)
        file=$dire$file

        type=$(echo "$file" | cut -d "/" -f3)
        number='^[0-9]+$'
        
        if [[ "$type" =~ $number || "$type" == "tablets" || "$type" == "smartphones" ]] ; then
            # Know if the file was optimized
            comment=$(identify -verbose $file | grep 'comment: photomanager')
            comment=$(echo "$comment" | cut -d ":" -f2)
            comment=$(echo "${comment/ /}")
            if [ "$comment" != "photomanager" ]; then

                # Get name
                name=$(identify -verbose $file | grep "Image:")
                name=$(echo "$name" | cut -d " " -f2)
                name=$(echo $file | rev | cut -d "/" -f1 | rev)

                # Get user name
                user=""
                if [[ $file == *"optimized"* ]]; then
                    user=$(echo "$file" | cut -d "/" -f3)
                fi

                if [[ $file == *"tablets"* ]]; then
                    user=$(echo "$file" | cut -d "/" -f4)
                fi

                if [[ $file == *"smartphones"* ]]; then
                    user=$(echo "$file" | cut -d "/" -f4)
                fi
                
                # optimize images for PC desktops
                if [[ $file == *"optimized"* ]]; then
                    sudo convert $file -quality 70 -resize 3000 -strip -set comment "photomanager" $file
                    cd  /var/www/html/photomanager

                    date=$(echo "$name" | cut -d "." -f1)
                    year=$(echo ${date:0:4})
                    month=$(echo ${date:4:2})
                    day=$(echo ${date:6:2})
                    hour=$(echo ${date:8:2})
                    minute=$(echo ${date:10:2})
                    second=$(echo ${date:12:2})
                    finalDate="$year-$month-$day $hour:$minute:$second"

                    # save image in database
                    image_id=$(php artisan image:save $user "/photomanager/$user/optimized/$year/$month/$day/$hour/$name" "/photomanager/originals/$user/$name" "$finalDate" 2>&1)
                    tablet=$(php artisan tabletImage:save $image_id "/photomanager/tablets/$user/$year/$month/$day/$hour/$name" 2>&1)
                    smartphones=$(php artisan smartphoneImage:save $image_id "/photomanager/smartphones/$user/$year/$month/$day/$hour/$name" 2>&1)
                fi

                # optimize images for tablets
                if [[ $file == *"tablets"* ]]; then
                    sudo convert $file -quality 70 -resize 1200 -strip -set comment "photomanager" $file                 
                fi

                # optimize images for smartphones
                if [[ $file == *"smartphones"* ]]; then
                    sudo convert $file -quality 70 -resize 768 -strip -set comment "photomanager" $file
                    cd  /var/www/html/photomanager
                fi
            fi
        fi
    fi
done