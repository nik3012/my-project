function [max_dx,max_dy,max_msdx,max_msdy, dx, dy] = JIMI_calc_profile_fading_v3(ml_in, p_in,varargin )
%calc_profile_fading : estimates fading (x,y and z) as result of polynomial profiles of RS/WS
%   For every mark in the ml struct dteremine the RS and WS setpoint for 5
%   y-positions in the slit. Based on these setpoints determine the effect
%   on Z2, Z3 and Z4. Using the sensitivities, this result is a dx,dy,dz
%   for each of the 5 positions in the slit. 
%   Using the illumination weights the average(dynamic) effect can be
%   calculated and also the fading (MSD)

optionsDef.lenstype      = '3400_34';
%[options, arguments] = ovl_parse_options(optionsDef, varargin{:}); % do NOT remove {:} because this is needed for Matlab varargin syntax

%% load data using LMtwin toolbox
try
    lm_load_definition(optionsDef.lenstype);
catch
    lm_twin_path = '\\asml.com\eu\shared\nl011032\tis-lq\Matlab_Tools\lm_twin_tng\WIP';
    warning(['Cannot load LM definitions. Adding path to lm_twin: ' lm_twin_path]); 
    addpath \\asml.com\eu\shared\nl011032\tis-lq\Matlab_Tools\lm_twin_tng\WIP
    try
        lm_load_definition(optionsDef.lenstype);
    catch
        error([sprintf('You need access to the following network share:\n') ...
               '   \\asml.com\eu\shared\nl011032\tis-lq\Matlab_Tools\lm_twin\WIP' ...
               sprintf('\nPlease use the IT service request form ''Access to Network Shares (read/write)'':\n') ...
               sprintf('   http://netscanner.asml.com/nl017015/nonconf/request_forms.html\n')]);
    end
end


lensdata.X = Generic.Lens.Grid.X(1, :) * 1e-3; % [mm] -> [m]
lensdata.Y = Generic.Lens.Grid.Y       * 1e-3;       % [mm] -> [m]
lensdata.W = Generic.Lens.Slit_Weights;

lensdata.obj_z_id = find(strcmp(cellstr(Generic.Manipulator.Name), 'Reticle.Z'));
lensdata.obj_Rx_id = find(strcmp(cellstr(Generic.Manipulator.Name), 'Reticle.Rx'));
lensdata.obj_Ry_id = find(strcmp(cellstr(Generic.Manipulator.Name), 'Reticle.Ry'));
lensdata.img_x_id = find(strcmp(cellstr(Generic.Manipulator.Name), 'Wafer.X'));
lensdata.img_y_id = find(strcmp(cellstr(Generic.Manipulator.Name), 'Wafer.Y'));
lensdata.img_z_id = find(strcmp(cellstr(Generic.Manipulator.Name), 'Wafer.Z'));
lensdata.img_Rz_id = find(strcmp(cellstr(Generic.Manipulator.Name), 'Wafer.Rz'));
lensdata.img_Rx_id = find(strcmp(cellstr(Generic.Manipulator.Name), 'Wafer.Rx'));
lensdata.img_Ry_id = find(strcmp(cellstr(Generic.Manipulator.Name), 'Wafer.Ry'));

for p_i = 1:length(p_in.static)
    switch p_in.static(p_i).name
        case 'bipx0'
            x_poly(4) = p_in.static(p_i).value;
        case 'bipx1'
            x_poly(3) = p_in.static(p_i).value;
        case 'bipx2'
            x_poly(2) = p_in.static(p_i).value;
        case 'bipx3'
            x_poly(1) = p_in.static(p_i).value;
        case 'bipy0'
            y_poly(4) = p_in.static(p_i).value;
        case 'bipy1'
            y_poly(3) = p_in.static(p_i).value;
        case 'bipy2'
            y_poly(2) = p_in.static(p_i).value;
        case 'bipy3'
            y_poly(1) = p_in.static(p_i).value;
        case 'biprz0'
            rz_poly(3) = p_in.static(p_i).value;
        case 'biprz1'
            rz_poly(2) = p_in.static(p_i).value;
        case 'biprz2'
            rz_poly(1) = p_in.static(p_i).value;
        case 'bopz0'
            z_poly(3) = p_in.static(p_i).value;
        case 'bopz1'
            z_poly(2) = p_in.static(p_i).value;
        case 'bopz2'
            z_poly(1) = p_in.static(p_i).value;
        case 'boprx0'
            rx_poly(3) = p_in.static(p_i).value;
        case 'boprx1'
            rx_poly(2) = p_in.static(p_i).value;
        case 'boprx2'
            rx_poly(1) = p_in.static(p_i).value;
        case 'bopry0'
            ry_poly(3) = p_in.static(p_i).value;
        case 'bopry1'
            ry_poly(2) = p_in.static(p_i).value;
        case 'bopry2'
            ry_poly(1) = p_in.static(p_i).value;
    end
end

for kk = 1:length(ml_in.wd.xf)
    abs_dif_x = abs(ml_in.wd.xf(kk) - lensdata.X);
    xi(kk)=find(abs_dif_x == min(abs_dif_x));
end

for offset = 1:size(lensdata.Y,1)
    % determine position of stages during the scan
    s_t_y = ml_in.wd.yf - lensdata.Y(offset,xi)';
    slit_y=lensdata.Y(offset,xi)';
    rs_z  = polyval(z_poly,s_t_y*4);
    rs_rx = polyval(rx_poly,s_t_y*4);
    rs_ry = polyval(ry_poly,s_t_y*4);
    ws_x  = polyval(x_poly,s_t_y);
    ws_y  = polyval(y_poly,s_t_y);
    ws_rz = polyval(rz_poly,s_t_y);
    % Note that
    % Generic.Lens.Factors.dZ2_dX=Generic.Lens.Factors.dZ3_dY=-0.33=-NA
    LD_z2_to_rsZ=Generic.Manipulator.Dependency(offset, xi', 2, lensdata.obj_z_id)*1/Generic.Lens.Factors.dZ2_dX*1e-3;
    LD_z3_to_rsZ=Generic.Manipulator.Dependency(offset, xi', 3, lensdata.obj_z_id)*1/Generic.Lens.Factors.dZ3_dY*1e-3;
    
    obj_common=rs_z'+4*rs_rx'.*slit_y'-4*rs_ry'.*ml_in.wd.xf';
    
    dx(offset, :)= ((ws_x'- ws_rz'.*slit_y')+LD_z2_to_rsZ.*obj_common);
    dy(offset, :)= ((ws_y'+ ws_rz'.*ml_in.wd.xf')+LD_z3_to_rsZ.*obj_common);
    
end
Wi = lensdata.W(:,xi);

m_dx = sum(dx .* Wi);
m_dy = sum(dy .* Wi);

f_dx = dx - ones(size(dx,1),1) * m_dx;
f_dy = dy - ones(size(dy,1),1) * m_dy;

msd_x = sqrt(sum(f_dx.^2 .* Wi.^2)./sum(Wi.^2));
msd_y = sqrt(sum(f_dy.^2 .* Wi.^2)./sum(Wi.^2));

% figure,
% subplot(221),
% sc_=quivers(ml_in.wd.xf*1e3,ml_in.wd.yf*1e3,m_dx',m_dy');
% hold on
% quivers(ml_in.wd.xf*1e3,ml_in.wd.yf*1e3,ml_in.layer.wr.dx,ml_in.layer.wr.dy,sc_,'r');axis equal
% axis equal
% 
% title('Scan integrated distortion (blue) and iHOPC model (red)')
% xlabel('full field x-pos [mm]')
% ylabel('full field y-pos [mm]')
% 
% %figure,
% subplot(222)
% hold on,quivers(ml_in.wd.xf*1e3,ml_in.wd.yf*1e3,dx(1,:)',dy(1,:)',sc_,int2color(1));
% hold on,quivers(ml_in.wd.xf*1e3,ml_in.wd.yf*1e3,dx(2,:)',dy(2,:)',sc_,int2color(2));
% hold on,quivers(ml_in.wd.xf*1e3,ml_in.wd.yf*1e3,dx(3,:)',dy(3,:)',sc_,int2color(3));
% hold on,quivers(ml_in.wd.xf*1e3,ml_in.wd.yf*1e3,dx(4,:)',dy(4,:)',sc_,int2color(4));
% hold on,quivers(ml_in.wd.xf*1e3,ml_in.wd.yf*1e3,dx(5,:)',dy(5,:)',sc_,int2color(5));
% axis equal
% title('Scan static distortion (5 slit y-pos)')
% xlabel('full field x-pos [mm]')
% ylabel('full field y-pos [mm]')
% 
% 
[d,xyi]=sort(ml_in.wd.yf+1e-3*ml_in.wd.xf);

Xs = reshape(ml_in.wd.xf(xyi),13,19);
Ys = reshape(ml_in.wd.yf(xyi),13,19);
fad_Xs = reshape(msd_x(xyi),13,19);
fad_Ys = reshape(msd_y(xyi),13,19);

% figure
% subplot(223)
% surf(Xs*1e3,Ys*1e3,fad_Xs*1e9); view(2), colorbar, shading interp
% title('MSD in x-direction [nm]')
% xlabel('full field x-pos [mm]')
% ylabel('full field y-pos [mm]')
% 
% 
% subplot(224)
% surf(Xs*1e3,Ys*1e3,fad_Ys*1e9); view(2), colorbar, shading interp
% title('MSD in y-direction [nm]')
% xlabel('full field x-pos [mm]')
% ylabel('full field y-pos [mm]')



max_dx=max(abs(m_dx));
max_dy=max(abs(m_dy));
max_msdx=max(abs(msd_x));
max_msdy=max(abs(msd_y));


    