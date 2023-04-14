function [fps_filtered, sbc_filtered, kpi] = bmmo_get_loop_kpi(input_structs, first_corr)
% function [fps_filtered, sbc_filtered, kpi] = bmmo_get_loop_kpi(input_structs, first_corr)
%
% Get SBC and KPI data for a sequence of BMMO-NXE input structures, with
% time filtering enabled. 
%
% Input
%   input_structs: 1xn array of BMMO-NXE input structures
%
% Optional Input
%   first_corr: previous SBC2 correction for the first iteration in the loop (default:
%       neutral SBC2)
%
% Output:
%   fps_filtered: 1x(n+1) array of SBC2 fingerprint structures for each
%       iteration of the loop (including the previous SBC2 as element 1)
%   sbc: 1x(n+1) array of SBC2 corrections, including the previous
%       correction from iteration 1 as element 1
%   kpi: 1xn array of output KPI structures
%   
% 20171006 SBPR Creation

if nargin < 2
    % create neutral SBC correction
    zero_out = bmmo_default_output_structure(bmmo_default_options_structure);
    first_corr = zero_out.corr;
end
sbc_filtered(1) = first_corr;

h = waitbar(0/length(input_structs), 'Simulating BMMO-NXE control loop');

for ii = 1:length(input_structs)   
    [fps_filtered(ii), tmp_sbc, kpi(ii)] = bmmo_get_filtered_sbc(input_structs(ii), sbc_filtered(ii), 1);      
    sbc_filtered(ii+1) = bmmo_update_corr_inlinesdm(tmp_sbc);
    waitbar(ii/length(input_structs), h);
end


fps_filtered(end+1) = bmmo_apply_SBC(input_structs(end), sbc_filtered(end)); 
