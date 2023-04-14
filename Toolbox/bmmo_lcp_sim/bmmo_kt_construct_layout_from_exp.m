function mlo = bmmo_kt_construct_layout_from_exp(tlgpath, shift_x, shift_y)
% function mlo = bmmo_kt_construct_layout_from_exp(tlgpath, shift_x, shift_y)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

ml_mmo = ovl_read_testlog(tlgpath,'info');
% constants for bmmo_KT_2_ml

expinfo = ml_mmo.expinfo(2);

% construct a template full-field ml structure based on the input

full_dummy = ovl_create_dummy('13X19', 'nlayer', 1, 'nwafer', 1);
full_field = ovl_get_fields(full_dummy, 1);

ml_exp.nmark = 247;
ml_exp.nfield = length(expinfo.xc);

ml_exp.wd.xc = reshape(repmat(expinfo.xc, 1, ml_exp.nmark)',[],1);
ml_exp.wd.yc = reshape(repmat(expinfo.yc, 1, ml_exp.nmark)',[],1);
ml_exp.wd.xf = reshape(repmat(full_field.wd.xf,[ml_exp.nfield 1]),[],1);
ml_exp.wd.yf = reshape(repmat(full_field.wd.yf,[ml_exp.nfield 1]),[],1);
ml_exp.wd.xw = ml_exp.wd.xc + ml_exp.wd.xf;
ml_exp.wd.yw = ml_exp.wd.yc + ml_exp.wd.yf;

ml_exp.nwafer = 1;
ml_exp.nlayer = 1;

ml_exp.layer.wr.dx = zeros(size(ml_exp.wd.xw));
ml_exp.layer.wr.dy = ml_exp.layer.wr.dx;

mlo = bmmo_shift_fields(ml_exp, shift_x, shift_y);