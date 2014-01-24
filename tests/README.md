# Harbour RPM Validator Tests
## Usage
Test can be run with:
```
./runtests.sh
```

## Setup
In order to have the ```runtests.sh``` working properly it's expected that the folder containing the project is called ```sdk-harbour-rpmvalidator```.

## Update
In case the tests fail and it's verified that the new output is the expected output, use ```generate_expected_output.sh``` to regenerate the expected output and rerun the tests.

If you add new tests to ```runtests.sh``` please also update ```generate_expected_output.sh```!
