#!/bin/bash
# vim:set softtabstop=4 shiftwidth=4 tabstop=4 expandtab:
#
# Copyright (C) 2014 Jolla Ltd.
# Contact: Reto Zingg <reto.zingg@jolla.com>
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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#

usage() {
    cat <<EOF
Run some basic tests with rpmvalidation.sh

Usage:
   $0 [OPTION]

Options:
   -g | --generate      generate expected output files
   -h | --help          this help

EOF
    # exit if any argument is given
    [[ -n "$1" ]] && exit 1
}

function parseCommandLineOptions () {
    OPT_GENERATE=0
    # parse command line options
    while [[ ${1:-} ]]; do
        case "$1" in
            -h | --help) shift
                usage quit
                ;;
            -g | --generate) shift
                OPT_GENERATE=1
                ;;
            -*)
                usage quit
                ;;
            *)
                ;;
        esac
    done
}

function oneTimeSetUp() {
    RPMVALITATOR="${SCRIPT_DIR}/../rpmvalidation.sh --sort --config-dir ${SCRIPT_DIR}/.."
    RPMS_DIR="${SCRIPT_DIR}/rpms"
    EXPECTED_DIR="${SCRIPT_DIR}/expected_outputs"
    SED_FILTER="${SCRIPT_DIR}/output_filter.sed"
    DIFF_OPTS="--ignore-space-change --ignore-blank-lines"
    HB_GOOD_ARM_RPM="harbour-good-0.5-1.armv7hl.rpm"
    HB_GOOD_x86_RPM="harbour-good-0.5-1.i586.rpm"
    HB_BAD_ARM_RPM="harbour-bad-0.2-1.armv7hl.rpm"
    HB_BAD_x86_RPM="harbour-bad-0.2-1.i586.rpm"
    if [[ ${OPT_GENERATE} -eq 0 ]] ; then
        # normal case for test runs
        OUTPUT_DIR=${SHUNIT_TMPDIR}
    else
        # --generate is set, so EXPECTED_DIR = OUTPUT_DIR
        # not used for real test run but to generate the
        # expected output, when something changed
        OUTPUT_DIR=${EXPECTED_DIR}
    fi
} 

function testHarbourGoodArm() {
    ${RPMVALITATOR} ${RPMS_DIR}/${HB_GOOD_ARM_RPM} 2>&1 | ${SED_FILTER} > ${OUTPUT_DIR}/testHarbourGoodArm.txt
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testHarbourGoodArm.txt ${OUTPUT_DIR}/testHarbourGoodArm.txt
    assertTrue 'Expected output differs.' $?
}

function testHarbourGoodArmNoColor() {
    ${RPMVALITATOR} --no-color ${RPMS_DIR}/${HB_GOOD_ARM_RPM} 2>&1 | ${SED_FILTER} > ${OUTPUT_DIR}/testHarbourGoodArmNoColor.txt
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testHarbourGoodArmNoColor.txt ${OUTPUT_DIR}/testHarbourGoodArmNoColor.txt
    assertTrue 'Expected output differs.' $?
}

function testHarbourBadArm() {
    ${RPMVALITATOR} ${RPMS_DIR}/${HB_BAD_ARM_RPM} 2>&1 | ${SED_FILTER} > ${OUTPUT_DIR}/testHarbourBadArm.txt
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testHarbourBadArm.txt ${OUTPUT_DIR}/testHarbourBadArm.txt
    assertTrue 'Expected output differs.' $?
}

function testHarbourBadArmNoColor() {
    ${RPMVALITATOR} --no-color ${RPMS_DIR}/${HB_BAD_ARM_RPM} 2>&1 | ${SED_FILTER} > ${OUTPUT_DIR}/testHarbourBadArmNoColor.txt
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testHarbourBadArmNoColor.txt ${OUTPUT_DIR}/testHarbourBadArmNoColor.txt
    assertTrue 'Expected output differs.' $?
}

function testHarbourGoodIntel() {
    ${RPMVALITATOR} ${RPMS_DIR}/${HB_GOOD_x86_RPM} 2>&1 | ${SED_FILTER} > ${OUTPUT_DIR}/testHarbourGoodIntel.txt
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testHarbourGoodIntel.txt ${OUTPUT_DIR}/testHarbourGoodIntel.txt
    assertTrue 'Expected output differs.' $?
}

function testHarbourBadIntel() {
    ${RPMVALITATOR} ${RPMS_DIR}/${HB_BAD_x86_RPM} 2>&1 | ${SED_FILTER} > ${OUTPUT_DIR}/testHarbourBadIntel.txt
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testHarbourBadIntel.txt ${OUTPUT_DIR}/testHarbourBadIntel.txt
    assertTrue 'Expected output differs.' $?
}

function testBadFileName() {
    ${RPMVALITATOR} ${RPMS_DIR}/bad-file-name.rpm 2>&1 | ${SED_FILTER} > ${OUTPUT_DIR}/testBadFileName.txt
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testBadFileName.txt ${OUTPUT_DIR}/testBadFileName.txt
    assertTrue 'Expected output differs.' $?
}

function testNotAnRpm() {
    ${RPMVALITATOR} ${RPMS_DIR}/some-random-file.rpm 2>&1 | ${SED_FILTER} > ${OUTPUT_DIR}/testNotAnRpm.txt
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testNotAnRpm.txt ${OUTPUT_DIR}/testNotAnRpm.txt
    assertTrue 'Expected output differs.' $?
}
 
function testBadFileNameNoColor() {
    ${RPMVALITATOR} --no-color ${RPMS_DIR}/bad-file-name.rpm 2>&1 | ${SED_FILTER} > ${OUTPUT_DIR}/testBadFileNameNoColor.txt
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testBadFileNameNoColor.txt ${OUTPUT_DIR}/testBadFileNameNoColor.txt
    assertTrue 'Expected output differs.' $?
}

function testNotAnRpmNoColor() {
    ${RPMVALITATOR} --no-color ${RPMS_DIR}/some-random-file.rpm 2>&1 | ${SED_FILTER} > ${OUTPUT_DIR}/testNotAnRpmNoColor.txt
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testNotAnRpmNoColor.txt ${OUTPUT_DIR}/testNotAnRpmNoColor.txt
    assertTrue 'Expected output differs.' $?
}

function testHarborBadArm() {
    ${RPMVALITATOR} ${RPMS_DIR}/harbor-bad-0.1-1.armv7hl.rpm 2>&1 | ${SED_FILTER} > ${OUTPUT_DIR}/testHarborBadArm.txt
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testHarborBadArm.txt ${OUTPUT_DIR}/testHarborBadArm.txt
    assertTrue 'Expected output differs.' $?
}

## Call and Run all Tests
parseCommandLineOptions $@
SCRIPT_DIR=$(dirname $(readlink -f $0))
# the positional parameters are unset ($@, $#, $*)
# we don't want them to be passed to shunit2 so it works in source mode
set --
. "${SCRIPT_DIR}/shunit2/shunit2"

