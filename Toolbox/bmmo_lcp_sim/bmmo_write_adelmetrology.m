function bmmo_write_adelmetrology(mls, targetlabels, name, MachineId)
% function bmmo_write_adelmetrology(mls, targetlabels, name, MachineId)
%
% Write ADELmetrology from arbitrary ml structures
%
% Input:
%   mls: array of ml structures
%   targetlabels: cell array of target label names
%   name: file identifier (string)
%   MachineID: TS Machine ID (string)
%
% Writes output to file  ['ADELmetrology_' name '.xml']
%
% This function uses the RapidXml C++ library Copyright (c) 2006, 2007 Marcin Kalicinski 
%
% 20170908 SBPR Creation


for ii = 1:length(mls)
    mls(ii).tlgname = targetlabels{ii};
end

mls(1).tlgname = name;
info_readout = bmmo_getADELmetroinfo(mls(1), MachineId);
info_readout.Header.Title = name;

meastime = info_readout.Header.CreateTime;

for ii = 1:length(mls)
    ml_array(ii) = bmmo_process_ml_for_adelmet(mls(ii), targetlabels{ii}, meastime);
end

filename = ['ADELmetrology_' name '.xml'];

bmmo_write_adelmetrology_mex(info_readout, ml_array, filename);

