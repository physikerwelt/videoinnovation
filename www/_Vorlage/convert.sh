#!/bin/bash

if [ "${1}" == "" ]; then
  echo "Missing file parameter"
  exit;
fi

infile="${1}"
outfile=$(echo "${infile}" | sed 's/\....$//i')
tmpfile="${outfile}_temporary.mp4"

outfile_hd="${outfile}_hd.mp4"
outfile_sd="${outfile}_sd.mp4"

# SD

options="-vcodec libx264 -b:v 500k -bt 650k -r 30 -flags +loop+mv4 -cmp 256 \
           -partitions +parti4x4+parti8x8+partp4x4+partp8x8+partb8x8 \
           -s 854x480 -aspect 16:9 \
           -me_method hex -subq 7 -trellis 1 -refs 5 -bf 3 \
           -flags2 +bpyramid+wpred+mixed_refs+dct8x8 -coder 1 -me_range 16 \
           -g 30 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -qmin 10\
           -qmax 51 -qdiff 4"

#ffmpeg -y -i "$infile" -an -pass 1 -threads 2 $options "$tmpfile"

ffmpeg -y -i "$infile" -acodec libfaac -ar 44100 -ab 64k -ac 1 -pass 2 -threads 2 $options "$tmpfile"

qt-faststart "$tmpfile" "$outfile_sd"

# HD

options="-vcodec libx264 -b:v 1000k -bt 1250k -r 30 -flags +loop+mv4 -cmp 256 \
           -partitions +parti4x4+parti8x8+partp4x4+partp8x8+partb8x8 \
           -me_method hex -subq 7 -trellis 1 -refs 5 -bf 3 \
           -flags2 +bpyramid+wpred+mixed_refs+dct8x8 -coder 1 -me_range 16 \
           -g 30 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -qmin 10\
           -qmax 51 -qdiff 4"

#ffmpeg -y -i "$infile" -an -pass 1 -threads 2 $options "$tmpfile"

ffmpeg -y -i "$infile" -acodec libfaac -ar 44100 -ab 96k -ac 1 -pass 2 -threads 2 $options "$tmpfile"

qt-faststart "${tmpfile}" "${outfile_hd}"

rm -f "${tmpfile}"
