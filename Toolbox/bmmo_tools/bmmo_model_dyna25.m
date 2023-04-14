
function output_struct = bmmo_model_dyna25(input_struct)
% function output_struct = bmmo_model_dyna25(input_struct)
%
% Run the BMMO-NXE drift control model with Dyna-25 instead of 7x7 sampling for sparse
% fields in layer 1
%
% Input: input_struct: valid BMMO-NXE model input
% 
% Output: output_struct: valid BMMO-NXE model output
%
% 20170720 SBPR Creation

[mlp, options] = bmmo_process_input(input_struct);


mlp_d25 = bmmo_get_dyna25_layout(mlp, options);
model_results = bmmo_run_submodels(mlp_d25, options);

output_struct = bmmo_process_output(input_struct, model_results, options);





