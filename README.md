# edit4kvideo
研究室用のBASHコード

研究室でとった4Kビデオを処理するための BASH スクリプトです。ffmpeg を使っています。

## 使い方

First assign the output folder. There should be no spaces around the equal sign.
Then assign the file to the video that needs to be processed.

`OUTPUTFOLDER="Data_Out/"`

`INFILE="./Data/DJI_0005.MOV"`

To split the video into quarters, run the splitvideo function.
The start time and stop time are in hh:mm:ss.

`splitvideo "00:00:10" "00:00:20"`

To reduce the video into full hd, run the reduce2fullhd function.
The start time and stop time are in hh:mm:ss.
`reduce2fullhd "00:00:10" "00:00:20"`

If you want to split or reduce the entire video, then run the function without the times.

To run the function on another file, just change thine INFILE parameter.
