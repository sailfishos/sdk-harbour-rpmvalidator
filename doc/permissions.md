${'##'} Allowed Permissions

Your application is allowed to define the following permissions in its X-Sailjail section:

% for section in allowed_permissions:
${make_permission_list(section)}\
% endfor
<%def name="make_permission_list(section)">\
% for permission in section[1:]:
  - ${permission[0]}
% if len(permission[1]) > 0:
    - ${permission[1]}
% endif
% endfor
</%def>
