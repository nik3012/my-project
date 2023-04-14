function [mlOut, sbcFps] = applySbcToMl(mlIn, corr, correctionFactor, ADELler, intrafieldOrder)
% function [mlOut, sbcFps] = applySbcToMl(mlIn, corr, correctionFactor, ADELler, intrafieldOrder)
%
% This function takes a parsed SBC correction set, an ml structure from an 
% OPO ADELmetrology as obtained by ovl_read_adelmetrology and the ADELler from the OPO lot. 
% Optionally, it is possible to specify the order of intrafield corrections
% using intrafieldOrder.
% It then applies the fingerprint of the SBC correction set to the ml
% structure using the provided correction factor.
%
% Inputs:
% - mlIn        = parsed ADELmetrology containing overlay measurements as produced by
%                 ovl_read_adelmetrology
% - corr        = parsed SBC correction set as produced by
%                 bmmo_kt_process_SBC2 / bmmo_kt_process_SBC2rep
% - correctionFactor
%               = factor to use when applying SBC fingerprint to ml
%                 structure. 1 corresponds to correction, -1 corresponds to
%                 decorrection.
% - ADELler     = filepath of OPO ADELLer or xml_loaded ADELler
%
% Optional inputs:
% - intrafieldOrder
%                 = order of intrafield corrections fit to the SBC correction
%                 set. Possible values are 3 (18 par) and 5 (33 par). 5th
%                 order is the default.
%
% Outputs:
% - mlOut      = (de)corrected ml structure in exposure order
% - sbcFps     = SBC fingerprint on OPO ml layout
% 
% Relevant KT: D001217927 PSA KT BL3 OPO (De)correction Tooling

import BMMO_XY.tools.OPO.*

% Check intrafieldOrder input
if ~exist('intrafieldOrder', 'var')
    intrafieldOrder = 5;
end

% Append ADELler info to ml-struct
mlInfoAppended = appendInfoToMl(mlIn, ADELler);

% (de)apply the correction
[mlOut, sbcFps] = applySbcToMlCore(mlInfoAppended, corr, correctionFactor, intrafieldOrder);

% Cleanup
mlOut      = rmfield(mlOut, {'expinfo', 'info'});
mlOut.info = mlIn.info;

end

