#!/usr/bin/env bash

# ##################################################
# Shared bash functions
#
# VERSION 1.1.0
#
# HISTORY
#
# Pre-PIrANHA version updates by Nate Landau:
# * 2015-01-02 - v1.0.0  - First Creation ("Shared bash functions 
#                          used by my mac setup scripts.").
#
# PIrANHA version updates by Justin Bagley:
# * 2019-03-08 - v1.0.1  - Added to PIrANHA (approximate date).
# * 2020-12-15 - v1.1.0  - Coded doCondaInstall from doInstall,
#                          added brewUpgrade, plus various minor
#                          edits.
#
# ##################################################


# hasHomebrew
# ------------------------------------------------------
# This function checks for Homebrew being installed.
# If it is not found, we install it and its prerequisites.
# ------------------------------------------------------
hasHomebrew () {
  # Check for Homebrew
  # verbose "Checking homebrew install".
  if type_not_exists 'brew'; then
    warning "No Homebrew. Gots to install it..."
    seek_confirmation "Install Homebrew?"
    if is_confirmed; then
      #   Ensure that we can actually, like, compile anything.
      if [[ ! "$(type -P gcc)" && "$OSTYPE" =~ ^darwin ]]; then
        notice "XCode or the Command Line Tools for XCode must be installed first."
        seek_confirmation "Install Command Line Tools from here?"
        if is_confirmed; then
          xcode-select --install
        else
          die "Please come back after Command Line Tools are installed."
        fi
      fi
      # Check for Git.
      if type_not_exists 'git'; then
        die "Git should be installed. It isn't."
      fi
      # Install Homebrew.
      #ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      brew tap homebrew/dupes
      brew tap homebrew/versions
      brew tap argon/mas
    else
      die "Without Homebrew installed, we won't get very far."
    fi
  fi
}

# brewMaintenance
# ------------------------------------------------------
# Will run the recommended Homebrew maintenance scripts.
# ------------------------------------------------------
brewMaintenance () {
  seek_confirmation "Run Homebrew maintenance?"
  if is_confirmed; then
    brew doctor
    brew update
    brew upgrade --all
  fi
}

# hasCasks
# ------------------------------------------------------
# This function checks for Homebrew Casks and Fonts being installed.
# If it is not found, we install it and its prerequisites.
# ------------------------------------------------------
hasCasks () {
  if ! $(brew cask > /dev/null); then
    brew install caskroom/cask/brew-cask
    brew tap caskroom/fonts
    brew tap caskroom/versions
  fi
}

# My preferred installation of FFMPEG
install_ffmpeg () {
  if [ ! $(type -P "ffmpeg") ]; then
    brew install ffmpeg --with-faac --with-fdk-aac --with-ffplay --with-fontconfig --with-freetype --with-libcaca --with-libass --with-frei0r --with-libass --with-libbluray --with-libcaca --with-libquvi --with-libvidstab --with-libsoxr --with-libssh --with-libvo-aacenc --with-libvidstab --with-libvorbis --with-libvpx --with-opencore-amr --with-openjpeg --with-openssl --with-opus --with-rtmpdump --with-schroedinger --with-speex --with-theora --with-tools --with-webp --with-x265
  fi
}

################################### UNDER DEVELOPMENT ####################################

## ------------------------------------------------------
## ISSUE:
## ------------------------------------------------------
## The 'to_install' function is causing the following error when sourced from this script 
## ('setupScriptFunctions.sh') in a piranha function script that is a shell script.
## 
## ERROR:
##    /usr/local/Cellar/piranha/HEAD-8fbf84b/lib/setupScriptFunctions.sh: line 118: syntax error near unexpected token `<'
##    /usr/local/Cellar/piranha/HEAD-8fbf84b/lib/setupScriptFunctions.sh: line 118: `    read -ra desired < <(echo "$1" | tr '\n' ' ')'
##
## Apparently bash process substitution (`< <()`) is not supported by sh.
##
## Urgency level: low-medium
## Why: It would be nice to be able to use checkDependencies.

# # doInstall
# # ------------------------------------------------------
# # Reads a list of items, checks if they are installed, installs
# # those which are needed.
# #
# # Variables needed are:
# # LISTINSTALLED:  The command to list all previously installed items.
# #                 Ex: "brew list" or "gem list | awk '{print $1}'"
# #
# # INSTALLCOMMAND: The Install command for the desired items.
# #                 Ex:  "brew install" or "gem install"
# #
# # RECIPES:      The list of packages to install.
# #               Ex: RECIPES=(
# #                     package1
# #                     package2
# #                   )
# #
# # Credit: https://github.com/cowboy/dotfiles
# # ------------------------------------------------------
# function to_install () {
#   local debugger desired installed i desired_s installed_s remain
#   if [[ "$1" == 1 ]]; then debugger=1; shift; fi
#     # Convert args to arrays, handling both space- and newline-separated lists.
#     read -ra desired < <(echo "$1" | tr '\n' ' ')
#     read -ra installed < <(echo "$2" | tr '\n' ' ')
#     # Sort desired and installed arrays.
#     unset i; while read -r; do desired_s[i++]=$REPLY; done < <(
#       printf "%s\n" "${desired[@]}" | sort
#     )
#     unset i; while read -r; do installed_s[i++]=$REPLY; done < <(
#       printf "%s\n" "${installed[@]}" | sort
#     )
#     # Get the difference. comm is awesome.
#     unset i; while read -r; do remain[i++]=$REPLY; done < <(
#       comm -13 <(printf "%s\n" "${installed_s[@]}") <(printf "%s\n" "${desired_s[@]}")
#   )
#   [[ "$debugger" ]] && for v in desired desired_s installed installed_s remain; do
#     echo "$v ($(eval echo "\${#$v[*]}")) $(eval echo "\${$v[*]}")"
#   done
#   echo "${remain[@]}"
# }
# 
# # Install the desired items that are not already installed.
# function doInstall () {
#   list=$(to_install "${RECIPES[*]}" "$(${LISTINSTALLED})")
#   if [[ "${list}" ]]; then
#     seek_confirmation "Confirm each package before installing?"
#     if is_confirmed; then
#       for item in "${list[@]}"
#       do
#         seek_confirmation "Install ${item}?"
#         if is_confirmed; then
#           notice "Installing ${item}"
#           # FFMPEG takes additional flags
#           if [[ "${item}" = "ffmpeg" ]]; then
#             install_ffmpeg
#           elif [[ "${item}" = "tldr" ]]; then
#             brew tap tldr-pages/tldr ;
#             brew install tldr ;
#           else
#             ${INSTALLCOMMAND} "${item}" ;
#           fi
#         fi
#       done
#     else
#       for item in "${list[@]}"
#       do
#         notice "Installing ${item}... "
#         # FFMPEG takes additional flags
#         if [[ "${item}" = "ffmpeg" ]]; then
#           install_ffmpeg
#         elif [[ "${item}" = "tldr" ]]; then
#           brew tap tldr-pages/tldr ;
#           brew install tldr ;
#         else
#           ${INSTALLCOMMAND} "${item}" ;
#         fi
#       done
#     fi
#   else
#     # Only print notice when not checking dependencies via another script.
#     if [ -z "$homebrewDependencies" ] && [ -z "$caskDependencies" ] && [ -z "$gemDependencies" ]; then
#       notice "Nothing to install. You've already installed all your recipes."
#     fi
# 
#   fi
# }
# 
# # doCondaInstall
# # ------------------------------------------------------
# # Similar to doInstall (above), but modified by JCB for 
# # conda packages (added: Tue Dec 15 17:40:26 CST 2020).
# #
# # NOTES: ${INSTALLCOMMAND} is set to "conda install" in the checkDependencies
# # function; 'to_install' is already defined above under 'doInstall'
# # function.
# # ------------------------------------------------------
# # Install the desired conda packages/software, if not already installed.
# function doCondaInstall () {
#   list=$(to_install "${RECIPES[*]}" "$(${LISTINSTALLED})")
#   if [[ "${list}" ]]; then
#       for item in "${list[@]}"; do
#         notice "Installing ${item}... "
#         if [[ "${item}" = "samtools" ]]; then
#           ${INSTALLCOMMAND} -c bioconda samtools ;
#         elif [[ "${item}" = "dDocent" ]] || [[ "${item}" = "ddocent" ]]; then
#           ${INSTALLCOMMAND} -c bioconda ddocent ;
#         elif [[ "${item}" = "bcftools" ]]; then
#           ${INSTALLCOMMAND} -c bioconda bcftools ;
#         elif [[ "${item}" = "iqtree" ]]; then
#           ${INSTALLCOMMAND} -c bioconda iqtree ;
#         elif [[ "${item}" = "raxml" ]]; then
#           ${INSTALLCOMMAND} -c bioconda raxml ;
#         elif [[ "${item}" = "mafft" ]]; then
#           ${INSTALLCOMMAND} -c bioconda mafft ;
#         elif [[ "${item}" = "trimal" ]] || [[ "${item}" = "trimAl" ]]; then
#           ${INSTALLCOMMAND} -c bioconda trimal  ;
#         elif [[ "${item}" = "dadi" ]]; then
#           ${INSTALLCOMMAND} -c bioconda dadi ;
#         elif [[ "${item}" = "BEAST" ]] || [[ "${item}" = "beast" ]]; then
#           ${INSTALLCOMMAND} -c bioconda beast ;
#         elif [[ "${item}" = "BEAST2" ]] || [[ "${item}" = "beast2" ]]; then
#           ${INSTALLCOMMAND} -c bioconda beast2 ;
#         elif [[ "${item}" = "phyluce" ]] || [[ "${item}" = "Phyluce" ]]; then
#           ${INSTALLCOMMAND} -c bioconda phyluce ;
#         elif [[ "${item}" = "sepp" ]] || [[ "${item}" = "SEPP" ]]; then
#           ${INSTALLCOMMAND} -c bioconda sepp ;
#         elif [[ "${item}" = "mrbayes" ]] || [[ "${item}" = "MrBayes" ]]; then
#           ${INSTALLCOMMAND} -c bioconda mrbayes ;
#         elif [[ "${item}" = "blast" ]] || [[ "${item}" = "BLAST" ]]; then
#           ${INSTALLCOMMAND} -c bioconda blast ;
#         elif [[ "${item}" = "ipyrad" ]] || [[ "${item}" = "pyRAD" ]] || [[ "${item}" = "pyrad" ]]; then
#           ${INSTALLCOMMAND} -c bioconda ipyrad ;
#         elif [[ "${item}" = "biopython" ]] || [[ "${item}" = "Biopython" ]]; then
#           ${INSTALLCOMMAND} -c anaconda biopython ;
#         elif [[ "${item}" = "newick_utils" ]] || [[ "${item}" = "Newick_Utils" ]]; then
#           ${INSTALLCOMMAND} -c bioconda newick_utils ;
#         elif [[ "${item}" = "exonerate" ]] || [[ "${item}" = "Exonerate" ]]; then
#           ${INSTALLCOMMAND} -c bioconda exonerate ;
#         elif [[ "${item}" = "secapr" ]] || [[ "${item}" = "SECAPR" ]]; then
#           ${INSTALLCOMMAND} -c bioconda secapr ;
#         else
#           ${INSTALLCOMMAND} "${item}"
#         fi
#       done
#   else
#     # Only print notice when no dependencies specified at all:
#     if [ -z "$condaDependencies" ] && [ -z "$homebrewDependencies" ] && [ -z "$caskDependencies" ] && [ -z "$gemDependencies" ]; then
#       notice "Nothing to install. You've already installed all your conda-distributed dependencies."
#     fi
# 
#   fi
# }
################################### UNDER DEVELOPMENT ####################################

# brewUpgrade
# ------------------------------------------------------
# Will upgrade Homebrew packages given as input.
#
# Usage: brewUpgrade <packageName>
# ------------------------------------------------------
brewUpgrade () {
  PACKAGE="$1"
  seek_confirmation "Upgrade Homebrew package ${PACKAGE}? "
  if is_confirmed; then
    brew update ;
    brew upgrade --fetch-HEAD "$PACKAGE" ;
  fi
}

# brewCleanup
# ------------------------------------------------------
# This function cleans up an initial Homebrew installation.
# ------------------------------------------------------
brewCleanup () {
  # This is where brew stores its binary symlinks.
  binroot="$(brew --config | awk '/HOMEBREW_PREFIX/ {print $2}')"/bin

  if [[ "$(type -P ${binroot}/bash)" && "$(cat /etc/shells | grep -q "$binroot/bash")" ]]; then
    info "Adding ${binroot}/bash to the list of acceptable shells"
    echo "$binroot/bash" | sudo tee -a /etc/shells >/dev/null
  fi
  if [[ "$SHELL" != "${binroot}/bash" ]]; then
    info "Making ${binroot}/bash your default shell"
    sudo chsh -s "${binroot}/bash" "$USER" >/dev/null 2>&1
    success "Please exit and restart all your shells."
  fi

  brew cleanup ;

  if $(brew cask > /dev/null); then
    brew cask cleanup ;
  fi
}

# hasDropbox
# ------------------------------------------------------
# This function checks for Dropbox being installed.
# If it is not found, we install it and its prerequisites.
# ------------------------------------------------------
hasDropbox () {
  # Confirm we have Dropbox installed.
  notice "Confirming that Dropbox is installed..."
  if [ ! -e "/Applications/Dropbox.app" ]; then
    notice "We don't have Dropbox.  Let's get it installed."
    seek_confirmation "Install Dropbox and all necessary prerequisites?"
    if is_confirmed; then
      # Run functions
      hasHomebrew
      brewMaintenance
      hasCasks

      # Set Variables.
      local LISTINSTALLED="brew cask list"
      local INSTALLCOMMAND="brew cask install --appdir=/Applications"

      local RECIPES=(dropbox)
      Install
      open -a dropbox ;
    else
      die "Can't run this script. Install Dropbox manually."
    fi
  else
    success "Dropbox is installed."
  fi
}
