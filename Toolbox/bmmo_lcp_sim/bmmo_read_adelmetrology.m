function [mlo, readout_date] = bmmo_read_adelmetrology(adel_input)
% function mlo = bmmo_read_adelmetrology(adel_input)
%
% Read an adelmetrology file into a 1 x n array of ml structures, where n
% is the number of unique target names in RecipeTargetId.TargetLabel
%
% Input: adel_input: full path of ADELmetrology input xml file
%
% Output: mlo: 1 x n array of ml structures
%
% 20170510 SBPR Now based on bmmo_parse_adelmetrology; now returns data in
%               field layout
% 20160606 SBPR Creation



[xc, yc, xf, yf, labelid, dx, dy, validx, validy, unique_target_labels, readout_date] = bmmo_parse_adelmetrology(adel_input);

[~, nwafer] = size(dx);

% Get the unique target labels in this structure
numtargets = length(unique_target_labels);

mlo = repmat(struct('nwafer', nwafer, 'layer', [], 'wd', [], 'nmark', 1, 'nfield', 0, 'nlayer', 1, 'tlgname', ''), 1, numtargets);

% Set invalid overlay data to NaN (excluding WID_UP readouts)
tmpvalid = false(size(validx));
wupid = find(strcmp(unique_target_labels, 'WID_UP'));
if ~isempty(wupid)
    wupid = find(labelid == wupid(1));
    tmpvalid(wupid, :) = true;
end
validx = validx | tmpvalid;
validy = validy | tmpvalid;
dx(~validx) = NaN;
dy(~validy) = NaN;

for it = 1:numtargets
    this_target = unique_target_labels{it};
    mlo(it).targetlabel = this_target;

    targetindex = (labelid == it);
    
    read_xc = xc(targetindex);
    read_yc = yc(targetindex);
    read_xf = xf(targetindex);
    read_yf = yf(targetindex);
    read_xw = read_xc + read_xf;
    read_yw = read_yc + read_yf;
    
    allmark = [read_xf, read_yf];
    allfield = [read_xc, read_yc];
    
    [umark, ima, imc] = unique(allmark, 'rows');
    [ufield, ifa, ifc] = unique(allfield, 'rows');
    
    
    nfield = size(ufield, 1);
    nmark = size(umark, 1);
    mlo(it).nfield = nfield;
    mlo(it).nmark = nmark;
   
    all_xc = repmat(ufield(:,1),  1, nmark);
    all_yc = repmat(ufield(:,2), 1, nmark);
    all_xf = repmat(umark(:,1), 1, nfield);
    all_yf = repmat(umark(:,2), 1, nfield);
    
    mlo(it).wd.xc = reshape(all_xc', [], 1);
    mlo(it).wd.yc = reshape(all_yc', [], 1);
    mlo(it).wd.xf = reshape(all_xf, [], 1);
    mlo(it).wd.yf = reshape(all_yf, [], 1);
    mlo(it).wd.xw = mlo(it).wd.xc + mlo(it).wd.xf;
    mlo(it).wd.yw = mlo(it).wd.yc + mlo(it).wd.yf;
    
    markindex = knnsearch([mlo(it).wd.xw mlo(it).wd.yw], [read_xw read_yw]);
    
    lindex = find(targetindex);  
    
    for iw = 1:nwafer
        mlo(it).layer.wr(iw).dx = nan * zeros(size(mlo(it).wd.xw));
        mlo(it).layer.wr(iw).dy = mlo(it).layer.wr(iw).dx;
        mlo(it).layer.wr(iw).dx(markindex) = dx(lindex, iw);
        mlo(it).layer.wr(iw).dy(markindex) = dy(lindex, iw);  
    end
end
 






