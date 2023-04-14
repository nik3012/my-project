function [wafer_sort_order, hash_list] = bmmo_map_wid_hash(mcl_rep, wid_hash)
% function wafer_sort_order = bmmo_map_wid_hash(mcl_rep, wid_hash)
%
% Map a cell array of WID hash values to the wafer exposure order given in
% the input ADELmultiCycleLotControlrep
%
% Input:
%   mcl_rep: full path of ADELmultiCycleLotControlrep
%   wid_hash: 1 * n cell array of wid hash values
%
% Output:
%   wafer_sort_order: 1 * n double vector giving sort order of wid hashes
%       in mcl report. 
%
% 20171031 SBPR Creation

try 
    mcl_rep_data = xml_load(mcl_rep);
catch
    error('Unable to load ADELmultiCycleLotControlrep file %s', mcl_rep);
end

exposure_sequence = arrayfun(@(x) str2double(x.elt.WaferSeqNr), mcl_rep_data.Results.WaferResultList);

hash_list = arrayfun(@(x) x.elt.EtchedWaferId.Hash.Readout, mcl_rep_data.Results.WaferResultList, 'UniformOutput', false);

hash_list = hash_list(exposure_sequence);

wafer_sort_order = zeros(size(wid_hash));

% for loop instead of vector because it is possible that not all exposed wafers are read out
for ii = 1:length(wid_hash)
    wafer_sort_order(ii) = find(strcmp(wid_hash{ii}, hash_list));
end

if any(wafer_sort_order == 0)
   warning('Not all readout wafers could be mapped: fallback to readout sort order');
   wafer_sort_order = 1:length(wid_hash);
end