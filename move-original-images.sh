#!/bin/bash
inotifywait -m -r -e close_write /home | while read line;
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
            # If the file exists it have to continue
            if [ -f  $file ]
            then
                # Get Name
                name=$(identify -verbose $file | grep "Image:")
                name=$(echo "$name" | cut -d " " -f2)
                name=$(echo $file | rev | cut -d "/" -f1 | rev)

                # Get user name
                user=$(echo "$file" | cut -d "/" -f3)

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
done
