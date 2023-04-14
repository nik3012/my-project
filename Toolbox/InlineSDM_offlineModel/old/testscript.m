
zippath = '\\asml.com\eu\shared\nl011052\BMMO_NXE_TS\01-Functional\102-Study_items\InlineSDM2021\prep\BMMO_20200416_184727.zip';
[input_struct, ~, sbc, job_report] = bmmo_read_lcp_zip(zippath);
mld     = ovl_average_fields(ovl_create_dummy('13X19', 'nlayer', 1, 'nwafer', 2));
[mlo, options] = bmmo_process_input(input_struct);
 
prevcor_ml = bmmo_ffp_to_ml(options.previous_correction.ffp, mld);
ffp_ml     = bmmo_ffp_to_ml(sbc.ffp, mld);

SDMModel.filter      = 'spline';
SDMModel.actuation   = '3600D';
SDMModel.poly2spline = 0;
SDMModel.playback    = 0;

[~, extra_data, ~, ~, ~, ~]=...
    bmmo_model_inlineSDM_new(ovl_get_wafers(ffp_ml,1),ovl_get_wafers(ffp_ml,2), 'LFP', 0, SDMModel);
for ichk = 1:2
    sys_input(ichk) = extra_data.input.scan(ichk);
    cor_sdm(ichk)   = extra_data.corr.scan(ichk);
    res_sdm(ichk)   = ovl_sub(extra_data.input.scan(ichk), cor_sdm(ichk));
end
close all;
h1 = figure;
ovl_plot(sys_input(1), 'field', 'legend', 'cust', 'scale', 0, 'prc', 2, 'ytxf', 'ytyf', 'pcolor', 'all', 'title', 'syspart');
h2 = figure;
ovl_plot(cor_sdm(1), 'field', 'legend', 'cust', 'scale', 0, 'prc', 2, 'ytxf', 'ytyf', 'pcolor', 'all', 'title', 'cor 3600BL3');
h3 = figure;
ovl_plot(res_sdm(1), 'field', 'legend', 'cust', 'scale', 0, 'prc', 2, 'ytxf', 'ytyf', 'pcolor', 'all', 'title', 'res 3600BL3');

% now use the 33par limiter on 3600D
SDMModel.filter      = '33par';
[~, extra_data, ~, ~, ~, ~]=...
    bmmo_model_inlineSDM_new(ovl_get_wafers(ffp_ml,1),ovl_get_wafers(ffp_ml,2), 'LFP', 0, SDMModel);
for ichk = 1:2
    sys_input(ichk) = extra_data.input.scan(ichk);
    cor_sdm(ichk)   = extra_data.corr.scan(ichk);
    res_sdm(ichk)   = ovl_sub(extra_data.input.scan(ichk), cor_sdm(ichk));
end
h4 = figure;
ovl_plot(sys_input(1), 'field', 'legend', 'cust', 'scale', 0, 'prc', 2, 'ytxf', 'ytyf', 'pcolor', 'all', 'title', 'sys');
h5 = figure;
ovl_plot(cor_sdm(1), 'field', 'legend', 'cust', 'scale', 0, 'prc', 2, 'ytxf', 'ytyf', 'pcolor', 'all', 'title', 'cor 3600bmmo');
h6 = figure;
ovl_plot(res_sdm(1), 'field', 'legend', 'cust', 'scale', 0, 'prc', 2, 'ytxf', 'ytyf', 'pcolor', 'all', 'title', 'res 3600bmmo');

% pptFilename = 'myPPTfile.ppt';
% [~, pptHandle] = openppt(pptFilename, 'new', 'comp_secret');
% slidetitle    = sprintf('BL3 on 3600D200 vs BMMO 5th order on 3400');
% slidesubtitle = sprintf('BK85, system part only, chuck1');   
% [slidenr,~]   = newslide(slidetitle,slidesubtitle,'phandle',pptHandle);
% figppt(h1,[2,3,1],'phandle',pptHandle);
% figppt(h2,[2,3,2],'phandle',pptHandle);
% figppt(h3,[2,3,3],'phandle',pptHandle);
% %figppt(h4,[2,3,4],'phandle',pptHandle);
% figppt(h5,[2,3,5],'phandle',pptHandle);
% figppt(h6,[2,3,6],'phandle',pptHandle);