function mlo = bmmo_process_ml_for_adelmet(mli, targetlabel, meastime)
% function mlo = bmmo_process_ml_for_adelmet(mli, targetlabel, meastime)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

mlo = mli;

if isfield(mlo, 'info')
    mlo = rmfield(mlo, 'info');
end
if isfield(mlo, 'expinfo')
    mlo = rmfield(mlo, 'expinfo');
end


mlo.tlgname = '';

fn = fieldnames(mlo.wd);
for ii = 1:length(fn)
    mlo.wd.(fn{ii}) = mlo.wd.(fn{ii}) * 1e3;
end

grid_offset_x = min(abs(mlo.wd.xc)); 
grid_offset_y = min(abs(mlo.wd.yc));

xpitch = 26.0;
ypitch = 33.0;

mlo.info.targetLabel = targetlabel;
mlo.info.measTime = meastime;

mlo.info.griddata.row = getindex(mlo.wd.yc, ypitch, grid_offset_y);
mlo.info.griddata.col = getindex(mlo.wd.xc, xpitch, grid_offset_x);

for il = 1:mlo.nlayer
    for iw = 1:mlo.nwafer
        mlo.layer(il).wr(iw).dx = mlo.layer(il).wr(iw).dx * 1e9;
        mlo.layer(il).wr(iw).dy = mlo.layer(il).wr(iw).dy * 1e9;
        mlo.layer(il).wr(iw).xv = ~isnan(mlo.layer(il).wr(iw).dx);
        mlo.layer(il).wr(iw).yv = ~isnan(mlo.layer(il).wr(iw).dy);
    end
end

end

function idx = getindex(posval,pitch,offset)

    idx =  round((posval - offset)/pitch);

end