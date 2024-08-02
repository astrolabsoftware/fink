#!/bin/bash

filenames=`ls *.png`

for filename in $filenames; do
  filename_alt="${filename/.png/"-alt.png"}"
  
  # negate
  convert $filename -channel RGB -negate $filename_alt

  # change background in-place
  convert $filename_alt -transparent black -background "rgba(30,33,41,255)" -fuzz 0% $filename_alt
done
