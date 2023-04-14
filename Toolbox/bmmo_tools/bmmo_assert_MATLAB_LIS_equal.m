function bmmo_assert_MATLAB_LIS_equal(input_zip, out_file, tol, show_NOKs)
% function bmmo_assert_MATLAB_LIS_equal(input_zip, out_file, tol, show_NOKs)
%
% Assert MATLAB and LIS SBCs, KPIS and WDMs as per the given spec 
%
% Inputs:
% input_zip : full path of BMMO input zip 
%
% Optional input:
% outfile: filename to output the assertion results,
% eg: 'output.txt' or provide outfile = stdout for printing to command line
% tol: tolerance for assertion of SBCs, default: 5e-13
% show_NOKs: List only NOKs from assertion if set to 1, default is 0
%


if nargin < 2
    sbc_output = stdout;
    kpi_output = stdout;
else
    if ischar(out_file)  
        sbc_output = ['MATLABvsLIS_SBC_', out_file];
        kpi_output = ['MATLABvsLIS_KPI_', out_file];
        wdm.output = ['MATLABvsLIS_WDM_', out_file];
    else
        sbc_output = out_file;
        kpi_output = out_file;
        wdm.output = out_file;
    end
end

if nargin < 3
    tol = 5e-13;
end

if nargin < 4
    show_NOKs = 0;
end

[input, ~, sbc_LIS, job_report, ~, wdm_LIS] = bmmo_read_lcp_zip(input_zip);

if isfield(input.info, 'configuration_data')
    disp(input.info.configuration_data);
end
% Run MATLAB model
fprintf(stdout, '\nRunning BMMO NXE drift control model...\n');
[out, wdm.MATLAB] = bmmo_nxe_drift_control_model(input);

% SBC assertion

ADEL_prec = 1; 
fprintf(stdout, 'Asserting MATLAB vs LIS SBC...\n');
bmmo_assert_SBC_equal(out.corr, sbc_LIS, sbc_output, ADEL_prec, tol, show_NOKs)

% KPI assertion
% get ADELsbrep file for the inline SDM kpis (MATLAB)

tmpdir = [tempname '_VCP_ZIP'];
mkdir(tmpdir);
cleanupTempDir = onCleanup(@()rmdir(tmpdir, 's'));
unzip7(input_zip, tmpdir);
lis =  bmmo_find_adels(tmpdir);
% add the applied inlineSDM kpis
if ischar(lis.adelsbcrep)
    if adelutils.is_encrypted(lis.adelsbcrep)
        disp('Decrypting ADELsbcOverlayDriftControlNxerepProtected');
        lis.adelsbcrep = bmmo_load_ADEL(lis.adelsbcrep);
    end
end
out1 = bmmo_parse_kpi_ADELsbcrep_inlineSDM(lis.adelsbcrep);
out.report.KPI.applied.InlineSDM = out1.applied.InlineSDM;

fprintf(stdout, 'Parsing LIS job report to same structure as BMMO MATLAB output...\n');
kpi_LIS = bmmo_parse_lcp_report(job_report);
fprintf(stdout, 'Asserting MATLAB vs LIS KPI...\n');
bmmo_assert_KPI_equal(out.report.KPI, kpi_LIS, kpi_output, tol, show_NOKs)
fprintf(stdout, '\nAssertion completed \n');

% WDM assertion

wdm.LIS = bmmo_convert_wdm_to_ml(wdm_LIS);
fprintf(stdout, 'Asserting MATLAB vs LIS WDM...\n');
bmmo_assert_equal_wdm_MATLAB_LIS(wdm);
fprintf(stdout, '\nAssertion completed \n');

end


