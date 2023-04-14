function parlist = bmmo_add_field_positions_to_parlist(parlist, ml)
% This function takes the inputs for ovl_model('apply'):
% a parameter list of structs and an ml struct. It then extracts the
% field centers xc and yc from the ml struct and adds them to the parameter
% list. This ensures no 'Missing field positions' warning is thrown by ovl_model.
% 
% Input parameters:
%   - parlist:  array of structs containing the parameters per field
%   - ml:       ml struct to be passed to ovl_model('apply')
%
% Output:
%   - parlist:  input parameter list extended with the applicable field
%               centers xc and yc.

field_centers = unique([ml.wd.xc,ml.wd.yc],'rows', 'stable');

for i = 1:length(parlist.field)
    parlist.field(i).xc = field_centers(i, 1);
    parlist.field(i).yc = field_centers(i, 2);
end
end