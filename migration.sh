#!/bin/bash
file=$1
image_id=$2

# If the file exists it have to continue
if [ -f  $file ]; then
    # Get Name
    name=$(echo "$file" | cut -d "/" -f12)

    # Get user name 
    user=$(echo "$file" | cut -d "/" -f6)

    # Get Date files name
    year=$(echo "$file" | cut -d "/" -f8)
    month=$(echo "$file" | cut -d "/" -f9)
    day=$(echo "$file" | cut -d "/" -f10)
    hour=$(echo "$file" | cut -d "/" -f11)

    # Create dir to save the new file
    root="/var/www/html/photomanager"
    if [ ! -d "$root/migration" ]
    then
        cd $root
        mkdir migration
    fi
 
    # Create directory to save smartphones images
    if [ ! -d "$root/migration/smartphones" ]
    then
        cd $root/migration
        mkdir smartphones
    fi

    if [ ! -d "$root/migration/smartphones/$user" ]
    then
        cd $root/migration/smartphones
        mkdir $user
    fi

    if [ ! -d "$root/migration/smartphones/$user/$year" ]
    then
        cd $root/migration/smartphones/$user/
        mkdir $year
    fi

    if [ ! -d "$root/migration/smartphones/$user/$year/$month" ]
    then
        cd $root/migration/smartphones/$user/$year
        mkdir $month
    fi

    if [ ! -d "$root/migration/smartphones/$user/$year/$month/$day" ]
    then
        cd $root/migration/smartphones/$user/$year/$month
        mkdir $day
    fi

    if [ ! -d "$root/migration/smartphones/$user/$year/$month/$day/$hour" ]
    then
        cd $root/migration/smartphones/$user/$year/$month/$day
        mkdir $hour
    fi

    if [ -d "$root/migration/smartphones/$user/$year/$month/$day/$hour" ]
    then
        # copy image to new dir
        cp $file $root/migration/smartphones/$user/$year/$month/$day/$hour/$name
    fi

    # Create directory to save tablets images
    if [ ! -d "$root/migration/tablets" ]
    then
        cd $root/migration
        mkdir tablets
    fi

    if [ ! -d "$root/migration/tablets/$user" ]
    then
        cd $root/migration/tablets
        mkdir $user
    fi

    if [ ! -d "$root/migration/tablets/$user/$year" ]
    then
        cd $root/migration/tablets/$user/
        mkdir $year
    fi

    if [ ! -d "$root/migration/tablets/$user/$year/$month" ]
    then
        cd $root/migration/tablets/$user/$year
        mkdir $month
    fi

    if [ ! -d "$root/migration/tablets/$user/$year/$month/$day" ]
    then
        cd $root/migration/tablets/$user/$year/$month
        mkdir $day
    fi

    if [ ! -d "$root/migration/tablets/$user/$year/$month/$day/$hour" ]
    then
        cd $root/migration/tablets/$user/$year/$month/$day
        mkdir $hour
    fi

    if [ -d "$root/migration/tablets/$user/$year/$month/$day/$hour" ]
    then
        # copy image to new dir
        cp $file $root/migration/tablets/$user/$year/$month/$day/$hour/$name
    fi

    sleep 5

    if [ -f "$root/migration/smartphones/$user/$year/$month/$day/$hour/$name" ]
    then
        # Optimize image
        cd $root/migration/smartphones/$user/$year/$month/$day/$hour/
        sudo convert $name -quality 100 -resize 768 -strip -set comment "photomanager" $name
        
        # Know if the file was optimized
        comment=$(identify -verbose $name | grep 'comment: photomanager')
        comment=$(echo "$comment" | cut -d ":" -f2)
        comment=$(echo "${comment/ /}")

        if [ "$comment" == "photomanager" ]; then
            cd  /var/www/html/photomanager
            artisan=$(php artisan smartphoneImage:save $image_id "/photomanager/smartphones/$user/$year/$month/$day/$hour/$name" 2>&1)
        fi
    fi

    if [ -f "$root/migration/tablets/$user/$year/$month/$day/$hour/$name" ]
    then
        # Optimize image
        cd $root/migration/tablets/$user/$year/$month/$day/$hour/
        sudo convert $name -quality 100 -resize 1200 -strip -set comment "photomanager" $name
        
            # Know if the file was optimized
        comment=$(identify -verbose $name | grep 'comment: photomanager')
        comment=$(echo "$comment" | cut -d ":" -f2)
        comment=$(echo "${comment/ /}")

        if [ "$comment" == "photomanager" ]; then
            cd  /var/www/html/photomanager
            artisan=$(php artisan tabletImage:save $image_id "/photomanager/tablets/$user/$year/$month/$day/$hour/$name" 2>&1)
        fi
    fi

    echo $image_id
fi