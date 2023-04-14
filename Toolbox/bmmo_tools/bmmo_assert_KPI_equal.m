function bmmo_assert_KPI_equal(kpi_struct1, kpi_struct2, out_file, tol, show_NOKs)
% function bmmo_assert_KPI_equal(kpi_struct1, kpi_struct2, out_file, tol, show_NOKs)
%
% Assert MATLAB and LIS job report KPIs as per the given spec (depending on
% decimals and units)
%
% Inputs:
% kpi_struct1: out.report.KPI (MATLAB output) or LIS/OTAS job report KPIs
% kpi_struct2: out.report.KPI (MATLAB output)or LIS/OTAS job report KPIs
%
% Optional input:
% outfile: filename to output the assertion results,
% eg: 'output.txt' or provide outfile = stdout for printing to command line
%
% tol: tolerance for assertion of KPIs(only KPIs with nm units),default: 5e-13
% show_NOKs: List only NOKs from assertion if set to 1, default is 0
%
%20201207 SBPR Creation
%20210107 ANBZ Updated for BL 3 KPIs and other missing KPIs

prev_state = warning('query', 'backtrace');
warning('backtrace', 'off');

%default title
title = 'kpi_struct 1 vs kpi_struct 2';

if nargin < 3
    outfile = stdout;
else
    if ischar(out_file)
        outfile = fopen(out_file, 'w');
        if contains(out_file, 'MATLABvsLIS')
            title = 'MATLAB vs LIS';
        end
    else
        outfile = out_file;
    end
end

if nargin < 4
    tol = 5e-13;
end


if nargin < 5
    show_NOKs = 0;
end

% determine configuration
conf =  sub_determine_config(kpi_struct1);
conf2 = sub_determine_config(kpi_struct2);
conf.KA_correction_enabled    = conf.KA_correction_enabled   && conf2.KA_correction_enabled;
conf.susd_correction_enabled  = conf.susd_correction_enabled && conf2.susd_correction_enabled;
conf.ERO_present              = conf.ERO_present && conf2.ERO_present;

fprintf(outfile,['KPIs: ', title,'\n\n']);

% Input Data KPIs
try
    sub_assert_input_KPI(kpi_struct1.input, kpi_struct2.input, outfile, conf,  tol, show_NOKs);
catch
    sub_warning('Error in assertion of Input KPIs, skipping to next assertion', outfile);
end

% Uncontrolled KPIs
try
    sub_assert_uncontrolled_KPI(kpi_struct1.uncontrolled, kpi_struct2.uncontrolled, outfile, conf, tol, show_NOKs)
catch
    sub_warning('Error in assertion of Uncontrolled input KPIs, skipping to next assertion', outfile);
end


% Applied correction PIs
try
    sub_assert_applied_corr_KPI(kpi_struct1.applied, kpi_struct2.applied, outfile, tol, show_NOKs)
catch
    sub_warning('Error in assertion of Applied correction KPIs, skipping to next assertion', outfile);
end


% Correction & Delta monitoring KPIs
try
    sub_assert_correction_KPI(kpi_struct1.correction, kpi_struct2.correction, outfile, conf, tol, show_NOKs)
catch
    sub_warning('Error in assertion of Correction Magnitude & Monitoring KPIs, skipping to next assertion', outfile);
end


try
    sub_assert_residue_KPI(kpi_struct1, kpi_struct2, outfile, conf, tol, show_NOKs)
catch
    sub_warning('Error in assertion of Correction Quality KPIs', outfile);
end

fclose('all');
warning(prev_state);

end



%SUB FUNCTIONS
function conf = sub_determine_config(kpi_struct)

if isfield(kpi_struct.correction.delta_unfiltered, 'grid')
    conf.KA_correction_enabled = 1;
else
    conf.KA_correction_enabled = 0;
end

if isfield(kpi_struct.correction.delta_unfiltered, 'susd')
    conf.susd_correction_enabled = 1;
else
    conf.susd_correction_enabled = 0;
end

if isfield(kpi_struct, 'Intra_33par_NCE')
    conf.intraf_actuation_order  = 5;
    conf.intraf_fieldname = 'intra_33_par';
conf.intraf_nce_fieldname = 'Intra_33par_NCE';
else
    conf.intraf_actuation_order  = 3;
    conf.intraf_fieldname = 'intra_18_par';
conf.intraf_nce_fieldname = 'Intra_18par_NCE';
end

if isfield(kpi_struct.input, 'input_clamp')
    conf.ERO_present = 1;
else 
    conf.ERO_present = 0;
end
end


function sub_warning(message, outfile)

if outfile == 1 %stdout case
    warning(message)
else % filename char case
    warning(message)
    fprintf(outfile, ['WARNING:', message,'\n']);
end
end


function sub_assertion(MATLAB, LIS, outfile, delta, show_NOKs)

try
    bmmo_assert_equal(MATLAB, LIS, delta, outfile, show_NOKs);
catch ME
    if strcmp(ME.identifier,'MATLAB:assertion:failed')
        sub_warning( 'Assertion Failed! Check the NOKs.', outfile);
    else
        rethrow(ME)
    end
end

end


function sub_assert_input_KPI(kpi_model, kpi_LIS, outfile, conf, tol, show_NOKs)

if conf.ERO_present
    f = {'overlay', 'input_clamp' 'outlier_coverage', 'valid', 'w2w'}; %Input fields
else
    f = {'overlay','outlier_coverage', 'valid', 'w2w'}; %Input fields
end

fprintf(outfile, ' \n');
fprintf(outfile, '\n');
fprintf(outfile, 'Input Data\n');

for i= 1:length(f)
    
    if strcmp(f{i}, 'outlier_coverage')
        fprintf(outfile, '\n');
        fprintf(outfile, [f{i},' (Delta expected to be less than : 5e-3)\n']);
        sub_assertion(kpi_model.(f{i}), kpi_LIS.(f{i}), outfile, 5e-3, show_NOKs)
        
    elseif strcmp(f{i}, 'valids')
        fprintf(outfile, '\n');
        fprintf(outfile, [f{i},' (Delta expected to be 0)\n']);
        sub_assertion(kpi_model.(f{i}), kpi_LIS.(f{i}), outfile, 5e-24, show_NOKs)
        
    else
        fprintf(outfile, '\n');
        fprintf(outfile, [f{i},' (Delta expected to be less than : ' ,num2str(tol), ')\n']);
        sub_assertion(kpi_model.(f{i}), kpi_LIS.(f{i}), outfile, tol, show_NOKs)
    end
end

end


function sub_assert_uncontrolled_KPI(kpi_model, kpi_LIS, outfile, conf, tol, show_NOKs)

if conf.ERO_present
    f = {'overlay', 'input_clamp', 'intrafield'};
else
    f = {'overlay', 'intrafield'};
end

fprintf(outfile, ' \n\n\n');
fprintf(outfile, 'Uncontrolled\n');

for i = 1:length(f)
    
    if strcmp(f{i}, 'intrafield')
        [kpi1_model, kpi1_LIS, kpi2_model, kpi2_LIS, kpi3_model, kpi3_LIS]...
            = sub_select_Kfac(kpi_model.(f{i}), kpi_LIS.(f{i}));
        fprintf(outfile, '\n');
        
        fprintf(outfile, ['Intrafield Metrics',' (Delta expected to be less than : ' ,num2str(tol), ')\n']);
        sub_assertion(kpi3_model, kpi3_LIS, outfile, tol, show_NOKs);
        
        fprintf(outfile, ' \n');
        fprintf(outfile, ['K factors (k7 to k12)',' (Delta expected to be less than : 5e-9)\n']);
        sub_assertion(kpi1_model, kpi1_LIS, outfile, 5e-9, show_NOKs)
        
        fprintf(outfile, ' \n');
        fprintf(outfile, ['K factors (k13 to k20)',' (Delta expected to be less than : 5e-7)\n']);
        sub_assertion(kpi2_model, kpi2_LIS, outfile, 5e-7, show_NOKs)
        
        if conf.intraf_actuation_order == 5  %5th order actuation
            [kpi1_model, kpi1_LIS, kpi2_model, kpi2_LIS, kpi3_model, kpi3_LIS]...
                = sub_select_Kfac2(kpi_model.(f{i}), kpi_LIS.(f{i}));
            fprintf(outfile, ' \n');
            
            fprintf(outfile, [ 'K factors (k22, k24, k25, k26, k27, k29)',...
                ' (Delta expected to be less than : 5e-5)\n']);
            sub_assertion(kpi1_model, kpi1_LIS, outfile, 5e-5, show_NOKs)
            
            fprintf(outfile, ' \n');
            fprintf(outfile,[ 'K factors (k32, k34, k36, k37, k39, k41)',...
                ' (Delta expected to be less than : 5e-3)\n']);
            sub_assertion(kpi2_model, kpi2_LIS, outfile, 5e-3, show_NOKs)
            
            fprintf(outfile, ' \n');
            fprintf(outfile,[  'K factors (k46, k48, k51)',...
                ' (Delta expected to be less than : 5e-1)\n']);
            sub_assertion(kpi3_model, kpi3_LIS, outfile, 5e-1, show_NOKs)
        end
    else
        fprintf(outfile, ' \n');
        fprintf(outfile, [f{i},' (Delta expected to be less than : ' ,num2str(tol), ')\n']);
        sub_assertion(kpi_model.(f{i}), kpi_LIS.(f{i}), outfile, tol, show_NOKs) 
    end
end

end


function sub_assert_applied_corr_KPI(kpi_model, kpi_LIS, outfile, tol, show_NOKs)

f = 'waferheating';
fprintf(outfile, ' \n\n\n');
fprintf(outfile,'Applied correction\n');

fprintf(outfile, [f,' (Delta expected to be less than : ' ,num2str(tol), ')\n']);
sub_assertion(kpi_model.(f), kpi_LIS.(f), outfile, tol, show_NOKs)

if isfield(kpi_model, 'InlineSDM')
    fprintf(outfile, ' \n');
    fprintf(outfile, ['InlineSDM',' (Delta expected to be 0)\n']);
    sub_assertion(kpi_model.InlineSDM, kpi_LIS.InlineSDM, outfile, 5e-24, show_NOKs)
    
else
    sub_warning('No Inline SDM KPIs found in MATLAB KPI struct, use sbcrep to include them', outfile)
end

end


function sub_assert_correction_KPI(kpi_model, kpi_LIS, outfile, conf, tol, show_NOKs)

corr_fields = {'delta_filtered', 'total_filtered','delta_unfiltered', 'total_unfiltered'};
fc          = {'waferheating','mirror','bao','intra_raw',conf.intraf_fieldname,'k_factors','total'};%correction fields

% switch based on SUSD and KA
if conf.susd_correction_enabled
    fc          = {'waferheating','susd','mirror','bao','intra_raw',conf.intraf_fieldname,'k_factors','total'};%correction fields
    
    if conf.KA_correction_enabled
        fc      = {'waferheating','susd','mirror','grid','bao','intra_raw',conf.intraf_fieldname,'k_factors','total'};%correction fields
    end
end

if conf.KA_correction_enabled
    fc          = {'waferheating','mirror','grid','bao','intra_raw',conf.intraf_fieldname,'k_factors','total'};%correction fields
    
    if conf.susd_correction_enabled
        fc      = {'waferheating','susd','mirror','grid','bao','intra_raw',conf.intraf_fieldname,'k_factors','total'};%correction fields
    end
end

fprintf(outfile, '\n\n\n');
fprintf(outfile, 'Correction Magnitude\n');


for ifield=1:length(corr_fields)
    
    for ii =  1:length(fc)
        
        if strcmp(fc{ii},'waferheating')
            fprintf(outfile, '\n');
            fprintf(outfile, [corr_fields{ifield}, '\n' , fc{ii},...
                ' (Delta expected to be less than : 5e-4)\n']);
            sub_assertion(kpi_model.(corr_fields{ifield}).(fc{ii}),...
                kpi_LIS.(corr_fields{ifield}).(fc{ii}), outfile, 5e-4, show_NOKs)
            
        elseif strcmp(fc{ii},'bao')
            
            [kpi1_model, kpi1_LIS, kpi2_model, kpi2_LIS] = ...
                sub_select_BAO(kpi_model.(corr_fields{ifield}).(fc{ii}),kpi_LIS.(corr_fields{ifield}).(fc{ii}));
            fprintf(outfile, '\n');
            
            fprintf(outfile, [corr_fields{ifield}, '\n' ,...
                'BAO metrics and Translation',' (Delta expected to be less than : ' ,num2str(tol), ')\n']);
            sub_assertion(kpi1_model, kpi1_LIS, outfile, tol, show_NOKs);
            
            fprintf(outfile, '\n');
            fprintf(outfile, [corr_fields{ifield}, '\n' ,...
                'BAO Parameters except Translation',' (Delta expected to be less than : 5e-10)\n']);
            sub_assertion(kpi2_model, kpi2_LIS, outfile, 5e-10, show_NOKs);
            
        elseif strcmp(fc{ii},conf.intraf_fieldname)
            if isfield(kpi_model.(corr_fields{ifield}),conf.intraf_fieldname)...
                    && isfield(kpi_LIS.(corr_fields{ifield}),conf.intraf_fieldname)
                fprintf(outfile, '\n');
                fprintf(outfile, [corr_fields{ifield}, '\n' , fc{ii},...
                    ' (Delta expected to be less than : ' ,num2str(tol), ')\n']);
                sub_assertion(kpi_model.(corr_fields{ifield}).(fc{ii}),...
                    kpi_LIS.(corr_fields{ifield}).(fc{ii}), outfile, tol, show_NOKs)
            else
                sub_warning('18par/33par correction metrics missing from kpi_struct1', outfile)
            end
            
            
        elseif strcmp(fc{ii}, 'k_factors')
            [kpi1_model, kpi1_LIS,kpi2_model, kpi2_LIS, kpi3_model, kpi3_LIS] =...
                sub_select_Kfac(kpi_model.(corr_fields{ifield}).(fc{ii}),kpi_LIS.(corr_fields{ifield}).(fc{ii}));
            fprintf(outfile, '\n');
            
            fprintf(outfile, [corr_fields{ifield}, '\n' , 'K factor Metrics',...
                ' (Delta expected to be less than : ' ,num2str(tol), ')\n']);
            sub_assertion(kpi3_model, kpi3_LIS, outfile, tol, show_NOKs)
            
            fprintf(outfile, '\n');
            fprintf(outfile, [corr_fields{ifield}, '\n' , 'K factors (k7 to k12)',...
                ' (Delta expected to be less than : 5e-9)\n']);
            sub_assertion(kpi1_model, kpi1_LIS, outfile, 5e-9, show_NOKs);
            
            fprintf(outfile, '\n');
            fprintf(outfile, [corr_fields{ifield}, '\n' , 'K factors (k13 to k20)',...
                ' (Delta expected to be less than : 5e-7)\n']);
            sub_assertion(kpi2_model, kpi2_LIS, outfile, 5e-7, show_NOKs);
            
            if conf.intraf_actuation_order == 5  %5th order acutation
                [kpi1_model, kpi1_LIS, kpi2_model, kpi2_LIS, kpi3_model, kpi3_LIS] =...
                    sub_select_Kfac2(kpi_model.(corr_fields{ifield}).(fc{ii}),kpi_LIS.(corr_fields{ifield}).(fc{ii}));
                fprintf(outfile, '\n');
                fprintf(outfile,[corr_fields{ifield}, ' ' ,...
                    'K factors (k22, k24, k25, k26, k27, k29)',...
                    ' (Delta expected to be less than : 5e-5)\n']);
                sub_assertion(kpi1_model, kpi1_LIS, outfile, 5e-5, show_NOKs)
                
                fprintf(outfile, '\n');
                fprintf(outfile,[corr_fields{ifield}, ' ' ,...
                    'K factors (k32, k34, k36, k37, k39, k41)',...
                    ' (Delta expected to be less than : 5e-3)\n']);
                sub_assertion(kpi2_model, kpi2_LIS, outfile, 5e-3, show_NOKs)
                
                fprintf(outfile, '\n');
                fprintf(outfile,[corr_fields{ifield}, ' ' ,...
                    'K factors (k46, k48, k51)',' (Delta expected to be less than : 5e-1)\n']);
                sub_assertion(kpi3_model, kpi3_LIS, outfile, 5e-1, show_NOKs)
            end
            
        else
            fprintf(outfile, '\n');
            fprintf(outfile, [corr_fields{ifield}, '\n' , fc{ii},...
                ' (Delta expected to be less than : ' ,num2str(tol), ')\n']);
            sub_assertion(kpi_model.(corr_fields{ifield}).(fc{ii}),...
                kpi_LIS.(corr_fields{ifield}).(fc{ii}), outfile, tol, show_NOKs)
        end
    end
    
    if  conf.ERO_present && strcmp(corr_fields{ifield}, 'total_filtered')
        fprintf(outfile, '\n');
        fprintf(outfile, [corr_fields{ifield}, '\n' , 'Modelled clamp',...
            ' (Delta expected to be less than : ' ,num2str(tol), ')\n']);
        sub_assertion(kpi_model.(corr_fields{ifield}).clamp,...
            kpi_LIS.(corr_fields{ifield}).clamp, outfile, tol, show_NOKs)
    end
end

% Delta monitoring general KPIs
fprintf(outfile, '\n\n\n');
fprintf(outfile, 'Delta Monitoring General\n');


[kpi1_model, kpi1_LIS, kpi2_model, kpi2_LIS, ~, ~] = sub_select_Kfac(kpi_model.monitor.intra_delta, kpi_LIS.monitor.intra_delta);
fprintf(outfile, '\n');

fprintf(outfile, [corr_fields{ifield}, '\n' , 'SUSD Translation Y',' (Delta expected to be less than : ' ,num2str(tol), ')\n']);
sub_assertion(kpi_model.monitor.susd, kpi_LIS.monitor.susd, outfile, tol, show_NOKs)

fprintf(outfile, '\n');
fprintf(outfile, [corr_fields{ifield}, '\n' , 'K factors (k7 to k12)',' (Delta expected to be less than : 5e-9)\n']);
sub_assertion(kpi1_model, kpi1_LIS, outfile, 5e-9, show_NOKs)

fprintf(outfile, '\n');
fprintf(outfile, [corr_fields{ifield}, '\n' , 'K factors (k13 to k20)',' (Delta expected to be less than : 5e-7)\n']);
sub_assertion(kpi2_model, kpi2_LIS, outfile, 5e-7, show_NOKs)

if conf.intraf_actuation_order == 5  %5th order acutation
    [kpi1_model, kpi1_LIS,kpi2_model, kpi2_LIS, kpi3_model, kpi3_LIS] = sub_select_Kfac2(kpi_model.monitor.intra_delta, kpi_LIS.monitor.intra_delta);
    fprintf(outfile, '\n');
    fprintf(outfile,[corr_fields{ifield}, ' ' , 'K factors (k22, k24, k25, k26, k27, k29)',' (Delta expected to be less than : 5e-5)\n']);
    sub_assertion(kpi1_model, kpi1_LIS, outfile, 5e-5, show_NOKs)
    
    fprintf(outfile, '\n');
    fprintf(outfile,[corr_fields{ifield}, ' ' , 'K factors (k32, k34, k36, k37, k39, k41)',' (Delta expected to be less than : 5e-3)\n']);
    sub_assertion(kpi2_model, kpi2_LIS, outfile, 5e-3, show_NOKs)
    
    fprintf(outfile, '\n');
    fprintf(outfile,[corr_fields{ifield}, ' ' , 'K factors (k46, k48, k51)',' (Delta expected to be less than : 5e-1)\n']);
    sub_assertion(kpi3_model, kpi3_LIS, outfile, 5e-1, show_NOKs)
end

end


function sub_assert_residue_KPI(kpi_struct1, kpi_struct2, outfile, conf, tol, show_NOKs)

 % Correction Quality KPIs
kpi_LIS = kpi_struct2.residue;
kpi_model = kpi_struct1.residue;
f ={'overlay','interfield','intrafield'}; %residue fields
fprintf(outfile, '\n\n\n');
fprintf(outfile, 'Correction Quality\n');
for ifield=1:length(f)
    fprintf(outfile, '\n');
    fprintf(outfile, [f{ifield},' (Delta expected to be less than : ' ,num2str(tol), ')\n']);
    sub_assertion(kpi_model.(f{ifield}), kpi_LIS.(f{ifield}), outfile, tol, show_NOKs);
end

% Intraf 18par/33par NCE KPIs
kpi_LIS = kpi_struct2.(conf.intraf_nce_fieldname);
kpi_model = kpi_struct1.(conf.intraf_nce_fieldname);
f = fieldnames(kpi_LIS);
fprintf(outfile, '\n');
fprintf(outfile, [conf.intraf_nce_fieldname,'\n']);
for ifield=1:length(f)
    fprintf(outfile, '\n');
    fprintf(outfile, [f{ifield},' (Delta expected to be less than : ' ,num2str(tol), ')\n']);
    sub_assertion(kpi_model.(f{ifield}), kpi_LIS.(f{ifield}), outfile, tol, show_NOKs);
end

end


function [kpi1_model, kpi1_LIS, kpi2_model, kpi2_LIS] = sub_select_BAO(kpi_model, kpi_LIS)

Bao_find ={'3std','997','m3s','max','translation'};

fd =fieldnames(kpi_model);
a = contains(fd, Bao_find);
new_fd =fd(a);

for ifield=1:length(new_fd)
    kpi1_model.(new_fd{ifield}) = kpi_model.(new_fd{ifield});
    kpi1_LIS.(new_fd{ifield}) = kpi_LIS.(new_fd{ifield});
end

kpi2_model      = rmfield(kpi_model,new_fd);
kpi2_LIS        = rmfield(kpi_LIS,new_fd);
end


function  [kpi1_model, kpi1_LIS, kpi2_model, kpi2_LIS, kpi3_model, kpi3_LIS] = sub_select_Kfac(kpi_model, kpi_LIS)

K_factors_find1 ={ 'k7','k8','k9','k10','k11','k12'};
K_factors_find2 ={ 'k13','k14','k15','k16','k17','k18','k19','k20'};

fd =fieldnames(kpi_model);
a = contains(fd,  K_factors_find1);
b = contains(fd,  K_factors_find2);
c = contains(fd, 'ovl_k');
new_fd1 = fd(a);
new_fd2 = fd(b);
new_fd3 = fd(c);

for i=1:length(new_fd1)
    kpi1_model.(new_fd1{i}) = kpi_model.(new_fd1{i});
    kpi1_LIS.(new_fd1{i}) = kpi_LIS.(new_fd1{i});
end

for i=1:length(new_fd2)
    kpi2_model.(new_fd2{i}) = kpi_model.(new_fd2{i});
    kpi2_LIS.(new_fd2{i}) = kpi_LIS.(new_fd2{i});
end

kpi3_model =  rmfield(kpi_model,new_fd3);
kpi3_LIS   =  rmfield(kpi_LIS,new_fd3);
end


function  [kpi1_model, kpi1_LIS, kpi2_model, kpi2_LIS, kpi3_model, kpi3_LIS] = sub_select_Kfac2(kpi_model, kpi_LIS)

K_factors_find1 ={ 'k22','k24','k25','k26','k27','k29'};
K_factors_find2 ={ 'k32','k34','k36','k37','k39','k41'};
K_factors_find3 ={ 'k46','k48','k51'};

fd =fieldnames(kpi_model);
a = contains(fd,  K_factors_find1);
b = contains(fd,  K_factors_find2);
c = contains(fd,  K_factors_find3);
new_fd1 = fd(a);
new_fd2 = fd(b);
new_fd3 = fd(c);

for i=1:length(new_fd1)
    kpi1_model.(new_fd1{i}) = kpi_model.(new_fd1{i});
    kpi1_LIS.(new_fd1{i}) = kpi_LIS.(new_fd1{i});
end

for i=1:length(new_fd2)
    kpi2_model.(new_fd2{i}) = kpi_model.(new_fd2{i});
    kpi2_LIS.(new_fd2{i}) = kpi_LIS.(new_fd2{i});
end

for i=1:length(new_fd3)
    kpi3_model.(new_fd3{i}) = kpi_model.(new_fd3{i});
    kpi3_LIS.(new_fd3{i}) = kpi_LIS.(new_fd3{i});
end

end

