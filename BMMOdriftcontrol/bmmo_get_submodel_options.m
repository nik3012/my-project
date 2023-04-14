function options_out = bmmo_get_submodel_options(options)
% function options_out = bmmo_get_submodel_options(options)
%
% Construct submodel options for bmmo-nxe drift control model
%
% Input
%   options: structure defined in bmmo_default_options_structure or 
%            bl3_default_options_structure
%
% Output
%   options_out: options with submodels.do_XX fields initialised
%   options_out.submodels: structure with one subfield for each element of
%                          options.submodel_sequence
%                          (possible field names: WH, SUSD, MI, KA, BAO, INTRAF)
%                          each field containing the following subfields
%                          fnhandle: function handle for generating fingerprints for this
%                          combined model element

options_out = options;
sm = [];

for isub = 1:length(options.submodel_sequence)
    sub = options.submodel_sequence{isub};
    switch(sub)
        case 'MIKA'
            sm.MIKA.fnhandle = @bmmo_sub_model_MIKA;
        case 'MIKA_EDGE'
            sm.MIKA_EDGE.fnhandle = @bmmo_sub_model_MIKA_EDGE;
        case 'WH'
            sm.WH.fnhandle = @bmmo_sub_model_WH;
        case 'WH_SUSD'
            sm.WH_SUSD.fnhandle = @bmmo_sub_model_WH_SUSD;
        case 'MI'
            sm.MI.fnhandle = @bmmo_sub_model_MI;
        case 'INTRAF'
            sm.INTRAF.fnhandle = @bmmo_sub_model_INTRAF;
        case 'BAO'
            sm.BAO.fnhandle = @bmmo_sub_model_BAO;
        case 'SUSD_2L_monitor'
            sm.SUSD_2L_monitor.fnhandle = @bmmo_sub_model_SUSD_2L_monitor;
        case 'SUSD_1L_monitor'
            sm.SUSD_1L_monitor.fnhandle = @bmmo_sub_model_SUSD_1L_monitor;
        case 'SUSD_1L' 
            sm.SUSD_1L.fnhandle = @bmmo_sub_model_SUSD_1L;
        otherwise
            error('Submodel value %s unknown', sub);
    end
end

options_out.submodels = sm;
