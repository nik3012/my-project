function mlo = bmmo_apply_wec(mli, wecdir, wids)
% function mlo = bmmo_apply_wec(mli, wecdir, wids)
%
% Apply the wec files in wecdir to the wafers in mli, with the wafer ids
% given by wids in order
%
% Input:
%   mli: overlay structure with n wafers
%   wecdir: directory containing WEC files
%   wids: 1*n cell array of strings: wafer IDs of the wafers in mli, in
%       order
%
% Output: 
%   mlo: mli with WEC applied
%
% 20170103 SBPR Creation
% 20170519 SBPR Now allows ml input data to have points with no WEC
%   correction

% make sure wids has the same length as the number of wafers in mli
assert(length(wids) == mli.nwafer, 'number of wids does not match input number of wafers');

% initialize output
mlo = mli;

% read wecdir
list = dir(wecdir);
fnames = {list.name};

flist = cell(1, mli.nwafer);
% find the adel wec files corresponding to the wids in wecdir
disp('Mapping WEC files:');
for iw = 1:mli.nwafer
    wec_id = logical(cellfun(@length, strfind(fnames, wids{iw})));
    assert(length(find(wec_id)) == 1, 'Unable to map WEC file for WID %s', wids{iw});
    flist{iw} = fnames{wec_id};
    d = sprintf('Wafer %d: %s', iw, flist{iw});
    disp(d);
end

disp('Subtracting WEC offsets');
xy_in = [mli.wd.xw mli.wd.yw];
% for each wafer
for iw = 1:mli.nwafer

    wecfilename = [wecdir filesep flist{iw}];
    [res.xy, res.dxy] = bmmo_parse_wec(wecfilename);

    
    % map the marks to the wafer map definition in mli
    [I, D] = knnsearch(res.xy, xy_in);
    
    
    valid_points = (D < 1e-6);
    if any(~valid_points)
        warning('Warning: Not all data points have WEC correction!');
        warning('Setting uncorrected points to NaN');
    end
        
    %assert(all(D < 1e-6), 'failed to map points of input');
    %assert(length(unique(I)) == length(I), 'failed to make one-to-one mapping')
    
    % subtract the offsets from the offsets for this wafer
    for il = 1:mli.nlayer
        mlo.layer(il).wr(iw).dx(valid_points) = mli.layer(il).wr(iw).dx(valid_points) - res.dxy(I(valid_points), 1);
        mlo.layer(il).wr(iw).dy(valid_points) = mli.layer(il).wr(iw).dy(valid_points) - res.dxy(I(valid_points), 2);
        
        mlo.layer(il).wr(iw).dx(~valid_points) = NaN;
        mlo.layer(il).wr(iw).dy(~valid_points) = NaN;
    end

end


