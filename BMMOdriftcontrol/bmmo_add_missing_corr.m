function corr_out = bmmo_add_missing_corr(corr_in, depth, options)
% function corr_out = bmmo_add_missing_corr(corr_in, depth, options)
%
% Given a bmmo correction structure with some corrections missing,
% completes the structure by adding zero corrections
%
% Input
%   corr_in: bmmo correction structure with some corrections (as defined in
%            bmmo_default_output structure) missing
%   depth:   depth of subfields to add to the input structure (default = 2)
%   options: bmmo or bl3 options structure (default = bmmo)
%
% Output
%   corr_out: bmmo correction structure as defined in
%             bmmo_default_output_structure

if nargin < 3
    if isfield(corr_in, 'KA') && isfield(corr_in.KA, 'grid_2de')
        BL3_KA_MEAS_LENGTH = 90601;
        
        if length(corr_in.KA.grid_2de(1).x) >= BL3_KA_MEAS_LENGTH
            options = bl3_default_options_structure;
        else
            options = bmmo_default_options_structure;
        end
    else
        options = bmmo_default_options_structure;
    end
end

if nargin < 2
    depth = 2;
end

empty_corr = bmmo_default_output_structure(options);

corr_out = bmmo_add_missing_fields(corr_in, empty_corr.corr, depth);

end

