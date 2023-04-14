function [mlo, kt_struct] = bmmo_get_meas_data(wafers_out, expinfo, phase, mark_type)
% function mlo = bmmo_get_meas_data(wafers_out, expinfo, phase)
%
% Get an ml structure (array) from KT_wafers_out, based on a template
% constructed from expinfo
%
% Input: wafers_out: full path to a KT_wafers_out file
%        expinfo: structure containing xc and yc vectors
%
% Output: mlo: ml structure array
%
% 20160331 SBPR Creation

if nargin < 3
    phase = 1;
end

if nargin < 4
    mark_type = 'XPA';
end

% constants for bmmo_KT_2_ml
USE_LAYOUT = 1;

if phase == 1
    X_SHIFT = 0.8405e-3;
    Y_SHIFT = -0.8695e-3;

    X_SHIFT_L2 = 0.9605e-3;
    Y_SHIFT_L2 = -0.1895e-3;

else
    X_SHIFT = 0;
    Y_SHIFT = 0;

    X_SHIFT_L2 = 0;
    Y_SHIFT_L2 = 0;
end

switch mark_type
    case 'XPA'
        layoutname = '13X19';
        xf_shift = [0 -260e-6];
        yf_shift = [0 -40e-6];
    case 'BF3u2V'
        layoutname = 'BF-FOXY3-DYNA-13X19';
        xf_shift = [0 -46e-6];
        yf_shift = [0 4e-5];
%         xf_shift = [0 0];
%         yf_shift = [0 0];
    otherwise 
        error('Unsupported mark type %s', mark_type);
end

% construct a template full-field ml structure based on the input
ml_exp = bmmo_kt_ml_from_expinfo(expinfo, layoutname);

% apply inverted shifts and recombine
ml_main = ovl_get_fields(ml_exp, 1:87);
ml_edge = ovl_get_fields(ml_exp, 88:ml_exp.nfield);

ml_main = bmmo_shift_fields(ml_main, -X_SHIFT, -Y_SHIFT);
ml_edge = bmmo_shift_fields(ml_edge, -X_SHIFT_L2, -Y_SHIFT_L2);

ml_exp = ovl_combine_fields(ml_main, ml_edge);

% map wafers_out to this structure

[mlo, kt_struct] = bmmo_KT_2_ml(wafers_out, USE_LAYOUT, ml_exp, 'EXPOSED!', mark_type);

% apply shifts to output and recombine
ml_main = ovl_get_fields(mlo, 1:87);
ml_edge = ovl_get_fields(mlo, 88:ml_exp.nfield);

ml_main = bmmo_shift_fields(ml_main, X_SHIFT, Y_SHIFT);
ml_edge = bmmo_shift_fields(ml_edge, X_SHIFT_L2, Y_SHIFT_L2);

mlo = ovl_combine_fields(ml_main, ml_edge);

% apply ys readout shift 
mlo = bmmo_shift_fields(mlo, xf_shift, yf_shift);

disp('ensuring field centres from ADELler are found in reconstructed ml');
xc_yc = [mlo.wd.xc, mlo.wd.yc];
u_xc_yc = unique(xc_yc, 'rows');
e_xc_yc = [expinfo(1).xc expinfo(1).yc];
[~, sortorder] = sort(e_xc_yc(:,2));
e_xc_yc = e_xc_yc(sortorder, :);
[~, sortorder] = sort(e_xc_yc(:,1));
e_xc_yc = e_xc_yc(sortorder, :);

assert(max(max(abs(u_xc_yc - e_xc_yc))) < 1e-12);

disp('verifying all fields have measurement data');
for iw = 1:mlo.nwafer
   for ifield = 1:mlo.nfield
        ml_field = ovl_get_fields(ovl_get_wafers(mlo, iw),ifield);
        if(all(isnan(ml_field.layer.wr.dx)) || all(isnan(ml_field.layer.wr.dy)))
            error('field %d of wafer %d is all NaN', ifield, iw);
        end
   end
end
