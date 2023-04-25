#!/usr/bin/env fish
#
# Download image from NASA Astronomy Picture of the Day (APOD) service
# and set it as wallpaper.

function download_apod_as_wallpaper
    set -l DOWNLOAD_DIR $HOME"/Downloads/apod"
    set -l API_URL "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY"

    # Set the most recent image as wallpaper on start in order to not
    # use black as wallpaper before downloading fished.
    feh --bg-fill (ls $DOWNLOAD_DIR/* -dt | head -n1)

    mkdir -p $DOWNLOAD_DIR

    echo "Fetching meta info from "$API_URL
    set -l response (curl --retry 3 --retry-delay 5 -L $API_URL 2>/dev/null)
    set -l image_url (echo $response | jq -r .hdurl)
    set -l image_description (echo $response | jq -r .explanation)
    set -l image_title (echo $response | jq -r .title)
    set -l image_name (basename $image_url)
    set -l image_save_path $DOWNLOAD_DIR/$image_name

    if not test -e $image_save_path
        echo "Downloading image from "$image_url" to "$image_save_path

        set -l temp_path "/tmp/apod.tmp"
        env all_proxy=http://127.0.0.1:1080 \
            curl --retry 6 --retry-delay 5 \
            -L $image_url \
            -o $temp_path \
            2>/dev/null
        or return

        mv $temp_path $image_save_path

        notify-send --expire-time=5000 "Wallpaper Downloaded" $image_title
    else
        echo "Image "$image_save_path" exists, downloading skipped"
    end

    feh --bg-fill $image_save_path 
end

while true
    download_apod_as_wallpaper
    sleep (math '60 * 60 * 7')  # check every 7 hours
end
