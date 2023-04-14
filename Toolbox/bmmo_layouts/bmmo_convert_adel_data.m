function [input_struct, readout_date] = bmmo_convert_adel_data(adelmet, adelsbc, adelwh)
% function input_struct = bmmo_convert_adel_data(adelmet, adelsbc, adelwh)
%
% Convert data from ADELmetrology (and optionally,
% ADELsbcOverlayDriftControlNxerep and ADELwaferHeatingCorrectionsReport)
% to BMMO-NXE model input structure
%
% Input:
%   adelmet: full path of ADELmetrology xml file
%
% Optional Input:
%   adelsbc: full path of ADELsbcOverlayDriftControlNxerep xml file
%       (default: zero previous correction)
%   adelwh: full path of ADELwaferHeatingCorrectionsReport xml file
%       (default: zero WH fingerprint)
%
% Output:
%   input_struct: valid BMMO-NXE input structure containing the data from
%   the ADEL file(s)
%
% 20170601 SBPR Creation


[mls, readout_date] = bmmo_read_adelmetrology(adelmet);

% find the first non-WID target label
labels = {mls.targetlabel};
target_index = sub_get_target_id(labels);
ml = mls(target_index);
input_struct = bmmo_convert_generic_ml(ml(1));

if nargin > 1
    prev_corr = bmmo_read_sbc_from_ADELrep(adelsbc);
    prev_corr.ffp = bmmo_map_ffp(input_struct, prev_corr.ffp); 
    
    input_struct.info.previous_correction = prev_corr;
    
    if nargin > 2
        input_struct = bmmo_kt_process_adelwhc_input(input_struct, adelwh);
    end
end


function index = sub_get_target_id(labels)

% look for non-WID targets
target_names = {'WID'};

index = true(size(labels));

for ii = 1:length(target_names)
    index = index & cellfun(@isempty, strfind(labels, target_names{ii})); 
end

