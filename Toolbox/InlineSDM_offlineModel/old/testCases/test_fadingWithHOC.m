addpath('C:\Users\jim\Documents\Projects\BMMO\Matlab_InlineSDM\July30');

pp.mag3y = -0.001058921654493;
pp.accx = -0.00011922665655926;
pp.accy = 0.;
pp.cshpx = 0.;
pp.cshpy = -0.000162523881162207;
pp.flw3x = 0.00078730758142082;
pp.k8 = 0.;
pp.k9 = -2.47571960354959E-06;
pp.k10 = -5.98157249402644E-07;

mlz= ovl_create_dummy('marklayout','BA-XY-DYNA-13x19','nlayer',1);
mlz_f = ovl_average_fields(mlz);
ml=ovl_model(mlz_f,'apply',pp,1);
lensdata = ovl_metro_parse_lens_data(ml,'lens_type','guess');
[res, corr, par, res_z2z3]=HOCModel(ml, lensdata);

par.static

%% third order in BOP_Rx is added.
[ml_res, intra_par] = ovl_model_hoc_JIMI(ml, lensdata);