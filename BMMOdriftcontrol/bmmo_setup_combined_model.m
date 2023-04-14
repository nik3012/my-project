function [ml_7x7, fps, C] = bmmo_setup_combined_model(mli, options, model)
% function [ml_7x7, fps, C] = bmmo_setup_combined_model(mli, options, model)
%
% Initialize the combined model for the WH and SUSD sub-models
% Returns the input structure resampled to 7X7, and the raw combined model
% fingerprints
%
% Input:
%  mli: ml structure
%  options: structure containing fields: WH K-factors, MI data
%  model: Combined model type, 'SUSD_1L', 'WH', 'WH_SUSD'
%
% Output: 
%  ml_7x7: mli with extra edge fields removed and resampled to 7X7
%  fps: vector of fingerprint structures
%  C: constraint matrix

% remove extra edgefields if applicable
ml_without_extra_edge = sub_remove_extra_edgefields(mli, options);

% extract 7x7 from remaining fields
dummy_reduced = bmmo_get_layout(ml_without_extra_edge, options.reduced_reticle_layout, options);

% resample input to 7x7
ml_7x7 = bmmo_resample(ml_without_extra_edge, dummy_reduced, options.WH_resample_options);

% average per chuck
ml_7x7 = bmmo_average_chuck(ml_7x7, options);

% WH sub-model & SUSD sub-model using combined model
% FPS is composed of WH, base of mirrors (x and y), interfield, intrafield and susd.
[fps, C] = bmmo_construct_FPS(ml_7x7, options, model);


% subfunction to remove edge fields from mli if applicable
function mlo = sub_remove_extra_edgefields(mli, options)

mlo = mli;

if mlo.nfield > options.layer_fields{1}(end) 
    mlo = ovl_get_fields(mlo, options.layer_fields{1});
end