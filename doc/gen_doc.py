#!/usr/bin/python3
#
# Copyright (C) 2021 Jolla Ltd.
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

from mako.template import Template
from array import *
import os
import re

def read_conf(filename):
    retval = [[]]
    i = 0
    with open(filename) as conffile:
        lines = conffile.readlines()
        for line in lines:
            if line.startswith('#'):
                retval.insert(0, [])
                retval[0].insert(0, line[1:-1])
            elif len(line) > 1:
                retval[0].insert(1, re.split('[(]*[!?*][()]+', line)[0])
    return retval

source_dir = os.path.join(os.path.dirname(__file__), '..')
allowed_libraries = read_conf(
    os.path.join(source_dir, 'allowed_libraries.conf'))
allowed_qmlimports = read_conf(
    os.path.join(source_dir, 'allowed_qmlimports.conf'))
allowed_requires = read_conf(
    os.path.join(source_dir, 'allowed_requires.conf'))
deprecated_libraries = read_conf(
    os.path.join(source_dir, 'deprecated_libraries.conf'))
deprecated_qmlimports = read_conf(
    os.path.join(source_dir, 'deprecated_qmlimports.conf'))
disallowed_qmlimports_patterns = read_conf(
    os.path.join(source_dir, 'disallowed_qmlimport_patterns.conf'))
doctemplate = Template(filename=os.path.join(os.path.dirname(__file__), 'base.html'))
print(doctemplate.render(allowed_libraries=allowed_libraries,
                         allowed_qmlimports=allowed_qmlimports,
                         allowed_requires=allowed_requires,
                         deprecated_libraries=deprecated_libraries,
                         deprecated_qmlimports=deprecated_qmlimports,
                         disallowed_qmlimports_patterns=disallowed_qmlimports_patterns))
