function [mlo, timestamp] = bmmo_convert_mmo_tlg(tlg, exp_tlg, adelwhc, nosub)
% function mlo = bmmo_convert_mmo_tlg(tlg, exp_tlg, mdl)
%
% Convert ATP-MMO testlog to bmmo input structure, optionally adding exposure info (from exposure testlog) and 
% WH K-factors (from ADELwaferHeatingCorrectionsReport)
%
% Input:
%   tlg: full path of WEC-corrected ATP-MMO testlog
%
% Optional:
%   exp_tlg: full path of exposure testlog (if not provided, field exposure
%       order will be taken from the field order in tlg, which is not
%       necessarily accurate
%   mdl: full path of MDL containing WH k-factors. If not provided, a zero
%       WH fingerprint will be provided
%
% Output: mlo: testlog converted to valid bmmo-nxe input format
%
% 20160916 SBPR Creation
% 20191022 SELR Read in scan direction and chuck usage from exp_tlg,
%               several fixes

if nargin < 3
    read_adelwhc = false;
else
    read_adelwhc = true;
end

if nargin < 2
    read_exp = false;
else
    read_exp = true;
end

if nargin < 4
    nosub = false;
end

disp('Reading raw testlog');
% First read the testlog
ml_raw = ovl_read_testlog(tlg, 'info');

try
    ml_raw = ovl_apply_rec(ml_raw);
catch
    warning('Could not perform REC, please do so manually if necessary')
end
mlt = rmfield(ml_raw, 'info');

% Convert to generic BMMO-NXE input format
% NB this assumes default chuck order
mlo = bmmo_convert_generic_ml(mlt);

% If provided, read the exposure testlog
if read_exp
    disp('Reading exposure testlog');
    ml_exp = ovl_read_testlog(exp_tlg, 'info');
    %[expinfo, expose_order] = bmmo_expinfo_from_tlg(ml_exp);
    mlo.expinfo = ml_exp.expinfo(2);
    mlo = ovl_get_fields(mlo, mlo.expinfo.map_fieldtoexp);
    mlo.expinfo.field_size = ml_exp.info.expo.lot.fieldsize{:};
    mlo.info.report_data.Scan_direction = mlo.expinfo.v;
    mlo.info.F.chuck_id = ml_exp.info.S.chuck_id;
    chucks_used = length(unique(mlo.info.F.chuck_id));
    if chucks_used == 2
        mlo.info.F.chuck_operation = 'USE_BOTH_CHUCK';
    elseif chucks_used < 2
        mlo.info.F.chuck_operation = 'ONE_CHUCK';
    end
end

% Convert the exposure testlog to expinfo
if read_adelwhc
    disp('Reading WH data from ADELwaferHeatingCorrectionsReport');
    % If provided, read the WH K-factors from the ADELwhc file
    % convert to BMMO-NXE input format
    mlo = bmmo_kt_process_adelwhc_input(mlo, adelwhc);

end

formatstring = 'eee, dd MMM yyyy HH:mm:ss';
if ~read_exp
    if isfield(ml_raw.info, 'S')
        timestamp = datetime(ml_raw.info.S.date(1:length(formatstring)), 'InputFormat', formatstring);
    else
        timestamp = datetime(ml_raw.info.M.date(1:length(formatstring)), 'InputFormat', formatstring);
    end
else
    timestamp = datetime(ml_exp.info.S.date(1:length(formatstring)), 'InputFormat', formatstring);
end

if ~nosub
    % convert to single-layer s2f
    mlo = ovl_sub_layers(mlo);   
    % single layer, so need full combined model
    mlo.configurable_options.combined_model_contents = {'MIX', 'MIY', 'INTRAF', 'INTERF', 'KA'};
end
