#!/usr/bin/python3

import argparse
import collections
import itertools
import logging
from logging import debug, info, warning, error
import os
import os.path
import re
import sys
import subprocess
from xml.dom import minidom
from xml.etree import ElementTree as ET

DEFAULT_ALLOWED_QMLIMPORTS_CONF = '/usr/share/sdk-harbour-rpmvalidator/allowed_qmlimports.conf'
SELF_INSTALL_PATH = '/opt/tests/sdk-harbour-rpmvalidator/check-qml-typeinfo.py'
SELF_PACKAGE_NAME = 'sdk-harbour-rpmvalidator-sdk-tests'
HWID_DETECT_COMMAND = 'ssu model -s'
SDK_TARGET_HWID = 'SDK Target'
UPDATE_TESTS_REQUIRES_SH = 'rpm/update-tests-requires.sh'
DEFAULT_QML_TYPEINFO = 'plugins.qmltypes'
QML_SEARCH_PATH = '/usr/lib/qt5/qml'
ZYPPER_EXIT_INF_CAP_NOT_FOUND = 104

class Error(Exception):
    def __init__(self, message):
        self.message = message

QmlModule = collections.namedtuple('QmlModule', ['id', 'versions'])
InstalledQmlModule = collections.namedtuple('InstalledQmlModule', ['id', 'path', 'qmldir'])

def parse_allowed_qmlimports_conf(file):
    """Parse allowed_qmlimports.conf file

    >>> from pprint import pprint
    >>> file_like = inspect.cleandoc(\"""
    ... # Comment
    ... # Another comment
    ...
    ... Foo.Bar 1.0
    ...
    ...   # Comment with leading blank
    ...
    ...    Foo.Baz 2.0
    ...   Foo.Bar 2.2 # Comment
    ... \""").splitlines()
    >>> pprint(list(parse_allowed_qmlimports_conf(file_like)))
    [QmlModule(id='Foo.Bar', versions=['1.0', '2.2']),
     QmlModule(id='Foo.Baz', versions=['2.0'])]
    """
    plain = []
    for line_num, line in enumerate(file, 1):
        # Remove comments, strip, skip blank lines
        line = re.sub(r'\s*#.*', '', line)
        line = line.strip()
        if line == '':
            continue

        words = re.split(r'\s+', line)
        if len(words) != 2:
            raise Error('Error parsing allowed_qmlimports.conf, line "{}"'
                        .format(line_num, line))

        plain.append(words)

    plain.sort(key=lambda x: x[0])

    imports = []
    for k, g in itertools.groupby(plain, lambda x: x[0]):
        imports.append(QmlModule(k, [x[1] for x in g]))

    return imports

def read_allowed_qmlimports_conf():
    global args
    try:
        file = open(args.allowed_qmlimports)
    except FileNotFoundError as e:
        raise Error('The file "{}" does not exist.'
                    .format(args.allowed_qmlimports)
            ) from e
    else:
        with file:
            return parse_allowed_qmlimports_conf(file)

def qmlmodules_to_capabilities(qmlmodules):
    """Convert list of QmlModule into strings usable as zypper's capabilities

    >>> qmlmodules_to_capabilities([
    ...    QmlModule('Foo.Bar', ['1.0', '2.2']),
    ...    QmlModule('Foo.Baz', ['2.0'])
    ... ])
    ['qml(Foo.Bar)', 'qml(Foo.Baz)']
    """
    return ['qml({})'.format(i.id) for i in qmlmodules]

def parse_qmldir(file, file_name):
    """Parse module definition 'qmldir' file intro a dictionary with 'command' as a key and
    a list of 'arguments' as a value

    >>> file_like = inspect.cleandoc(\"""
    ... # Comment
    ... module Foo.Bar
    ... typeinfo foobar.qmltypes
    ... Baz 1.0 Baz.qml
    ... \""").splitlines()
    >>> parsed = parse_qmldir(file_like, '-')
    >>> sorted(parsed.items(), key=lambda t: t[0])
    [('Baz', ['1.0', 'Baz.qml']), ('module', ['Foo.Bar']), ('typeinfo', ['foobar.qmltypes'])]
    """
    parsed = {}

    for line in file:
        tokens = line.split()
        debug('%s: "%s" -> %s', file_name, line, tokens)
        if not tokens or tokens[0] == '#':
            continue
        parsed[tokens[0]] = tokens[1:]

    if not 'module' in parsed:
        raise Error('QML module definition "{}" does not declare module identified'
                .format(file_name))

    return parsed

def read_qmldir(file_name):
    with open(file_name) as file:
        return parse_qmldir(file, file_name)

def list_installed_modules():
    retv = {}
    for dir_path, dir_names, file_names in os.walk(QML_SEARCH_PATH):
        for file_name in file_names:
            if file_name == 'qmldir':
                file_path = os.path.join(dir_path, file_name)
                qmldir = read_qmldir(file_path)
                id = qmldir['module'][0]
                retv[id] = InstalledQmlModule(id, dir_path, qmldir)
    return retv

def what_provides(qmlmodule):
    capability = qmlmodules_to_capabilities([qmlmodule])[0]

    proc = subprocess.Popen(['rpm', '--query', '--whatprovides', '--queryformat',
                             '%{NAME}\n', capability],
                            stdout=subprocess.PIPE, universal_newlines=True)
    outs, errs = proc.communicate()

    if proc.returncode != 0:
        raise Error('Failed to determine package name for "{}"'.format(capability))

    lines = outs.splitlines()
    if len(lines) == 1:
        return lines[0]
    elif len(lines) == 0:
        raise Error('Nothing provides "{}"'.format(capability))
    else:
        raise Error('More than one package provides "{}"'.format(capability))

def is_preinstalled(qmlmodule):
    rpmpackage = what_provides(qmlmodule)

    proc = subprocess.Popen(['rpm', '--erase', '--test', rpmpackage],
                            stderr=subprocess.PIPE, universal_newlines=True)
    outs, errs = proc.communicate()

    if proc.returncode == 0:
        return (rpmpackage, False)

    lines = errs.splitlines()

    if len(lines) == 0:
        raise Error('Unexpected empty output from "rpm --erase"')

    if lines[0] == 'error: Failed dependencies:':
        del lines[0]
    else:
        raise Error('Unexpected leading line of "rpm --erase" output')

    required_by_this = False
    required_by_others = False
    for line in lines:
        if ' is needed by ' not in line:
            raise('Unexpected line format in "rpm --erase" output')

        if re.search(' {}-[0-9]'.format(SELF_PACKAGE_NAME), line):
            required_by_this = True
        else:
            required_by_others = True

    if not required_by_this:
        warning('QML module "%s" not pulled in by the sdk-tests package. '
                'Need to run "%s" in sources?',
                qmlmodule.id, UPDATE_TESTS_REQUIRES_SH)

    return (rpmpackage, required_by_others)

def main_list():
    qmlmodules = read_allowed_qmlimports_conf()
    ids = (m.id for m in qmlmodules)
    print('\n'.join(ids))
    return 0

def main_list_caps():
    qmlmodules = read_allowed_qmlimports_conf()
    qmlmodules = (m for m in qmlmodules)
    capabilities = qmlmodules_to_capabilities(qmlmodules)
    print('\n'.join(capabilities))
    return 0

def main_check():
    global args

    if not args.qmlmodule:
        qmlmodules = read_allowed_qmlimports_conf()
    else:
        qmlmodules = [QmlModule(qmlmodule, []) for qmlmodule in args.qmlmodule]

    all_installed = list_installed_modules()

    retv = 0
    for qmlmodule in qmlmodules:
        info('Checking "%s"', qmlmodule.id)

        if qmlmodule.id not in all_installed:
            print(qmlmodule.id, 'does not seem to be installed')
            retv = 1
            continue

        installed = all_installed[qmlmodule.id]

        if 'typeinfo' in installed.qmldir:
            qml_typeinfo = installed.qmldir['typeinfo'][0]
        else:
            qml_typeinfo = DEFAULT_QML_TYPEINFO
        qml_typeinfo = os.path.join(installed.path, qml_typeinfo)

        if os.path.exists(qml_typeinfo):
            continue

        if 'typeinfo' in installed.qmldir:
            print(qmlmodule.id, 'declares nonexisting "typeinfo" in its "qmldir"')
        else:
            print(qmlmodule.id, 'has no', DEFAULT_QML_TYPEINFO)
        retv = 1

    return retv

def main_check_patterns():
    global args

    if not args.qmlmodule:
        qmlmodules = read_allowed_qmlimports_conf()
    else:
        qmlmodules = [QmlModule(qmlmodule, []) for qmlmodule in args.qmlmodule]

    retv = 0
    for qmlmodule in qmlmodules:
        info('Checking "%s"', qmlmodule.id)

        package, preinstalled = is_preinstalled(qmlmodule)
        if not preinstalled:
            print('{} ({}) was not required by patterns'.format(package, qmlmodule.id))
            retv = 1

    return retv


def main_create_tests_xml():
    root = ET.Element('testdefinition', attrib={'version': '1.0'})

    hwiddetect = ET.SubElement(root, 'hwiddetect')
    hwiddetect.text = HWID_DETECT_COMMAND

    suite = ET.SubElement(root, 'suite', name='rpmvalidator-tests')

    set1 = ET.SubElement(suite, 'set', name='rpmvalidator-tests-qml-autocompletion-support')
    set1_desc = ET.SubElement(set1, 'description')
    set1_desc.text = 'Verify that all allowed QML imports provide "{}" file'.format(DEFAULT_QML_TYPEINFO)

    set2 = ET.SubElement(suite, 'set', name='rpmvalidator-tests-qml-autocompletion-patterns',
                         hwid=SDK_TARGET_HWID)
    set2_desc = ET.SubElement(set2, 'description')
    set2_desc.text = 'Verify that all allowed QML imports are available by default (preinstalled)'

    for qmlmodule in read_allowed_qmlimports_conf():
        case1 = ET.SubElement(set1, 'case', name='tst_{}'.format(qmlmodule.id))
        step1 = ET.SubElement(case1, 'step')
        step1.text = '{} check "{}"'.format(SELF_INSTALL_PATH, qmlmodule.id)

        case2 = ET.SubElement(set2, 'case', name='tst_patterns_{}'.format(qmlmodule.id))
        step2 = ET.SubElement(case2, 'step')
        step2.text = '{} check-patterns "{}"'.format(SELF_INSTALL_PATH, qmlmodule.id)

    ugly = ET.tostring(root, encoding='utf-8')
    pretty = minidom.parseString(ugly).toprettyxml(indent='  ', encoding='utf-8')
    sys.stdout.write(str(pretty, 'utf-8'))

def argument_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('-v', '--verbose', action='store_true',
            help='Enable more detailed progress reporting')
    parser.add_argument('-a', '--allowed_qmlimports', metavar='FILE',
            default=DEFAULT_ALLOWED_QMLIMPORTS_CONF,
            help='Use the specified FILE instead of the one available from system')

    subs = parser.add_subparsers(title='subcommands')

    sub_list = subs.add_parser('list',
            help='List allowed QML imports')
    sub_list.set_defaults(func=main_list)

    sub_list_caps = subs.add_parser('list-caps',
            help='List allowed QML imports as RPM capabilities')
    sub_list_caps.set_defaults(func=main_list_caps)

    sub_check = subs.add_parser('check',
            help='Check the given QML modules (or all allowed) for valid QML typeinfo')
    sub_check.set_defaults(func=main_check)
    sub_check.add_argument('qmlmodule', nargs='*')

    sub_check_patterns = subs.add_parser('check-patterns',
            help='Check that given QML modules (or all allowed) are pulled in by patterns')
    sub_check_patterns.set_defaults(func=main_check_patterns)
    sub_check_patterns.add_argument('qmlmodule', nargs='*')

    sub_create_tests_xml = subs.add_parser('create-tests-xml',
            help='Build a test definition XML to check all allowed QML modules')
    sub_create_tests_xml.set_defaults(func=main_create_tests_xml)

    return parser

def main():
    global args

    parser = argument_parser()
    args = parser.parse_args()
    if not hasattr(args, 'func'):
        parser.print_help()
        exit(1)

    if args.verbose:
        logging.getLogger().setLevel(logging.INFO)

    try:
        ec = args.func()
        exit(ec)
    except Error as e:
        error(e.message)
        exit(1)

################################################################################
# Main execution starts here

args = None
self_test = False
if __name__ == '__main__':
    logging.basicConfig(level=logging.WARNING)

    if len(sys.argv) > 1 and sys.argv[1] == '--self-test':
        del sys.argv[1]
        self_test = True
    else:
        main()
        exit()

################################################################################
# Self test starts here

import doctest
import inspect
import unittest

class TestCase(unittest.TestCase):

    def test_doctest(self):
        (failed, total) = doctest.testmod()
        self.assertEqual(failed, 0)

if self_test:
    unittest.main()
