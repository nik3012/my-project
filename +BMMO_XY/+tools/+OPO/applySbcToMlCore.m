function [mlOut, sbcFps] = applySbcToMlCore(mlInfoAppended, corr, correctionFactor, intrafieldOrder)
% function [mlOut, sbcFps] = applySbcToMlCore(mlInfoAppended, corr, correctionFactor, intrafieldOrder)
%
% function called by applySbcToMl that does the actual
% (de)correction by combining the SBCs and the OPO ml obtained from
% appendInfoToMl
%
%
% Inputs:
% - mlInfoAppended        = parsed ADELmetrology containing overlay measurements as produced by
%                           ovl_read_adelmetrology and info appended by
%                           appendInfoToMl
% - corr                 = parsed SBC correction set as produced by
%                          bmmo_kt_process_SBC2 / bmmo_kt_process_SBC2rep
% - correctionFactor
%                        = factor to use when applying SBC fingerprint to ml
%                          structure. 1 corresponds to correction, -1 corresponds to
%                          decorrection.
% - ADELler              = filepath of OPO ADELLer or xml_loaded ADELler
% - intrafieldOrder      = order of intrafield corrections fit to the SBC correction
%                          set. Possible values are 3 (18 par) and 5 (33 par). 5th
%                          order is the default.
%
% Outputs:
% - mlOut                = (de)corrected ml structure in exposure order
% - sbcFps               = SBC fingerprint on OPO ml layout
% 
%
% Note: This function is not meant to be called separately, only through
% applySbcToMl.
%



% Check whether input SBC is a BMMO NXE or BL3 correction set
BMMO_KA_GRID_POINTS = 3721;
if length(corr.KA.grid_2de(1).x) > BMMO_KA_GRID_POINTS
    options = bl3_default_options_structure;
else
    options = bmmo_default_options_structure;
end

% Update intrafield actuation order
options = bmmo_options_intraf(options, intrafieldOrder);

% Generate the SBC fingerprint on relevant OPO ml layout
[sbcFps, ~] = bmmo_apply_SBC_to_ml(mlInfoAppended, corr, 1, options);

% (De)correct the generated OPO ml using the total SBC fingerprint
mlOut = ovl_combine_linear(mlInfoAppended, 1, sbcFps.TotalSBCcorrection, correctionFactor);

end