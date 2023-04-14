function sbc_configuration = bmmo_configuration_from_sbc(sbc)
% function sbc_configuration = bmmo_configuration_from_sbc(sbc)
%
% Given the SBC correcton, determines the Job configuration and outputs in
% the same format as in.info.configuration_data (BMMO/BL3 input). The
% function will only determine the configuration that can be found using the SBC
% structure in MATLAB.
%
% Input:
%   sbc: SBC correction
%
% Output:
%  sbc_configuration : Configuration determined using sbc
N_GRID_POINTS_BMMO = 3721;

if isfield(sbc, 'KA') && isfield(sbc.KA, 'grid_2de')
    
    if numel(sbc.KA.grid_2de(1).x) > N_GRID_POINTS_BMMO
        sbc_configuration.bl3_model = 1;
    else
        sbc_configuration.bl3_model = 0;
    end
    
    sbc_configuration.KA_correction_enabled = sub_determine_KA_configuration(sbc.KA.grid_2de);
    
    if  isfield(sbc.KA, 'grid_2dc')
        sbc_configuration.KA_measure_enabled = sub_determine_KA_configuration(sbc.KA.grid_2dc);
    end
    
else
    sbc_configuration.KA_correction_enabled = 0;
end

if isfield(sbc, 'SUSD') && isfield(sbc.SUSD, 'TranslationY')
    Ty_id =   cell2mat(arrayfun(@(x)(any(x.TranslationY)), sbc.SUSD, 'UniformOutput', false));
    
    if any(Ty_id)
        sbc_configuration.susd_correction_enabled = 1;
    else
        sbc_configuration.susd_correction_enabled = 0;
    end
else
    sbc_configuration.susd_correction_enabled = 0;
end
end


function KA_configuration = sub_determine_KA_configuration(grid)

if any(grid(1).dx) || any(grid(1).dy) || any(grid(2).dx) || any(grid(2).dy)
    KA_configuration = 1;
else
    KA_configuration = 0;
end

end