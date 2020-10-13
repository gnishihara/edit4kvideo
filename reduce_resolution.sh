#!bin/bash
# Note:
# This is not an R script. It is a BASH script.
# Rのスクリプトじゃないです。BASHスクリプトです。

split_with_time () {
  if [[ $# > 2 ]] || [[ $# = 1 ]]; then echo "Usage reduce2fullhd start stop."; return 1; fi
  if [[ ! "$1" =~ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then echo "Start time should look like 00:00:00"; return 1; fi
  if [[ ! "$2" =~ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then echo "End time should look like 00:00:10"; return 1; fi
  STARTTIME="${1//:/\\:}"
  STOPTIME="${2//:/\\:}"

  CHECK=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name \
          -of default=nokey=1:noprint_wrappers=1 "$INFILE")
  if [[ "${CHECK#*}" > 0 ]]; then
    ffmpeg \
      -i "$INFILE" \
      -filter_complex "[0:v]trim='${STARTTIME}':'${STOPTIME}',setpts=PTS-STARTPTS[vout];
                      [0:a]atrim='${STARTTIME}':'${STOPTIME}',asetpts=PTS-STARTPTS[aout];
                      [vout]split=4[v1][v2][v3][v4];
                      [aout]asplit=4[a1][a2][a3][a4];
                      [v1]crop=iw/2:ih/2:0:0[tl];
                      [v2]crop=iw/2:ih/2:ow:0[tr];
                      [v3]crop=iw/2:ih/2:0:oh[bl];
                      [v4]crop=iw/2:ih/2:ow:oh[br]" \
       -c:v libx265 \
       -c:a libfdk_aac \
       -crf 18 \
       -preset medium \
      -map [tl] -map [a1] ./"${OUTPUTFOLDER}""${FTL##*/}" \
      -map [tr] -map [a2] ./"${OUTPUTFOLDER}""${FTR##*/}" \
      -map [bl] -map [a3] ./"${OUTPUTFOLDER}""${FBL##*/}" \
      -map [br] -map [a4] ./"${OUTPUTFOLDER}""${FBR##*/}" -y
  else
    ffmpeg \
      -i "$INFILE" \
      -filter_complex "[0:v]trim='${STARTTIME}':'${STOPTIME}',setpts=PTS-STARTPTS[vout];
                      [vout]split=4[v1][v2][v3][v4];
                      [v1]crop=iw/2:ih/2:0:0[tl];
                      [v2]crop=iw/2:ih/2:ow:0[tr];
                      [v3]crop=iw/2:ih/2:0:oh[bl];
                      [v4]crop=iw/2:ih/2:ow:oh[br]" \
       -c:v libx265 \
       -c:a libfdk_aac \
       -crf 18 \
       -preset medium \
      -map [tl] ./"${OUTPUTFOLDER}""${FTL##*/}" \
      -map [tr] ./"${OUTPUTFOLDER}""${FTR##*/}" \
      -map [bl] ./"${OUTPUTFOLDER}""${FBL##*/}" \
      -map [br] ./"${OUTPUTFOLDER}""${FBR##*/}" -y
  fi
}

split_no_time () {
  CHECK=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name \
          -of default=nokey=1:noprint_wrappers=1 "$INFILE")
  if [[ "${CHECK#*}" > 0 ]]; then
    ffmpeg \
    -i "$INFILE" \
    -filter_complex "[0:v]split=4[v1][v2][v3][v4];
                     [0:a]asplit=4[a1][a2][a3][a4];
                     [v1]crop=iw/2:ih/2:0:0[tl];
                     [v2]crop=iw/2:ih/2:ow:0[tr];
                     [v3]crop=iw/2:ih/2:0:oh[bl];
                     [v4]crop=iw/2:ih/2:ow:oh[br]" \
     -c:v libx265 \
     -c:a libfdk_aac \
     -crf 18 \
     -preset medium \
    -map [tl] -map [a1] ./"${OUTPUTFOLDER}""${FTL##*/}" \
    -map [tr] -map [a2] ./"${OUTPUTFOLDER}""${FTR##*/}" \
    -map [bl] -map [a3] ./"${OUTPUTFOLDER}""${FBL##*/}" \
    -map [br] -map [a4] ./"${OUTPUTFOLDER}""${FBR##*/}" -y
  else
    ffmpeg \
    -i "$INFILE" \
    -filter_complex "[0:v]split=4[v1][v2][v3][v4];
                     [v1]crop=iw/2:ih/2:0:0[tl];
                     [v2]crop=iw/2:ih/2:ow:0[tr];
                     [v3]crop=iw/2:ih/2:0:oh[bl];
                     [v4]crop=iw/2:ih/2:ow:oh[br]" \
     -c:v libx265 \
     -c:a libfdk_aac \
     -crf 18 \
     -preset medium \
    -map [tl] ./"${OUTPUTFOLDER}""${FTL##*/}" \
    -map [tr] ./"${OUTPUTFOLDER}""${FTR##*/}" \
    -map [bl] ./"${OUTPUTFOLDER}""${FBL##*/}" \
    -map [br] ./"${OUTPUTFOLDER}""${FBR##*/}" -y
  fi
}

splitvideo () {
  # This function is used to split the video into four quadrants.
  # The resolution of the video is preserved, so each video will be 1/4 the
  # size of the 4K video. The output is fullhd 1920 x 1080.
  if [ ! -d ${OUTPUTFOLDER} ]; then
    mkdir "${OUTPUTFOLDER}"
  fi
  FTL="${INFILE%.*}"_tl.mkv
  FTR="${INFILE%.*}"_tr.mkv
  FBL="${INFILE%.*}"_bl.mkv
  FBR="${INFILE%.*}"_br.mkv

  if [[ ${#*} == 0 ]]; then split_no_time; fi
  if [[ ${#*} == 2 ]]; then split_with_time $1 $2; fi

}

reduce2fullhd () {
  # This function will reduce the video to fullhd (1920x1080).
  # Start and stop times can be passed to cut the video.
  if [ ! -d ${OUTPUTFOLDER} ]; then mkdir "${OUTPUTFOLDER}"; fi
  if [[ $# > 2 ]] || [[ $# = 1 ]]; then echo "Usage reduce2fullhd start stop."; return 1; fi
  if [[ ! "$1" =~ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then echo "Start time should look like 00:00:00"; return 1; fi
  if [[ ! "$2" =~ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then echo "End time should look like 00:00:10"; return 1; fi


  OUTFILE="${INFILE%.*}"_1080.mkv
  if [[ $#* < 2 ]];then
    # If the time stamps are not given, then reduce the entire video.
    ffmpeg -i "${INFILE}" \
      -c:v libx265 -c:a copy -crf 18 -preset medium -vf scale=1920:1080 \
      ./"${OUTPUTFOLDER}""${OUTFILE##*/}" -y
  else
    # If the time stamps are given, then reduce only the specified duration.
    ffmpeg -ss ${1} -i "${INFILE}" -to ${2} \
      -c:v libx265 -c:a copy -crf 18 -preset medium -vf scale=1920:1080 \
      ./"${OUTPUTFOLDER}""${OUTFILE##*/}" -y
  fi
}

################################################################################
# First assign the output folder. There should be no spaces around the equal sign.
# Then assign the file to the video that needs to be processed.
OUTPUTFOLDER="Data_Out/"
INFILE="./Data/DJI_0005.MOV"

# To split the video into quarters, run the splitvideo function.
# The start time and stop time are in hh:mm:ss.
splitvideo "00:00:10" "00:00:20"

# To reduce the video into full hd, run the reduce2fullhd function.
# The start time and stop time are in hh:mm:ss.
reduce2fullhd "00:00:10" "00:00:20"

# If you want to split or reduce the entire video, then run the function without
# the times.

# To run the function on another file, just change thine INFILE parameter.