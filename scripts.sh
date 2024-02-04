#!/usr/bin/env bash

# construct the favicon
# requires manually creating icon104.png by resizing icon.svg in kolourpaint
function make_icon {
	magick convert icon104.png \
		\( -clone 0 -resize 16x16 \) \
		\( -clone 0 -resize 32x32 \) \
		\( -clone 0 -resize 48x48 \) \
		\( -clone 0 -resize 64x64 \) \
		-delete 0 -colors 256 docs/favicon.ico
}

# as it turns out, i don't actually need this
# i'm keeping it, it's funny
function make_grid_gif {
	# for some fucking reason imagemagick doesn't like being given a *perfectly reasonable* list of images to composite into a gif
	# so instead we have to manufacture the images one-by-one
	DIR=$(mktemp -d)
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

# actual grid making
function make_grid {
	TRANS=0.05
	magick convert grid-base.png -fill black -colorize 100% -channel A -evaluate multiply $TRANS +channel docs/grid-light.png
	magick convert grid-base.png -channel A -evaluate multiply $TRANS +channel docs/grid-dark.png
	magick convert docs/grid-light.png -crop 96x96+0+32 docs/grid-light-small.png
	magick convert docs/grid-dark.png -crop 96x96+0+32 docs/grid-dark-small.png
}

# updates index.html and users.html
function make_users {
	cat users.md | perl make_users.pl
}

"$@"
