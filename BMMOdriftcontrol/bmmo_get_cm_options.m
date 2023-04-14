function cm = bmmo_get_cm_options(options)
% function cm = bmmo_get_cm_options(options)
%
% Construct combined model options for bmmo-nxe drift control model
%
% Input
%   options: structure defined in bmmo_default_options_structure
%
% Output
%   cm: structure with one subfield for each element of
%       options.combined_model_contents
%       (possible field names: MIX, MIY, INTRAF, INTERF, KA, SUSD)
%       each field containing the following subfields
%           fnhandle: function handle for generating fingerprints for this
%               combined model element
%           length: number of fingerprints for this combined model element
%           fpindex: index of fingerprint in combined model array

cm = struct;
MAX_CHUCK = 2;

fpindex = MAX_CHUCK; % last index of WH in FPS
fn = fieldnames(options.combined_model_contents);
for icms = 1:length(fn)
    offset = fpindex;
    cm.(fn{icms}) = struct;
    for icom = 1:length(options.combined_model_contents.(fn{icms}))
        com = options.combined_model_contents.(fn{icms}){icom};
        switch(com)
            case 'MIX'
                cm.(fn{icms}).MIX.fnhandle = @bmmo_construct_FPS_MIX;
                cm.(fn{icms}).MIX.length = options.xty_spline_params.nr_segments + 1;
            case 'MIY'
                cm.(fn{icms}).MIY.fnhandle = @bmmo_construct_FPS_MIY;
                cm.(fn{icms}).MIY.length = options.ytx_spline_params.nr_segments + 1;
            case 'INTERF'
                cm.(fn{icms}).INTERF.fnhandle = @bmmo_construct_FPS_INTERF;
                cm.(fn{icms}).INTERF.length = length(options.INTERF.name);
            case 'INTERFMAG'
                cm.(fn{icms}).INTERFMAG.fnhandle = @bmmo_construct_FPS_INTERFMAG;
                cm.(fn{icms}).INTERFMAG.length = length(options.INTERFMAG.name);
            case 'INTRAF'
                cm.(fn{icms}).INTRAF.fnhandle = @bmmo_construct_FPS_INTRAF;
                cm.(fn{icms}).INTRAF.length = length(options.INTRAF.name);
            case 'KA_POLY'
                cm.(fn{icms}).KA_POLY.fnhandle = @bmmo_construct_FPS_KA;
                cm.(fn{icms}).KA_POLY.length = (sum(options.KA_orders) ) * 2;
            case 'KA_POLY_NONLINEAR'
                cm.(fn{icms}).KA_POLY_NONLINEAR.fnhandle = @bmmo_construct_FPS_KA_nonlinear;
                ka_orders = options.KA_orders;
                ka_orders(ka_orders == 1) = [];
                cm.(fn{icms}).KA_POLY_NONLINEAR.length = (sum(ka_orders) ) * 2;
            case 'KA_EDGE'
                cm.(fn{icms}).KA_EDGE.fnhandle = @bmmo_construct_FPS_GaussianEDGE;
                cm.(fn{icms}).KA_EDGE.length = length(options.GaussianEdge_nodes);
            case 'SUSD'
                cm.(fn{icms}).SUSD.fnhandle = @bmmo_construct_FPS_SUSD;
                cm.(fn{icms}).SUSD.length = 1;
            case 'BAO'
                cm.(fn{icms}).BAO.fnhandle = @bmmo_construct_FPS_BAO;
                cm.(fn{icms}).BAO.length = 10;
            case 'WH'
                cm.(fn{icms}).WH.fnhandle = @bmmo_construct_FPS_WH;
                cm.(fn{icms}).WH.length = 2;
            otherwise
                error('Combined model value %s unknown', com);
        end
        cm.(fn{icms}).(com).fpindex = offset + 1;
        offset = offset + cm.(fn{icms}).(com).length;
    end
end
