#!/usr/bin/env python

# run like:
# /generate_video_thumbnails_standalone.py video.mp4 cutmax

import sys
import os
import subprocess
import json
from pathlib import Path

# setup input file, output file naming conventions
ifile = sys.argv[1];
cpfile = sys.argv[2];

filename = Path(ifile);
filenamebase = os.path.splitext(filename)[0]
ofnamebase = os.path.basename(filenamebase)
print("input data file: ", ifile)
print("input control points file: ", cpfile)
print("ofilenamebase: ", ofnamebase)

#imgformat = "png"
imgformat = "webp"


# Find duration of input video file in milliseconds
def video_duration(ivideo):
    dur=0;
    if os.path.exists(ivideo):
        result = subprocess.run(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'default=noprint_wrappers=1:nokey=1', ivideo], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        dur = float(result.stdout)
    else:
        dur = float(0)
    return dur * 1000;

durms=video_duration(ifile)
print("duration in ms: ", durms)


def minimum(a, b):
  if a < b:
    return a
  else:
    return b

def minimum_vlen():
    # limits, hard max is 10sec.
    hardmax = 10 * 1000;
    maxvlen = int(sys.argv[2]);
    a = minimum(maxvlen, hardmax)
    b = minimum(a, durms)
    return b


# Output file that is a json serialiaztion dictionary of itemized shots.
filmstrip_dict = {}

# Extract frame from video stream at specified points.
#
# Either pick a set number of result thumbnails (say 12) spaced
# discretely over entire duration or an offset from the beginning
# given an interval in seconds (250ms = .25s)
#
# from
# https://tinyurl.com/32m4ywhx
#
# "This example will seek to the position of 0h:0m:14sec:435msec and
# output one frame (-frames:v 1) from that position into a PNG file.

#ffmpeg -i input.flv -ss 00:00:14.435 -frames:v 1 out.png

# partition number is integer of total segments t
def generate_video_filmstrip_partition_n(ivideo, totaln):
    cspace = ' '
    for i in range(totaln):
        print(i)
        timecoden = (i/totaln) * durms
        if timecoden < 60:
            thumbflag = "-ss 00:00:" + str(timecoden) + cspace + "-update -frames:v 1"
        else:
            timecodemin = int(timecoden/60)
            timecodesec = timecoden - timecodemin;
            thumbflag = "-ss 00:" + str(timecodemin) + ":" + str(timecodesec) + cspace + "-update -frames:v 1"
        ofname = f"{filenamebase}_{i:02d}.{imgformat}"
        fcommand="ffmpeg -i " + ifile + cspace + thumbflag + cspace + ofname
        #print(str(timecoden) + cspace + fcommand)
        os.system(fcommand)
        filmstrip_dict[str(i)] = f"{ofnamebase}_{i:02d}.{imgformat}"


# intervaln is integer of interval between frames in milliseconds (ms)
def generate_video_filmstrip_interval(ivideo, intervaln):
    print("max length of video: ", minimum_vlen())
    cspace = ' '
    totaln = int(minimum_vlen() / intervaln)
    offset = 0;
    for i in range(totaln):
        print(i)
        timecodems = offset + (intervaln * i);
        timecoden = float(timecodems / 1000);
        if timecoden < 60:
            thumbflag = "-ss 00:00:" + str(timecoden) + cspace + "-frames:v 1"
        else:
            timecodemin = int(timecoden/60)
            timecodesec = timecoden - timecodemin;
            thumbflag = "-ss 00:" + str(timecodemin) + ":" + str(timecodesec) + cspace + "-frames:v 1"
        #timecodestr = f"{timecoden:.2f}"
        timecodestr = f"{timecodems:05}"
        ofname = f"{filenamebase}_{timecodestr}.{imgformat}"
        fcommand="ffmpeg -i " + ifile + cspace + thumbflag + cspace + ofname
        #print(str(timecoden) + cspace + fcommand)
        os.system(fcommand)
        filmstrip_dict[timecodestr] = f"{ofnamebase}_{timecodestr}.{imgformat}"


# control points taken from SpeedIndexProgress visual metrics.
def generate_video_filmstrip_control_points(ivideo, cpfilename):
    cspace = ' '
    try:
        with open(cpfilename, 'r') as f:
            for line in f:
                timecodems = int(line.strip());
                if timecodems > durms:
                    msg = f"requested time ({timecodems}ms) "
                    msg += f"is longer than video file length {durms}ms"
                    print(msg)
                else:
                    timecodes = float(timecodems / 1000);
                    #timecodestr = f"{timecoden:.2f}"
                    #timecodestr = f"{timecodems:05}"
                    #timecodestr = f"-ss {timecodes:05d}"
                    timecodestr = f"-ss {timecodes}"
                    frameflag = "-frames:v 1"
                    scaleflag = "-vf scale=iw/4:ih/4"
                    ofname = f"{filenamebase}_{timecodems:05d}.{imgformat}"

                    # seek first makes ffmpeg faster, supposedly
                    fcommand="ffmpeg " + timecodestr + cspace + "-i " + ivideo + cspace
                    fcommand += frameflag + cspace + scaleflag + cspace + ofname
                    result = os.system(fcommand)
                    print("\n")
                    print(f"at second: {str(timecodes)}\n")
                    print(f"command: {fcommand}\n")
                    print(f"returns: {result}\n")
                    print("\n")
                    if not result:
                        filmstrip_dict[timecodems] = f"{ofnamebase}_{timecodems:05d}.{imgformat}"

    except FileNotFoundError:
        print(f"Error: The file '{cpfilename}' was not found.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
        sys.exit(1)


# Assume ivideo.json file created during extraction.
# 2024-11-11-android-chrome-amazon.mp4
# 2024-11-11-android-chrome-amazon-video.json
def serialize_data(ivideo, filmstrip_res, tdict, ofname):
    vdict = {}
    ivideoj = ivideo.replace(".mp4", "-video.json")
    if os.path.exists(ivideoj):
        with open(ivideoj, 'r') as vj:
            vdata_dict = json.load(vj)
            vdict["video"] = vdata_dict
    vdict["filmstrip_interval"] = filmstrip_res
    vdict["filmstrip"] = tdict
    with open(ofname, 'w') as f:
        json.dump(vdict, f, indent=2)

#generate_video_filmstrip_partition_n(ifile, 12)
#generate_video_filmstrip_interval(ifile, 100)
generate_video_filmstrip_control_points(ifile, cpfile)

#serialize_data(ifile, 100, filmstrip_dict, filenamebase + "-filmstrip.json")
serialize_data(ifile, "control_points", filmstrip_dict, filenamebase + "-filmstrip.json")
