function table = bmmo_kt_bao_to_table(baos, names)
% function table = bmmo_kt_bao_to_table(baos, names)
% 
% Convert cell arrays of bao corrections and identifying names to suitable
% input for tableppt
%
% Input: baos: 1 x n cell array of bao corrections
%        names: 1 x n cell array of strings, descriptive names for each bao
%           correction
%
% Output:
%   table: 11 x (n+1) cell array of data with the following format
%       correction      name{1}             name{2} ...
%       Translationx    bao{1}.TranslationX bao{2}.TranslationX
%        ...
%
% 20160510 SBPR Creation

assert(length(baos) == length(names), 'Mismatch between baos and bao names');

n = length(baos);

table = cell(11, (n+ 1));

% Fill in the first row of the table with the names

table{1,1} = 'Correction';
for i = 1:n
    table{1, i+1} = names{i};
end

baonames = fieldnames(baos{1});
assert(length(baonames) == 10);

for r = 1:10
    table{(r+1), 1} = baonames{r};
    for c = 1:n
        table{(r+1),(c+1)} = baos{c}.(baonames{r});
    end
end


