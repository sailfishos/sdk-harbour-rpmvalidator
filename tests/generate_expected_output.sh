#!/bin/bash
# vim:set softtabstop=4 shiftwidth=4 tabstop=4 expandtab:
#
# Copyright (C) 2013 - 2014 Jolla Ltd.
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

SCRIPT_DIR=$(dirname $(readlink -f $0))
RPMVALITATOR="${SCRIPT_DIR}/../rpmvalidation.sh --sort --config-dir ${SCRIPT_DIR}/.."
RPMS_DIR="${SCRIPT_DIR}/rpms"
EXPECTED_DIR="${SCRIPT_DIR}/expected_outputs"
SED_FILTER="${SCRIPT_DIR}/output_filter.sed"
HB_GOOD_ARM_RPM="harbour-good-0.5-1.armv7hl.rpm"
HB_GOOD_x86_RPM="harbour-good-0.5-1.i586.rpm"
HB_BAD_ARM_RPM="harbour-bad-0.1-1.armv7hl.rpm"
HB_BAD_x86_RPM="harbour-bad-0.1-1.i586.rpm"


${RPMVALITATOR} ${RPMS_DIR}/${HB_GOOD_ARM_RPM} 2>&1 | ${SED_FILTER} > ${EXPECTED_DIR}/testHarbourGoodArm.txt 
${RPMVALITATOR} --no-color ${RPMS_DIR}/${HB_GOOD_ARM_RPM} 2>&1 | ${SED_FILTER} > ${EXPECTED_DIR}/testHarbourGoodArmNoColor.txt 

${RPMVALITATOR} ${RPMS_DIR}/${HB_BAD_ARM_RPM} 2>&1 | ${SED_FILTER} > ${EXPECTED_DIR}/testHarbourBadArm.txt
${RPMVALITATOR} --no-color ${RPMS_DIR}/${HB_BAD_ARM_RPM} 2>&1 | ${SED_FILTER} > ${EXPECTED_DIR}/testHarbourBadArmNoColor.txt

${RPMVALITATOR} ${RPMS_DIR}/${HB_GOOD_x86_RPM} 2>&1 | ${SED_FILTER} > ${EXPECTED_DIR}/testHarbourGoodIntel.txt 
${RPMVALITATOR} ${RPMS_DIR}/${HB_BAD_x86_RPM} 2>&1 | ${SED_FILTER} > ${EXPECTED_DIR}/testHarbourBadIntel.txt

${RPMVALITATOR} ${RPMS_DIR}/bad-file-name.rpm 2>&1  | ${SED_FILTER} > ${EXPECTED_DIR}/testBadFileName.txt 
${RPMVALITATOR} ${RPMS_DIR}/some-random-file.rpm 2>&1 | ${SED_FILTER} > ${EXPECTED_DIR}/testNotAnRpm.txt 
${RPMVALITATOR} --no-color ${RPMS_DIR}/bad-file-name.rpm 2>&1  | ${SED_FILTER} > ${EXPECTED_DIR}/testBadFileNameNoColor.txt 
${RPMVALITATOR} --no-color ${RPMS_DIR}/some-random-file.rpm 2>&1 | ${SED_FILTER} > ${EXPECTED_DIR}/testNotAnRpmNoColor.txt 
