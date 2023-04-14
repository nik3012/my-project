function assert_equal_wdm_OTAS_LIS(OTAS, VCP, WDM, print_type, plot_type)

% Function for VCP validation: delta, no. of valids, plots of delta
% OTAS and VCP.

%

% IINPUTS
%OTAS : OTAS input

%VCP : VCP model input



%OPTIONAL INPUTS
% print_type = 1, shows the delta for each chuck/wafer
% print_type = 2, shows the delta and number of valid points for each chuck/wafer
% plot_type = 1, Plots the delta ovl plots for each chuck/wafer
% plot_type = 2, Plots the OTAS,VCP and delta ovl plots for each chuck/wafer

threshold = 5e-13;



if nargin < 5
    plot_type = 0;
    
else
    openppt('new')
end

if nargin < 4
    print_type =0;
    
end

if nargin < 3
    WDM = 'all';
    
end


f1 = fieldnames(OTAS);
f2  = fieldnames(VCP);
corr = {'total_unfiltered','total_filtered'};



if contains(WDM, 'all')
    str2 = {'Wafer_Heating', 'Mirror_exposure','KA_exposure_grid','bao','correction_overlay','Intrafield_nce_18par'};
    str1 = {'WH', 'MI','KA','BAO','TotalSBCcorrection','Intrafield_18parNCE'};
    str3 = {'uncontrolled_meas', 'susd_correction','applied_inline_sdm', 'controlled', 'sbc_residual_outliers_removed', 'raw_intrafield'};
    str4 = {'uncontrolled_overlay', 'total_filtered_susd', 'previous_actuated_inlineSDM', 'controlled_overlay', 'residual_overlay', 'total_filtered_Intrafield_raw'};
    
else
    str2 = {'Wafer_Heating', 'Mirror_exposure','KA_exposure_grid','bao','correction_overlay','Intrafield_nce_18par'};
    str1 = {'WH', 'MI','KA','BAO','TotalSBCcorrection','Intrafield_18parNCE'};
    str3 = {'uncontrolled_meas', 'susd_correction','applied_inline_sdm', 'controlled', 'sbc_residual_outliers_removed', 'raw_intrafield'};
    str4 = {'uncontrolled_overlay', 'total_filtered_susd', 'previous_actuated_inlineSDM', 'controlled_overlay', 'residual_overlay', 'total_filtered_Intrafield_raw'};
    index = contains(str1,WDM);
    str2 = str2(index);
    str1 = str1(index);   
end



    OTAS1 = OTAS;
    for ichk = 1:2
        
        OTAS.total_unfiltered_Intrafield_18parNCE(ichk) = ovl_average_fields(OTAS1.total_unfiltered_Intrafield_18parNCE(ichk));
        OTAS.total_filtered_Intrafield_18parNCE(ichk)   = ovl_average_fields(OTAS1.total_filtered_Intrafield_18parNCE(ichk));
       
        VCP.total_filtered_Intrafield_raw(ichk)   = ovl_average_fields(VCP.total_filtered_Intrafield_raw(ichk));
        VCP.total_filtered_Intrafield_nce_18par(ichk)   = ovl_average_fields(VCP.total_filtered_Intrafield_nce_18par(ichk));
        VCP.total_unfiltered_Intrafield_nce_18par(ichk) = ovl_average_fields(VCP.total_unfiltered_Intrafield_nce_18par(ichk));
        
        VCP.previous_actuated_inlineSDM(ichk) = ovl_average_fields(VCP.previous_actuated_inlineSDM(ichk));
        
        % correct for RINT microshift
        options.x_shift = [0,-2.600000000000000e-04;0,-2.600000000000000e-04];
        %[yc yf; yc yf]
        options.y_shift = [0,-4.000000000000000e-05;0,-4.000000000000000e-05];
        if isfield(OTAS,'susd_correction')
         OTAS.susd_correction(ichk) = bmmo_shift_fields(OTAS.susd_correction(ichk) , options.x_shift, options.y_shift);
        end
         OTAS.controlled(ichk) = bmmo_shift_fields(OTAS.controlled(ichk) , options.x_shift, options.y_shift);
         OTAS.sbc_residual_outliers_removed(ichk) = bmmo_shift_fields(OTAS.sbc_residual_outliers_removed(ichk) , options.x_shift, options.y_shift);
         
    end




for iii=1:length(str1)
    
    if any(contains(f1,str1{iii})) && any(contains(f2,str2{iii}))
        
        for ii = 1:length(corr)
            mli1 = OTAS.([corr{ii} '_' str1{iii}]);
            mli2 = VCP.([corr{ii} '_' str2{iii}]);
            plot_name = [(corr{ii}) ' ' (str1{iii})];
            
            if mli2(1).nfield == 1
                for ic=1:2
                    mli2(ic).wd = mli1(ic).wd;
                end
            end
            
            for i=1:length(mli1)
                ml_delta(i) = ovl_sub(mli1(i), mli2(i));
                
            end
            
            if ~isequal(ml_delta(1).nmark,0)
                
                
                
                
                if plot_type ==1
                    for  i=1: length(mli1)
                        chr = int2str(i);
                        if mli1(1).nfield ==1
                            fopc(ml_delta(i),'field','title',['Delta Chuck ',chr])
                        else
                            fopc(ml_delta(i),'title',['Delta Chuck ',chr])
                        end
                    end
                    toppt('Delta ovl plot for each Chuck', plot_name)
                    close all
                    
                elseif plot_type == 2
                    for  i=1: length(mli1)
                        chr = int2str(i);
                        if mli1(1).nfield ==1
                            fopc(mli1(i),'field','title',['OTAS Chuck ',chr])
                            fopc(mli2(i),'field','title',['VCP Chuck ',chr])
                            fopc(ml_delta(i),'field','title',['Delta Chuck ',chr])
                        else
                            fopc(mli1(i),'title',['OTAS Chuck ',chr])
                            fopc(mli2(i),'title',['VCP Chuck ',chr])
                            fopc(ml_delta(i),'title',['Delta Chuck ',chr])
                        end
                        
                    end
                    toppt('OTAS vs VCP: ovl plot for each chuck',plot_name)
                    close all
                    
                end
                for i=1: length(mli1)
                    ax(i) = max(abs(ml_delta(i).layer.wr.dx));
                    axn1(i) = sum(~isnan(mli1(i).layer.wr.dx));
                    axn2(i) = sum(~isnan(mli2(i).layer.wr.dx));
                    axn3(i) = sum(~isnan(ml_delta(i).layer.wr.dx));
                    ay(i) =  max(abs(ml_delta(i).layer.wr.dy));
                    ayn1(i) = sum(~isnan(mli1(i).layer.wr.dy));
                    ayn2(i) = sum(~isnan(mli2(i).layer.wr.dy));
                    ayn3(i) = sum(~isnan(ml_delta(i).layer.wr.dy));
                end
                
                if print_type == 0
                    for  i=1: length(mli1)
                        deltaok = ax(i) < threshold & ay(i) < threshold;
                        if deltaok && isequal(axn1(i),axn2(i),axn3(i),ayn1(i),ayn2(i),ayn3(i))
                            disp([plot_name ' Chuck ' num2str(i) ' Delta is OK!, smaller than ' num2str(threshold) ' and No. of marks are same'])
                            
                            
                        elseif deltaok && ~isequal(axn1(i),axn2(i),axn3(i),ayn1(i),ayn2(i),ayn3(i))
                            disp([plot_name ' Chuck ' num2str(i) ' Delta is OK!, smaller than ' num2str(threshold)])
                            warning([plot_name ' Chuck ' num2str(i) 'No. of marks are not same!'])
                            
                        elseif ~deltaok && isequal(axn1(i),axn2(i),axn3(i),ayn1(i),ayn2(i),ayn3(i))
                            warning([plot_name ' Chuck ' num2str(i) ' P2p delta larger than ' num2str(threshold) ' check delta plot (No. of Marks are same)'])
                            
                        elseif ~deltaok && ~isequal(axn1(i),axn2(i),axn3(i),ayn1(i),ayn2(i),ayn3(i))
                            warning([plot_name ' Chuck ' num2str(i) ' P2p delta larger than ' num2str(threshold) ' check delta plot (No. of Marks are not same)'])
                        end
                    end
                    
                    
                elseif print_type == 1
                    
                    disp([ 'Delta max values for dx and dy (per chuck)' ' ' plot_name])
                    for  i=1: length(mli1)
                        format long
                        disp([ax(i), ay(i)])
                    end
                    
                elseif print_type == 2
                    
                    disp([ 'Delta max values for dx and dy (per chuck)' ' ' plot_name])
                    for  i=1: length(mli1)
                        format long
                        disp([ax(i), ay(i)])
                    end
                    
                    
                    disp([ 'Number of marks (per chuck) - OTAS ( dx and dy) and VCP (dx and dy)' ' ' plot_name])
                    for  i=1: length(mli1)
                        format long
                        disp([axn1(i),ayn1(i),  axn2(i), ayn2(i)])
                    end
                    
                elseif print_type == 3
                    
                    disp([ 'Delta max values for dx and dy (per chuck)' ' ' plot_name])
                    for  i=1: length(mli1)
                        format long
                        disp([ax(i), ay(i)])
                    end
                    
                    
                    disp([ 'Number of marks (per chuck) - OTAS ( dx and dy) and VCP (dx and dy)' ' ' plot_name])
                    for  i=1: length(mli1)
                        format long
                        disp([axn1(i),ayn1(i),  axn2(i), ayn2(i)])
                    end
                    
                    disp([ 'Number of marks (per chuck) - Delta (dx and dy)' ' ' plot_name])
                    for  i=1: length(mli1)
                        format long
                        disp([axn3(i),ayn3(i)])
                    end
                    
                end
                
                clear ml_delta
            elseif isequal(ml_delta.nmark,0)
                disp(['Zero Number of marks !!!!!,']);
            end
            
        end
    end
end

for iii = 1:length(str3)
    if  isfield(OTAS,str3{iii}) && any(contains(f2,str4{iii}))
        
        
        mli1 = OTAS.(str3{iii});
        mli2 = VCP.(str4{iii});
        plot_name =  (str4{iii});
        
        if mli2(1).nfield == 1
            for ic=1:2
                mli2(ic).wd = mli1(ic).wd;
            end
        end
        
        for i=1:length(mli1)
            ml_delta(i) = ovl_sub(mli1(i), mli2(i));
            
        end
        
        if ~isequal(ml_delta(1).nmark,0)
            
            
            
            
            if plot_type ==1
                for  i=1: length(mli1)
                    chr = int2str(i);
                    if mli1(1).nfield ==1
                        fopc(ml_delta(i),'field','title',['Delta Chuck ',chr])
                    else
                        fopc(ml_delta(i),'title',['Delta Chuck ',chr])
                    end
                end
                toppt('Delta ovl plot for each Chuck', plot_name)
                close all
                
            elseif plot_type == 2
                for  i=1: length(mli1)
                    chr = int2str(i);
                    if mli1(1).nfield ==1
                        fopc(mli1(i),'field','title',['OTAS Chuck ',chr])
                        fopc(mli2(i),'field','title',['VCP Chuck ',chr])
                        fopc(ml_delta(i),'field','title',['Delta Chuck ',chr])
                    else
                        fopc(mli1(i),'title',['OTAS Chuck ',chr])
                        fopc(mli2(i),'title',['VCP Chuck ',chr])
                        fopc(ml_delta(i),'title',['Delta Chuck ',chr])
                    end
                    
                end
                toppt('OTAS vs VCP: ovl plot for each chuck',plot_name)
                close all
                
            end
            for i=1: length(mli1)
                ax(i) = max(abs(ml_delta(i).layer.wr.dx));
                axn1(i) = sum(~isnan(mli1(i).layer.wr.dx));
                axn2(i) = sum(~isnan(mli2(i).layer.wr.dx));
                axn3(i) = sum(~isnan(ml_delta(i).layer.wr.dx));
                ay(i) =  max(abs(ml_delta(i).layer.wr.dy));
                ayn1(i) = sum(~isnan(mli1(i).layer.wr.dy));
                ayn2(i) = sum(~isnan(mli2(i).layer.wr.dy));
                ayn3(i) = sum(~isnan(ml_delta(i).layer.wr.dy));
            end
            
            if print_type == 0
                    for  i=1: length(mli1)
                        deltaok = ax(i) < threshold & ay(i) < threshold;
                        if deltaok && isequal(axn1(i),axn2(i),axn3(i),ayn1(i),ayn2(i),ayn3(i))
                            disp([plot_name ' Chuck ' num2str(i) ' Delta is OK!, smaller than ' num2str(threshold) ' and No. of marks are same'])
                            
                            
                        elseif deltaok && ~isequal(axn1(i),axn2(i),axn3(i),ayn1(i),ayn2(i),ayn3(i))
                            disp([plot_name ' Chuck ' num2str(i) ' Delta is OK!, smaller than ' num2str(threshold)])
                            warning([plot_name ' Chuck ' num2str(i) 'No. of marks are not same!'])
                            
                        elseif ~deltaok && isequal(axn1(i),axn2(i),axn3(i),ayn1(i),ayn2(i),ayn3(i))
                            warning([plot_name ' Chuck ' num2str(i) ' P2p delta larger than ' num2str(threshold) ' check delta plot (No. of Marks are same)'])
                            
                        elseif ~deltaok && ~isequal(axn1(i),axn2(i),axn3(i),ayn1(i),ayn2(i),ayn3(i))
                            warning([plot_name ' Chuck ' num2str(i) ' P2p delta larger than ' num2str(threshold) ' check delta plot (No. of Marks are not same)'])
                        end
                    end
                
                
            elseif print_type == 1
                
                disp([ 'Delta max values for dx and dy (per chuck)' ' ' plot_name])
                for  i=1: length(mli1)
                    format long
                    disp([ax(i), ay(i)])
                end
                
            elseif print_type == 2
                
                disp([ 'Delta max values for dx and dy (per chuck)' ' ' plot_name])
                for  i=1: length(mli1)
                    format long
                    disp([ax(i), ay(i)])
                end
                
                
                disp([ 'Number of marks (per chuck) - OTAS ( dx and dy) and VCP (dx and dy)' ' ' plot_name])
                for  i=1: length(mli1)
                    format long
                    disp([axn1(i),ayn1(i),  axn2(i), ayn2(i)])
                end
                
            elseif print_type == 3
                
                disp([ 'Delta max values for dx and dy (per chuck)' ' ' plot_name])
                for  i=1: length(mli1)
                    format long
                    disp([ax(i), ay(i)])
                end
                
                
                disp([ 'Number of marks (per chuck) - OTAS ( dx and dy) and VCP (dx and dy)' ' ' plot_name])
                for  i=1: length(mli1)
                    format long
                    disp([axn1(i),ayn1(i),  axn2(i), ayn2(i)])
                end
                
                disp([ 'Number of marks (per chuck) - Delta (dx and dy)' ' ' plot_name])
                for  i=1: length(mli1)
                    format long
                    disp([axn3(i),ayn3(i)])
                end
                
            end
            
            clear ml_delta
        elseif isequal(ml_delta.nmark,0)
            disp(['Zero Number of marks !!!!!,']);
        end
        
    end
    
    
end



