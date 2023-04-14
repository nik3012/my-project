function susd = bmmo_kt_get_injected_SUSD(drift_path)
% function susd = bmmo_kt_get_injected_SUSD(drift_path)
%
% Return the injected SUSD parameters
%
% Input:
%           drift_path: path of directory containing drift dd files
%
% Output: susd: IFO correction per chuck and scan direction


susdpath = [drift_path filesep 'BMMO_drift_SUSD.dd'];

susdmat = dd2mat(0, susdpath);
for ic = 1:2
    ty(ic) = susdmat.chuck(ic).intra_field.offset.translation.y ;
end

options = bmmo_default_options_structure;
out = bmmo_default_output_structure(options);
susd = out.corr.SUSD;

IFO_chuck_index = [1 1 2 2];
for icorr_IFO = 1:length(options.IFO_scan_direction)
    susd(icorr_IFO).TranslationY = options.IFO_scan_direction(icorr_IFO)*ty(IFO_chuck_index(icorr_IFO));
end