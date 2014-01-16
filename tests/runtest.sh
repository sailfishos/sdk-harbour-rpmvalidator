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

function oneTimeSetUp() {
    RPMVALITATOR="${SCRIPT_DIR}/../rpmvalidation.sh --sort --config-dir ${SCRIPT_DIR}/.."
    RPMS_DIR="${SCRIPT_DIR}/rpms"
    EXPECTED_DIR="${SCRIPT_DIR}/expected_outputs"
    SED_FILTER="${SCRIPT_DIR}/output_filter.sed"
    DIFF_OPTS="--ignore-space-change --ignore-blank-lines"
    HB_GOOD_ARM_RPM="harbour-good-0.5-1.armv7hl.rpm"
    HB_GOOD_x86_RPM="harbour-good-0.5-1.i586.rpm"
    HB_BAD_ARM_RPM="harbour-bad-0.1-1.armv7hl.rpm"
    HB_BAD_x86_RPM="harbour-bad-0.1-1.i586.rpm"
} 

function testHarbourGoodArm() {
    ${RPMVALITATOR} ${RPMS_DIR}/${HB_GOOD_ARM_RPM} 2>&1 | ${SED_FILTER} > ${SHUNIT_TMPDIR}/testHarbourGoodArm.txt 
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testHarbourGoodArm.txt ${SHUNIT_TMPDIR}/testHarbourGoodArm.txt
    assertTrue 'Expected output differs.' $?
}

function testHarbourGoodArmNoColor() {
    ${RPMVALITATOR} --no-color ${RPMS_DIR}/${HB_GOOD_ARM_RPM} 2>&1 | ${SED_FILTER} > ${SHUNIT_TMPDIR}/testHarbourGoodArmNoColor.txt 
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testHarbourGoodArmNoColor.txt ${SHUNIT_TMPDIR}/testHarbourGoodArmNoColor.txt
    assertTrue 'Expected output differs.' $?
}

function testHarbourBadArm() {
    ${RPMVALITATOR} ${RPMS_DIR}/${HB_BAD_ARM_RPM} 2>&1 | ${SED_FILTER} > ${SHUNIT_TMPDIR}/testHarbourBadArm.txt 
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testHarbourBadArm.txt ${SHUNIT_TMPDIR}/testHarbourBadArm.txt
    assertTrue 'Expected output differs.' $?
}

function testHarbourBadArmNoColor() {
    ${RPMVALITATOR} --no-color ${RPMS_DIR}/${HB_BAD_ARM_RPM} 2>&1 | ${SED_FILTER} > ${SHUNIT_TMPDIR}/testHarbourBadArmNoColor.txt 
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testHarbourBadArmNoColor.txt ${SHUNIT_TMPDIR}/testHarbourBadArmNoColor.txt
    assertTrue 'Expected output differs.' $?
}

function testHarbourGoodIntel() {
    ${RPMVALITATOR} ${RPMS_DIR}/${HB_GOOD_x86_RPM} 2>&1 | ${SED_FILTER} > ${SHUNIT_TMPDIR}/testHarbourGoodIntel.txt 
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testHarbourGoodIntel.txt ${SHUNIT_TMPDIR}/testHarbourGoodIntel.txt
    assertTrue 'Expected output differs.' $?
}

function testHarbourBadIntel() {
    ${RPMVALITATOR} ${RPMS_DIR}/${HB_BAD_x86_RPM} 2>&1 | ${SED_FILTER} > ${SHUNIT_TMPDIR}/testHarbourBadIntel.txt 
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testHarbourBadIntel.txt ${SHUNIT_TMPDIR}/testHarbourBadIntel.txt
    assertTrue 'Expected output differs.' $?
}

function testBadFileName() {
    ${RPMVALITATOR} ${RPMS_DIR}/bad-file-name.rpm 2>&1 | ${SED_FILTER} > ${SHUNIT_TMPDIR}/testBadFileName.txt 
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testBadFileName.txt ${SHUNIT_TMPDIR}/testBadFileName.txt
    assertTrue 'Expected output differs.' $?
}

function testNotAnRpm() {
    ${RPMVALITATOR} ${RPMS_DIR}/some-random-file.rpm 2>&1 | ${SED_FILTER} > ${SHUNIT_TMPDIR}/testNotAnRpm.txt 
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testNotAnRpm.txt ${SHUNIT_TMPDIR}/testNotAnRpm.txt
    assertTrue 'Expected output differs.' $?
}
 
function testBadFileNameNoColor() {
    ${RPMVALITATOR} --no-color ${RPMS_DIR}/bad-file-name.rpm 2>&1 | ${SED_FILTER} > ${SHUNIT_TMPDIR}/testBadFileNameNoColor.txt 
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testBadFileNameNoColor.txt ${SHUNIT_TMPDIR}/testBadFileNameNoColor.txt
    assertTrue 'Expected output differs.' $?
}

function testNotAnRpmNoColor() {
    ${RPMVALITATOR} --no-color ${RPMS_DIR}/some-random-file.rpm 2>&1 | ${SED_FILTER} > ${SHUNIT_TMPDIR}/testNotAnRpmNoColor.txt 
    diff ${DIFF_OPTS} ${EXPECTED_DIR}/testNotAnRpmNoColor.txt ${SHUNIT_TMPDIR}/testNotAnRpmNoColor.txt
    assertTrue 'Expected output differs.' $?
}

## Call and Run all Tests
SCRIPT_DIR=$(dirname $(readlink -f $0))
. "${SCRIPT_DIR}/shunit2/shunit2"

