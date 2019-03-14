#!/usr/bin/env bash

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: piranha                                                                          #
  VERSION="v1.0"                                                                         #
# Author: Justin C. Bagley                                                               #
# Date: Created by Justin Bagley on Fri, Mar 8 08:36:24 CST 2019.                        #
# Last update: March 8, 2019                                                             #
# Copyright (c) 2019 Justin C. Bagley. All rights reserved.                              #
# Please report bugs to <bagleyj@umsl.edu>.                                              #
#                                                                                        #
# Description: Main script for PIrANHA package, controls all other scripts.              #
#                                                                                        #
##########################################################################################

# Provide a variable with the location of this script.
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source Scripting Utilities
# -----------------------------------
# These shared utilities provide many functions which are needed to provide
# the functionality in this boilerplate. This script will fail if they can
# not be found.
# -----------------------------------

UTILS_LOCATION="${SCRIPT_PATH}/lib/utils.sh" # Update this path to find the utilities.

if [[ -f "${UTILS_LOCATION}" ]]; then
  source "${UTILS_LOCATION}"
else
  echo "Please find the file util.sh and add a reference to it in this script. Exiting..."
  exit 1
fi

# Source shared functions and variables
# -----------------------------------

FUNCS_LOCATION="${SCRIPT_PATH}/lib/sharedFunctions.sh" # Update this path to find the shared functions.
VARS_LOCATION="${SCRIPT_PATH}/lib/sharedVariables.sh" # Update this path to find the shared variables.

if [[ -f "${FUNCS_LOCATION}" ]] && [[ -f "${VARS_LOCATION}" ]]; then
  source "${FUNCS_LOCATION}" ;
  source "${VARS_LOCATION}" ;
else
  echo "Please find the files sharedFunctions.sh and sharedVariables.sh and add references to them in this script. Exiting... "
  exit 1
fi

# Set bin location
# -----------------------------------

#BIN_LOCATION="${SCRIPT_PATH}/bin/" # Update this path to find the piranha bin folder.
BIN_LOCATION=./bin/

# trapCleanup Function
# -----------------------------------
# Any actions that should be taken if the script is prematurely
# exited.  Always call this function at the top of your script.
# -----------------------------------
function trapCleanup() {
  echo ""
  # Delete temp files, if any
  if is_dir "${tmpDir}"; then
    rm -r "${tmpDir}"
  fi
  die "Exit trapped. In function: '${FUNCNAME[*]}'"
}

# safeExit
# -----------------------------------
# Non destructive exit for when script exits naturally.
# Usage: Add this function at the end of every script.
# -----------------------------------
function safeExit() {
  # Delete temp files, if any
  if is_dir "${tmpDir}"; then
    rm -r "${tmpDir}"
  fi
  trap - INT TERM EXIT
  exit
}

# Set Flags
# -----------------------------------
# Flags which can be overridden by user input.
# Default values are below
# -----------------------------------
quiet=false
printLog=false
verbose=false
force=false
strict=false
debug=false
args=()

# Set Temp Directory
# -----------------------------------
# Create temp directory with three random numbers and the process ID
# in the name.  This directory is removed automatically at exit.
# -----------------------------------
tmpDir="/tmp/${SCRIPT_NAME}.$RANDOM.$RANDOM.$RANDOM.$$"
(umask 077 && mkdir "${tmpDir}") || {
  die "Could not create temporary directory! Exiting."
}

# Logging
# -----------------------------------
# Log is only used when the '-l' flag is set.
#
# To never save a logfile change variable to '/dev/null'
# Save to Desktop use: $HOME/Desktop/${SCRIPT_BASENAME}.log
# Save to standard user log location use: $HOME/Library/Logs/${SCRIPT_BASENAME}.log
# -----------------------------------
logFile="$HOME/Library/Logs/${SCRIPT_BASENAME}.log"

# Check for Dependencies
# -----------------------------------
# Arrays containing package dependencies needed to execute this script.
# The script will fail if dependencies are not installed.  For Mac users,
# most dependencies can be installed automatically using the package
# manager 'Homebrew'.  Mac applications will be installed using
# Homebrew Casks. Ruby and gems via RVM.
# -----------------------------------
homebrewDependencies=()
caskDependencies=()
gemDependencies=()





function piranha () {

######################################## START ###########################################
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
FUNCTION_TO_RUN=NULL

############ CREATE USAGE & HELP TEXTS
## USAGE / pseudocode:    ./piranha <blank> , ./piranha -h -help -H -Help all call USAGE / VERBOSE_USAGE
##            reg Usage:  ./piranha <function> <args> <workingDir>
##            start with  ./piranha <function> <workingDir>, and let <function> (= bin/<script>) give its own usage and have its own input structure... so piranha just calls the script for the given function...

USAGE="Usage: $(basename $0) [Help: -h help] [Options: -f V --version] <workingDir>
 ## Help:
  -h   help text (also: --help) echo this help text and exit

 ## Options:
  -f   function (def: NULL; other: PIrANHA functions in bin/) name of function to run
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$USAGE"
	exit
fi

if [[ "$1" == "-V" ]] || [[ "$1" == "--version" ]]; then
	echo "$(basename $0) $VERSION";
	exit
fi

############ PARSE THE OPTIONS
while getopts 'f:' opt ; do
  case $opt in
## PHYLIP2NEXUS options:
    r) FUNCTION_TO_RUN=$OPTARG ;;
## Missing and illegal options:
    :) printf "Missing argument for -%s\n" "$OPTARG" >&2
       echo "$USAGE" >&2
       exit 1 ;;
   \?) printf "Illegal option: -%s\n" "$OPTARG" >&2
       echo "$USAGE" >&2
       exit 1 ;;
  esac
done

############ SKIP OVER THE PROCESSED OPTIONS
shift $((OPTIND-1)) 
# Check for mandatory positional parameters
if [ $# -lt 1 ]; then
	echo "$USAGE"
	exit 1
fi
USER_SPEC_PATH="$1"

echo "
piranha v1.0, March 2019  (main script for PIrANHA v0.1.7+)  "
echo "Copyright (c) 2019 Justin C. Bagley. All rights reserved.  "
echo "------------------------------------------------------------------------------------------"
##
## USAGE / pseudocode:    ./piranha <blank> , ./piranha -h -help -H -Help all call USAGE / VERBOSE_USAGE
##            reg Usage:  ./piranha <function> <args> <workingDir>
##            start with  ./piranha <function> <workingDir>, and let <function> (= bin/<script>) give its own usage and have its own input structure... so piranha just calls the script for the given function...

############ I. READ INPUT, SET UP WORKSPACE, AND CHECK / ECHO MACHINE TYPE.
	echoCDWorkingDir
	echo "INFO      | $(date) |          Checking machine type... "
	checkMachineType
	echo "INFO      | $(date) |               Found machine type ${machine}. "

	if [[ "${machine}" = "Linux" ]]; then
		## Test for file limits for current user and reset if necessary, only on Linux. Modified
		## from dDocent script (J. Puritz GitHub repository dDocent). Added here Mar 8, 2019.
		echo "INFO      | $(date) |          Checking file limits..."
		F_LIMIT=$(ulimit -n)
		export F_LIMIT
		if [[ "$F_LIMIT" != "uN_LIMITed" ]]; then
			N_LIMIT=$(( $NumInd * 10 ));
				if [[ "$F_LIMIT" -lt "$N_LIMIT" ]]; then
					ulimit -n $N_LIMIT;
			fi
		fi
	fi

############ II. CALL USER-SPECIFIED FUNCTION / SCRIPT IN BIN LOCATION. 

	echo "args..."
	echo "$args"

	echo "INFO      | $(date) |          Calling $FUNCTION_NAME..."

	#failed: source ""$BIN_LOCATION""$FUNCTION_NAME"
	#source "$(echo ${BIN_LOCATION}${FUNCTION_NAME})"
	MY_EXECUTION_PATH="$(echo ${BIN_LOCATION}${FUNCTION_NAME})"
	echo "$MY_EXECUTION_PATH"
	
	#BIN_LOCATION
	#/Users/justinbagley/GitHub/PIrANHA-1.0/bin/
	
	sh "$MY_EXECUTION_PATH"
	#if test, this path is: /Users/justinbagley/GitHub/PIrANHA-1.0/bin/test

	echo "args..."
	echo "$args"

##########################################################################################
######################################### END ############################################

}




# ############# ############# #############
# ##       TIME TO RUN THE SCRIPT        ##
# ##                                     ##
# ## You shouldn't need to edit anything ##
# ## beneath this line                   ##
# ##                                     ##
# ############# ############# #############

# Trap bad exits with your cleanup function
trap trapCleanup EXIT INT TERM

# Set IFS to preferred implementation
IFS=$'\n\t'

# Exit on error. Append '||true' when you run the script if you expect an error.
set -o errexit

# Run in debug mode, if set
if ${debug}; then set -x ; fi

# Exit on empty variable
if ${strict}; then set -o nounset ; fi

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`, for example.
set -o pipefail

# Invoke the checkDependenices function to test for Bash packages.  Uncomment if needed.
# checkDependencies

# Run the script
piranha

# Exit cleanly
safeExit