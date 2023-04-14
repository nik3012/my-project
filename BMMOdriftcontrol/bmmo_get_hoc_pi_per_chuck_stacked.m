function pi_struct = bmmo_get_hoc_pi_per_chuck_stacked(ml, options, pitext)
% function pi_struct = bmmo_get_hoc_pi_per_chuck_stacked(ml, options, pitext)
%
% Create a per-chuck stacked HOC performance indicator struct for the given input
%
% Input
%   ml: input overlay structure
%   options: bmmo-nxe options structure as defined in
%       bmmo_default_options_structure
%   pi_text: text to use in pi struct field name
%   e.g. for chuck 2 k7: ovl_k7_chk2(pi_text)
%
% Output
%   pi_struct: overlay performance indicator structure

if nargin < 2
    options = bmmo_default_options_structure;
end

% get k-factors and residual
[kfactors, corr] = bmmo_get_kfactors_per_chuck(ml, options);

options.chuck_usage.chuck_id = sort(options.chuck_usage.chuck_id);
options.chuck_usage.chuck_id_used = sort(options.chuck_usage.chuck_id_used);
% copy k-factors to KPI struct
pi_struct = bmmo_get_hoc_pi_struct(kfactors, pitext, options);

% copy overlay to KPI struct

pi_struct = bmmo_get_ov_pi_per_chuck_stacked(corr, options, pi_struct);
