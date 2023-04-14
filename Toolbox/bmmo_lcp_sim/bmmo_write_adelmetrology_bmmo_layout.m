function bmmo_write_adelmetrology_bmmo_layout(ml_wid_up, ml_wid_down, mlo, name, MachineId)
% function bmmo_write_adelmetrology_bmmo_layout(ml_wid_up, ml_wid_down, mlo, name, MachineId)
%
% Write ADELmetrology from bmmo layout ml structures
%
% Input:
%   ml_wid_up: WID_UP overlay structure
%   ml_wid_down: WID_DOWN overlay structure
%   mlo: 1x1 or 1x2 array of LS_OV_* overlay structures
%   name: file identifier (string)
%   MachineID: TS Machine ID (string)
%
% Writes output to file  ['ADELmetrology_' name '.xml']
%
% This function uses the RapidXml C++ library Copyright (c) 2006, 2007 Marcin Kalicinski 
%
% 20170908 SBPR Creation

for ilayer = 1:length(mlo)
    mlo(ilayer).tlgname = name;
end

info_readout = bmmo_getADELmetroinfo(mlo(1), MachineId);

meastime = info_readout.Header.CreateTime;

% build ml array
ml_array(1) = bmmo_process_ml_for_adelmet(mlo(1), 'LS_OV_RINT', meastime);
ml_array(2) = bmmo_process_ml_for_adelmet(ml_wid_up, 'WID_UP', meastime);
ml_array(3) = bmmo_process_ml_for_adelmet(ml_wid_down, 'WID_DOWN', meastime);

if numel(mlo) > 1
    ml_array(4) = bmmo_process_ml_for_adelmet(mlo(2), 'LS_OV_NOWEC_RINT', meastime);
end

filename = ['ADELmetrology_' name '.xml'];

bmmo_write_adelmetrology_mex(info_readout, ml_array, filename);

