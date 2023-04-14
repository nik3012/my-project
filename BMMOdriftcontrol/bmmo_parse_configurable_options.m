function options_out = bmmo_parse_configurable_options(options_in, configurable_options)
% function options_out = bmmo_parse_configurable_options(options_in, configurable_options)
%
% Parse configurable options, overwriting already existing fields of
% options_in
%
% Input:
%   options_in:           options structure as defined in bmmo_default_options_structure
%   configurable_options: substructure of ml input, containing a subset of
%                         fields of options_in
%
% Output: 
%   options_out:          options_in with data in common fields overwritten with
%                         data from configurable_options

% find the fieldnames from options
options_out = sub_replace_field_info(options_in, configurable_options);


%% End of main function -- subfunctions below


    function s_out = sub_replace_field_info(s_in, s_new)

    s_out = s_in;

    % if inputs are not structures, s_out = s_new
    if (~isstruct(s_out) & ~isstruct(s_new)) | isempty(s_out)
        s_out = s_new;

    % otherwise, if both are structs    
    elseif isstruct(s_out) & isstruct(s_new)
        % get the fieldnames of s_out
        in_fieldnames = fieldnames(s_out);

        % get the fieldnames of s_new
        new_fieldnames = fieldnames(s_new);

        % find the fields in s_new that are also in s_out
        commonfields = intersect(in_fieldnames, new_fieldnames);

        % handle structure arrays of variable length
        len_s = min([length(s_out), length(s_new)]);   
        
        % for each field, replace the field info
        for ifield = 1:length(commonfields)
            for is = 1:len_s
                s_out(is).(commonfields{ifield}) = sub_replace_field_info(s_out(is).(commonfields{ifield}), s_new(is).(commonfields{ifield}));
            end
        end
    end
    
    