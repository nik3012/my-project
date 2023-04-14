function bmmo_xml_save(filename, data, root, root_attrib)
% function bmmo_xml_save(filename, data, root, root_attrib)
%
% alternative to xml_save, which allows write of root node attributes
%
% Input:
%   filename: filename to write to
%   data: xml data in matlab struct format, as read by xml_load
%   root: string containing root name
%   root_attrib: string of root attributes


fh = fopen(filename, 'W');

%handle root node
fprintf(fh, '<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fh, '<%s %s>\n', root, root_attrib);
sub_xml_to_txt(fh, data, 1);

fprintf(fh, '</%s>\n', root);

fclose(fh);


function sub_xml_to_txt(fh, data, depth)

precision = '%.12g';

names = fieldnames(data);
for f = 1:numel(names)
    name = names{f};

    % Hop through the items for this field
    content = data.(name);

    if isstruct(content)
            cname = strrep(name, '_colon_', ':');

            % Write field name (assume we start on unindented newline)
            fprintf(fh, '<%s>\n', cname);
            for i = 1:numel(content)
                sub_xml_to_txt(fh, content(i), depth+1);
            end
            fprintf(fh, '</%s>\n', cname);
            
     elseif isnumeric(content)
            fprintf(fh, '<%s>', name);
            % Write number with designated precision
            txt = sprintf(precision, content);
            fprintf(fh, '%s</%s>\n', txt, name);

     elseif ischar(content)
            fprintf(fh, '<%s>', name);
            % Just paste string content
            txt = content;
            fprintf(fh, '%s</%s>\n', txt, name);

     else
            % Illegal content. Raise the alarm! Slow whoop all over!
            error('Invalid class %s for field %s', class(content), name);

     end % of content inspection

end
