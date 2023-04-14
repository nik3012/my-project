function [options_out, T] = bl3_set_model_configuration(options_in)
%function [options_out, T] = bl3_set_model_configuration(options_in)
%
% This function will set the correct submodel_sequence and combined model
% contents in the options structure, based on the configuration options in
% the options structure (SUSD on/off, KA on/off, 1L/2L)
%
% Input :
% options_in:      existing options structure
%
% Ouput :
% options_out:     input options with submodel_sequence and
%                  combined_model_contents set
% T:               lookup table with all possible model configuration

options_out = options_in;

T = sub_get_mapping_table;
T_selected = T(T.layer == options_out.no_layer_to_use &...
    T.susd == options_out.susd_control & T.ka == options_out.KA_control, :);

options_out.submodel_sequence = T_selected{1, 'submodel_sequence'}{1};
options_out.combined_model_contents = T_selected{1, 'cm_contents'}{1};


function T = sub_get_mapping_table

layer = [1;1;1;1;2;2;2;2];
susd = [0;0;1;1;0;0;1;1];
ka = [0;1;0;1;0;1;0;1];
seq_1L_default = {'SUSD_1L_monitor','MI','BAO','INTRAF'};
seq_1L_SUSD = {'SUSD_1L','MI','BAO','INTRAF'};
seq_1L_MIKA_EDGE = {'SUSD_1L_monitor','MIKA_EDGE','BAO','INTRAF'};
seq_1L_MIKA_EDGE_SUSD = {'SUSD_1L','MIKA_EDGE','BAO','INTRAF'};
seq_2L_default = {'WH','SUSD_2L_monitor','MI','BAO','INTRAF'};
seq_2L_MIKA_EDGE = {'WH','SUSD_2L_monitor','MIKA_EDGE','BAO','INTRAF'};
seq_2L_SUSD = {'WH_SUSD','MI','BAO','INTRAF'};
seq_2L_SUSD_MIKA_EDGE = {'WH_SUSD','MIKA_EDGE','BAO','INTRAF'};

submodel_sequence = {seq_1L_default;seq_1L_MIKA_EDGE;seq_1L_SUSD;seq_1L_MIKA_EDGE_SUSD;...
    seq_2L_default;seq_2L_MIKA_EDGE;seq_2L_SUSD;seq_2L_SUSD_MIKA_EDGE};

cm_contents = sub_get_cm_contents(submodel_sequence);
T = table(layer, susd, ka, submodel_sequence, cm_contents);


function cm = sub_get_cm_contents(submodel_sequence)

for i = 1:length(submodel_sequence)
    cm_contents.OR = {'WH', 'SUSD', 'MIX', 'MIY', 'INTERF', 'INTRAF', 'KA_POLY_NONLINEAR','KA_EDGE'};
    for j = 1:length(submodel_sequence{i})
        switch submodel_sequence{i}{j}
            case 'MIKA_EDGE'
                cm_contents.MIKA_EDGE = {'MIX', 'MIY', 'INTERFMAG', 'KA_POLY','KA_EDGE', 'INTRAF'};
            case {'SUSD_1L', 'SUSD_1L_monitor'}
                cm_contents.SUSD_1L = {'SUSD', 'MIX', 'MIY', 'INTERF', 'INTRAF', 'KA_POLY_NONLINEAR','KA_EDGE'};
            case {'SUSD_2L_monitor', 'WH_SUSD'}
                cm_contents.WH_SUSD = {'WH', 'SUSD'};
            case {'WH'}
                cm_contents.WH = {'WH'};
            case {'MI'}
                cm_contents.MI = {'MIX', 'MIY'};
        end
    end
    cm{i, 1} = cm_contents;
end