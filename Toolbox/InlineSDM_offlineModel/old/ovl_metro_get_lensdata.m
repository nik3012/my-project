% Get lens-related data. Needed for NXE lens/scan modeling (MI curved-slit, SDM, KC, KZ).
% Data is fetched from the LMtwin toolbox, so users need access to it.
% Internally caching is used for performance, but also to handle R12 clients which typically set
% their own lens data at the start of modeling, such that subsequent calls do not need the lens toolbox.
%
% Optional inputs:
%   lenstype                   : (default '3300_33') which IMA lens type data file to use
%   release                    : (default 'version2_0_2') which IMA Matlab toolbox release to use, could also be 'WIP'
%
% Warning:
%   This function required the Projection Lensmodel to be available on your Matlab search path:
%       module.include('\\asml.com\eu\shared\nl011032\Projection_tooling\projection_toolbox_p\Lensmodel')
%
% Output: structure which looks like
%
%                   X: [-0.0127 -0.0106 -0.0085 -0.0064 -0.0042 -0.0021 0 0.0021 0.0042 0.0064 0.0085 0.0106 0.0127]
%                   Y: [5x13 double]
%                   W: [5x13 double]
%            obj_z_id: 1
%    obj_z_dx_samples: [-0.0085 -0.0071 -0.0057 -0.0042 -0.0028 -0.0014 0 0.0014 0.0028 0.0042 0.0057 0.0071 0.0085]
%    obj_z_dy_samples: [-0.0250 -0.0254 -0.0258 -0.0260 -0.0262 -0.0263 -0.0264 -0.0263 -0.0262 -0.0260 -0.0258 -0.0254 -0.0250]
%       yslit_samples: [1x13 double]
%             nom_mag: 0.2500
%             Generic: [1x1 struct]
%             CLM_SDM: [1x1 struct]
%                 DLM: [1x1 struct]
%
% See also: ovl_metro_set_lensdata, ovl_model_sdm

% 20130424 ASaz Creation
% 20130519 JFei Persistent cache; simplified option handling using ovl_parse_options
% 20130724 JFei Updated error message to redirect to IT access request form
% 20130806 JFei Added DLM
% 20131023 ASaz Fix for optionsDef
% 20131213 SaBo Added semicolons to suppress output
% 20140401 JFei Use ovl_metro_cache for offline use. Contact me for cached file if you do not have access.
% 20140807 ASaz Fix for fake cache warnings
% 20141127 ABAQ r12: only allow use of values stored in cache
% 20141208 JFEI remove persistent cache, users should use ovl_metro_cache instead
% 20150319 JFEI IMA actively develops on WIP... changed to a stable release
% 20150407 JFEI r12: strfind->findstr and error->error_r12
% 20150727 ABAQ Integrate NXE 2DE-HF phase1: promote to Basics
% 20151207 ABAQ 2DE-HFp1 QBL sync: make implementation R12 *AND* R2012 compliant
% 20180131 XJUN Fix lens model functions after LM migration.
%

function lensdata = ovl_metro_get_lensdata(varargin)

%% option handling
optionsDef.flags     = cell(0);
optionsDef.lenstype  = '3300_33';
optionsDef.release   = 'version2_0_2'; % or something like 'WIP'
[options, arguments] = ovl_parse_options(optionsDef, varargin{:});

% NOTE: the following key is shared with ovl_metro_set_lensdata
cache_key = ['ovl_metro_lensdata' '_' options.lenstype];

check_ok = 1;
% try cache: valid way for models aware of this mechanism.
cache = ovl_metro_cache('get', cache_key);
if cache.valid
    lensdata = cache.data;
    return
else
    check_ok = 0;
end

%<DEBUG>
% analysis only
if ~check_ok
    lensdata         = sub_get_lensdata(options);
    % store in cache for subsequent use
    ovl_metro_cache('set', cache_key, lensdata);
    check_ok = 1;
end
%</DEBUG>

% all options exhausted - bail out with error
% NOTE: don't remove! This part is reachable, when analysis block above will be
% disabled for TwinScan deployable code, for which the only valid option is to
% provide lensdata on interface or propagate via cache
if ~check_ok
    error_r12('OVL:ovl_metro_get_lensdata:bad_lensdata', 'something is wrong with lensdata provided on interface');
end

%  The rest of the body should be dropped.
%<DEBUG>
function lensdata = sub_get_lensdata(options)
%% load data using LMtwin toolbox
try
    [CLM_SDM, DLM, Generic] = sub_lm_calculate(options.lenstype);
catch
    if (~exist('lm_load_definition', 'file'))...
            | (~exist('lm_calc_lens_model', 'file'))
        % check/add LM path
        if ispc
            lm_path = ['\\\\asml.com\\eu\\shared\\nl011032\\Projection_tooling\\projection_toolbox_p\\Lensmodel'];
        else
            lm_path = ['/shared/nl011032/Projection_tooling/projection_toolbox_p/Lensmodel'];
        end
        error_r12('OVL:ovl_metro_get_lensdata:lm_twin_not_found',...
            ['Cannot find projection toolbox; please add the projection module:\n' ...
            'use module.include(' lm_path ')\n' ...
            '(if you don''t have access to this share, please request access using\n' ...
            'https://calltemplates.asml.com/cgi-bin/calltemplates.cgi?form_id=50302)'] );
    else
        error_r12('OVL:ovl_metro_get_lensdata:failed', 'Calculation of lens model failed.');
    end
end

% Use ASML-Q grid, undo nasty scaling of LMtwin data.
lensdata.X = Generic.Lens.Grid.X(1, :) * 1e-3; % [mm] -> [m]
lensdata.Y = Generic.Lens.Grid.Y       * 1e-3;       % [mm] -> [m]
lensdata.W = Generic.Lens.Slit_Weights;
% object plane dependencies
lensdata.obj_z_id = find(strcmp(cellstr(Generic.Manipulator.Name), 'Reticle.Z'));
lensdata.obj_z_dx_samples =...
    sum(Generic.Manipulator.Dependency(:, :, 2, lensdata.obj_z_id) .* lensdata.W) / Generic.Lens.Factors.dZ2_dX * 1e-3; %[nm/um] -> [m/m]
lensdata.obj_z_dy_samples =...
    sum(Generic.Manipulator.Dependency(:, :, 3, lensdata.obj_z_id) .* lensdata.W) / Generic.Lens.Factors.dZ3_dY * 1e-3; %[nm/um] -> [m/m]
% curved slit
lensdata.yslit_samples = sum(lensdata.Y .* lensdata.W);
lensdata.nom_mag = 0.25;

% return lensdata as current in ovl_model_sdm
% return also lensdata.Generic, to encapsulate the nasty global
lensdata.Generic = Generic;
lensdata.CLM_SDM = CLM_SDM;
lensdata.DLM     = DLM;

function [CLM_SDM, DLM, Generic] = sub_lm_calculate(lenstype)
if ispc
    lm_def = lm_load_definition(lenstype);
    
    if ~isempty( findstr(lenstype, '3100'))
        clm_model_str = 'Fading Calibration - CLM - DISTO - SDM Calibration';
        dlm_model_str = '* - DLM - Fading Control';
    else
        clm_model_str = '* - CLM - DISTO - SDM Calibration';
        dlm_model_str = '* - DLM - Default';
    end
    
    CLM_SDM = lm_calc_lens_model(lm_def.Generic, lm_def.LM, clm_model_str);
    DLM     = lm_calc_lens_model(lm_def.Generic, lm_def.LM, dlm_model_str);
    Generic = lm_def.Generic;
else
    load('/sdev_shared/fc065data/EUV/bmmo/lensdata_33_a.mat')
end

%</DEBUG>
