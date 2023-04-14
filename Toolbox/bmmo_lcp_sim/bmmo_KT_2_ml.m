function [ml, kt_struct] = bmmo_KT_2_ml( path, use_layout, lt, markname, marktype, kt_struct )
% function ml = bmmo_KT_2_ml( path, use_layout, ml_tmp, markname, marktype )
%
% Given a KT_wafers_* file and a markname and marktype, generate an ml structure based on
% the given template and x,y shifts
%
% Input:
%   path: full path of KT_wafers_* file
%   use_layout: nonzero if lt is an ml structure with an input layout;
%       otherwise zero
%   lt: if use_layout is > 0, a single-layer, single-wafer ml structure to
%       provide the layout; otherwise the number of digits to round the
%       input to
%   markname: mark name to load from KT_wafers (e.g. 'EXPOSED!')
%   marktype: mark type to load from KT_wafers (e.g. 'XPA')
%
% Output: 
%   ml: generated ml structure
%
% 20160331 SBPR Refactored from KT_wo_2_ml

if use_layout    
    % generate a template output
    ml = ovl_create_dummy(lt);

    % get the layout marks from the template input
    layout_marks = [lt.wd.xw, lt.wd.yw];
else
    ml = struct;
end
    
if nargin < 6
    % load the marks into a matlab structure
    kt_struct = dd2mat(0, path);
end

% kt_struct will be a nwafer * 1 structure array
nwafer = length(kt_struct);
ml.nwafer = nwafer;


for iw = 1:ml.nwafer

    % get a nmark * 2 matrix of the marks of interest
    index = strcmp({kt_struct(iw).AA_marks.name}, markname) & strcmp({kt_struct(iw).AA_marks.mark_type}, marktype);

    if ~any(index)
        error(['No marks of name ' markname ' and type ' marktype ' found!']);
    end
    
    aa_marks = [kt_struct(iw).AA_marks(index)];
    aa_marks = [aa_marks.position];

    xvec = [aa_marks.x];
    yvec = [aa_marks.y];

    marks = [xvec', yvec'];

    if ~use_layout && iw == 1
        ml.wd.xw = round(marks(:, 1), lt);
        ml.wd.yw = round(marks(:, 2), lt);
        ml.wd.xc = ml.wd.xw;
        ml.wd.yc = ml.wd.yw;
        ml.wd.xf = zeros(size(ml.wd.xw));
        ml.wd.yf = ml.wd.xf;
        ml.nmark = 1;
        ml.nfield = length(ml.wd.xw);
        ml.nlayer = 1;
        
        layout_marks = [ml.wd.xw, ml.wd.yw];
    end
        
     %figure; plot(layout_marks(:,1), layout_marks(:,2), 'bo');
     %hold; plot(marks(:,1), marks(:,2), 'rx');
    
    
    % for each point in marks, get the index and distance of the closest point
    % in layout_marks
    [I, D] = knnsearch(layout_marks, marks, 'k', 1);

    % ignore all indices greater than threshold
    % TODO: handle marks in shifted fields, etc.
    THRESH = 1e-6;
    
    if any(D >= THRESH)
        warning('Not all marks in KT_wafers could be mapped to input layout');
    end
        
    I = I(D < THRESH);
    marks = marks(D < THRESH, :);

    tmp_out = nan(size(layout_marks));
    tmp_out(I, :) = marks - layout_marks(I, :);

    ml.layer.wr(iw).dx = tmp_out(:, 1);
    ml.layer.wr(iw).dy = tmp_out(:, 2);
end
