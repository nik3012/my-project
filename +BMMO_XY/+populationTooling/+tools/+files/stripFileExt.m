function filename = stripFileExt(filename)

filenameParts = split(filename, '.');
numberOfParts = length(filenameParts);

if numberOfParts == 1
    filename = filenameParts{1};
else
    warning('Please do not provide a file-extension in the filename')
    filename = '';
    for index = 1 : (numberOfParts - 1)
        filename = [filename filenameParts(index)];
    end
end

end