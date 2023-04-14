function [fps, C] = bmmo_construct_FPS(mli, options, model)
% function [fps, C] = bmmo_construct_FPS(mli, options, model)
%
% This function generates the sub-model fingerprints as per the specified
% model configuration
%
% Input:
%  mli: Input tlg, contains WH fingerprints during exposure in mli.info
%  options: BMMO/BL3 option structure
%  model: Combined model type, 'OR', 'SUSD_1L', 'MI', 'MIKA', 'WH', WH_SUSD 
%
% Output:
%  fps: Generated fingerprints (cell array of ml structures)
%    fps{1} : WHFP on chuck(1)
%    fps{2} : WHFP on chuck(2)
%    Remaining are fingerprints specified in options.combined_model_contents
%  C: Constraint matrix
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

% get all-zero single layer ml struct as basis
ml = ovl_get_layers(ovl_get_wafers(mli(options.chuck_usage.chuck_id_used(1)),1),1);
ml_zero = ovl_create_dummy(ml);

% Loop over the combined model contents
fp_types_length = length(options.combined_model_contents.(model));
for ifp = 1:fp_types_length
    % get the function handle from the model name
    cm_fn = options.cm.(model).(options.combined_model_contents.(model){ifp}).fnhandle;
    fps_temp = feval(cm_fn, ml_zero, options);
    % execute the model
    fps_tempsz = size(fps_temp,1);
    fps(1).(options.combined_model_contents.(model){ifp})= sub_fps_to_mat(fps_temp(1,:));
    
    if fps_tempsz == 2
        fps(2).(options.combined_model_contents.(model){ifp})= sub_fps_to_mat(fps_temp(2,:));
    end
    
end

% Add constraints
C = [];
if isfield(options.cm.(model), 'constrained')
    cn = fieldnames(options.cm.(model).constrained);
    for i = 1:length(cn)
        con = options.cm.(model).constrained.(cn{i});
        C.(cn{i}) = [];
        for j = 1:length(con)
            to_constrain = fps.(cn{i});
            constraints = fps.(con{j});
            constr_mat = constraints' * to_constrain;
            constr_mat(isnan(constr_mat)) = 0;
            C.(cn{i}) = [C.(cn{i}); constr_mat];
        end
    end
end


function mat = sub_fps_to_mat(fps)

mat = [];
for i = 1:length(fps)
    col = [fps{i}.layer.wr.dx; fps{i}.layer.wr.dy];
    mat = [mat col];
end
