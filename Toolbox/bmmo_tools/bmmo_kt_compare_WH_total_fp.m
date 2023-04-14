function bmmo_kt_compare_WH_total_fp(ml_zero, sbc_in, sbc_ref, sbc1name, sbc2name, factor)
% function bmmo_kt_compare_WH_total_fp(ml_zero, sbc_in, sbc_ref)
%
% Create plots comparing fingerprints, adding to an existing presentation 
%
% Input: 
%   ml_zero: all-zero reference structure
%   sbc_in: SBC correction from LCP
%   sbc_ref: simulated SBC correction
%
% 20160503 SBPR Creation

if nargin < 4 || nargin < 5
    sbc1name = 'LCP';
    sbc2name = 'Simulated';
end

if nargin < 6
    factor = 1;
end

fp1 = bmmo_kt_apply_SBC(ml_zero, sbc_in);
fp2 = bmmo_kt_apply_SBC(ml_zero, sbc_ref, factor);


options.chuck_usage.chuck_id = [1 2 1 2 1 2];
options.chuck_usage.chuck_id = options.chuck_usage.chuck_id(1:ml_zero.nwafer);
options.chuck_usage.chuck_id_used = [1 2];

fn = fieldnames(fp1);

% Average per chuck
for ifield = 1:length(fn)
    fp1.(fn{ifield}) = bmmo_average_chuck(ovl_remove_edge(fp1.(fn{ifield})), options);
    fp2.(fn{ifield}) = bmmo_average_chuck(ovl_remove_edge(fp2.(fn{ifield})), options);

    name1 = [sbc1name ' ' fn{ifield} ' correction']; 
    name2 = [sbc2name ' ' fn{ifield} ' correction'];
    
    bmmo_kt_plot_6_fps(fp1.(fn{ifield}), fp2.(fn{ifield}), name1, name2, options);
end


