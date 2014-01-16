# Harbour RPM Validator

This script checks and reports some basic Harbour requirements for app packages:

  * Package naming checks
  * File name, path and permission checks
  * Icon size and format checks
  * QML imports, shared libraries and RPM dependencies
  * Very basic static analysis for possible problems with the code

A successful validation means that the basic packaging is okay, however, it does not guarantee that the package or app will be accepted in Harbour. Validation is just one step in the QA process, and your application can fail validation for other reasons.

However, a validation failure means that the package will **NOT** be accepted in Harbour, so fix all validation failures before submitting your package to Harbour to avoid automatic QA failures.

Jolla makes the script available so developers can check if their application passes basic criterias for application submission to Harbour. It reduces turnaround times, as basic RPM validation failures can be found and fixed by the application developer already during development, and not only during QA.

While this script can also be used as a convenient tool to test how to best circumvent the Harbour rules, please use it for good, and not for evil. Apps circumventing Harbour rules will be removed from the store, even in cases where they might have been approved already, so please play by the rules. We believe if you want to work around the script, you would also find ways to do it, without the script being public, it would just take you longer. Be aware that working around our rules, you hurt us, the customer and yourself in the end.

There are good reasons why we have rules in Harbour. Please respect them and work with us if you do not understand certain rules or think they need to change. To suggest improvements:

  * Use together.jolla.com with the "harbour-api-request" tag to request new libraries and APIs
  * Use together.jolla.com to submit ideas for policy changes to the rules
  * Send a pull request if you have non-policy improvements/additions to the script
  * Send a pull request for patches to check for/suggest coding/packaging best practices (as warnings, not failures)


## Usage

```
./rpmvalidation.sh .path/to/rpm-file
```

Tested under Fedora w/o changes, needed tools should be preinstalled by default.

On Ubuntu and Debian, you might need to install the following additional packages:

```
apt-get install rpm rpm2cpio cpio
```
