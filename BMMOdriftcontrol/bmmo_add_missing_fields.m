function struct_out = bmmo_add_missing_fields(struct_out, struct_template, depth)
% function struct_out = bmmo_add_missing_fields(struct_in, struct_template, depth)
%
% Copies to struct_in the fields that are in struct_template, but not in struct_in
%
% Input
%   struct_in:              matlab structure
%   struct_template:        matlab structure
%   depth:                  depth of subfields to add to the structure (default = 1)
%
% Output
%   struct_out:             struct in with the missing fields added

if nargin < 3
    depth = 1;
end

if depth > 0
    if isstruct(struct_template) % if input is a struct
        
        dims1 = numel(struct_template);
        dims2 = numel(struct_out);
        nStruct = min(dims1,dims2);
        
        field_cell1 = fieldnames(struct_template); % list of field names (struct_template)
        if isstruct(struct_out)
            field_cell2 = fieldnames(struct_out); % list of field names (struct_out)
        else
            field_cell2 = {};
        end
        
        
        % determine unique fields in struct_template and copy to struct_out
        f = setdiff(field_cell1, field_cell2);
        if ~isempty(f)
            for idiff = 1:length(f)
                for ii = 1:nStruct
                    struct_out(ii).(f{idiff}) = struct_template(ii).(f{idiff});
                end
            end
        end
        
        depth = depth - 1; 
        
        for ii = 1:nStruct
            for i =1:length(field_cell1)
                struct_out(ii).(field_cell1{i}) = bmmo_add_missing_fields(struct_out(ii).(field_cell1{i}),struct_template(ii).(field_cell1{i}),depth);
            end
        end
        
    end
end