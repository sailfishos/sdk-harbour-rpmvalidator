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
import sys, getopt

def read_conf(filename):
    retval = [[]]
    with open(filename) as conffile:
        lines = conffile.readlines()
        comment = ''
        for line in lines:
            if line.startswith('#'):
                if line.startswith('# ###'):
                    # add new heading
                    retval.append([])
                    retval[len(retval)-1].insert(0, line[1:-1].strip())
                else:
                    # ignore extra comments in the beginning of file
                    if len(retval) > 1:
                        # comment line, save for future use
                        comment = comment + line[1:-1].lstrip()
            elif len(line) > 1:
                lib = []
                lib.append(re.split('[(]*[!?*][()]+', line)[0].rstrip('\n'))
                lib.append(comment)
                comment = ''
                retval[len(retval)-1].append(lib)
    return retval

def usage():
    print('gen_doc.py -t <type> [-l permissions]')
    print('   where type is either "html" or "md"')
    sys.exit(1)

def main(argv):
    type = ''
    list_type = 'apis'
    try:
        opts, args = getopt.getopt(argv, "t:l:", ["type=","list-type="])
    except getopt.GetoptError:
        usage()
    for opt, arg in opts:
        if opt in ("-t", "--type"):
            type = arg
        if opt in ("-l", "--list-type"):
            list_type = arg
    if not type:
        usage()
    source_dir = os.path.join(os.path.dirname(__file__), '..')
    allowed_libraries = read_conf(
        os.path.join(source_dir, 'allowed_libraries.conf'))
    allowed_qmlimports = read_conf(
        os.path.join(source_dir, 'allowed_qmlimports.conf'))
    allowed_requires = read_conf(
        os.path.join(source_dir, 'allowed_requires.conf'))
    deprecated_libraries = read_conf(
        os.path.join(source_dir, 'deprecated_libraries.conf'))
    dropped_libraries = read_conf(
        os.path.join(source_dir, 'dropped_libraries.conf'))
    deprecated_qmlimports = read_conf(
        os.path.join(source_dir, 'deprecated_qmlimports.conf'))
    dropped_qmlimports = read_conf(
        os.path.join(source_dir, 'dropped_qmlimports.conf'))
    disallowed_qmlimports_patterns = read_conf(
        os.path.join(source_dir, 'disallowed_qmlimport_patterns.conf'))
    allowed_permissions = read_conf(
        os.path.join(source_dir, 'allowed_permissions.conf'))
    template = Template(filename=os.path.join(os.path.dirname(__file__),
                                              list_type + '.' + type))
    print(template.render(allowed_libraries=allowed_libraries,
                         allowed_qmlimports=allowed_qmlimports,
                         allowed_requires=allowed_requires,
                         deprecated_libraries=deprecated_libraries,
                         dropped_libraries=dropped_libraries,
                         deprecated_qmlimports=deprecated_qmlimports,
                         dropped_qmlimports=dropped_qmlimports,
                         disallowed_qmlimports_patterns=disallowed_qmlimports_patterns,
                         allowed_permissions=allowed_permissions))

if __name__ == "__main__":
   main(sys.argv[1:])
