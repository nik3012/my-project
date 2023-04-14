function ml_bmmo = bmmo_convert_generic_ml(mli, reticle_layout)
% function ml_bmmo = bmmo_convert_generic_ml(mli, reticle_layout)
%
% Convert any ml structure into a valid BMMO-NXE input with
%  - zero WH fingerprint
%  - alternating chuck IDs beginning with chuck 1
%  - same exposure order as field order in input
%  - other info set to default values
%
% Input: mli: any valid ovl_toolbox overlay structure
%        reticle_layout: (string) one of the supported layouts from
%           ovl_create_dummy
%
% Output: ml_bmmo: valid input for bmmo_nxe_drift_control_model
%
% 20160602 SBPR Creation

if nargin < 2
    [found, reticle_layout, x_shift, y_shift] = bmmo_guess_reticle_layout(mli);
    if found
        ml_bmmo.configurable_options.x_shift = [0 x_shift];
        ml_bmmo.configurable_options.y_shift = [0 y_shift];
    else
        error('Unknown reticle layout with set tolerance level');
    end
end

% copy the basic wafer definition info
ml_bmmo.wd = mli.wd;

if mli.nlayer > 1
   mli = ovl_sub_layers(mli); 
end

ml_bmmo.layer = mli.layer;
ml_bmmo.nfield = mli.nfield;
ml_bmmo.nmark = mli.nmark;
ml_bmmo.nwafer = mli.nwafer;
ml_bmmo.nlayer = mli.nlayer;
if isfield(mli, 'tlgname')
    ml_bmmo.tlgname = mli.tlgname;
else
    ml_bmmo.tlgname = 'BMMO Input';
end

ml_bmmo.expinfo = bmmo_get_default_expinfo(ml_bmmo);
ml_bmmo.info = bmmo_get_default_info(ml_bmmo, reticle_layout);
ml_bmmo.configurable_options.intrafield_reticle_layout = reticle_layout;
if mli.nmark < 49
    ml_bmmo.configurable_options.reduced_reticle_layout = reticle_layout;
end
ml_bmmo.configurable_options.layer_fields = {1:mli.nfield};
ml_bmmo.configurable_options.mark_type = 'unknown';

if ml_bmmo.nfield < 89
    ml_bmmo.configurable_options.fid_intrafield = 1:ml_bmmo.nfield;
    ml_bmmo.configurable_options.fid_left_right_edgefield = [];
    ml_bmmo.configurable_options.fid_top_bottom_edgefield = [];
end

