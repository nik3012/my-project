function out = bmmo_default_model_result(mli, options)
% function out = bmmo_default_model_result(mli, options)
%
% Initialize the default structure for intermediate model results. This
% structure is used by bmmo_run_submodels for maintaining and passing
% results of the BMMO-NXE submodels.
%
% Input:
%   mli:        ml structure
%   options:    options structure, as defined in
%               bmmo_default_options_structure
%
% Output:
%   out:        initialized structure for submodel results

% Create default MI and KA grids and values
mxy = options.map_param.start_position:options.map_param.pitch:-options.map_param.start_position;
mz = zeros(length(mxy),1);
ka_grid_exp = bmmo_KA_grid(options.KA_start, options.KA_pitch);
ka_grid_meas = bmmo_KA_grid(options.KA_meas_start, options.KA_pitch);

ka_grid_exp = bmmo_KA_fix_interpolant(ka_grid_exp);
ka_grid_meas = bmmo_KA_fix_interpolant(ka_grid_meas);

% Initialize chuck-independent results
out.SUSD.Calib_SUSD     = [0, 0];
out.SUSD.Monitor_SUSD   = out.SUSD.Calib_SUSD;

% Initialize outlier stats
out.outlier_stats = bmmo_default_outlier_stats(mli);
out.ml_outlier_removed = mli;

% Initialize residuals

% Initialize WH input
out.WH.Calib_WH         = 0;
out.WH.lambda           = 0;

% We have two versions of the input WH fingerprint in results
% For the single-layer case, both are the same
out.WH.model_fp = options.WH.input_fp_per_chuck;
out.WH.res_fp = options.WH.input_fp_per_chuck;

% Initialize layout-dependent results
if options.no_layer_to_use == 1
    out.WH.input            = ovl_get_fields(mli, options.layer_fields{1});
    out.interfield_residual = bmmo_average_chuck(mli, options);
    out.sub_model_input = mli;
else
    out.WH.input    = bmmo_reconstruct_2layer_s2f(mli, options);
    
    for ic = 1:2
        out.WH.model_fp(ic) = bmmo_reconstruct_2layer_s2f(options.WH.input_fp_per_chuck(ic), options);
        dummy_reduced = ovl_create_dummy(out.WH.model_fp(ic),'marklayout',options.reduced_reticle_layout,...
        'nwafer',out.WH.model_fp(ic).nwafer,'nlayer',out.WH.model_fp(ic).nlayer,'return_info',1);
        tmp_fp = bmmo_resample(out.WH.model_fp(ic), dummy_reduced, options.WH_resample_options);
        out.WH.model_fp(ic) = rmfield(tmp_fp, 'tlgname');
        out.WH.res_fp(ic) = sub_get_l1_input(options.WH.input_fp_per_chuck(ic), options);
        
    end
    out.sub_model_input = sub_get_l1_input(mli, options);
    out.interfield_residual = bmmo_average_chuck(out.sub_model_input, options);
end
out.intrafield_input = out.interfield_residual;


mlz = ovl_create_dummy(mli);
[~, zeropars]= bmmo_model_BAO(mlz, options);
emptyfield = ovl_average_fields(bmmo_average(mlz));

% Initialize chuck-dependent results
for chuck_id = 1:2
    
    out.SUSD.model_fp(chuck_id)          = ovl_get_wafers(mlz, 1);
    
    out.MI.Calib_MI(chuck_id).x_mirr     = struct('y',mxy,'dx',mz);
    out.MI.Calib_MI(chuck_id).y_mirr     = struct('x',mxy,'dy',mz);
    out.MI.Calib_MI_wsm(chuck_id).x_mirr = out.MI.Calib_MI(chuck_id).x_mirr;
    out.MI.Calib_MI_wsm(chuck_id).y_mirr = out.MI.Calib_MI(chuck_id).y_mirr;
    out.MI.res(chuck_id)                 = out.interfield_residual(chuck_id);
    
    out.KA.Calib_KA(chuck_id)            = ka_grid_exp;
    out.KA.Calib_KA_meas(chuck_id)       = ka_grid_meas;
    
    out.BAO.correction(chuck_id)         = struct('tx',0,'ty',0,'rs',0,'ra',0,'ms',0,'ma',0,'rws',0,'rwa',0,'mws',0,'mwa',0);
    out.BAO.before_KA(chuck_id)          = zeropars;
    out.BAO.before_MI(chuck_id)          = out.BAO.before_KA(chuck_id);
    out.BAO.BAO_in_MIKA(chuck_id)        = out.BAO.before_KA(chuck_id);
    
    fields = options.intraf_CETparfull.name;
    for idx = 1:length(fields)
        out.INTRAF.Calib_Kfactors(chuck_id).(fields{idx})=0;
    end  
    
    out.INTRAF.residual(chuck_id)        = emptyfield;
    out.INTRAF.Calib_intra(chuck_id)     = emptyfield;
end


% End of main function; sub-functions below
function mlo = sub_get_l1_input(mli, options)
% Extract the specified 89 fields from 167 field input

mlo = mli;

if mli.nfield >= max(options.edge_fields)
    mlo = ovl_get_fields(mli, [options.layer_fields{1}, options.edge_fields]);
end
