#!/bin/bash
GPX_ANI=GpxAnimator-1.3.1.jar
GPX_ANI=GpxAnimator-1.4.jar
GPX_ANI=GpxAnimator-1.4-SNAPSHOT.one-jar.jar
function animate() {
        # http://zdila.github.io/gpx-animator/
        rm -f CombineGPX_Segment.mp4
        java -jar $GPX_ANI \
		--input CombineGPX_Segment.gpx \
		--color "#15337f" \
		--forced-point-time-interval 500 \
		--label "Paul & Sally
Suzuki Bandit 1250" \
		--background-map-visibility 0.5 \
		--attribution "" \
		--margin 75 \
		--width 1024 \
		--height 768 \
		--gui \
		--output CombineGPX_Segment.mp4
        #open CombineGPX_Segment.mp4
}
PL=""
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for file in $(find MP4GPS -iname \*.gpx | sort)
do
	PL+="-f \"$file\" "
done
IFS=$SAVEIFS
echo "RUN THIS COMMAND and add wpt's and remove trksegs"
echo "gpsbabel -i gpx $PL -o gpx,gpxver=1.1 -F CombineGPX.gpx"
read
awk 'BEGIN{p=1}(/<\/trkseg>/){ p=0 }(p==1){print $0}(/<trkseg>/){p=1}END{print "</trkseg></trk></gpx>"}' CombineGPX.gpx > CombineGPX_Segment.gpx
animate
