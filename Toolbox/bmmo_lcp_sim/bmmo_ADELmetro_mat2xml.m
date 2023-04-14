function meas = bmmo_ADELmetro_mat2xml(xml, fid, dotcount, meas, depth)
%MAT2XML Convert matlab structure to XML
% 
% Alternative to built-in XMLWRITE, which does not compile under R13.
% 
% Usage:
%   Save to file                  --> MAT2XML(xml, savefile)
%   Convert to string             --> txt = MAT2XML(xml)
%   Use alternative header+footer --> txt = MAT2XML(xml, '', txt_head, txt_foot)
% 
% Where xml is the to-be-converted (nested multidimensional) structure:
%   - Items of xml may be strings or numbers, but not cells or matrices.
%   - Items are written in same sequence as in structure.
%   - Tab sign indentation is applied.
%   - Default header is <?xml version="1.0"?>, default footer empty
% 
% Author:
%   Jasper Menger, April 2011
% 
% 20160407 SBPR in search of faster alternative to struct2xml for
%               ADELmetrology generation

% Optional arguments
indent    = ''      ; 
precision = '%g'    ;
if nargin < 5 
    depth = 1; 
end

% Quick sanity check
if ~isstruct(xml)
    error('Input must be a structure');
end


% Hop through the fields of xml struct in default sequence
names = fieldnames(xml);
for f = 1:numel(names)
    name = names{f};
    
    if strcmp(name, 'SequenceNumber')
        meas = meas + 1;
    end

    if meas == dotcount
        fprintf(stdout, '.');
        meas = 0;
    end
    
    % skip fields that have been handled already
    if ~strcmp(name, 'Text') && ~strcmp(name, 'Attributes')
    
        % Hop through the items for this field
        content = xml.(name);

        if isstruct(content)
            for i = 1:numel(content)

                %before printing here, we should build an attribute string
                %if one exists
                attributes = '';
                if isfield(content(i), 'Attributes')
                    attributes = sub_get_attributes(content(i).Attributes);
                end

                cname = strrep(name, '_colon_', ':');
                
                % Write field name (assume we start on unindented newline)
                if depth == 1
                    fprintf(fid, '<?xml version="1.0"?>\n<%s:MetrologyReport %s>', cname, attributes); 
                else
                    fprintf(fid, '%s<%s%s>', indent, cname, attributes);
                end
                % Have a look at the content
                if isfield(content(i), 'Text')
                    text = sub_get_text(content(i).Text);
                    fprintf(fid, '%s', text);
                else
                    fprintf(fid, '\n');
                end

                % Take care of structs within structs by recursive call to oneself

                meas = bmmo_ADELmetro_mat2xml(content(i), fid, dotcount, meas, depth + 1);
                % Properly close the field
                if depth == 1
                    fprintf(fid, '</%s:MetrologyReport>\n', cname);
                else
                    if isfield(content(i), 'Text')
                        fprintf(fid, '</%s>\n',  cname);
                    else
                        fprintf(fid, '%s</%s>\n', indent, cname);
                    end
                end
            end
         elseif isnumeric(content)
                fprintf(fid, '%s<%s>', indent, name);
                % Write number with designated precision
                txt = sprintf(precision, content);
                fprintf(fid, '%s</%s>\n', txt, name);

         elseif ischar(content)
                fprintf(fid, '%s<%s>', indent, name);
                % Just paste string content
                txt = content;
                fprintf(fid, '%s</%s>\n', txt, name);

         else
                % Illegal content. Raise the alarm! Slow whoop all over!
                error('Invalid class %s for field %s', class(content), name);

         end % of content inspection
    end  
end % of field loop


function text = sub_get_attributes(attr)

text = '';

fn = fieldnames(attr);
for ifield = 1:length(fn)
   cname = strrep(fn{ifield}, '_colon_', ':');
   text = [text ' ' cname '="'];
   if isnumeric(attr.(fn{ifield}))
       val = sprintf(precision, attr.(fn{ifield}));
   else
       val = attr.(fn{ifield});
   end
   text = [text val '"'];
end

function txt = sub_get_text(val)

if isnumeric(val)
   txt = sprintf(precision, val);
else
   txt = val;
end

