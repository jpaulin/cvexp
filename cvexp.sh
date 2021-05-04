#!/bin/bash

# What is this? 
#
# This is a bash script, called 'cvexp.sh'. It reads data from file,
# and calculates sum of work experience. The file format is described in
# FORMAT.md

# Command line switches
# ---------------------
# (none yet)

# Configuration of script
# -----------------------
# The unit of "n" is currently: workdays 
# Divisor for a month is:       21 workdays
# Reporting in addition:        years
# Divisor for 1 year of exp:    252 workdays       

# If you wish to change units, please change the script
# in places following a '# UNITS' comment.

# My own name (as a tool) to be used in messages to user
mytname=cvexp

# Globally visible Config
wkfile=cvdata.txt

# Holy principles of this script
#
# 1. must be always runnable simply by ./cvexp.sh
# 2. must always produce some tangible results when run

#
# Counting module - returns hours, and other aggregate counts
#
#   Need Global: $wkfile
#


# Check file existence error
# If there is no data file, we cannot process
#
# TY Linuxize!
if [ ! -f "${wkfile}" ]; then
    echo "$wkfile data file does not exist. Cannot proceed!"
    exit 1
fi

echo "Your work experience is:"

# Filtered payload data will appear in this file
# We want to filter out from cvdata:
# - '#' starting lines which are comments
tmpfilename='cv_tmp.dat'

# Original blocks as they were before using tmp file
# awk 'BEGIN {FS = " "} ; {sum += $1} END {printf "%d months\n", sum/21.0}' "${wkfile}"
# awk 'BEGIN {FS = " "} ; {sum += $1} END {printf "%1.1d years\n", sum/(12.0*21)}' "${wkfile}"

#
# Big goal: ensure tmp file creation works.
# This means that given a folder with no tmp file to begin with,
# after creation code the file DOES exist.

#
# If tmp file exists, at this point, we want to remove it. Only if it exists, though.
if [ -f "${tmpfilename}" ]; then
    rm $tmpfilename
    if [ -f "${tmpfilename}" ]; then
	echo "Fail: I/O error - a persisting tmp file we cannot remove called ${tmpfilename}"
	echo "Please remove manually, and run this script again"
	exit 0
    fi
fi

# cat and grep to vet
cat $wkfile | grep -v '^\#.*' >$tmpfilename

# Now it must be present
# Note there are 2 "error" cases in case file does not exist
# 1. The cvdata (data) was all comments and/or whitespace
# 2. The cvdata file was not being able to read
if [ ! -f "${tmpfilename}" ]; then
    echo "${mytname} fail: No data to work on."
    echo "Make some valid data entries to file ${wkfile}"
    exit 0
fi

# UNITS - change divisor to be congruent to unit of number in input (data) file
#         eg. if recording full working days, divisor=21 for months (in reporting)
#         eg. if recording full working days, divisor=12*21 for years (in reporting)
# The multiplying (using * 1.0 ) in many places is due to making sure numbers less
# than 1.0 count also towards experience.
awk 'BEGIN {FS = " "} ; {sum += $1 * 1.0} END {printf "%1.2f months\n", (1.000*sum)/21.0}' "${tmpfilename}"
awk 'BEGIN {FS = " "} ; {sum += $1 * 1.0} END {printf "%1.2f years\n", (1.000*sum)/(12.0*21)}' "${tmpfilename}"

# Only debug option: Count payload data lines processed
# linecount=`wc -l "${tmpfilename}"`
# echo "Script processed ${linecount} lines"

# IF the script used a tmp file, then remove it
rm -f "${tmpfilename}"

