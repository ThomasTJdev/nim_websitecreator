#!/usr/bin/env bash

# INSPIRED BY PIHOLE. PLEASE SEE PIHOLE LICENSE FOR USE.
# Pi-hole: A black hole for Internet advertisements
# (c) 2017-2018 Pi-hole, LLC (https://pi-hole.net)
#
# PIHOLE FILE CAN BE FOUND AT https://install.pi-hole.net
#
# THIS FILE IS NOT PUBLIC DOMAIN AND MAY NOT BE USED.
# THIS IS A PRIVATE DEVELOPMENT FILE.

# NimWC automated installer

# -e option instructs bash to immediately exit if any command [1] has a non-zero exit status
# We do not want users to end up with a partially working install, so we exit the script
# instead of continuing the installation with something broken
set -e

# Location for final installation log storage
installLoc=$HOME/nimwc

# Git url
gitRepoUrl="https://github.com/ThomasTJdev/nim_websitecreator.git"

# Colors
COL_NC='\e[0m' # No Color
COL_LIGHT_GREEN='\e[1;32m'
COL_LIGHT_RED='\e[1;31m'
COL_LIGHT_YELLOW='\e[1;33m'
COL_LIGHT_BLUE='\e[1;34m'
TICK="[${COL_LIGHT_GREEN}✓${COL_NC}]"
CROSS="[${COL_LIGHT_RED}✗${COL_NC}]"
INFO="[i]"
# shellcheck disable=SC2034
DONE="${COL_LIGHT_GREEN} done!${COL_NC}"
OVER="\\r\\033[K"

# Params
CFG_FIREJAIL=true
CFG_USERNAME="admin"
CFG_EMAIL="admin@admin.com"
CFG_PASS="nimwcadmin"
CFG_SYSTEMCTL=false
CFG_SYSTEMCTLNAME="nimwc"
CFG_APPNAME="nimwc_main"
CFG_SYMBOLIC=false
CFG_STANDARDDATA=""

# BinBash
# Find the rows and columns will default to 80x24 if it can not be detected
screen_size=$(stty size || printf '%d %d' 24 80)
# Set rows variable to contain first number
printf -v rows '%d' "${screen_size%% *}"
# Set columns variable to contain second number
printf -v columns '%d' "${screen_size##* }"

# Divide by two so the dialogs take up half of the screen, which looks nice.
r=$(( rows / 2 ))
c=$(( columns / 2 ))
# Unless the screen is tiny
r=$(( r < 20 ? 20 : r ))
c=$(( c < 70 ? 70 : c ))


#
# NIMWC
#
show_ascii_logo() {
  echo -e "${COL_LIGHT_YELLOW}
                          ▓                ▓
                           ▓               ▓
           ▓               ▓▓             ▓▓
           ▓▓             ▓▓▀▓▓        ▓▓ ▓
            ▓▓▓        ▄▓▓    ▀▓▓▓▓▓▓▓▓▀   ▓
            ▓▓ ▀▓▓▓▓▓▓▓▀                   ▓
             ▓▓              ${COL_LIGHT_BLUE}▄▄▄▄${COL_LIGHT_YELLOW}          ▓▌
              ▓        ${COL_LIGHT_BLUE}▄▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄${COL_LIGHT_YELLOW}    ▓▌
              ▓▓    ${COL_LIGHT_BLUE}▄▓▓▓▀             ▀▓▓▓▓▓
               ${COL_LIGHT_YELLOW}▓▌ ${COL_LIGHT_BLUE}▄▓▓▓                  ▀▓▓▓▓
                ▓▓▓▓                      ▀▓▓
                ▓▓▓                         ▓▓▄
                ▓▓                          ▓▓▓▓▓▓▓▓▓▓▓▄
            ▄▓▓▓▓▓                                    ▀▓▓▄
        ▓▓▓▓▀▀▀                                         ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
    ▄▓▓▓▀                                                              ▀▓▓▓▄
   ▓▓▓                                                                   ▀▓▓▄
  ▓▓▌                                                                      ▓▓▓
  ▓▓         ▓▓▓    ▓▓   ▓▌  ▓▓▓▓    ▓▓▓▓ ▓▓▓   ▓▓▓   ▓▓▌ ▓▓▓▓▓▓▓▓         ▓▓▓
 ▓▓▌         ▓▓▓▓▄  ▓▓   ▓▌  ▓▓▓▓▓  ▓▓▓▓▓  ▓▓   ▓▓▓  ▓▓  ▓▓                 ▓▓
 ▓▓▌         ▓▌ ▀▓▓ ▓▓   ▓▌  ▓▓ ▀▓▓▓▓  ▓▓   ▓▓ ▓▓ ▓▓ ▓▓   ▓▌                ▓▓
  ▓▓         ▓▌   ▓▓▓▓   ▓▌  ▓▓   ▓▓   ▓▓    ▓▓▓   ▓▓▓    ▓▓▓▄▄▄▓▓         ▓▓
   ▓▓▄      ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀        ▓▓▌
    ▓▓▓▄                                                                 ▓▓▀
     ▀▓▓▓▓▄                                                           ▄▓▓▓▀
        ▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀${COL_NC}"
}


#
# FOLDERS
#
setup_folder() {
  local directory="${1}"

  if [[ -d "${directory}" ]]; then
    printf "  %b %s\\n" "${TICK}" "Directory exists: ${directory}"
  else
    printf "  %b %s\\n" "${INFO}" "Directory does not exists. Creating ${directory}"
    mkdir -p "${directory}" || return 1
    printf "  %b %s\\n" "${TICK}" "Directory created"
  fi
}


#
# CHECK REQUIRED
#
is_command() {
    # Checks for existence of string passed in as only function argument.
    # Exit value of 0 when exists, 1 if not exists. Value is the result
    # of the `command` shell built-in call.
    local check_command="$1"

    command -v "${check_command}" >/dev/null 2>&1
}

check_req() {
  if is_command ${1} ; then
    local str="${1} is installed"
    printf "  %b %s\\n" "${TICK}" "${str}"
  else
    local str="${1} is requied"
    printf "  %b %s\\n" "${CROSS}" "${str}"
    exit 1
  fi
}


#
# GIT REPO
#
# A function for checking if a directory is a git repository
is_repo() {
    # Use a named, local variable instead of the vague $1, which is the first argument passed to this function
    # These local variables should always be lowercase
    local directory="${1}"
    # A local variable for the current directory
    local curdir
    # A variable to store the return code
    local rc
    # Assign the current directory variable by using pwd
    curdir="${PWD}"
    # If the first argument passed to this function is a directory,
    if [[ -d "${directory}" ]]; then
        # move into the directory
        cd "${directory}"
        # Use git to check if the directory is a repo
        # git -C is not used here to support git versions older than 1.8.4
        git status --short &> /dev/null || rc=$?
    # If the command was not successful,
    else
        # Set a non-zero return code if directory does not exist
        rc=1
    fi
    # Move back into the directory the user started in
    cd "${curdir}"
    # Return the code; if one is not set, return 0
    return "${rc:-0}"
}

make_repo() {
    # Set named variables for better readability
    local directory="${1}"
    local remoteRepo="${2}"
    # The message to display when this function is running
    str="Clone ${remoteRepo} into ${directory}"
    # Display the message and use the color table to preface the message with an "info" indicator
    printf "  %b %s..." "${INFO}" "${str}"

    # If the directory exists,
    if [[ -d "${directory}" ]]; then
        # delete everything in it so git can clone into it
        rm -rf "${directory}"
    fi

    # Clone the repo and return the return code from this command
    git clone -q --depth 1 "${remoteRepo}" "${directory}" &> /dev/null || return $?
    # Show a colored message showing it's status
    printf "%b  %b %s\\n" "${OVER}" "${TICK}" "${str}"
    # Always return 0? Not sure this is correct
    return 0
}

# We need to make sure the repos are up-to-date so we can effectively install Clean out the directory if it exists for git to clone into
update_repo() {
    # Use named, local variables
    # As you can see, these are the same variable names used in the last function,
    # but since they are local, their scope does not go beyond this function
    # This helps prevent the wrong value from being assigned if you were to set the variable as a GLOBAL one
    local directory="${1}"
    local curdir

    # A variable to store the message we want to display;
    # Again, it's useful to store these in variables in case we need to reuse or change the message;
    # we only need to make one change here
    local str="Update repo in ${1}"

    # Make sure we know what directory we are in so we can move back into it
    curdir="${PWD}"
    # Move into the directory that was passed as an argument
    cd "${directory}" &> /dev/null || return 1
    # Let the user know what's happening
    printf "  %b %s..." "${INFO}" "${str}"
    # Stash any local commits as they conflict with our working code
    #git stash --all --quiet &> /dev/null || true # Okay for stash failure
    git clean --quiet --force -d || true # Okay for already clean directory
    # Pull the latest commits
    git pull --quiet &> /dev/null || return $?
    # Show a completion message
    printf "%b  %b %s\\n" "${OVER}" "${TICK}" "${str}"
    # Move back into the original directory
    cd "${curdir}" &> /dev/null || return 1
    return 0
}


# A function that combines the functions previously made
getGitFiles() {
    # Setup named variables for the git repos
    # We need the directory
    local directory="${1}"
    # as well as the repo URL
    local remoteRepo="${2}"
    # A local variable containing the message to be displayed
    local str="Check for existing repository in ${1}"
    # Show the message
    printf "  %b %s..." "${INFO}" "${str}"
    # Check if the directory is a repository
    if is_repo "${directory}"; then
        # Show that we're checking it
        printf "%b  %b %s\\n" "${OVER}" "${TICK}" "${str}"
        # Update the repo, returning an error message on failure
        update_repo "${directory}" || { printf "\\n  %b: Could not update local repository. Contact support.%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"; exit 1; }
    # If it's not a .git repo,
    else
        # Show an error
        printf "%b  %b %s\\n" "${OVER}" "${CROSS}" "${str}"
        # Attempt to make the repository, showing an error on failure
        make_repo "${directory}" "${remoteRepo}" || { printf "\\n  %bError: Could not update local repository. Contact support.%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"; exit 1; }
    fi
    # echo a blank line
    echo ""
    # and return success?
    return 0
}


# Reset a repo to get rid of any local changed
resetRepo() {
    # Use named variables for arguments
    local directory="${1}"
    # Move into the directory
    cd "${directory}" &> /dev/null || return 1
    # Store the message in a variable
    str="Resetting repository within ${1}..."
    # Show the message
    printf "  %b %s..." "${INFO}" "${str}"
    # Use git to remove the local changes
    git reset --hard &> /dev/null || return $?
    # And show the status
    printf "%b  %b %s\\n" "${OVER}" "${TICK}" "${str}"
    # Returning success anyway?
    return 0
}


clone_or_update_repos() {
  # We need the directory
    local directory="${1}"
    # as well as the repo URL
    local remoteRepo="${2}"
    # so get git files for Core
    getGitFiles ${directory} ${remoteRepo} || \
    { printf "  %bUnable to clone %s into %s, unable to continue%b\\n" "${COL_LIGHT_RED}" "${piholeGitUrl}" "${PI_HOLE_LOCAL_REPO}" "${COL_NC}"; \
    exit 1; \
    }
}


welcomeDialogs() {
    whiptail --msgbox --backtitle "Welcome" --title "Nim Website Creator" "\\n\\nThis installer will install and enable NimWC!\\n\\n\\n\\nYour website will be ready in seconds. Checkout the demo at:  https://nimwc.org" ${r} ${c}
}


setInstallFolder() {
  local directory=${1}
  local installDir=$(whiptail --inputbox "Full path to install" 8 78 "${directory}" --title "Install location" 3>&1 1>&2 2>&3)
  installLoc=${installDir}
  printf "  %b %s\\n" "${INFO}" "Install directory: ${installLoc}"
}

setUserParams() {
  CFG_USERNAME=$(whiptail --inputbox "Username (x > 3)" 8 78 "${CFG_USERNAME}" --title "Admin user" 3>&1 1>&2 2>&3)
  CFG_EMAIL=$(whiptail --inputbox "Email (x > 5)" 8 78 "${CFG_EMAIL}" --title "Admin user" 3>&1 1>&2 2>&3)
  CFG_PASS=$(whiptail --inputbox "Password (x > 9)" 8 78 "${CFG_PASS}" --title "Admin user" 3>&1 1>&2 2>&3)
  printf "  %b %s\\n" "${TICK}" "User data updated. You can always edit them within the browser."
}

setStandardData() {
  local ToggleCommand
  local ChooseOptions
  local Choices

  ToggleCommand=(whiptail --separate-output --radiolist "Insert standard data?" ${r} ${c} 6)
  ChooseOptions=("Bulma (Recommended)" "" on
      Bootstrap "" off
      Water "" off
      Off "" off)
  Choices=$("${ToggleCommand[@]}" "${ChooseOptions[@]}" 2>&1 >/dev/tty) || (printf "  %bCancel was selected, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}" && exit 1)
  case ${Choices} in
      "Bulma (Recommended)")
          printf "  %b Bulma standard data On\\n" "${INFO}"
          CFG_STANDARDDATA="--insertdata bulma"
          ;;
      Bootstrap)
          printf "  %b Bootstrap standard data\\n" "${INFO}"
          CFG_STANDARDDATA="--insertdata bootstrap"
          ;;
      Water)
          printf "  %b Water standard data (HTML Classless)\\n" "${INFO}"
          CFG_STANDARDDATA="--insertdata water"
          ;;
      Off)
          printf "  %b Standard data off\\n" "${INFO}"
          CFG_STANDARDDATA=""
          ;;
  esac
}

setSystemctl() {
  local ToggleCommand
  local ChooseOptions
  local Choices

  ToggleCommand=(whiptail --separate-output --radiolist "Enable systemctl?" ${r} ${c} 6)
  ChooseOptions=("On (Recommended)" "" on
      Off "" off)
  Choices=$("${ToggleCommand[@]}" "${ChooseOptions[@]}" 2>&1 >/dev/tty) || (printf "  %bCancel was selected, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}" && exit 1)
  case ${Choices} in
      "On (Recommended)")
          printf "  %b Systemctl On\\n" "${INFO}"
          #enable_service ${CFG_SYSTEMCTLNAME}
          CFG_SYSTEMCTL=true
          ;;
      Off)
          printf "  %b Systemctl Off\\n" "${INFO}"
          #disable_service ${CFG_SYSTEMCTLNAME}
          CFG_SYSTEMCTL=false
          ;;
  esac
}

setSymbolicLink() {
  local ToggleCommand
  local ChooseOptions
  local Choices

  ToggleCommand=(whiptail --separate-output --radiolist "Make symbolic link to NimWC?" ${r} ${c} 6)
  ChooseOptions=("On" "" on
      Off "" off)
  Choices=$("${ToggleCommand[@]}" "${ChooseOptions[@]}" 2>&1 >/dev/tty) || (printf "  %bCancel was selected, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}" && exit 1)
  case ${Choices} in
      "On")
          printf "  %b Symbolic link On\\n" "${INFO}"
          # Set it to true
          CFG_SYMBOLIC=false
          ;;
      Off)
          printf "  %b Symbolic link Off\\n" "${INFO}"
          # or false
          CFG_SYMBOLIC=true
          ;;
  esac
}

setCompileFlag() {
  local ToggleCommand
  local ChooseOptions
  local Choices

  ToggleCommand=(whiptail --separate-output --radiolist "Use firejail?" ${r} ${c} 6)
  ChooseOptions=("Off" "" on
                On "" off)
  Choices=$("${ToggleCommand[@]}" "${ChooseOptions[@]}" 2>&1 >/dev/tty) || (printf "  %bCancel was selected, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}" && exit 1)
  case ${Choices} in
      Off)
          printf "  %b Firejail Off\\n" "${INFO}"
          # To false
          CFG_FIREJAIL=false
          ;;
      On)
          printf "  %b Firejail On\\n" "${INFO}"
          check_req firejail
          # Set it to true
          CFG_FIREJAIL=true
          ;;
  esac
}

config_nimwc() {
  local directory=${1}
  local strConfig=${directory}"/config/config.cfg"
  local strConfigDefault=${directory}"/config/config_default.cfg"

  # Check if config.cfg exists or create it
  if [ ! -f ${strConfig} ]; then
    printf "  %b %s\\n" "${INFO}" "Copy default config file to ${strConfig}"
    cp -v ${strConfigDefault} ${strConfig} &> /dev/null || return 1
    printf "  %b %s\\n" "${TICK}" "Config file created"
  else
    printf "  %b %s\\n" "${TICK}" "Config exists: ${strConfig}"
  fi
}

compile_nimwc() {
  local directory=${1}
  local appName="nimwcpkg/${CFG_APPNAME}"

  # Stop service if running
  if [[ "${EUID}" -eq 0 ]]; then
    if check_service_active ${CFG_SYSTEMCTLNAME} ; then
      stop_service ${CFG_SYSTEMCTLNAME} &> /dev/null
      printf "  %b %s\\n" "${TICK}" "Service stopped"
    fi
  fi

  # Cd to directory
  cd "${directory}" &> /dev/null || return 1

  # Delete sub runner
  if [ -f ${appName} ]; then
    rm ${appName} &> /dev/null || return 1
    printf "  %b %s\\n" "${TICK}" "Old compile file removed"
  fi

  # Check firejails is enabled
  if [[ "${CFG_FIREJAIL}" == false ]]; then
    sed -i '/-d:firejail/d' nimwc.nim.cfg
    printf "  %b %s\\n" "${TICK}" "Firejail disabled"
  fi

  # Compile
  printf "  %b %s\\n" "${INFO}" "Compiling"
  local strCompile="nim c -d:release nimwc"
  eval $strCompile

  # Symbolic link
  if [[ "${CFG_SYMBOLIC}" == true ]]; then
    ln -s ${directory}/nimwc /usr/bin/nimwc
    printf "  %b %s\\n" "${TICK}" "Symbolic link created"
  fi

  # Systemctl
  if [[ "${CFG_SYSTEMCTL}" == true ]]; then
    enable_service ${CFG_SYSTEMCTLNAME}
    printf "  %b %s\\n" "${TICK}" "Systemctl enabled"
  fi

  # Generate DB
  local strRunDataDb="./nimwc --newdb"
  eval $strRunDataDb

  # Insert standard data
  if [[ ! -z "${CFG_STANDARDDATA}" ]]; then
    printf "  %b %s\\n" "${INFO}" "Inserting standard data"
    local strRunData="yes | ./nimwc ${CFG_STANDARDDATA}"
    eval $strRunData
  fi

  # Add admin user
  printf "  %b %s\\n" "${INFO}" "To finish the setup of NimWC, add an Admin user:"
  printf "  %b %s\\n" "${INFO}" " ${installLoc}/nimwc --newadmin"

  if [[ "${EUID}" -eq 1 ]]; then
    printf "\\n\\n"
    printf "  %b %s\\n" "${INFO}" "NimWC was installed as a non-root user, remember to:"
    printf "  %b %s\\n" "${INFO}" " Make a servicefile to autostart\\n"
    printf "  %b %s\\n" "${INFO}" " Symlink to enable start with 'nimwc'"
    printf "  %b %s\\n" "${INFO}" "   ln -s ${directory}/nimwc /usr/bin/nimwc"
  fi
}


stop_service() {
    # Stop service passed in as argument.
    # Can softfail, as process may not be installed when this is called
    local str="Stopping ${1} service"
    printf "  %b %s..." "${INFO}" "${str}"
    if is_command systemctl ; then
        systemctl stop "${1}" &> /dev/null || true
    else
        service "${1}" stop &> /dev/null || true
    fi
    printf "%b  %b %s...\\n" "${OVER}" "${TICK}" "${str}"
}

# Start/Restart service passed in as argument
restart_service() {
    # Local, named variables
    local str="Restarting ${1} service"
    printf "  %b %s..." "${INFO}" "${str}"
    # If systemctl exists,
    if is_command systemctl ; then
        # use that to restart the service
        systemctl restart "${1}" &> /dev/null
    # Otherwise,
    else
        # fall back to the service command
        service "${1}" restart &> /dev/null
    fi
    printf "%b  %b %s...\\n" "${OVER}" "${TICK}" "${str}"
}

# Enable service so that it will start with next reboot
enable_service() {
    # Local, named variables
    local str="Enabling ${1} service to start on reboot"
    printf "  %b %s..." "${INFO}" "${str}"
    # If systemctl exists,
    if is_command systemctl ; then
        # use that to enable the service
        systemctl enable "${1}" &> /dev/null
    # Otherwise,
    else
        # use update-rc.d to accomplish this
        update-rc.d "${1}" defaults &> /dev/null
    fi
    printf "%b  %b %s...\\n" "${OVER}" "${TICK}" "${str}"
}

# Disable service so that it will not with next reboot
disable_service() {
    # Local, named variables
    local str="Disabling ${1} service"
    printf "  %b %s..." "${INFO}" "${str}"
    # If systemctl exists,
    if is_command systemctl ; then
        # use that to disable the service
        systemctl disable "${1}" &> /dev/null
    # Otherwise,
    else
        # use update-rc.d to accomplish this
        update-rc.d "${1}" disable &> /dev/null
    fi
    printf "%b  %b %s...\\n" "${OVER}" "${TICK}" "${str}"
}

check_service_active() {
    # If systemctl exists,
    if is_command systemctl ; then
        # use that to check the status of the service
        systemctl is-enabled "${1}" &> /dev/null
    # Otherwise,
    else
        # fall back to service command
        service "${1}" status &> /dev/null
    fi
}



main() {
    ######## FIRST CHECK ########
    # Must not be root to install!
    printf "\\n\\n"

    printf "  %b %s\\n" "${INFO}" "User priviligies"
    if [[ "${EUID}" -eq 0 ]]; then
        # they are root
        printf "  %b %s\\n" "${INFO}" "You are running as root - take care"
        printf "      Make sure to download this script from a trusted source\\n\\n"
        printf "  %b %s\\n" "${TICK}" "NimWC will be enabled with systemctl"
    # Otherwise,
    else
        # They do not have enough privileges, so let the user know
        show_ascii_logo
        printf "\\n"
        printf "  %b %s\\n" "${TICK}" "You are running as non-root user"
        printf "  %b %s\\n" "${CROSS}" "NimWC will not be enabled with systemctl"
        printf "  %b %s\\n" "${CROSS}" "NimWC will not be symlinked to /usr/bin"
    fi

    # Check req
    printf "\\n\\n"
    printf "  %b %s\\n" "${INFO}" "Checking required software"
    check_req nim
    check_req git

    # Display welcome dialogs
    welcomeDialogs

    # Install folder
    setInstallFolder ${installLoc}

    # Login details
    #  - This is now done within nimwc (5.5.0)
    #setUserParams

    # Standard data
    setStandardData

    # Flags
    setCompileFlag

    # Symbolic link
    if [[ "${EUID}" -eq 0 ]]; then
      setSymbolicLink
    fi

    # Enable with systemctl
    #if [[ "${EUID}" -eq 0 ]]; then
    #  setSystemctl
    #fi

    # Create folder
    printf "\\n"
    setup_folder ${installLoc}

    # Clone/Update the repos
    printf "\\n"
    clone_or_update_repos ${installLoc} ${gitRepoUrl}

    # Config NimWC
    config_nimwc ${installLoc}

    # Compile
    compile_nimwc ${installLoc}

}

if [[ "${PH_TEST}" != true ]] ; then
    main "$@"
fi
