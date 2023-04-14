function [mlo, options] = bmmo_field_reconstruction(mli, options)
% function [mlo, options] = bmmo_field_reconstruction(mli, options)
%
% Given an input layout, this function reconstructs the layout used by NXE BMMO 
% drift control, by mapping to a generated 13x19 layout based on
% the field centres and field ordering in mli.expinfo
%
% Input:
% mli:      input layout containing an expinfo substructure as defined in the
%           EDS
% options:  options structure
%
% Output:
% mlo:      reconstructed ml struct
% options:  options structure (layer_fields possibly changed)
% 
% For details of the model and definitions of in/out interfaces, refer to
% D000323756 EDS BMMO NXE drift control model

tolerance_exponent = 12; % tolerance for layout mark equality is 10^-12 m

% build target layouts per layer
mlo = bmmo_construct_layout_from_ml(mli, options);

for ilayer = 1:length(mlo)
    % shift fields to measurement position
    mlo(ilayer) = bmmo_shift_fields(mlo(ilayer), options.x_shift, options.y_shift, ilayer);

    % map input layout to shifted exposure layout, with fields in exposure
    % sort order
    mlo(ilayer) = bmmo_map_layouts(mli, mlo(ilayer), tolerance_exponent);

    % shift mapped fields to exposure position
    mlo(ilayer) = bmmo_shift_fields(mlo(ilayer), -options.x_shift, -options.y_shift);
end

% combine the layers if there is more than one layer
if length(mlo) > 1
    mlo = bmmo_combine_fields(mlo(1), mlo(2), 1:mlo(2).nfield);
end

% fix layer_fields depending on input data
if mlo.nfield < min(options.edge_fields)
    options.layer_fields{1} = 1:mlo.nfield;
    options.layer_fields = options.layer_fields(1);
end


