function  [par_mc, extra_data, par, KPI, RES, COR] = bmmo_model_inlineSDM(ml_field_chk1, ml_field_chk2, varargin)
%% Output
%     par_mc.scan
%     par_mc.lens
%     extra_data.corr.lens 
%     extra_data.corr.scan 
%     extra_data.corr.lens_static
%     extra_data.input.lens
%     extra_data.input.scan
%     KPI (1~8) as defined on page 23 in D000347979
%     RES (1~3) as defined on page 23 in D000347979

%% Input 
%     ml struct - BMMO input (13x19) averaged fields after removing KA, MI, ..., 10 par BAO 
%     Note : zernikes in [nm], adjustables in [um]

%% Handle options
optionsDef.HOC           = 1;
optionsDef.lens_type     = '3400';
optionsDef.interpolation = 'polyfit4';
optionsDef.LFP           = 1;
optionsDef.CET_model     = '';
optionsDef.filterCoeff   = 1; 
[options, arguments] = ovl_parse_options(optionsDef, varargin{:}); % do NOT remove {:} because this is needed for Matlab varargin syntax

% load data using LMtwin toolbox
if ~exist('lm_calc_aberrations','file')
    if ispc
    error('OVL:ovl_model_sdm:lm_twin_not_found',['Cannot find projection toolbox; please add the projection module:\n' ...
        'use module.include(''\\\\asml.com\\eu\\shared\\nl011032\\Projection_tooling\\projection_toolbox_p'')\n' ...
        '(if you don''t have access to this share, please request access using\n' ...
        'https://calltemplates.asml.com/cgi-bin/calltemplates.cgi?form_id=50302)']);
    else
    error('OVL:ovl_model_sdm:lm_twin_not_found',['Cannot find projection toolbox; please add the projection module:\n' ...
        'use module.include(''/shared/nl011032/Projection_tooling/projection_toolbox_p'')\n' ...
        '(if you don''t have access to this share, please request access using\n' ...
        'https://calltemplates.asml.com/cgi-bin/calltemplates.cgi?form_id=50302)']);
    end
end

%% load definition : Machine type
lensdata = ovl_metro_parse_lens_data(ml_field_chk2, 'lens_type', options.lens_type);

%% LFP
szd_LFP = zeros(5,13,64); 
mli = ml_field_chk1;
if options.LFP
    if isstruct(mli.info.F.LFP_data)
    % load LFP and do the decryption, if needed
    creation_time=mli.info.F.date;
    where_us=findstr(creation_time,'us');
    where_space=findstr(creation_time(1:where_us),' ');
    creation_time=str2num(creation_time(where_space(end)+1:where_us-1));
    for jj=1:5
        for ii=1:13
            for hh=1:63 
                dummylfp = mli.info.F.LFP_data.y(jj).zd(ii,hh+1);
                if abs(dummylfp) < 0.000001
                    szd_LFP(jj,ii,hh)=1e9*dummylfp; % load only
                else                    
                    szd_LFP(jj,ii,hh)=1e9/(dummylfp * (creation_time + (jj - 1) * 13 + ii + hh - 3));  % load and decrpt
                end
            end
        end
    end
    else 
        szd_LFP(:,:,1:62) = mli.info.F.LFP_data(:,:,2:63)*1e9;
    end
end
%% Initialize outputs
ml_res           = [];
par_mc           = [];
extra_data       = [];

ml_field_avg = ovl_combine_linear(ml_field_chk1,0.5, ml_field_chk2, 0.5);
%% Scan integrate (13x1) : (dx,dy)
% Note that ovl_scan_intagrate+ovl_average_columns=ovl_average_columns
% ovl_scan_integrate (13x7/19) = ovl_average_columns (13x1) x 7/19 copies in y
ml_dynrep_input_dlm = ovl_scan_integrate(ml_field_avg);  %(13x7/19)
ml_dyn_input_dlm = ovl_average_columns(ml_field_avg);  % (13x1)

%% Pre-processing for HOC Model 
tmp = ovl_scan_integrate(ml_field_avg);     % (13x19) : constant interpolation of 13x1 ; copies of ml_dyn_input_dlm in y direction
ml_input_HOC(1) = ovl_sub(ml_field_chk1, tmp );      % subtract lens correctables (13x19)
ml_input_HOC(2) = ovl_sub(ml_field_chk2, tmp );   

%% HOC Model
for ichk = 1:2
    [ml_HOC_res(ichk), ml_field_HOC_corr(ichk), intra_par_HOC(ichk), HOCrespart_z2z3(ichk)] = HOCModel(ml_input_HOC(ichk), lensdata, options.CET_model);
 end

%% Lens Corrections
% No residual of HOC goes to the DLM
par_lens(1:13) = zeros(size(lensdata));
par_lens(13+1:13*2) = zeros(size(lensdata));
par_lens(27) = options.filterCoeff;
[Static_corr_Z, ml_field_lens_corr, adj_pob, par] = LensCorrections(ml_dynrep_input_dlm, lensdata, szd_LFP, par_lens);


%% Fill other outputs
extra_data.corr.lens = ml_field_lens_corr;
extra_data.corr.lens_static = Static_corr_Z;
extra_data.input.lens= ml_dynrep_input_dlm;  %dx, dy in [m]
extra_data.res.lens = ovl_sub(extra_data.input.lens, extra_data.corr.lens);
for ichk = 1:2
    extra_data.corr.scan(ichk) = ml_field_HOC_corr(ichk);
    extra_data.input.scan(ichk) = ml_input_HOC(ichk);
end
extra_data.input.chk(1)=ml_field_chk1;
extra_data.input.chk(2)=ml_field_chk2;
extra_data.input.avg = ml_field_avg;
%% Setting par_mc :  adj in [um and urad]

par_mc.scan = intra_par_HOC;
par_mc.lens.Ob_z                                = adj_pob( find( strcmp( cellstr( lensdata.Generic.Manipulator.Name), 'Reticle.Z')));
par_mc.lens.Ob_Rx                               = adj_pob( find( strcmp( cellstr( lensdata.Generic.Manipulator.Name), 'Reticle.Rx')));
par_mc.lens.Ob_Ry                               = adj_pob( find( strcmp( cellstr( lensdata.Generic.Manipulator.Name), 'Reticle.Ry')));
for mirror_idx = [1 2 3 4 6]; 
   par_mc.lens.(sprintf('Mi%d_x',  mirror_idx)) = adj_pob( find( strcmp( cellstr( lensdata.Generic.Manipulator.Name), sprintf('Mirror%d.X',  mirror_idx))));
   par_mc.lens.(sprintf('Mi%d_y',  mirror_idx)) = adj_pob( find( strcmp( cellstr( lensdata.Generic.Manipulator.Name), sprintf('Mirror%d.Y',  mirror_idx))));
   par_mc.lens.(sprintf('Mi%d_z',  mirror_idx)) = adj_pob( find( strcmp( cellstr( lensdata.Generic.Manipulator.Name), sprintf('Mirror%d.Z',  mirror_idx))));
   par_mc.lens.(sprintf('Mi%d_Rx', mirror_idx)) = adj_pob( find( strcmp( cellstr( lensdata.Generic.Manipulator.Name), sprintf('Mirror%d.Rx', mirror_idx))));
   par_mc.lens.(sprintf('Mi%d_Ry', mirror_idx)) = adj_pob( find( strcmp( cellstr( lensdata.Generic.Manipulator.Name), sprintf('Mirror%d.Ry', mirror_idx))));
   par_mc.lens.(sprintf('Mi%d_Rz', mirror_idx)) = adj_pob( find( strcmp( cellstr( lensdata.Generic.Manipulator.Name), sprintf('Mirror%d.Rz', mirror_idx))));
end 
par_mc.lens.Im_x                                = adj_pob( find( strcmp( cellstr( lensdata.Generic.Manipulator.Name), 'Wafer.X')));
par_mc.lens.Im_y                                = adj_pob( find( strcmp( cellstr( lensdata.Generic.Manipulator.Name), 'Wafer.Y')));
par_mc.lens.Im_z                                = adj_pob( find( strcmp( cellstr( lensdata.Generic.Manipulator.Name), 'Wafer.Z')));
par_mc.lens.Im_Rx                               = adj_pob( find( strcmp( cellstr( lensdata.Generic.Manipulator.Name), 'Wafer.Rx')));
par_mc.lens.Im_Ry                               = adj_pob( find( strcmp( cellstr( lensdata.Generic.Manipulator.Name), 'Wafer.Ry')));
par_mc.lens.Im_Rz                               = adj_pob( find( strcmp( cellstr( lensdata.Generic.Manipulator.Name), 'Wafer.Rz')));


%% CORs
COR.lens.Z2 =  spline( ml_dyn_input_dlm.wd.xf', ml_dyn_input_dlm.layer.wr.dx', lensdata.X)* lensdata.Generic.Lens.Factors.dZ2_dX ; %[m]
COR.lens.Z3 =  spline( ml_dyn_input_dlm.wd.xf', ml_dyn_input_dlm.layer.wr.dy', lensdata.X)* lensdata.Generic.Lens.Factors.dZ3_dY ; %[m]
for ichk = 1:2
    COR.hoc(ichk)=ml_input_HOC(ichk);
end

%% KPIs

% KPI4, RES1
lens_res = ovl_sub(extra_data.input.lens, extra_data.corr.lens);
KPI.maxLensRes.dx = max(abs(lens_res.layer.wr.dx));
KPI.maxLensRes.dy = max(abs(lens_res.layer.wr.dy));
RES.LensRes.dx = lens_res.layer.wr.dx; 
RES.LensRes.dy = lens_res.layer.wr.dy; 

% KPI2
KPI.maxLensCorr.dx = max(abs(extra_data.corr.lens.layer.wr.dx));
KPI.maxLensCorr.dy = max(abs(extra_data.corr.lens.layer.wr.dy));

% KPI6
tmp = ovl_average_columns( extra_data.input.lens);
z2 = tmp.layer.wr.dx * lensdata.Generic.Lens.Factors.dZ2_dX;
p = polyfit(lensdata.X * 100, z2' * 1e9, 3);  % m - > cm, m -> nm
z2_2 = p(2);  
%figure; plot(lensdata.X * 100, z2'*1e9,'.-')

z3 = tmp.layer.wr.dy * lensdata.Generic.Lens.Factors.dZ3_dY;
p=polyfit(lensdata.X * 100, z3' * 1e9, 3);  % m - > cm
z3_2 = p(2);   % m -> nm
%figure; plot(lensdata.X * 100, z3'*1e9,'.-')

KPI.Z2_2 = z2_2;
KPI.Z3_2 = z3_2;

for ichk = 1:2
     % RES3
   hoc_res(ichk) = ovl_sub(extra_data.input.scan(ichk), extra_data.corr.scan(ichk));
   RES.HOCRes(ichk).dx = hoc_res(ichk).layer.wr.dx;
   RES.HOCRes(ichk).dy = hoc_res(ichk).layer.wr.dy;

    % RES2
   total_res(ichk) = ovl_add(hoc_res(ichk), lens_res);
   RES.TotalRes(ichk).dx = total_res(ichk).layer.wr.dx; 
   RES.TotalRes(ichk).dy = total_res(ichk).layer.wr.dy; 

   % KPI3
   KPI.maxTotalRes(ichk).dx = max(abs(total_res(ichk).layer.wr.dx));  
   KPI.maxTotalRes(ichk).dy = max(abs(total_res(ichk).layer.wr.dy));  

   % KPI1
   if ichk == 1
       total_corr(ichk) = ovl_sub(ml_field_chk1, total_res(ichk));
   elseif ichk == 2
       total_corr(ichk) = ovl_sub(ml_field_chk2, total_res(ichk));
   end
   KPI.maxTotalCorr(ichk).dx = max(abs(total_corr(ichk).layer.wr.dx));   
   KPI.maxTotalCorr(ichk).dy = max(abs(total_corr(ichk).layer.wr.dy));

    % KPI5 : temporary fix to make the CET model work
    if ~isempty(options.CET_model)
        KPI.FadingMSD(ichk).x = '';
        KPI.FadingMSD(ichk).y = '';
    else
        [max_dx,max_dy,max_msdx,max_msdy,~,~] = JIMI_calc_profile_fading_v4(ml_input_HOC(ichk),intra_par_HOC(ichk));
        KPI.FadingMSD(ichk).x = max_msdx;
        KPI.FadingMSD(ichk).y = max_msdy;
    end

    % KPI7
   KPI.maxHOCCorr(ichk).dx = max(abs(extra_data.corr.scan(ichk).layer.wr.dx));
   KPI.maxHOCCorr(ichk).dy = max(abs(extra_data.corr.scan(ichk).layer.wr.dy));

   % KPI8
   KPI.maxHOCRes(ichk).dx = max(abs(hoc_res(ichk).layer.wr.dx));
   KPI.maxHOCRes(ichk).dy = max(abs(hoc_res(ichk).layer.wr.dy));
end
