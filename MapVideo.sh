GPX_ANI=GpxAnimator-1.4-SNAPSHOT.one-jar.jar
function animate() {
        # http://zdila.github.io/gpx-animator/
        java -jar ${GPX_ANI} \
		--input  MP4GPS/${NAME}.gpx \
		--color "#15337f" \
		--forced-point-time-interval 1000 \
		--label "Paul & Sally Suzuki Bandit 1250" \
		--background-map-visibility 0.5 \
		--attribution "" \
		--width 640 \
		--height 360 \
		--font-size 10 \
		--tail-duration 0 \
		--total-time $LEN \
		--margin 5 \
		--gui \
		--output MP4GPS/${NAME}_gps.mp4
		#--speedup 1 \
		#--skip-idle false \
}

function overlay() {
	ffmpeg -y \
    		-i  MP4GPS/$NAME.mp4 -i MP4GPS/${NAME}_gps.mp4 \
    		-filter_complex " \
        		[0:v]setpts=PTS-STARTPTS[top]; \
        		[1:v]setpts=PTS-STARTPTS, \
             			format=yuva420p,colorchannelmixer=aa=0.8[bottom]; \
        		[top][bottom]overlay=0:720" \
    		MP4GPS/${NAME}_Overlay.mp4
}

for NMEA in $(ls MP4GPS/*.nmea)
do
	NAME=$(basename $NMEA | sed 's/\.[^.]*$//')
	LEN=$(ffprobe -hide_banner -v quiet -show_streams -print_format flat MP4GPS/$NAME.mp4 | grep "0.duration=" | awk -F\" '{print $2*1000}')
	echo "Processing $NAME -> $LEN"
	animate
	overlay
done
