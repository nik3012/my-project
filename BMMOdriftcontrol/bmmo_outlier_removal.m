function [mlo, stat, data_accepted] = bmmo_outlier_removal(mli, options)
% function [mlo, stat, data_accepted] = bmmo_outlier_removal(mli, options)
%
% This function is the outlier removal sub-model for bmmo_nxe_drift_control_model
% It detects outliers from the input data and set their dx, dy to
% NaN
%
% Input:
%   mli: input ml structure, field reconstruction has been completed
%   options: BMMO/BL3 default options structure
%
% Output:
%   mlo: output ml structure where outliers have been removed
%   stat: structure containing details of each outlier (location etc) per
%       wafer, per layer,  as defined in ovl_remove_outliers
%   data_accepted: True if outlier density is lower than threshold defined in
%       options.outlier_max_fraction
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

% Declare constants
outlier_type.INVALID = 1;
outlier_type.W2W = 2;
outlier_type.MODEL = 3;

mlo = mli;

if options.chuck_usage.chuck_id_used(1) == 2
    mli(2) = mli;
end
[FPS, C] = bmmo_construct_FPS(mli, options, 'OR');
data_accepted = true;
 
if mlo.nlayer == 1
    mlo_s = mlo;
elseif mlo.nlayer == 2 % ( s2f )
    mlo_s = ovl_sub(ovl_get_layers(mlo,2),ovl_get_layers(mlo,1)); 
else
    error('Data must have single layer or two layers.');
end

if data_accepted
    % 1st step, limit overlay larger than options.outlier_max_ovl
    for iwafer = 1:mlo_s.nwafer
        this_waf = ovl_get_wafers(mlo_s,iwafer);
        [~, ~, ~, ~, dx, dy] = ovl_concat_wafer_results(this_waf);
         
        idx = find(abs(dx) > options.outlier_max_ovl);
        idy = find(abs(dy) > options.outlier_max_ovl);
        id_over_limit = unique([idx;idy]);
        mlo_s.layer.wr(iwafer).dx(id_over_limit) = NaN;
        mlo_s.layer.wr(iwafer).dy(id_over_limit) = NaN;
        
        stat_this_wafer(iwafer).x   = this_waf.wd.xw(id_over_limit);
        stat_this_wafer(iwafer).y   = this_waf.wd.yw(id_over_limit);
        stat_this_wafer(iwafer).idx = id_over_limit;
        stat_this_wafer(iwafer).r   = sqrt(this_waf.wd.xw(id_over_limit).^2 + this_waf.wd.xw(id_over_limit).^2);
        stat_this_wafer(iwafer).dr  = sqrt(this_waf.layer.wr.dx(id_over_limit).^2 + this_waf.layer.wr.dy(id_over_limit).^2);
        stat_this_wafer(iwafer).n   = numel(id_over_limit); 
        stat_this_wafer(iwafer).type = outlier_type.INVALID * ones(size(id_over_limit));
    end
    % 2nd step, w2w outlier removal
    for chuck_id = options.chuck_usage.chuck_id_used
        this_wafer = find(options.chuck_usage.chuck_id == chuck_id);
        ml_ch = ovl_get_wafers(mlo_s, this_wafer);
        test_constants.coverage_factor = options.outlier_coverage_factor;
        test_constants.remove_large = 0;
        
        [ml_after,  outliers_data] = ovl_w2w_outliers(ml_ch,'coverage_factor',options.outlier_coverage_factor,...
            'neighborhood_radius',options.outlier_check_radius);
        
        for iwafer = this_wafer
            ol_wafer_index = find(this_wafer == iwafer);
            if ~isempty(outliers_data.lay.outliers_data)
                
                index = find(vertcat(outliers_data.lay.outliers_data(:).iwafer)==ol_wafer_index);
                
                if(index)
                    ol_data_iwaf = outliers_data.lay.outliers_data(index);
                    
                    stat_this_wafer1(iwafer).x = [ol_data_iwaf.xw]';
                    stat_this_wafer1(iwafer).y = [ol_data_iwaf.yw]';
                    stat_this_wafer1(iwafer).idx = ([ol_data_iwaf.ifield]'-1)*mlo_s.nmark + [ol_data_iwaf.imark]';
                    stat_this_wafer1(iwafer).r = sqrt([ol_data_iwaf.xw].^2 + [ol_data_iwaf.yw].^2)';
                    stat_this_wafer1(iwafer).dr = sqrt([ol_data_iwaf.dx].^2 + [ol_data_iwaf.dy].^2)';
                    stat_this_wafer1(iwafer).n = numel(ol_data_iwaf);
                    stat_this_wafer1(iwafer).type = outlier_type.W2W * ones(numel(ol_data_iwaf), 1);
                    stat_this_wafer(iwafer) = sub_combine_outlier_stat(stat_this_wafer(iwafer), stat_this_wafer1(iwafer));
                end
            end
            mlo_s.layer.wr(iwafer) = ml_after.layer.wr(ol_wafer_index);
        end
    end 
    
    % 3rd step, run combined model then detect outlier from the residue
    for iwafer = 1:mlo_s.nwafer
        options_copy                           = options;
        options_copy.chuck_usage.chuck_id      = options.chuck_usage.chuck_id(iwafer);
        options_copy.chuck_usage.chuck_id_used = options_copy.chuck_usage.chuck_id;
        options_copy.chuck_usage.nr_chuck_used = 1;
        this_waf = ovl_get_wafers(mlo_s,iwafer);
        
        outlier_found = true;
       
       while outlier_found
            outlier_input(options_copy.chuck_usage.chuck_id) = this_waf;
            [~, ~, res] = bmmo_fit_fingerprints(outlier_input, FPS, options_copy, C);
            res = res(options_copy.chuck_usage.chuck_id_used);
            [~, ~, ~, ~, stats_outl2] = ovl_remove_outliers(res, 'nxe', options_copy.outlier_coverage_factor);
            stats_outl2.layer.wafer.type = outlier_type.MODEL * ones(stats_outl2.layer.wafer.n, 1);
            
            stat_this_wafer(iwafer) = sub_combine_outlier_stat(stat_this_wafer(iwafer), stats_outl2.layer.wafer);
            idx_out = stats_outl2.layer.wafer.idx;
            this_waf.layer.wr.dx(idx_out) = NaN;
            this_waf.layer.wr.dy(idx_out) = NaN;
            if isempty(idx_out)
                outlier_found = false;
            end
        end
        mlo_s.layer.wr(iwafer).dx  = this_waf.layer.wr.dx;
        mlo_s.layer.wr(iwafer).dy  = this_waf.layer.wr.dy;
        stat1.wafer(iwafer) = stat_this_wafer(iwafer);
    end
    for ilayer = 1:mlo.nlayer
        for iwafer = 1:mlo.nwafer
            mlo.layer(ilayer).wr(iwafer).dx = mlo_s.layer.wr(iwafer).dx;
            mlo.layer(ilayer).wr(iwafer).dy = mlo_s.layer.wr(iwafer).dy;
            stat.layer(ilayer).wafer(iwafer) = stat1.wafer(iwafer);
        end
    end    
end


function out = sub_combine_outlier_stat(in1,in2)
out.x   = [in1.x; in2.x];
out.y   = [in1.y; in2.y];
out.idx = [in1.idx; in2.idx];
out.r   = [in1.r; in2.r];
out.dr  = [in1.dr; in2.dr];
out.n   = in1.n + in2.n;
out.type = [in1.type; in2.type];
