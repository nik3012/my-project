function [mlo, bar_struct] = bmmo_input_from_adels(adelmet, adeller, adelsbcrep, adelwhc, adelrec, wecdir, filter, bar_struct, mapped_wids, exposure_wids, adelmcl)
% function mlo = bmmo_input_from_adels(adelmet, adeller, adelsbcrep, adelwhc, adelrec, wecdir, filter, bar_struct)
%
% Parse ADEL files from LCP/VCP job report to recreate LCP/VCP Matlab input to
% BMMO-NXE model
%
% Input
%   adelmet: ADELmetrology path
%   adeller: ADELler path
%   adelsbcrep: ADELsbcOverlayDriftControlNxeRep path
%   adelwhc: ADELwaferHeatingCorrectionReport path
%   adelrec: ADELreticleErrorCorrection path
%   adelmcl: ADELmultiCycleLotControlrep path
%   wecdir: Directory containing WEC files
%   filter: flag to set time filtering
%
%
% Optional Input:
%   bar_struct: progress bar structure
%   mapped_wids: WIDs mapped in LCP/VCP job report. If empty or missing, the
%                WIDs from ADELmetrology will be used
%   exposure_wids: Exposure context WIDs from LCP/VCP Job report
%   adelmcl: ADELmultiCycleLotControlrep path

% Output:
%   mlo: BMMO-NXE input structure
%   bar_struct: progress bar structure or []
%
% 20170131 SBPR Updated to add progress bar
% 20190725 SELR Keep readout NaNs in input_struct(Constistent with LCP/VCP)
% 20200807 KZAK Added readout of ADELexposureTrajectories (CET NCE)
% 2020918  ANBZ Updated readout mapping based on exposure order using adeller

%empty all variables if not given
if nargin < 8
    bar_struct    = [];
end
if nargin < 9
    mapped_wids   = [];
end
if nargin < 10
    exposure_wids = [];
end
if nargin < 11
    adelmcl       = [];
end

% Define no. of marks for 2L and no. fields for 1L
N_SMF_L2 = 7672;
N_F_L1   = 89;

% parse Adelmetrology
bar_struct = bmmo_log_progress('Reading ADELmetrology', bar_struct);
ml_all     = bmmo_process_adelmetrology(adelmet);

% RINT target
id     = strcmp({ml_all.targetlabel}, 'LS_OV_RINT');
ml_raw = ml_all(id);

% determine WIDs from WID_UP
bar_struct = bmmo_log_progress('Reading WIDs', bar_struct);
wid_id     =  strcmp({ml_all.targetlabel}, 'WID_UP');
%wids = ovl_get_wid(ml_all(wid_id));
[wids, aux, hash] = bmmo_get_wid(ml_all(wid_id));
disp(wids);

% map the WIDs from the LCP report to ADELmetrology
disp('Mapping WIDs from Job report to ADELmetrology');
if ~isempty(mapped_wids)
    widmapping = sub_get_wid_mapping(wids, mapped_wids);
    wids       = mapped_wids;
    %disp(widmapping);
    hash       = hash(widmapping);
    %disp(hash);
else
    widmapping = 1:ml_raw.nwafer;
end
ml_raw = ovl_get_wafers(ml_raw, widmapping);

% Apply WEC
bar_struct = bmmo_log_progress('Applying WEC', bar_struct);
ml_raw     = bmmo_apply_wec(ml_raw, wecdir, wids);

% get an ml structure from adeller and map the layouts
bar_struct = bmmo_log_progress('Reading expinfo', bar_struct);
[ml_raw.expinfo, mark_type, adeller_wids] = bmmo_expinfo_from_adeller(adeller);
bar_struct = bmmo_log_progress(['Mark type: ',mark_type], bar_struct);

% map the readout wafers to the exposure order
if ~isempty(adelmcl)
    bar_struct = bmmo_log_progress('Reading MCL report', bar_struct);
    [~, exposure_hash_list] = bmmo_map_wid_hash(adelmcl, hash);
    disp('Applying exposure wafer sort order based on etched WID');
    [~, wafer_sort_order, sortid] = intersect(exposure_hash_list, hash, 'stable');
    disp(sortid');
    ml_raw = ovl_get_wafers(ml_raw, sortid); % Also need to map chuck IDs here!
    
    % map the readout wafer to the exposure wafer using adeller, if adelmcl is not available
elseif ~isempty(exposure_wids)
    [~, wafer_sort_order, sortid] = intersect(adeller_wids, exposure_wids, 'stable');
    disp('Applying exposure wafer sort order using customer manual mapping and ADELler');
    disp(sortid');
    ml_raw = ovl_get_wafers(ml_raw, sortid);
    
    % in case of no adelmcl and exposure_wids
else
    warning('Assuming same readout and expose order')
    wafer_sort_order = 1:ml_raw.nwafer;
end

% Turn off second layer for case: 2L exposure & 1L readout
if ml_raw.nfield < N_SMF_L2 && length(ml_raw.expinfo.xc) > N_F_L1
    ml_raw.expinfo = bmmo_clip_expinfo_to_l1(ml_raw.expinfo);
end

options = bmmo_default_options_structure;
options = bmmo_get_xy_shift(ml_raw, options);
ml_tmp  = bmmo_field_reconstruction(ml_raw, options);

% Fill in fields of info (such as kfactors, previous corr) and expinfo
bar_struct = bmmo_log_progress('Reading info', bar_struct);
ml_tmp = bmmo_kt_preprocess_input(ml_tmp, adeller, adelwhc, adelsbcrep, filter, wafer_sort_order);

ml_tmp = bmmo_shift_fields(ml_tmp, options.x_shift, options.y_shift);

% Apply REC
bar_struct = bmmo_log_progress('Applying REC', bar_struct);
ml_rec_applied = bmmo_apply_rec(ml_tmp, adelrec);

mlo = bmmo_map_to_smf(ml_rec_applied, ml_raw);
mlo = rmfield(mlo, 'expinfo');
mlo = bmmo_add_missing_fields(mlo, ml_tmp);

for iwafer = 1:mlo.nwafer
    id_uni = find((isnan(mlo.layer.wr(iwafer).dx) & ~isnan(mlo.layer.wr(iwafer).dy))|(~isnan(mlo.layer.wr(iwafer).dx) & isnan(mlo.layer.wr(iwafer).dy)));
    mlo.layer.wr(iwafer).dx(id_uni) = NaN;
    mlo.layer.wr(iwafer).dy(id_uni) = NaN;
end


end

    
function widmapping = sub_get_wid_mapping(allwids, mapped_wids)

widmapping = zeros(size(mapped_wids));
% set the length of string to be same as in ADELmetrology
n = length(allwids{1});
for ii = 1:length(mapped_wids)
    mapped_ids = mapped_wids{ii}(1:n);
    widmapping(ii) = find(strcmp(mapped_ids, allwids));
end

end

