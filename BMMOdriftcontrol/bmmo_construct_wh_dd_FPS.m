function fps = bmmo_construct_wh_dd_FPS (mli, options)
% function fps = bmmo_construct_wh_dd_FPS (mli, options)
%
% This function generates the fingerprints needed for WH or SUSD combined
% model
%
% Input:
%  mli: BMMO/Bl3 processed input, contains WH fingerprints during exposure
%   in mli.info
%
% Output:
%  fps: Generated fingerprints (cell array of ml structures)
%   fps{1} : WHFP on chuck(1)
%   fps{2} : WHFP on chuck(2)
%   Remining are fingerprints specified in options.combined_model_contents
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

% get all-zero single layer ml struct as basis
ml = ovl_get_layers(ovl_get_wafers(mli(1),1),1);
ml_zero = ovl_create_dummy(ml);

% The WH fingerprint is always in the combined model as the first element
fps = bmmo_construct_FPS_WH(ml_zero, options);

% Loop over the rest of the combined model contents
fp_types_length = length(options.combined_model_contents);
for ifp = 1:fp_types_length
    % get the function handle from the model name
    cm_fn = options.cm.(options.combined_model_contents{ifp}).fnhandle;
    
    % execute the model
    fp_cell = feval(cm_fn, ml_zero, options);
    
    fps = [fps, fp_cell];
end



