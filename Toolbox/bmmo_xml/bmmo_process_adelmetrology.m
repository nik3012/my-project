function mlo = bmmo_process_adelmetrology(filename)
% function mlo = bmmo_process_adelmetrology(filename)
%
% Read an adelmetrology file into a 1 x n array of ml structures, where n
% is the number of unique target names in RecipeTargetId.TargetLabel
%
% Input: adel_input: full path of ADELmetrology input xml file
%
% Output: mlo: 1 x n array of ml structures
%
% 20160606 SBPR Creation
% 20190731 SELR Updated smf for consistency with lcp

[xc, yc, xf, yf, labelid, dx, dy, validx, validy, unique_target_labels] = bmmo_parse_adelmetrology(filename);

[~, nwafer] = size(dx);

% Get the unique target labels in this structure
numtargets = length(unique_target_labels);

mlo = repmat(struct('nwafer', nwafer, 'layer', [], 'wd', [], 'nmark', 1, 'nfield', 0, 'nlayer', 1, 'tlgname', ''), 1, numtargets);

% Set invalid overlay data to NaN (excluding WID_UP readouts)
tmpvalid = false(size(validx));
wupid = find(strcmp(unique_target_labels, 'WID_UP'));
wupid = find(labelid == wupid(1));
tmpvalid(wupid, :) = true;
validx = validx | tmpvalid;
validy = validy | tmpvalid;
dx(~validx) = NaN;
dy(~validy) = NaN;

for it = 1:numtargets
    this_target = unique_target_labels{it};
    mlo(it).targetlabel = this_target;

    targetindex = (labelid == it);
    mlo(it).wd.xc = xc(targetindex);
    mlo(it).wd.yc = yc(targetindex);
    mlo(it).wd.xf = xf(targetindex);
    mlo(it).wd.yf = yf(targetindex);
    mlo(it).wd.xw = mlo(it).wd.xc + mlo(it).wd.xf;
    mlo(it).wd.yw = mlo(it).wd.yc + mlo(it).wd.yf;
    
    mlo(it).nfield = length(mlo(it).wd.xw);
    lindex = find(targetindex);  
    
    for iw = 1:nwafer
        mlo(it).layer.wr(iw).dx = dx(lindex, iw);
        mlo(it).layer.wr(iw).dy = dy(lindex, iw);  
    end
end
 







