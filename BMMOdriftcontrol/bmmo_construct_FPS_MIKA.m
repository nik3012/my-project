function fps = bmmo_construct_FPS_MIKA (mli, options, combined_model_contents)
% function fps = bmmo_construct_FPS_MIKA (mli, options, combined_model_contents)
%
% This function generates the fingerprints needed for MIKA-combined
% model
%
% Input:
%  mli: Input tlg, contains WH fingerprints during exposure in mli.info
%  options: BMMO/BL3 option structure
%  combined_model_contents: sub-model contents of the combined model
%
% Output:
% fps: Generated fingerprints (cell array of ml structures)
%   fps{1} : WHFP on chuck(1)
%   fps{2} : WHFP on chuck(2)
%   Remining are fingerprints specified in options.combined_model_contents
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

% get all-zero single layer ml struct as basis
ml = ovl_get_layers(ovl_get_wafers(mli(1),1),1);
ml_zero = ovl_create_dummy(ml);

% % The WH fingerprint is always in the combined model as the first element
% fps = bmmo_construct_FPS_WH(ml_zero, options);
% Fit WH fps's with 0
if options.chuck_usage.nr_chuck_used == 1
    fps{1} = ml_zero;
else
    fps{1} = ml_zero;
    fps{2} = ml_zero;
end
% For MIKA use different combined model
fp_types_length = length(combined_model_contents);
for ifp = 1:fp_types_length
    % get the function handle from the model name
    cm_fn = options.cm.(combined_model_contents{ifp}).fnhandle;
    
    % execute the model
    fp_cell = feval(cm_fn, ml_zero, options);
    fps = [fps, fp_cell];
end

