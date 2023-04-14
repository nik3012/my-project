function [fps_filtered, sbc_filtered, kpi] = bmmo_sim_1wpc_loop(input_structs)
% function [fps_filtered, sbc_filtered, kpi] = bmmo_sim_1wpc_loop(input_structs)
%
% Get SBC and KPI data for a sequence of BMMO-NXE input structures, 
% splitting each input into 1 wafer per chuck components,with
% time filtering enabled. 
%
% Input
%   input_structs: 1xn array of BMMO-NXE input structures
%
%
% Output:
%   fps_filtered: 1x(3n+1) array of SBC2 fingerprint structures for each
%       iteration of the loop (including the previous SBC2 as element 1)
%   sbc: 1x(3n+1) array of SBC2 corrections, including the previous
%       correction from iteration 1 as element 1
%   kpi: 1x3n array of output KPI structures
%   
% 20171006 SBPR Creation
input_split = bmmo_split_input(input_structs);
[fps_filtered, sbc_filtered, kpi] = bmmo_get_loop_kpi(input_split);


