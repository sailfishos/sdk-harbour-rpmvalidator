#!/bin/bash
#
# Copyright (C) 2013 - 2021 Jolla Ltd.
# Copyright (C) 2018 - 2020 Open Mobile Platform LLC.
# Contact: http://jolla.com/
#
# This file is part of the SailfishOS SDK
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

shopt -s extglob

#
# Definitions
#

#
# DEBUG levels
#
#	0	- no debug
#	1	- debug
#	2	- verbose debug
#	3	- verbose debug and no clean up
#
DEBUG=2

#
# RC levels
#
#	0 	- Validation was successful
#	1	- Validation failed
#	2	- Validation succeded with warnings
#
RC=0

# Per-validation step checking if there was a warning/failure/info
FAILED=0
WARNED=0
INFOED=0

# Set to 1 in .desktop file validation when sailfish-qml is used
USES_SAILFISH_QML_LAUNCHER=0

# Set to 1 in the QML validation when "Sailfish.Silica" is imported
USES_SAILFISH_SILICA_QML_IMPORT=0

# Set to 1 in the QML validateion when "QtQuick.XmlListModel" is imported
# this is dragged in by fingerterm on testers device, but not on device by default
USES_XML_LIST_MODEL_QML_IMPORT=0

# Flag if we've already given the AutoReqProv suggestion
SUGGESTED_AUTOREQPROV=0

# Flag if we've already suggested using XDG Base Dir
SUGGESTED_XDG_BASEDIR=0

# Flag if $NAME check was ok
NAME_CHECK_PASSED=0

# Auxiliary variable to check if INFO message has been already printed out 
# for particular type of error
INFO_MSG_PRINTED=0

# Auxiliary variable to check if the rpath check is needed
RPATH_CHECK_NEEDED=0
POSSIBLE_RPATH_CHECK_NEEDED=0

# Auxiliary variable to track arch
ARCH_DEPENDANT=0

RPM_NAME=''
NAME=''
BIN_NAME=''
SHARE_NAME=''
DESKTOP_NAME=''
ICON_NAME=''
TMP_DIR=''

PACKAGING_SCRIPT_DIR='/usr/share/sdk-harbour-rpmvalidator'
SCRIPT_DIR=''
SCRIPT_CONF='rpmvalidation.conf'

# Print/logging helper functions
#
log_debug() {
    if [[ $DEBUG -gt 0 ]] ; then
        echo -e $*
    fi
}

incolor() {
    COLOR=$1
    shift

    # no color if $BATCHER.. is set or if turned off by option
    if [[ -n $BATCHERBATCHERBATCHER || -n $OPT_NOCOLOR ]]; then
        echo -e "$@"
    else
        echo -e "\e[${COLOR}m$@\e[0m"
    fi
}

validation_message() {
    KIND=$1
    shift
    FILENAME=$1
    case "$FILENAME" in
        usr*|opt*)
            FILENAME=/$FILENAME
            ;;
        *)
            ;;
    esac
    shift
    if [ -z $BATCHERBATCHERBATCHER ]; then
        echo -e "$KIND [$(incolor 34 $FILENAME)]" "$@"
    else
        echo "$KIND|$FILENAME|$@"
    fi
}

validation_error() {
    validation_message "$(incolor 31 ERROR)" "$@"
    RC=1
    FAILED=1
}

validation_warning() {
    validation_message "$(incolor 33 WARNING)" "$@"
    WARNED=1
}

validation_info() {
    validation_message "$(incolor 36 INFO)" "$@"
    INFOED=1
}

validation_success() {
    validation_message "$(incolor 32 OK)" "$@"
}

run_validator() {
    CHECK_NAME=$1
    shift

    if [ -z $BATCHERBATCHERBATCHER ]; then
        echo -e "$CHECK_NAME"
        echo -e "$(echo $CHECK_NAME | $SED -e 's/./=/g')"
    else
        echo "=$CHECK_NAME"
    fi

    FAILED=0
    WARNED=0
    INFOED=0
    $@

    if [ -z $BATCHERBATCHERBATCHER ]; then
        if [ $FAILED -eq 0 ]; then
            # if WARNED or INFOED, the test still passed
            echo -e "$(incolor 32 PASSED)"
        else
            echo -e "$(incolor 31 FAILED)"
        fi
        echo
    fi

    return $RC
}

# display usage information
usage() {
    cat <<EOF
Run a basic quality criteria check for the given RPM file.

Usage:
   $0 [OPTION] <rpm-file>

Options:
   -d <level>               set debug level (0, 1, 2, 3)
   -c | --no-color          no color in log output
   -g | --config-dir <dir>  read config files from this dir
   -s | --sort              sort the output of find commands
   -v | --version           display script version
   -h | --help              this help

EOF

    # exit if any argument is given
    [[ -n "$1" ]] && exit 1
}

#
# Preparations
#
rpmprepare () {
    # parse command line options
    while [[ ${1:-} ]]; do
        case "$1" in
            -h | --help) shift
                usage quit
                ;;
            -c | --no-color) shift
                OPT_NOCOLOR=1
                ;;
            -d*)
                # read -d with or without space after it
                if [ ${#1} -gt 2 ]; then
                    DEBUG=${1:2}; shift
                else
                    [ -z "$2" ] && usage quit
                    DEBUG="$2"; shift 2;
                fi
                # only valid debug levels accepted
                if [[ $DEBUG != [0123] ]]; then
                    usage quit
                fi
                ;;
            -g | --config-dir) shift
                OPT_CONF_DIR=$1; shift
                [[ -z $OPT_CONF_DIR ]] && usage quit
                OPT_CONF_DIR=$(readlink -f $OPT_CONF_DIR)
                [[ ! -d $OPT_CONF_DIR ]] && { echo "ERROR: given directory [$OPT_CONF_DIR] does not exist"; exit 1; }
                ;;
            -s | --sort) shift
                # eval can be used to pipe command lines to sort
                OPT_SORT="| sort"
                ;;
            -v | --version) shift
                # do not print out version here because SCRIPT_DIR might
                # have changed if the config dir option is given
                OPT_VERSION=1
                ;;
            -*)
                usage quit
                ;;
            *)
                # this is the file we are validating
                RPM_NAME=$(readlink -f $1)
                shift
                ;;
        esac
    done

    # first thing, figure out where all the config files are
    if [[ -n $OPT_CONF_DIR ]]; then
        SCRIPT_DIR=$OPT_CONF_DIR
    elif [ -d $PACKAGING_SCRIPT_DIR ]; then
        SCRIPT_DIR=$PACKAGING_SCRIPT_DIR
    else
        SCRIPT_DIR=$(dirname $(readlink -f $0))
    fi

    if [[ $OPT_VERSION -eq 1 ]]; then
        if [[ -f "$SCRIPT_DIR/version" ]]; then
            cat $SCRIPT_DIR/version
            exit 0
        else
            echo "unknown"
            exit 0
        fi
    fi

    # this is a required parameter
    [[ -z $RPM_NAME ]] && usage quit

    [[ ! -f $RPM_NAME ]] && { validation_error $RPM_NAME "File not found!"; exit 1; }

    # the version file is created during RPM build and should not be in
    # version control
    [[ -f "$SCRIPT_DIR/version" ]] && log_debug "RPM Validation script v$(cat $SCRIPT_DIR/version)"

    TMP_DIR=`mktemp -d -t "RPM-CHECK-XXXXXXXX"`
    if [[ $? -gt 0 ]] ; then
        RC=1
        validation_error "$RPM_NAME" "Could not create tmp directory!"
        return $RC
    fi

    # set cleanup handler for TMP_DIR
    trap "{ trap - EXIT; if [[ $DEBUG -lt 3 ]]; then rpmcleanup; else echo Skip clean up; fi }" EXIT

    log_debug "Created temporary directory $TMP_DIR"

    log_debug "Reading config scripts from $SCRIPT_DIR"

    # before doing anything with the rpm, check that it is an rpm file
    RPM_FILE_TYPE=$(file -b $RPM_NAME)
    if [[ ! ${RPM_FILE_TYPE} =~ ^RPM.v.* ]] ; then
        RC=1
        validation_error "$RPM_NAME" "is not an rpm file!"
        return $RC
    fi
  
    if [[ ! -f $SCRIPT_DIR/$SCRIPT_CONF ]] ; then
        RC=1
        validation_error "$SCRIPT_DIR/$SCRIPT_CONF" "Could not read the configuration file!"
        return $RC
    fi

    # that is ugly, but in 1st run we need so $RPM is available
    # 2nd so $NAME is available in config?!
    source $SCRIPT_DIR/$SCRIPT_CONF
    NAME=$($RPM -q --queryformat='%{NAME}' -p $RPM_NAME)
    source $SCRIPT_DIR/$SCRIPT_CONF
  
    log_debug "Prepare for RPM validation of file $RPM_NAME"

    #
    # Unpack RPM file
    #
    pushd $TMP_DIR >/dev/null 2>&1
    if [[ $DEBUG -lt 2 ]] ; then
        $RPM2CPIO $RPM_NAME | $CPIO --quiet -idm
    else
        $RPM2CPIO $RPM_NAME | $CPIO -idmv
    fi
    if [[ $? -gt 0 ]] ; then
        RC=1
        popd >/dev/null 2>&1
        validation_error "$RPM_NAME" "Invalid RPM file!"
        return $RC
    fi

    popd >/dev/null 2>&1
}

check_contained_in() (
    # First argument is the query, following arguments (can be multiple ones)
    # are the list of files containing patterns to match the query against.
    # The files can contain comments (lines starting with #) and empty lines
    # for structuring.
    QUERY=$1
    shift
    cd $SCRIPT_DIR
    while read pat; do
        [[ $QUERY == $pat ]] && return 0
        [[ $QUERY == "$pat()(64bit)" ]] && return 0
    done < <(cat "$@")
    return 1
)

check_file_exists() {
    FILENAME=$1
    shift
    if [ ! -f $FILENAME ]; then
        validation_warning $FILENAME "File not found" $*
        return 1
    fi
    return 0
}

require_file_exists() {
    FILENAME=$1
    shift
    if [ ! -f $FILENAME ]; then
        validation_error $FILENAME "File not found" $*
    fi
}

fail_if_file_exists() {
    FILENAME=$1
    shift
    if [ -f $FILENAME ]; then
        validation_error $FILENAME "File must not exist" $*
    fi
}

check_directory_exists() {
    FILENAME=$1
    shift
    if [ ! -d $FILENAME ]; then
        validation_warning $FILENAME "Directory not found" $*
    fi
}

fail_if_directory_exists() {
    FILENAME=$1
    shift
    if [ -d $FILENAME ]; then
        validation_error "Directory must not exist" $*
    fi
}

check_for_icons() {
    FOUND_ICON=0
    MISS_ICON=0
    for SIZE in $ICON_SIZES; do
        ICON_NAME=$(echo $ICON_NAME_PATH | sed "s/@@SIZE@@/$SIZE/")
        if check_file_exists $ICON_NAME; then
            FOUND_ICON=1
        else
            MISS_ICON=1
        fi
    done

    # this case should not happen!
    # $FOUND_ICON -eq 0 && $MISS_ICON -eq 0
    if [[ $FOUND_ICON -eq 1 && $MISS_ICON -eq 0 ]]; then
        # all fine, we found an icon, non missing
        validation_info "$ICON_NAMES_REGEX" "All needed icons found!"
    elif [[ $FOUND_ICON -eq 0 && $MISS_ICON -eq 1 ]]; then
        # all icons are missing
        validation_error "$ICON_NAMES_REGEX" "No icons found! RPM must contain at least one icon, see: https://harbour.jolla.com/faq#Icons"
    elif [[ $FOUND_ICON -eq 1 && $MISS_ICON -eq 1 ]]; then
        # Some icons are missing
        validation_warning "$ICON_NAME_PATH" "Not all icons found! It is recommended that the rpm contains icons with the following sizes: $ICON_SIZES. See: https://harbour.jolla.com/faq#Icons"
    fi
}

#
# Path validations
#
validatepaths () {
    # Optional, might not need shared data
    check_directory_exists $SHARE_NAME

    if [ $USES_SAILFISH_QML_LAUNCHER -eq 1 ]; then
        # If the application is launched using "sailfish-qml", there must be no
        # application binary, as it's a QML-only app (binary will never be used)
        fail_if_file_exists $BIN_NAME "(.desktop file uses sailfish-qml)"
    else
        require_file_exists $BIN_NAME
    fi

    # Mandatory files
    require_file_exists $DESKTOP_NAME
    check_for_icons

    # Files and directories that must not exist
    fail_if_directory_exists $LIB_DEBUG_NAME "(Debug symbols must not be included)"
    fail_if_directory_exists $SRC_DEBUG_NAME "(Debug sources must not be included)"

    # Find all non-directories and empty directories, including hidden files/dirs
    # (to avoid reporting parent directories of files)
    while read rpm_file ; do
        rpm_file=${rpm_file#.}
        if [ "$rpm_file" = "/$SHARE_NAME" ]; then
            validation_warning "$rpm_file" "Empty directory"
        else
            validation_error "$rpm_file" "Installation not allowed in this location"
        fi
    done < <(eval "$FIND . -depth \( \( ! -type d \) -o \( -type d -a -size 0 \) \) $OPT_SORT" \
        | $EGREP -v -E "^./($BIN_NAME|$SHARE_NAME/.*|$DESKTOP_NAME|$ICON_NAMES_REGEX)$")

    # Accidentally added files
    while read filename; do
        filename=${filename#.}
        case "$filename" in
            *.git|*.svn|*.hg|*.bzr|*.cvs)
                validation_error "$filename" "Source control directories must not be included"
                ;;
            *)
                validation_error "$filename" "This kind of file must not be included"
        esac
    done < <(eval "$FIND . \( -name .git -o -name .svn -o -name .hg -o -name .bzr \
        -o -name .cvs -o -name .DS_Store -o -name *~ -o -name .*.swp \) $OPT_SORT")
}

#
# Desktop file validation
#
validatedesktopfile() {
    if [ ! -f $DESKTOP_NAME ]; then
        validation_error $DESKTOP_NAME "File is missing - cannot validate .desktop file"
        return
    fi

    VALID_NAME=`$GREP "^Name=" $DESKTOP_NAME | $GREP -Ev "^Name=$"`
    if [[ -z $VALID_NAME ]] ; then
        validation_error $DESKTOP_NAME "Missing valid Name declaration, must not be empty"
        INFO_MSG_PRINTED=1
    fi

    $GREP "^Icon=$NAME[[:space:]]*$" $DESKTOP_NAME >/dev/null 2>&1
    if [[ $? -ne 0 ]] ; then
        validation_error $DESKTOP_NAME "Missing valid Icon declaration, must be Icon=$NAME"
        INFO_MSG_PRINTED=1
    fi

    $GREP -E "^Exec(=|=sailfish-qml[[:space:]]+)$NAME" $DESKTOP_NAME >/dev/null 2>&1
    if [[ $? -ne 0 ]] ; then
        validation_error $DESKTOP_NAME "Missing valid Exec declaration, must be Exec=$NAME"
        INFO_MSG_PRINTED=1
    fi

    $GREP -E "^Exec=sailfish-qml[[:space:]]+$NAME" $DESKTOP_NAME  >/dev/null 2>&1
    if [[ $? -eq 0 ]] ; then
        validation_info $DESKTOP_NAME "Application is a QML-only app (sailfish-qml launcher)"
        USES_SAILFISH_QML_LAUNCHER=1
    fi

    $GREP "^Type=Application[[:space:]]*$" $DESKTOP_NAME  >/dev/null 2>&1
    if [[ $? -ne 0 ]] ; then
        validation_error $DESKTOP_NAME "Missing valid Type declaration"
        INFO_MSG_PRINTED=1
    fi

    $GREP "^\[Sailjail\]$" $DESKTOP_NAME  >/dev/null 2>&1
    if [[ $? -eq 0 ]] ; then
        validation_error $DESKTOP_NAME "Sailjail section not allowed (use X-Sailjail instead)"
        INFO_MSG_PRINTED=1
    fi

    $GREP "^\[X-Sailjail\]$" $DESKTOP_NAME  >/dev/null 2>&1
    if [[ $? -eq 0 ]] ; then
        validatexsailjail <<<$(sed '1,/^\[X-Sailjail\]/d;/\[/,$d' $DESKTOP_NAME)
    fi

    $GREP "^X-Nemo-Application-Type=silica-qt5[[:space:]]*$" $DESKTOP_NAME >/dev/null 2>&1
    if [[ $? -ne 0 ]] ; then
        if [ $USES_SAILFISH_SILICA_QML_IMPORT -eq 1 ]; then
            validation_warning $DESKTOP_NAME "X-Nemo-Application-Type should be silica-qt5 for apps importing Sailfish.Silica in QML"
            validation_info $DESKTOP_NAME "Set X-Nemo-Application-Type to silica-qt5 unless mapplauncherd can't start the application."
            validation_info $DESKTOP_NAME "See also: https://git.sailfishos.org/mer-core/mapplauncherd/blob/master/README"
            INFO_MSG_PRINTED=1
        fi
        if [ $USES_SAILFISH_QML_LAUNCHER -eq 1 ]; then
            # Assume that developers who write QML-only applications with the launcher also use
            # Silica components, and they have to use the silica-qt5 booster to start it up
            validation_error $DESKTOP_NAME "X-Nemo-Application-Type must be silica-qt5 for sailfish-qml apps"
            INFO_MSG_PRINTED=1
        else
            $EGREP "^X-Nemo-Application-Type=(no-invoker|generic|qtquick2|qt5)[[:space:]]*$" $DESKTOP_NAME >/dev/null 2>&1
            if [[ $? -ne 0 ]] ; then
                validation_error $DESKTOP_NAME "X-Nemo-Application-Type not declared (use silica-qt5 for QML apps)"
                INFO_MSG_PRINTED=1
            else
                validation_warning $DESKTOP_NAME "X-Nemo-Application-Type should be silica-qt5 (not a Silica app?)"
            fi
        fi
    fi

    if [ $INFO_MSG_PRINTED -eq 1 ]; then
        validation_info $DESKTOP_NAME "Please see our FAQ here: https://harbour.jolla.com/faq#.desktop-Files"
        INFO_MSG_PRINTED=0
    fi
}

validatexsailjail() {
    local validatedlinesfound=0
    while read line; do
        if [[ ! -z "$line" ]]; then
            validatesailjailkey "$line"
            validatedlinesfound=1
        fi
    done
    if [ $validatedlinesfound -eq 0 ]; then
        validation_error $DESKTOP_NAME "Empty X-Sailjail section not allowed"
        INFO_MSG_PRINTED=1
    fi
}

validatesailjailkey() {
    local key=$(echo $1 | sed "s/=.*//")
    local value=$(echo $1 | sed "s/[^=]*=\(.*\)/\1/")
    if ! check_contained_in "$key" $ALLOWED_SAILJAILKEYS; then
        validation_error $DESKTOP_NAME "X-Sailjail key is not allowed: $key"
        INFO_MSG_PRINTED=1
    elif [[ $key == Permissions ]]; then
        validatesailjailpermissions <<<$value
    elif [[ $key == OrganizationName ]]; then
        validateorganizationname "$value"
    elif [[ $key == ApplicationName ]]; then
        if [[ ! $value =~ ^[A-Za-z_-][A-Z0-9a-z_-]*$ ]]; then
            echo ApplicationName=$value
            validation_error "ApplicationName contains illegal characters"
            INFO_MSG_PRINTED=1
        fi
    fi
}

validateorganizationname () {
    if [[ ! $1 =~ ^[0-9a-z._-]+$ ]]; then
        validation_error $DESKTOP_NAME "Organization name contains illegal characters"
        INFO_MSG_PRINTED=1
    fi
    if [[ $1 =~ (^|[.])[0-9] ]]; then
        validation_error $DESKTOP_NAME "Organization name component may not start with a number"
        INFO_MSG_PRINTED=1
    fi
    if check_contained_in "$1" $DISALLOWED_ORGNAMES; then
        validation_error $DESKTOP_NAME "OrganizationName not allowed: $1"
        INFO_MSG_PRINTED=1
    fi
}

validatesailjailpermissions() {
    IFS=';' read -ra PERMISSIONS
    for permission in "${PERMISSIONS[@]}"; do
        if ! check_contained_in "$permission" $ALLOWED_PERMISSIONS; then
            validation_error $DESKTOP_NAME "X-Sailjail permission not allowed: $permission"
            INFO_MSG_PRINTED=1
        fi
    done
}

isLibraryAllowed() {
    if check_contained_in "$1" $ALLOWED_LIBRARIES; then
        :
    elif check_contained_in "$1" $DEPRECATED_LIBRARIES; then
        validation_warning "$2" "Shared library is deprecated: $1"
        INFO_MSG_PRINTED=1
    else
        # $LIB could be in /usr/share/app-name ?
        FOUND_LIB=$(eval $FIND $SHARE_NAME -name "$1" 2> /dev/null $OPT_SORT)
        if [[ -n $FOUND_LIB ]] ; then
            # OK it's an own lib, check that rpath is set correctly
            RPATH_CHECK_NEEDED=1
        else
            validation_error "$2" "Cannot link to shared library: $1"
            INFO_MSG_PRINTED=1
        fi
    fi
}

#
# Get list of linked libraries for a given binary / shared library
#
get_linked_libs() {
    $OBJDUMP -x "$1" 2> /dev/null | $GREP 'NEEDED' | $SED -e 's/\s\+/ /g' | $CUT -f 3 -d ' '
}

check_linked_libs() {
    for LIB in $(get_linked_libs "$1"); do
        isLibraryAllowed "$LIB" "$1"
    done
    if [ $INFO_MSG_PRINTED -eq 1 ]; then
        validation_info $1 "Please see our FAQ here: https://harbour.jolla.com/faq#Shared_Libraries"
        INFO_MSG_PRINTED=0
    fi
}

validateicon() {
    # Example output: "PNG image data, 86 x 86, 8-bit/color RGBA, non-interlaced"
    for SIZE in $ICON_SIZES; do
        ICON_NAME=$(echo $ICON_NAME_PATH | sed "s/@@SIZE@@/$SIZE/")
        SIZE_FILETYPE=$(echo $SIZE | sed 's/x/ x /')
        filetype=""

        if [[ -r $ICON_NAME && -s $ICON_NAME ]]; then
            filetype=$(file -b $ICON_NAME)
        else
            validation_warning "$ICON_NAME" "Icon not found!"
            continue
        fi

        case "$filetype" in
            "PNG image data, $SIZE_FILETYPE,"*)
            # OK, that's the image type we expect
            ;;
            PNG*)
                validation_error $ICON_NAME "Wrong size, must be $SIZE"
                validation_info $ICON_NAME "Detected as '$filetype'"
                validation_info $ICON_NAME "Please see our FAQ here: https://harbour.jolla.com/faq#Icons"
                ;;
            *)
                validation_error $ICON_NAME "Must be a PNG image"
                validation_info $ICON_NAME "Detected as '$filetype'"
                validation_info $ICON_NAME "Please see our FAQ here: https://harbour.jolla.com/faq#Icons"
                ;;
        esac
    done
}

#
# Library validations
#
validatelibraries() {
    # Go through all files to also find stray libs and executables
    while read binary ; do
        binary=${binary#./}
        filetype=$(file -b "$binary")
        # Example output: "ELF 32-bit LSB  shared object, ARM, EABI5 version 1 (SYSV), ..."

        case "$filetype" in
            ELF*32-bit*LSB*ARM* | ELF*32-bit*LSB*Intel* | ELF*64-bit*LSB*ARM*)
                if [[ $filetype == *not?stripped ]] ; then
                    validation_warning "$binary" "file is not stripped!"
                fi
                ARCH_DEPENDANT=1

                case "$binary" in
                    $BIN_NAME)
                        # Application main binary is obviously okay
                        ;;
                    $SHARE_NAME/lib/*.so.*|$SHARE_NAME/lib/*.so)
                        validation_info "$binary" "Private shared library shipped"
                        POSSIBLE_RPATH_CHECK_NEEDED=1
                        ;;
                    *.so.*|*.so)
                        if [ -f $(dirname $binary)/qmldir ]; then
                            # TODO: Check if the directory name is right ($NAME with "-" replaced with "/")
                            # TODO: Check if the qmldir references the shared library with the right name
                            validation_info "$binary" "Shared library for private QML import (qmldir found)"
                        else
                            validation_error "$binary" "Library in wrong location (must be in /$SHARE_NAME/lib/)"
                        fi
                        ;;
                    *)
                        validation_error "$binary" "ELF binary in wrong location (must be /$BIN_NAME)"
                        ;;
                esac

                ;;
            ELF*"LSB shared object, no machine"*)
                case "$binary" in
                    $SHARE_NAME/*.go)
                        validation_info "$binary" "Guile object file found"
                        ;;
                    *)
                        validation_error "$binary" "ELF binary with wrong arch or location: $filetype"
                        ;;
                esac
                ;;
            ELF*)
                validation_error "$binary" "ELF file with wrong arch: $filetype"
                ;;
            *)
                # Not an ELF file
                ;;
        esac

        check_linked_libs "$binary"
    done < <(eval $FIND . -type f -o -type l $OPT_SORT)
}

list_functions_in_elf() {
    BINARY=$1
    KIND=$2
    readelf --wide --syms $BINARY | c++filt | \
        while read _ _ _ SYMTYPE _ _ SYMIDX SYMNAME; do
            if [ "$SYMTYPE" = "FUNC" ]; then
                if [ "$KIND" = "UND" ]; then
                    if [ "$SYMIDX" = "UND" ]; then
                        echo "$SYMNAME"
                    fi
                else
                    if [ "$SYMIDX" != "UND" ]; then
                        echo "$SYMNAME"
                    fi
                fi
            fi
        done
}

list_defined_functions_in_elf() {
    list_functions_in_elf $1 DEF
}

list_undefined_functions_in_elf() {
    list_functions_in_elf $1 UND
}

#
# Symbol validations
#
validatesymbols() {
    if [ -x $BIN_NAME ]; then
        # Check if the library has a proper main function defined
        MAIN_SYMBOL=""
        if [ "$RPM_ARCH" == "armv7hl" ]; then
            MAIN_SYMBOL="__libc_start_main@GLIBC_$GLIBC_MAIN_VERSION_ARM"
        elif [ "$RPM_ARCH" == "i486" ]; then
            MAIN_SYMBOL="__libc_start_main@GLIBC_$GLIBC_MAIN_VERSION_I486"
        fi

        if ! list_undefined_functions_in_elf $BIN_NAME | $GREP -q "^${MAIN_SYMBOL}.*"; then
            validation_error $BIN_NAME "Binary does not link to $MAIN_SYMBOL."
        fi

        if ! list_defined_functions_in_elf $BIN_NAME | $GREP -q "^main$"; then
            if [ $USES_SAILFISH_SILICA_QML_IMPORT -eq 0 ]; then
                validation_warning $BIN_NAME "Binary does not export main() symbol - booster might fail"
            else
                validation_error $BIN_NAME "Binary must export main() symbol for booster to work (Q_DECL_EXPORT)"
            fi
        fi
    else
        if [ $USES_SAILFISH_QML_LAUNCHER -eq 0 ]; then
            validation_error $BIN_NAME "Main binary must be an executable ELF file"
        fi
    fi
}

#
# QML file validations
#
validateqmlfiles() {
    # TODO: seems also .js files can include imports! Qml types can be imported in .js files like : .import QtQuick.LocalStorage 2.0 as Sql
    # TODO: what if the developer does call his qml files .foo ?
    while read QML_FILE; do
        while read QML_IMPORT_LINE; do
            # break the qml import line down, it can have more than one
            # import statement separated by semicolons:
            #
            # import foo.zoo 1.0 as bar; import abc.def 1.0;

            while IFS=';' read -ra STATEMENT_ARRAY; do
                for IMPORT_STATEMENT in "${STATEMENT_ARRAY[@]}"; do
                    QML_IMPORT=$($SED -e 's/^\s*import/import/' -e 's/\s\+/ /g' -e 's/ as .*$//' -e 's/;$//' <<< $IMPORT_STATEMENT | $CUT -f2-3 -d ' ')

                    SAILFISH_SILICA_IMPORT="Sailfish.Silica 1.0"
                    if [ "$QML_IMPORT" = "$SAILFISH_SILICA_IMPORT" ]; then
                        if [ $USES_SAILFISH_SILICA_QML_IMPORT -eq 0 ]; then
                            validation_info "$QML_FILE" "Uses Sailfish Silica Components (only reported once)"
                            USES_SAILFISH_SILICA_QML_IMPORT=1
                        fi
                    fi
                    XML_LIST_MODEL_IMPORT="QtQuick.XmlListModel"
                    if [[ "$QML_IMPORT" =~ ^${XML_LIST_MODEL_IMPORT}.* ]]; then
                        USES_XML_LIST_MODEL_QML_IMPORT=1
                    fi

                    # easy things first, is it whitelisted ?
                    if check_contained_in "$QML_IMPORT" $ALLOWED_QMLIMPORTS; then
                        continue
                    elif check_contained_in "$QML_IMPORT" $DEPRECATED_QMLIMPORTS; then
                        validation_warning "$QML_FILE" "Import '$QML_IMPORT' is deprecated"
                        INFO_MSG_PRINTED=1
                        continue
                    else
                        # is it a file import "foo.js" or similar ?
                        if [[ $QML_IMPORT =~ ^[\"\'](.*)[\"\'] ]] ; then
                            QML_IMPORT_PATH=${BASH_REMATCH[1]}
                            if [[ ${QML_IMPORT:1:1} == / ]] ; then
                                # absolute path imports are forbidden
                                # this allows us to evt. relocate the rpm install
                                validation_error "$QML_FILE"  "Import '$QML_IMPORT' is not valid - absolute path imports are forbidden, please use relative paths"
                                continue
                            elif [[ -e $(dirname "$QML_FILE")/$QML_IMPORT_PATH ]] ; then
                                # relative paths are allowed
                                # but we have to ensure it stays in the app folder
                                REAL_QML_IMPORT_PATH=$(readlink -f $(dirname "$QML_FILE")/$QML_IMPORT_PATH)
                                REAL_SHARE_NAME_PATH=$(readlink -f $SHARE_NAME)
                                if [[ "${REAL_QML_IMPORT_PATH##$REAL_SHARE_NAME_PATH}" != "$REAL_QML_IMPORT_PATH" ]] ; then
                                    # ok all fine the path points to a path under /usr/share/app-name/
                                    continue
                                else
                                    validation_error "$QML_FILE" "Import '$QML_IMPORT' is not valid - the relative path points outside of '$SHARE_NAME' this is not allowed"
                                fi
                            elif [[ ${QML_IMPORT:1:5} == qrc:/ ]] ; then
                                # built in resources are ok
                                continue
                            else
                                validation_error "$QML_FILE" "Import '$QML_IMPORT' is not valid - the path points to an unsupported external path"
                            fi
                        else
                            # allow all except explicitly disallowed modules
                            if ! check_contained_in "$QML_IMPORT" $DISALLOWED_QMLIMPORTS; then
                                continue
                            fi
                        fi
                        # XXX: Where is the corresponding error message for this?
                        RC=1
                    fi

                    if [[ $RC -gt 0 ]] ; then
                        validation_error "$QML_FILE" "Import '$QML_IMPORT' is not allowed"
                        INFO_MSG_PRINTED=1
                    fi
                done
            done <<< "$QML_IMPORT_LINE"
        done < <($GREP -e '^[[:space:]]*import[[:space:]]' "$QML_FILE" | $SED -e 's/\x0D$//')
    done < <(eval $FIND $SHARE_NAME -name \*.qml 2> /dev/null $OPT_SORT)

    if [ $INFO_MSG_PRINTED -eq 1 ]; then
        validation_info $NAME "Please see our FAQ here: https://harbour.jolla.com/faq#QML_API"
        INFO_MSG_PRINTED=0
    fi
}

#
# Name validation
#
validatenames() {
    # Regular expression against which the name must be matched
    NAME_REGEX='^harbour-[-a-z0-9_\.]+$'

    echo $NAME | $EGREP -q $NAME_REGEX
    if [[ $? -ne 0 ]] ; then
        validation_error $NAME "Name is not valid. Must start with 'harbour-', matching '$NAME_REGEX'."
        validation_info $NAME "Please see our FAQ here: https://harbour.jolla.com/faq#Naming"
    else
        NAME_CHECK_PASSED=1
    fi
}

#
# RPM file name validation
# must follow: http://www.rpm.org/max-rpm/ch-rpm-file-format.html
# name-version-release.architecture.rpm
#
validaterpmfilename(){
    RPM_ARCH=$($RPM -q --queryformat='%{ARCH}' -p $RPM_NAME)
    RPM_VERSION=$($RPM -q --queryformat='%{VERSION}' -p $RPM_NAME)
    RPM_RELEASE=$($RPM -q --queryformat='%{RELEASE}' -p $RPM_NAME)

    EXPECTED_RPM_FILE_NAME="${NAME}-${RPM_VERSION}-${RPM_RELEASE}.${RPM_ARCH}.rpm"
    CURRENT_RPM_FILE_NAME=$(basename $RPM_NAME)

    if [[ ! $RPM_VERSION =~ ^[0-9.]+$ ]]; then
        validation_error $RPM_VERSION "rpm version must contain only digits (0-9) and periods (.)"
    fi

    if [[ ! $RPM_RELEASE =~ ^[0-9._]+$ ]]; then
        validation_error $RPM_RELEASE "rpm release must contain only digits (0-9), underscores (_) and periods (.)"
    fi

    if [[ $RPM_ARCH != @(armv7hl|aarch64|i486|noarch) ]]; then
        validation_error $CURRENT_RPM_FILE_NAME \
            "Architecture must be armv7hl, aarch64, i486 or noarch"
    fi

    if [[ $NAME_CHECK_PASSED == 1 ]]; then
        # the EXPECTED_RPM_FILE_NAME can be trusted, it is correct!
        if [[ ${EXPECTED_RPM_FILE_NAME} != ${CURRENT_RPM_FILE_NAME} ]]; then
            validation_error $CURRENT_RPM_FILE_NAME "rpm file name is not valid, expected to be: '$EXPECTED_RPM_FILE_NAME'"
            validation_info $NAME "Please see our FAQ here: https://harbour.jolla.com/faq#Naming"
        fi
    else
        # the EXPECTED_RPM_FILE_NAME can not be trusted
        validation_warning $CURRENT_RPM_FILE_NAME "rpm file name can not be verified for sure ('Package name' check failed), ensure it to be: harbour-name-version-release.architecture.rpm"
    fi
}

#
# helper fuction for validatepermissions
#
isWritable() {
    # remember in bash true = 0, false = 1
    case "$1" in
        "2" | "3" | "6" | "7" )
            # 2 = writable
            # 3 = writable + executable
            # 6 = writable + readable
            # 7 = writable + readable + executable
            return 0
            ;;
        *)
            # 1 = executable
            # 4 = readable
            # 5 = readable + executable
            return 1
            ;;
    esac
}

isExecutable() {
    # remember in bash true = 0, false = 1
    case "$1" in
        "1" | "3" | "5" | "7" )
            # 1 = executable
            # 3 = writable + executable
            # 5 = readable + executable
            # 7 = writable + readable + executable
            return 0
            ;;
        *)
            # 2 = writable
            # 4 = readable
            # 6 = writable + readable
            return 1
            ;;
    esac
}

#
# Permission validation
#
validatepermissions() {
    # Validate directory
    while IFS=$'\a' read FULL_PERM OWNER_USER OWNER_GROUP PATH_NAME; do
        FILE_TYPE=${FULL_PERM: -6:2}
        OWNER_PERM=${FULL_PERM: -3:1}
        GROUP_PERM=${FULL_PERM: -2:1}
        OTHERS_PERM=${FULL_PERM: -1:1}
        SU_PERM=${FULL_PERM: -4:1}

        # FILE_TYPE 04 = dir
        if [[ $FILE_TYPE -eq "04" ]] ; then
            if isWritable $GROUP_PERM ; then
                validation_error "$PATH_NAME" "Group-writable directory"
            fi
            if isWritable $OTHERS_PERM ; then
                validation_error "$PATH_NAME" "World-writable directory"
            fi
        fi
        # FILE_TYPE 10 = file
        if [[ $FILE_TYPE == "10" ]] ; then
            if [[ $SU_PERM -gt 0 ]] ; then
            validation_error "$PATH_NAME" "setuid, setgid or sticky bit set"
            fi

            filename=${PATH_NAME#/}
            case $filename in
                $BIN_NAME|$SHARE_NAME/*.so|$SHARE_NAME/*.so.*)
                    # Binary should (obviously) be executable
                    # Shipped private shared libraries can be, too
                    ;;
                *)
                    if isExecutable $OWNER_PERM || isExecutable $GROUP_PERM || isExecutable $OTHERS_PERM ; then
                        validation_error "$PATH_NAME" "File must not be executable (current permissions: ${OWNER_PERM}${GROUP_PERM}${OTHERS_PERM})"
                    fi
                    ;;
            esac
        fi

        if [[ $OWNER_USER != "root" ]] ; then
            validation_error "$PATH_NAME" "Owner is '$OWNER_USER', should be 'root'"
        fi

        if [[ $OWNER_GROUP != "root" ]] ; then
            validation_error "$PATH_NAME" "Group is '$OWNER_GROUP', should be 'root'"
        fi

    done < <($RPM -q --queryformat "[%{FILEMODES:octal}\a%{FILEUSERNAME}\a%{FILEGROUPNAME}\a%{FILENAMES}\n]" -p $RPM_NAME)
}

#
# Pre and post installation script validation
#
validatescripts() {
    SCRIPTINFO=$($RPM -qp --scripts $RPM_NAME | $GREP -o '^.*scriptlet.*:$' | $CUT -f 1 -d ' ')
    for script in $SCRIPTINFO; do
        validation_error "$script" "RPM '$script' script not allowed"
    done
}

suggest_autoreqprov() {
    if [ $INFO_MSG_PRINTED -eq 1 ]; then
        validation_info $NAME "Please see our FAQ here: https://harbour.jolla.com/faq#2.6.0 how to use '__provides_exclude_from' and '__requires_exclude' .spec file to avoid that"
        INFO_MSG_PRINTED=0
    fi
}

validaterpmprovides() {
    PROVIDES=$($RPM -q --queryformat '[%{PROVIDES}\n]\n' -p $RPM_NAME)

    for provide in $PROVIDES; do
        case "$provide" in
            ${NAME}*|"application()"|"application(${NAME}.desktop)")
                # Do nothing
                ;;
            lib*.so.*|lib*.so)
                validation_error "$provide" "'Provides: $provide' not allowed in RPM"
                suggest_autoreqprov "$provide"
                ;;
            *)
                validation_error "$provide" "'Provides: $provide' not allowed in RPM"
                ;;
        esac
    done
}

validaterpmobsoletes() {
    OBSOLETES=$($RPM -q --queryformat '[ %{OBSOLETES} ]\n' -p $RPM_NAME)

    for obsolete in $OBSOLETES; do
        validation_error "$obsolete" "'Obsoletes: $obsolete' not allowed in RPM"
    done
}

validaterpmrequires() {
    REQUIRES=$($RPM -q --queryformat '[ %{REQUIRES} ]\n' -p $RPM_NAME)

    FOUND_LIBSAILFISHAPP_LAUNCHER=0
    LIBSAILFISHAPP_LAUNCHER_PACKAGE=libsailfishapp-launcher
    FOUND_IMPORT_XMLLISTMODEL=0
    IMPORT_XMLLISTMODEL_PACKAGE=qt5-qtdeclarative-import-xmllistmodel
    for require in $REQUIRES; do
        if check_contained_in "$require" $ALLOWED_REQUIRES; then
            # This is a whitelisted requirement, don't do further checks
            case "$require" in
                $IMPORT_XMLLISTMODEL_PACKAGE)
                    FOUND_IMPORT_XMLLISTMODEL=1
                    ;;
            esac
            continue
        fi

        if check_contained_in "$require" $DEPRECATED_REQUIRES; then
            validation_warning "$require" "Dependency is deprecated"
            INFO_MSG_PRINTED=1
            continue
        fi

        case "$require" in
            rpmlib\(*\)|rtld\(GNU_HASH\))
                # For now, we simply accept all rpmlib(...) dependencies, we
                # could theoretically add a fixed set of features here later
                ;;
            $LIBSAILFISHAPP_LAUNCHER_PACKAGE)
                FOUND_LIBSAILFISHAPP_LAUNCHER=1
                if [ $USES_SAILFISH_QML_LAUNCHER -eq 0 ]; then
                    validation_error "$require" "Invalid 'Requires: $require' in library"
                    validation_info "$require" "Remove this dependency (sailfish-qml launcher not used in .desktop file)"
                fi
                ;;
            lib*.so.*|lib*.so)
                # Additional shared library dependencies
                validation_error "$require" "Cannot require shared library: '$require'"
                INFO_MSG_PRINTED=1
                ;;
            *)
                # Some other unknown dependency that we don't know about
                validation_error "$require" "Dependency not allowed"
                INFO_MSG_PRINTED=1
                ;;
        esac
    done
    suggest_autoreqprov "$1"

    # Case where developer has a qml-only app (sailfish-qml is used), but the RPM
    # doesn't depend on libsailfishapp-launcher (which contains sailfish-qml)
    if [ $USES_SAILFISH_QML_LAUNCHER -eq 1 -a $FOUND_LIBSAILFISHAPP_LAUNCHER -eq 0 ]; then
        validation_error "$LIBSAILFISHAPP_LAUNCHER_PACKAGE" "Add 'Requires: $LIBSAILFISHAPP_LAUNCHER_PACKAGE' to the .spec file"
    fi

    # qt5-qtdeclarative-import-xmllistmodel is not by default on device, but gets installed
    # with fingerterm, so it works fine for QA testers
    if [ $USES_XML_LIST_MODEL_QML_IMPORT -eq 1 -a $FOUND_IMPORT_XMLLISTMODEL -eq 0 ]; then
        validation_error "$IMPORT_XMLLISTMODEL_PACKAGE" "Use of 'XmlListModel' detected, but rpm does not require it! Add 'Requires: $IMPORT_XMLLISTMODEL_PACKAGE' to the .spec file"
    fi
}

suggest_xdg_basedir() {
    if [ $SUGGESTED_XDG_BASEDIR -eq 0 ]; then
        validation_info "$1" "Please do not hard code the path to any subfolders in /home/nemo or other home directories. As a rule of thumb follow the XDG Base Directory Specification and use \$HOME instead of hardcoded paths."
        validation_info "$1" "Please see our FAQ here: https://harbour.jolla.com/faq#2.13.0"
        SUGGESTED_XDG_BASEDIR=1
    fi
}

validatesandboxing() {
    while read filename; do
        # TODO: fix prober, but this seems to work around the out of file
        # descriptor issue
        (true)
        filename=${filename#./}
        while read match; do
            validation_error "/$filename" "Hardcoded path: $match"
            suggest_xdg_basedir "$filename"
        done < <(strings "$filename" | $EGREP "/home/(nemo|defaultuser)/")
    done < <(eval $FIND . ! -type d $OPT_SORT)
}

validaterpath() {
    RPATH_OK=0
    LOCACTIONS_SHOWN=0
    SHOW_URLS=0

    BIN_RPATH_STR=$(readelf -d ./${BIN_NAME} | $GREP 'Library rpath:' | $SED -e 's/\s\+/ /g' | $CUT -f 6 -d ' ' | $SED -e 's/\[//' -e 's/\]//')
    if [[ -z ${BIN_RPATH_STR} ]]; then
        validation_info "${BIN_NAME}" "rpath in binary is empty!"
    fi
    BIN_RPATH_ARR=$(echo ${BIN_RPATH_STR} | tr ":" "\n")

    for BIN_RPATH in ${BIN_RPATH_ARR}; do
        if   [[ ${BIN_RPATH} == \$ORIGIN/../share/${NAME}/lib ]]; then
            RPATH_OK=1
        elif [[ ${BIN_RPATH} == \$ORIGIN/../share/${NAME}/lib/ ]]; then
            RPATH_OK=1
        elif [[ ${BIN_RPATH} == /usr/share/${NAME}/lib ]]; then
            RPATH_OK=1
        elif [[ ${BIN_RPATH} == /usr/share/${NAME}/lib/ ]]; then
            RPATH_OK=1
        else
            validation_warning "${BIN_NAME}" "rpath '${BIN_RPATH}' in binary does not point to an allowed location!"
            if [[ $LOCACTIONS_SHOWN -eq 0 ]]; then
                validation_info "allowed location:" "/usr/share/${NAME}/lib"
                validation_info "allowed location:" "\$ORIGIN/../share/${NAME}/lib"
                validation_info "allowed:" "Trailing slash in path name is allowed."
                LOCACTIONS_SHOWN=1
            fi
            RPATH_OK=0
        fi
    done

    if [[ ${RPATH_OK} -eq 0 && $RPATH_CHECK_NEEDED -eq 1 ]] ; then
        validation_info "${CURRENT_RPM_FILE_NAME}" "The RPM contains shared libraries, the rpath in the binary must be set accordingly."
        validation_error "${BIN_NAME}" "The rpath in binary is not allowed: '${BIN_RPATH_STR}'"
        SHOW_URLS=1
    elif [[ ${RPATH_OK} -eq 0 && $RPATH_CHECK_NEEDED -eq 0 && $POSSIBLE_RPATH_CHECK_NEEDED -eq 1 ]] ; then
        validation_warning "${CURRENT_RPM_FILE_NAME}" "The RPM contains shared libraries, but it can't be determined for sure if they are needed by the binary, if so then the rpath must be set accordingly."
        SHOW_URLS=1
    else
        validation_success "rpath in binary seems to be ok: '${BIN_RPATH_STR:-empty}'"
    fi

    if [[ $SHOW_URLS -eq 1 ]]; then
        validation_info "See also:" "https://harbour.jolla.com/faq#6.3.0"
        validation_info "See also:" "https://together.jolla.com/question/10713/create-the-example-of-including-your-own-library-and-standard-qt-module-in-a-harbour-compatible-way/#14098"
    fi
}

validatearch(){
    if [[ $RPM_ARCH != "noarch" && $USES_SAILFISH_QML_LAUNCHER -eq 1 && $ARCH_DEPENDANT -eq 0 ]]; then
        validation_warning $CURRENT_RPM_FILE_NAME "QML-only RPMs should be 'noarch', but it is '$RPM_ARCH'"
    fi
}

validatevendor(){
    RPM_VENDOR=$($RPM -q --queryformat='%{VENDOR}' -p $RPM_NAME)
    RPM_VENDOR_SIZE=$($RPM -q --queryformat='%{VENDOR:arraysize}' -p $RPM_NAME)

    if [[ $RPM_VENDOR_SIZE == "(none)" && $RPM_VENDOR == "(none)" ]]; then
        validation_success "No vendor set!"
        return
    fi

    if [[ $RPM_VENDOR_SIZE -eq 1 && $RPM_VENDOR == "meego" ]]; then
        validation_warning $CURRENT_RPM_FILE_NAME "Vendor is set to 'meego'! This is not recommended, unless your previous submissions to Harbour have the vendor set to 'meego' also. Do this only if you know what you are doing!"
        return
    fi

    validation_error $CURRENT_RPM_FILE_NAME "Vendor in RPM package is set to '$RPM_VENDOR'. Setting a vendor in RPM package is not allowed!"
}

#
# Validations
#
rpmvalidation () {
    pushd $TMP_DIR >/dev/null 2>&1

    echo -e "\n"

    if [ ! -z $BATCHERBATCHERBATCHER ]; then
        echo "!BEGIN!$RPM_NAME"
    fi

    run_validator "Package name" validatenames
    # needs to run after validatenames, due to NAME_CHECK_PASSED flag
    run_validator "RPM file name" validaterpmfilename

    # These checks set the USES_* variables, so we need to run them in this order
    # to make sure the variables are already set when needed (QML, Desktop, ...)
    # "Desktop file" must run after "RPM file name" so $RPM_ARCH is set
    run_validator "QML files" validateqmlfiles
    run_validator "Desktop file" validatedesktopfile

    run_validator "Paths" validatepaths
    run_validator "Libraries" validatelibraries
    run_validator "Icon" validateicon
    # needs to run after validaterpmfilename, needs $RPM_ARCH
    run_validator "Symbols" validatesymbols
    run_validator "Permissions" validatepermissions
    run_validator "Scripts" validatescripts
    run_validator "Provides" validaterpmprovides
    run_validator "Obsoletes" validaterpmobsoletes
    # has to run after validateqmlfiles
    run_validator "Requires" validaterpmrequires
    run_validator "Sandboxing" validatesandboxing
    # "RPATH" and "Architecture" need to run after 'Libraries' so RPATH_CHECK_NEEDED and ARCH_DEPENDANT are set
    # "RPATH" and "Architecture" need to run after 'RPM file name' so CURRENT_RPM_FILE_NAME and RPM_ARCH are set
    # "RPATH" and "Architecture" need to run after 'Desktop file' so USES_SAILFISH_QML_LAUNCHER is set correctly
    if [[ $USES_SAILFISH_QML_LAUNCHER -eq 0 ]] ; then
        run_validator "RPATH" validaterpath
    fi
    run_validator "Architecture" validatearch
    run_validator "Vendor check" validatevendor

    if [ -z $BATCHERBATCHERBATCHER ]; then
        echo -e "\n"

        if [[ $RC -ne 1 ]] ; then
            echo -e "Validation succeeded: $(incolor 32 $RPM_NAME)"
        else
            echo -e "Validation failed: $(incolor 31 $RPM_NAME)"
        fi
    else
        if [ $RC -eq 0 ]; then
            echo "!END!PASS!$RPM_NAME"
        else
            echo "!END!FAIL!$RPM_NAME"
        fi
    fi

    popd  >/dev/null 2>&1

    return $RC
}

#
# Clean up
#
rpmcleanup () {
    if [[ -n $TMP_DIR ]] ; then
        log_debug "Clean up"
        rm -rf $TMP_DIR
    fi
}


###########################
# Main
###########################

rpmprepare $@

if [[ $RC -eq 0 ]] ; then
    rpmvalidation
fi

# cleaning up is done by the EXIT trap

exit $RC

# For Emacs:
# Local Variables:
# indent-tabs-mode:nil
# tab-width:4
# End:
# For VIM:
# vim:set softtabstop=4 shiftwidth=4 tabstop=4 expandtab:
