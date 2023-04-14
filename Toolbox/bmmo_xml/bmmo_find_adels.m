function adel_struct = bmmo_find_adels(dir_name, adels_to_find, adel_fields)
% function adel_struct = bmmo_find_adels(dir_name)
%
% Find the a list of ADEL files in (unzipped) LCP/VCP output dir
%
% Input
%   dir_name: full path of directory containing ADEL files from LCP/VCP
%           BMMO-NXE job output
%
% Output
%   adel_struct: Structure containing the following fields (all strings):
%       adelmet: ADELmetrology file path
%       adeller: lot exposure report
%       adelsbcrep: sbc report
%       adelwhc: wh correction report
%       adelrec: REC file
%       adellcp: LCP/VCP job report
%       adelinv: invalidated data report
%       adelmcl: Multi-cycle lot report
%       adelwdm: waferdatamap file
%
% 20170131 SBPR updated for BOOST; made more generic
% 20190724 SELR option to specify ADEL to look for from input
% 20200917 ANBZ Updated for VCP, where MCL and Invalids ADEL
% files can be absent and Job report has a different filename
% 20201030 LUDU search for ADELwdm and add to struct
% 20201217 ANBZ search for ADELwfrgridNCE and add to struct
% 20210208 LUDU search for ADELsbcrepProtected and add to struct

% Initialize invalids and MCL
adel_struct.adelinv        = [];
adel_struct.adelmcl        = [];
adel_struct.adelexp        = [];
adel_struct.adelwfrgridNCE = [];

% Get ADEL file names from directory
dir_list = dir(dir_name);
allfiles = {dir_list.name};

if nargin < 2
    % ADEL filenames to find
    adels_to_find = {'ADELmetrology', 'ADELler', 'ADELsbcOverlayDriftControlNxerep', ...
        'ADELwaferHeatingCorrectionsReport', 'ADELreticleErrorCorrection', 'ADELlpcJobReportBaseLinerMmoNxe'};
    % Fields in output structure (must match one-to-one with adels_to_find)
    adel_fields = {'adelmet', 'adeller', 'adelsbcrep', 'adelwhc', 'adelrec', 'adellcp'};
    
    % determine if its LIS (VCP) Job report
    if any(contains(allfiles, 'ADELbmmoOverlayJobReport'))
        adels_to_find{1,end} = 'ADELbmmoOverlayJobReport';
        disp('Parsing LIS ADELs:')
    else
        disp('Parsing OTAS ADELs:')
    end
    
    % check if ADELsubstrateInvalidatedData is present
    if any(contains(allfiles, 'ADELsubstrateInvalidatedData'))
        adels_to_find{1,end+1} = 'ADELsubstrateInvalidatedData';
        adel_fields{1,end+1} = 'adelinv';
    end
    % check if ADELmultiCycleLotControlrep is present
    if any(contains(allfiles, 'ADELmultiCycleLotControlrep'))
        adels_to_find{1,end+1} = 'ADELmultiCycleLotControlrep';
        adel_fields{1,end+1} = 'adelmcl';
    end
    % check if ADELexposeTrajectoriesReport is present
    if any(contains(allfiles, 'ADELexposureTrajectoriesReport'))
        adels_to_find{1,end+1} = 'ADELexposureTrajectoriesReport';
        adel_fields{1,end+1} = 'adelexp';
    end
        % check if ADELwaferGridResidualReport is present
    if any(contains(allfiles, 'ADELwaferGridResidualReport'))
        adels_to_find{1,end+1} = 'ADELwaferGridResidualReport';
        adel_fields{1,end+1} = 'adelwfrgridNCE';
    end
    % check if ADELwaferDataMap is present
    if any(contains(allfiles, 'ADELwaferDataMap'))
        adels_to_find{1,end+1} = 'ADELwaferDataMap';
        adel_fields{1,end+1} = 'adelwdm';
    end
    % check if ADELsbcOverlayDriftControlNxerepProtected is present
    if any(contains(allfiles, 'ADELsbcOverlayDriftControlNxerepProtected'))
        fd = find(contains(adels_to_find, 'ADELsbcOverlayDriftControlNxerep'));
        adels_to_find{1,fd} = 'ADELsbcOverlayDriftControlNxerepProtected';
    end
end


% consider xml files only
allfiles = allfiles(~isnan(cell2num(strfind(allfiles, '.xml'))));
% take only the current job report
jobrep_ids = find(contains(allfiles, 'ADELbmmoOverlayJobReport'));
if length(jobrep_ids) > 1
    allfiles =  sub_rmv_previous_jobrep(dir_name, allfiles, jobrep_ids);
end
% find if all the necessary ADEL files are present and copy the filepath
for ii = 1:length(adels_to_find)
    index = strncmp(adels_to_find{ii}, allfiles, length(adels_to_find{ii}));
    assert(length(find(index)) == 1, 'Error: unique %s not found in directory %s', adels_to_find{ii}, dir_name);
    adel_struct.(adel_fields{ii}) = [dir_name filesep allfiles{index}];
end


%% SUB FUNCTIONS

function allfiles_out =  sub_rmv_previous_jobrep(dir_name, allfiles, jobrep_ids)
allfiles_out = allfiles;

for i = 1:length(jobrep_ids)
     jobrep = xml_load([dir_name filesep allfiles_out{jobrep_ids(i)}]);
     creation_time(i) = bmmo_parse_adel_timestamp(jobrep.Header.CreateTime);
end

 [~,min_id] = min(creation_time);
allfiles_out(jobrep_ids(min_id)) = [];

