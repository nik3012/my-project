
function bmmo_inject_ADELmetrology_wids(adelmet_in, target, wids)
% function bmmo_inject_ADELmetrology_wids(adelmet_in, type, wids)
%
% Inject the given wids into a given ADELmetrology file
% The WIDS can be either a cell array of strings, or a cell array of 
% 2-element ml arrays, where ml(1) encodes WID_UP and ml(2) encodes
% WID_DOWN
%
% Input: adelmet_in: full path of adelmetrology file
%        wids: either a 1 x n cell array of wafer id strings, or an ml structure  
% 
% Output: 


% read adelmetrology measurements into ml structure
disp('Reading ADELmetrology file');
[ml, header] = bmmo_read_adelmetrology(adelmet_in);

mlid = 0;
for id = 1:length(ml)
    if strcmp(ml(id).targetlabel, target)
        mlid = id;
    end
end
if mlid == 0
    error('target %s not found in adelmetrology file', target);
end

machine_id = header.MachineID;

if iscell(wids) && ischar(wids{1})
    nwafer_wids = length(wids);
else
    nwafer_wids = wids.nwafer;
end
assert(nwafer_wids >= ml(mlid).nwafer, 'Not enough wids specified for input data');

% (if needed) convert given wid into YS wid marks in separate ml structures
if iscell(wids) && ischar(wids{1})
    disp('Encoding WIDs');
    for iw = 1:nwafer_wids
        mlwid{iw} = bmmo_encode_wid(wids{iw});
    end
    
    % combine the per-wafer wid data into two ml structures
    ml_wid_up = mlwid{1}(1);
    ml_wid_down = mlwid{1}(2);
    for iw = 2:nwafer_wids
        ml_wid_up = ovl_combine_wafers(ml_wid_up, mlwid{iw}(1));
        ml_wid_down = ovl_combine_wafers(ml_wid_down, mlwid{iw}(2));
    end
else
    % split into WID_UP and WID_DOWN targets
    ml_wid_up = sub_get_subset(wids, 1);
    ml_wid_down = sub_get_subset(wids, -1);
end



% write adelmetrology again
disp('writing ADELmetrology');
bmmo_write_adelmetrology(ml_wid_up, ml_wid_down, ml(mlid), 'wid_injected', machine_id);


function mlo = sub_get_subset(mli, k)

mlo = mli;
if k > 0
   subids = mlo.wd.yw > 0; 
else
   subids = mlo.wd.yw < 0; 
end

subids = find(subids);
subids = subids(2:2:end); % only encode the 92 marks used

mlo.wd.xc = mlo.wd.xc(subids);
mlo.wd.yc = mlo.wd.yc(subids);
mlo.wd.xf = mlo.wd.xf(subids);
mlo.wd.yf = mlo.wd.yf(subids);
mlo.wd.xw = mlo.wd.xw(subids);
mlo.wd.yw = mlo.wd.yw(subids);

for il = 1:mlo.nlayer
    for iw = 1:mlo.nwafer
        mlo.layer(il).wr(iw).dx = mlo.layer(il).wr(iw).dx(subids);
        mlo.layer(il).wr(iw).dy = zeros(size(mlo.layer(il).wr(iw).dx));
    end
end

mlo.nfield = length(mlo.wd.xc);
