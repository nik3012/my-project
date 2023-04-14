function [sbc2, sbc2ref] = bmmo_kt_compare_LCP_sbc_with_injected(ADEL_monitor_sbc, ml_zero)
% function [sbc2, sbc2ref] = bmmo_kt_compare_LCP_sbc_with_injected(ADEL_monitor_sbc, ml_zero)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%
if nargin < 2
    % create a dummy layout with full coverage, for constructing fingerprints
    ml_zero = ovl_create_dummy('marklayout','BA-XY-DYNA-13X19','nwafer',6,'nlayer',1,'inner_rad',144);
end

%read in the xml SBC2 ADEL recipe 
disp('reading ADEL SBC2 from LCP');
sbc2 = bmmo_kt_process_SBC2(ADEL_monitor_sbc);

% read in the injected SBC2
disp('reading injected data');
sbc2ref = bmmo_kt_get_injected_corr;

%%Produce plotting required to compare the two SBC2 correction sets
disp('producing fingerprint plots');
%
bmmo_kt_compare_sbc_corrections(sbc2, sbc2ref, 'LCP generated SBC2', 'Injected SBC2', 1); 

bmmo_kt_compare_WH_total_fp(ml_zero,  sbc2ref, sbc2, 'Injected SBC2', 'LCP SBC2');

end