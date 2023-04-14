function [sbc, kpi, new_inputs] = bmmo_rerun(inputs, process_input, args)
% function [sbc, kpi] = bmmo_rerun(inputs, process_input, args)
%
% Rerun BMMO-NXE loop, processing the inputs as in the specified function. 
% By default, use bmmo_recorrect with 18par update of previous_correction
%
% Input:
%   inputs: 1xn vector of BMMO-NXE input structures (e.g. as returned by
%       bmmo_read_all_zips)
%
% Optional input: 
%   process_input: handle of function to process inputs, with the signature
%       function new_input = process_input(input, args)
%   args: structure of input arguments, containing at least the following fields:
%       previous_input: valid BMMO-NXE input structure
%       previous_output: valid BMMO-NXE output structure
%
% Output:
%   sbc: 1xn vector of SBC2 corrections
%   kpi: 1xn vector of model KPI
%   new_inputs: 1xn vector of inputs as modified by process_input fn
%
% 20180212 SBPR Creation

if nargin < 2
    [~, options] = bmmo_process_input(inputs(1)); 
    if options.intraf_actuation_order == 5
        process_input = @default_process_input_bl3;
    else
        process_input = @default_process_input; % definition below;
    end
    args.previous_input = inputs(1);
    temp_out.corr = inputs(1).info.previous_correction;
    args.previous_output = temp_out;
    args.iteration = 1;
end

num_iterations = length(inputs);
h = waitbar(0/num_iterations, 'Running BMMO simulation');

for k = 1:num_iterations

    % do some input processing
    new_inputs(k) = feval(process_input, inputs(k), args);
    % run the model
    bmmo_output = bmmo_nxe_drift_control_model(new_inputs(k));
    
    kpi(k) = bmmo_output.report.KPI;
    
    sbc(k) = rmfield(bmmo_output.corr, 'Configurations');
    
    args.previous_input = new_inputs(k);
    args.previous_output = bmmo_output;
    args.iteration = args.iteration + 1;
    
    waitbar(k/num_iterations, h);
end

function input_out = default_process_input(input_in, args)

input_out = bmmo_recorrect(input_in, args.previous_output.corr, @bmmo_update_corr_18par);

function input_out = default_process_input_bl3(input_in, args)

input_out = bmmo_recorrect(input_in, args.previous_output.corr, @bmmo_update_corr_33par);
