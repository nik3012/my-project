% =============================================================================
% Functions in Toolbox\bmmo_layouts
% This folder contains functions for processing non-BMMO-NXE layouts for 
% use in the BMMO-NXE model.
% =============================================================================
% <help_update_needed>
%
%   bmmo_collapse_layers          - Convert multi-layer input to single-layer with field shift
%   bmmo_construct_layout         - Construct empty ml structure from expinfo and intrafield layout
%   bmmo_convert_generic_ml       - Convert ml structure to BMMO-NXE model input
%   bmmo_convert_mmo_tlg          - Convert ATP-MMO testlog to bmmo input structure
%   bmmo_convert_whc_data         - Convert WH calibration data to bmmo input structure
%   bmmo_expinfo_from_tlg         - Generate expinfo from a tlg
%   bmmo_fill_layout              - Generate fully-defined layout from partially-defined layout structure
%   bmmo_get_default_expinfo      - Generate a default expinfo structure
%   bmmo_get_default_info         - Generate a default info structure
%   bmmo_get_kfactors_from_MDL    - Read WH k-factor data from a EUHDMI MDL file
%   bmmo_get_shifts_from_expinfo  - Get layer shifts from expinfo
%   bmmo_guess_reticle_layout     - Guess the reticle layout from an ml structure
%   bmmo_map_shifted_layouts      - Map the overlay data in one layout to the nearest marks in another



