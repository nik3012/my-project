function ml_field = bmmo_cet_to_ml_field(cet_residual, field_id, wafer_id)
% function ml_field = bmmo_cet_to_ml_field(cet_residual, field_id, wafer_id)
%
% This function converts the per field CET residual in ndgrid format 
% to ml structure
%
% Input:
%  cet_residual: per field CET residual in ndgrid format
%  field_id: CET residual field ID
%  wafer_id: CET residual wafer ID
%
% Output:
%  ml_field: Per field CET residual converted from ndgrid to ml struct

ml_field.wd.xf = reshape(cet_residual.xf_grid, [], 1);
ml_field.wd.yf = reshape(cet_residual.yf_grid, [], 1);
ml_field.wd.xc = zeros(size(ml_field.wd.xf));
ml_field.wd.yc = zeros(size(ml_field.wd.xf));
ml_field.wd.xw = ml_field.wd.xf;
ml_field.wd.yw = ml_field.wd.yf;

ml_field.nlayer = 1;
ml_field.nwafer = 1;
ml_field.nfield = 1;
ml_field.nmark = numel(ml_field.wd.xf);

ml_field.tlgname = '';

ml_field.layer.wr.dx = reshape(cet_residual.wafer(wafer_id).dx(:, field_id), size(ml_field.wd.xf));
ml_field.layer.wr.dy = reshape(cet_residual.wafer(wafer_id).dy(:, field_id), size(ml_field.wd.xf));