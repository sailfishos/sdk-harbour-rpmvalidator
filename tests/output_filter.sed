#!/bin/sed -f

# the used temp dir changes!
s/Created temporary directory.*$/Created temporary directory/

# this should remove parts of the path which is always different
s#/.*/\(sdk-harbour-rpmvalidator/\{0,1\}.*\)#\1#

# depending on how the script is installed this line is there or not
s/RPM Validation script .*//

# file command output differs
s/\(ELF file with wrong arch: \).*/\1/
