function mlo = bmmo_combine_fields(mli,mlt,fid)
% function mlo = bmmo_combine_fields(mli,mlt,fid)
%
% Wrapper for ovl_combine_fields which also combines the information in
% BMMO/BL3 NXE substructures. Append given field ids from mlt to mli.
%
% Input
%   mli, mlt: ml structures
%   fid: double vector of field ids from mlt to append to mli
%
% Output
%   mlo: ml structure, mli with fields fid from mlt append, and BMMO/BL3
%   NXE substructures updated accordingly

mlo = ovl_combine_fields(mli, ovl_get_fields(mlt,fid));

if isfield(mlo, 'expinfo') & isfield(mlt, 'expinfo')
    mlo.expinfo.xc              = [mlo.expinfo.xc            ; mlt.expinfo.xc(fid)            ];
    mlo.expinfo.yc              = [mlo.expinfo.yc            ; mlt.expinfo.yc(fid)            ];
end

if isfield(mlo, 'info') & isfield(mlt, 'info')
    if isfield(mlo.info, 'report_data') & isfield(mlt.info, 'report_data')
        if isfield(mlo.info.report_data, 'Scan_direction') & isfield(mlt.info.report_data, 'Scan_direction')
            mlo.info.report_data.Scan_direction = [mlo.info.report_data.Scan_direction mlt.info.report_data.Scan_direction(fid)];
        end
        if isfield(mlo.info.report_data, 'WH_K_factors') & isfield(mlt.info.report_data, 'WH_K_factors')
            for iwafer = 1:mlo.nwafer;
                mlo.info.report_data.WH_K_factors.wafer(iwafer).field = [mlo.info.report_data.WH_K_factors.wafer(iwafer).field mlt.info.report_data.WH_K_factors.wafer(iwafer).field(fid)];
            end
        end
    end
end

