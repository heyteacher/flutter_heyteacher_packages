#!/bin/bash
#
# ffmpeg commands.
#
#!/bin/bash

# print usage
usage() {
    echo "Usage:"
    echo "    ffmpeg_cmd.sh crop <input_video> <output_video> <width_in_px> <height_in_px> <x_in_px> <y_in_px>"
    echo "    ffmpeg_cmd.sh cut  <input_video> <output_video> <start_in_sec> <end_in_sec>"
    echo "    ffmpeg_cmd.sh extract <input_video> <output_video> <start_in_sec> <end_in_sec>"
    echo "    ffmpeg_cmd.sh concat <input_video_1> <input_video_2> [input_video_3 ...] <output_video> <fade_duration_in_sec> "
}

# cut an interval from video from start to end
cut() {
    local input_video=$2
    local output_video=$3
    local start_in_secs=$4
    local end_in_secs=$5
    echo ""
    echo "cut $input_video > output_video $output_video (start: ${start_in_secs}s, end: ${end_in_secs}s)"
    echo ""
    ffmpeg -v quiet -i $input_video  \
      -vf "select='not(between(t,$start_in_secs,$end_in_secs))'" \
      -af "select='not(between(t,$start_in_secs,$end_in_secs))'" \
       $output_video
}

# crop video using width, height, x, y specified
crop() {
    local input_video=$2
    local output_video=$3
    local width_in_px=$4
    local height_in_px=$5
    local x_in_px=$6
    local y_in_px=$7
    echo ""
    echo "crop $input_video > $output_video (w: ${width_in_px}px h: ${height_in_px}px x: ${x_in_px}px y: ${y_in_px}px)"
    echo ""
    ffmpeg -v quiet -i $input_video  \
      -filter:v "crop=$width_in_px:$height_in_px:$x_in_px:$y_in_px" \
      $output_video
}

# extract an interval from video from start to end
extract() {
    local input_video=$2
    local output_video=$3
    local start_in_secs=$4
    local end_in_secs=$5
    echo ""
    echo "extract $input_video > $output_video (start: ${start_in_secs}s, end: ${end_in_secs}s)"
    echo ""
    ffmpeg -v quiet -i $input_video  \
       -vf "select='between(t,$start_in_secs,$end_in_secs)'" \
       -af "select='between(t,$start_in_secs,$end_in_secs)'" \
       $output_video
}

# concat videos into one applying fade bkack transition between them
concat() {
    local input_video_1=$2
    local input_video_2=$3
    local output_video=$4
    local fade_duration_in_sec=$5
    echo ""
    echo "concat $input_video_1 + $input_video_2 > $output_video (fade_duration: ${fade_duration_in_sec}s)"
    echo ""

    # Source - https://stackoverflow.com/a/22243834
    # Posted by Ivan Neeson, modified by community. See post 'Timeline' for change history
    # Retrieved 2025-11-06, License - CC BY-SA 3.0
    local fps_input_video_1=$(ffprobe -v quiet -i $input_video_1 -show_entries stream=r_frame_rate -of csv="p=0")
    local fps_input_video_2=$(ffprobe -v quiet -i $input_video_2 -show_entries stream=r_frame_rate -of csv="p=0") 
    local duration_input_video_1=$(ffprobe -v quiet -i $input_video_1 -show_entries format=duration -of csv="p=0")
    # Source - https://stackoverflow.com/a/29696267
    # Posted by Brijesh Valera
    # Retrieved 2025-11-06, License - CC BY-SA 3.0
    duration_input_video_1=${duration_input_video_1%.*}
    # start fade transition fade duration seconds before the end of first videos
    local offset=$(($duration_input_video_1 - $fade_duration_in_sec))
    
    ffmpeg -v quiet -r $fps_input_video_1 -i $input_video_1 \
    -r $fps_input_video_2 -i $input_video_2 \
    -filter_complex xfade=transition=fadeblack:duration=$fade_duration_in_sec:offset=$offset \
    $output_video
}

# which commands execution
case "${@: 1:1}" in
    "cut") cut "$@";;
    "crop") crop "$@";;
    "extract") extract "$@";;
    "concat") concat "$@";;
    "") usage "$@";;
    *) echo "";echo "invalid command ${@: 1}";echo "";usage "$@";;
esac
