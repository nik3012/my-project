function [ml_res, setpoints, ml_fad] = bmmo_cet_model(ml, varargin)
% function [ml_res, setpoints, ml_fad] = bmmo_cet_model(ml, varargin)
%
% This is a wrapper function for ovl_cet_model. It fixes two
% inconsistencies of the ml structures output by CET:
% ml.layer should be a 1 x nwafer structure,  and the dz field is removed
%
% For details on input & output parameters see ovl_cet_model
% 

[ml_res, setpoints, ml_fad] = ovl_cet_model(ml, varargin{:});

ml_res = sub_fix_ml(ml_res);
ml_fad = sub_fix_ml(ml_fad);
end


function mlo = sub_fix_ml(mli)
mlo = mli;
if size(mlo.layer.wr, 1) > size(mlo.layer.wr, 2)
    mlo.layer.wr = mlo.layer.wr';
end
mlo.layer.wr = rmfield(mlo.layer.wr, 'dz');
end

