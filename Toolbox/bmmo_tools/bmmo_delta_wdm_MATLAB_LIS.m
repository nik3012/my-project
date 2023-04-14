function bmmo_delta_wdm_MATLAB_LIS(mli1, mli2, plot_name, print_type, plot_type, out_file)
%function bmmo_delta_wdm_MATLAB_LIS(mli1, mli2, plot_name, print_type, plot_type, out_file)
%
% Function for LIS SP validation of waferdatamaps: delta, no. of valids, plots of delta
% MATLAB and LIS.
%
% INPUTS
%
% mli1 : MATLAB measurement layout input
% Can accept ml in following format:
% 1) ml with 1 x 1 struct and nwafers (like n = 6)
% 2) ml with 1 x 2 struct for each chuck and nwafer =1
%
% mli2 : LIS measurement layout input
% Can accept ml in following format:
% 1) ml with 1 x n struct, where n = no. of wafers
% 2) ml with 1 x 2 struct for each chuck and nwafer =1
%
% plot_name: string input containing waferdatamap name 
%
% OPTIONAL INPUTS
%
% print_type = 0, shows if delta is OK/NOK and # of valids are matching
% print_type = 1, shows the delta for each chuck/wafer
% print_type = 2, shows the delta and number of valid points for each chuck/wafer
% plot_type  = 1, Plots the delta ovl plots for each chuck/wafer
% plot_type  = 2, Plots the Model,VCP and delta ovl plots for each chuck/wafer
% out_file :filename to output the assertion results,
% eg: 'output.txt' or provide outfile = stdout for printing to command line

threshold = 5e-13;

%default title
title = 'mli1 vs mli2';

if mli2(1).nfield == 1
    for ic = 1:2
        mli2(ic).wd = mli1(ic).wd;
    end
end

for i = 1:length(mli1)
    ml_delta(i) = ovl_sub(mli1(i), mli2(i));
end

if ~isequal(ml_delta(1).nmark,0)
    if plot_type == 1
        for  i = 1:length(mli1)
            sub_wafer_plot(ml_delta(i), 'Delta Chuck ', i)
        end
        toppt('Delta ovl plot for each Chuck', plot_name)
        close all
        
    elseif plot_type == 2
        for  i = 1:length(mli1)          
            sub_wafer_plot(mli1(i), 'MATLAB Chuck ', i)
            sub_wafer_plot(mli2(i), 'LIS Chuck ', i)
            sub_wafer_plot(ml_delta(i), 'Delta Chuck ', i)
        end
        toppt('MATLAB vs LIS: ovl plot for each chuck', plot_name)
        close all 
    end
    
    for i = 1:length(mli1)
        max_delta_x(i) = max(abs(ml_delta(i).layer.wr.dx));
        mli1_x_n_valids(i) = sum(~isnan(mli1(i).layer.wr.dx));
        mli2_x_n_valids(i) = sum(~isnan(mli2(i).layer.wr.dx));
        delta_x_n_valids(i) = sum(~isnan(ml_delta(i).layer.wr.dx));
        max_delta_y(i) =  max(abs(ml_delta(i).layer.wr.dy));
        mli1_y_n_valids(i) = sum(~isnan(mli1(i).layer.wr.dy));
        mli2_y_n_valids(i) = sum(~isnan(mli2(i).layer.wr.dy));
        delta_y_n_valids(i) = sum(~isnan(ml_delta(i).layer.wr.dy));
    end
    
    if print_type == 0
        for  i = 1:length(mli1)
            deltaok = (max_delta_x(i) < threshold) & (max_delta_y(i) < threshold);
            if deltaok && isequal(mli1_x_n_valids(i), mli2_x_n_valids(i), delta_x_n_valids(i), mli1_y_n_valids(i), mli2_y_n_valids(i), delta_y_n_valids(i))
                sub_print_type_0(out_file, i, plot_name, threshold, ' Delta is OK!, smaller than ', ' and No. of marks are same');
                
            elseif deltaok && ~isequal(mli1_x_n_valids(i), mli2_x_n_valids(i), delta_x_n_valids(i), mli1_y_n_valids(i), mli2_y_n_valids(i), delta_y_n_valids(i))
                sub_print_type_0(out_file, i, plot_name, threshold, ' Delta is OK!, smaller than ', ' No. of marks are not same!');
                
            elseif ~deltaok && isequal(mli1_x_n_valids(i), mli2_x_n_valids(i), delta_x_n_valids(i), mli1_y_n_valids(i), mli2_y_n_valids(i), delta_y_n_valids(i))
                sub_print_type_0(out_file, i, plot_name, threshold, ' Delta is NOK!, p2p delta larger than ', ' No. of marks are same!');
                
            elseif ~deltaok && ~isequal(mli1_x_n_valids(i), mli2_x_n_valids(i), delta_x_n_valids(i), mli1_y_n_valids(i), mli2_y_n_valids(i), delta_y_n_valids(i))
                sub_print_type_0(out_file, i, plot_name, threshold, ' Delta is NOK!, p2p delta larger than ', ' No. of marks are not same!');
            end
        end
        
    elseif print_type == 1
        
        fprintf(out_file, '\n');
        fprintf(out_file, ['Delta max values for dx and dy (per chuck) ', plot_name]);
        sub_print_type_nozero(out_file, mli1, max_delta_x, max_delta_y);
        
    elseif print_type == 2
        
        fprintf(out_file, '\n');
        fprintf(out_file, [ 'Delta max values for dx and dy (per chuck) ', plot_name]);
        sub_print_type_nozero(out_file, mli1, max_delta_x, max_delta_y);
        
        fprintf(out_file, ['Number of marks (per chuck) - MATLAB ( dx and dy) and LIS (dx and dy) ', plot_name]);
        sub_print_type_nozero(out_file, mli1, mli1_x_n_valids, mli1_y_n_valids, mli2_x_n_valids, mli2_y_n_valids);
        
    elseif print_type == 3
        
        fprintf(out_file, ['Delta max values for dx and dy (per chuck) ', plot_name]);
        sub_print_type_nozero(out_file, mli1, max_delta_x, max_delta_y);
        
        fprintf(out_file, ['Number of marks (per chuck) - MATLAB ( dx and dy) and LIS (dx and dy) ', plot_name]);
        sub_print_type_nozero(out_file, mli1, mli1_x_n_valids, mli1_y_n_valids, mli2_x_n_valids, mli2_y_n_valids);
        
        fprintf(out_file, [ 'Number of marks (per chuck) - Delta (dx and dy) ', plot_name]);
        for  i=1: length(mli1)
            fprintf(out_file, '\n');
            fprintf(out_file, [num2str(delta_x_n_valids(i)),'    ', num2str(delta_y_n_valids(i))]);
        end
    end
    clear ml_delta
    
elseif isequal(ml_delta.nmark, 0)
    fprintf(out_file, 'Zero Number of marks !!!!!');
end
end

function sub_wafer_plot(ml, title, chuck_id)

if ml.nfield == 1
    figure;
    ovl_plot(ml, 'field', 'title', [title, int2str(chuck_id)],...
        'vcolor', 'scale', 0, 'prc', 4, 'legend', 'cust');
else
    figure;
    ovl_plot(ml, 'title', [title, int2str(chuck_id)],...
        'vcolor', 'scale', 0, 'prc', 4, 'legend', 'cust');
end

end


function sub_print_type_nozero(file, ml, in_1, in_2, in_3, in_4)

for  i = 1:length(ml)
    format long
    fprintf(file, '\n');
    if nargin < 5
        fprintf(file, [num2str(in_1(i)),'    ', num2str(in_2(i))]);
    elseif nargin == 6
        fprintf(file, [num2str(in_1(i)),'    ', num2str(in_2(i)), '    ', num2str(in_3(i)), '    ', num2str(in_4(i))]);
    end
    fprintf(file, '\n');
end
end

function sub_warning(message, file)

if file == 1 %stdout case
    warning(message)
else % filename char case
    warning(message)
    fprintf(file, ['WARNING:', message,'\n']);
end
end

function sub_print_type_0(file, chuck_id, plot_name, threshold, str_OK_NOK, str_valids)

fprintf(file, '\n');
sub_warning([plot_name, ' Chuck ', num2str(chuck_id), str_OK_NOK,...
    num2str(threshold), str_valids], file);
fprintf(file, '\n');
end