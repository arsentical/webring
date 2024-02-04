#!/usr/bin/env bash
function make_icon {
	magick convert icon104.png \
		\( -clone 0 -resize 16x16 \) \
		\( -clone 0 -resize 32x32 \) \
		\( -clone 0 -resize 48x48 \) \
		\( -clone 0 -resize 64x64 \) \
		-delete 0 -colors 256 ../favicon.ico
}

# as it turns out, i don't actually need this
# i'm keeping it, it's funny
function make_grid_gif {
	# for some fucking reason imagemagick doesn't like being given a *perfectly reasonable* list of images to composite into a gif
	# so instead we have to manufacture the images one-by-one
	DIR=$(mktemp -d)
	echo "$DIR"
	ARGS=()
	for i in {0..256}; do
		OUT=$(printf %s/%03d.png "$DIR" $i)
		magick grid-base.png -roll "-$i+$(($i / 2))" $OUT
		ARGS+=( $OUT )
		echo -ne "\r$i / 256"
	done
	echo
	echo "frames"
	magick convert -size 128x128 -delay 3 -loop 0 -dispose previous "${ARGS[@]}" -layers Optimize grid.gif
	rm -r $DIR
}

function make_grid {
	TRANS=0.05
	magick convert grid-base.png -fill black -colorize 100% -channel A -evaluate multiply $TRANS +channel ../grid-light.png
	magick convert grid-base.png -channel A -evaluate multiply $TRANS +channel ../grid-dark.png
	magick convert ../grid-light.png -crop 96x96+0+32 ../grid-light-small.png
	magick convert ../grid-dark.png -crop 96x96+0+32 ../grid-dark-small.png
}

function make_users {
	sed -e 's/\[\[user list\]\]/BALLS/g' -e 's/\[\[user text\]\]/AAAAA/g' index-template.html >../index.html
}

"$@"
