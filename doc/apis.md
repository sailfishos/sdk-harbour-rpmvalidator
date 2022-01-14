${'##'} Allowed Libraries

Your application can link against the following libraries:

% for section in allowed_libraries:
${makelist("Allowed_Libraries", section)}\
% endfor
${'##'} Allowed QML Imports

Your app is not allowed to have QML imports matching the following patterns:

% for section in disallowed_qmlimports_patterns:
${makelist ("Allowed_QML_Imports", section)}\
% endfor
The exceptions to this rule are the following imports:

% for section in allowed_qmlimports:
${makelist("Allowed_QML_Imports", section)}\
% endfor
${'##'} Allowed package dependencies

Usually you shouldn't add library depencencies or python module dependencies to your package manually, as these dependencies are generated automatically. Your rpm packages can require the following:

% for section in allowed_requires:
${makelist("Allowed_Package_Dependencies", section)}\
% endfor
${'##'} Deprecated libraries

The following libraries have been deprecated, and they should no longer be used in new code. They will be dropped from allowed libraries in a future release:

% for section in deprecated_libraries:
${makelist("Deprecated_Libraries", section)}\
% endfor
${'##'} Deprecated QML Imports

The following QML Imports have been renamed. The old imports should no longer be used in new code. They will be dropped from allowed imports in a future release:

% for section in deprecated_qmlimports:
${makerenamelist("Deprecated_QML_Imports", section)}\
% endfor
<%def name="makelist(section, subsection)">\
% if len(subsection) > 1:
${'###'} ${subsection[0]}

% for lib in subsection[1:]:
  - ${lib}
% endfor

% endif
</%def>
<%def name="makerenamelist(section, subsection)">\
% if len(subsection) > 1:
% for lib in subsection[1:]:
  - ${lib}
    - ${subsection[0]}
% endfor
% endif
</%def>