function ml_CET_out = bmmo_interp_CET_NCE(ml_CET_NCE, options)
% function ml_CET_out = bmmo_interp_CET_NCE(ml_CET_NCE, options)
%
% Given the ml structure(KA CET NCE, full CET NCE) in CET grid layout, interpolates it per
% field to BMMO layout (RINT marks)
% 
% Input:
%   ml_CET_NCE: KA CET NCE or full CET NCE in ml structure parsed from ADEL
%   options:    bl3 option structure
%
% Output:
%   ml_CET_out: KA CET NCE or CET NCE in BMMO layout

% get CET NCE coordinates yf/yw( more decimals)
ml_temp = ovl_create_dummy(ml_CET_NCE, 'marklayout', options.CET_marklayout);
ml_CET_NCE =   bmmo_sort_ml(ml_CET_NCE, ml_temp);
ml_CET_NCE.wd  = ml_temp.wd;

% Peform per field interpolation of CET NCE
ml_CET_out = bmmo_convert_CET_to_RINT(ml_CET_NCE, options);

