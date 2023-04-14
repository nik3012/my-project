% =============================================================================
% Functions in Toolbox\bmmo_xml
% This folder contains functions for processing ADEL files and other
% non-Matlab formats for use in BMMO-NXE modelling
% =============================================================================
%
%   bmmo_add_ADEL_SBC               - Add two ADEL SBC corrections 
%   bmmo_add_ADEL_SBC_wrapper       - Add ADEL SBC corrections in given dirs
%   bmmo_add_sbc_to_ADEL            - Add Matlab SBC correction to ADEL sbc file
%   bmmo_apply_rec                  - Apply REC to the input structure
%   bmmo_apply_wec                  - Apply WEC to the input structure
%   bmmo_create_ADEl_SBC            - Create zero ADEL SBC from given input
%   bmmo_create_BAO_dd              - Create BAO dd MCs
%   bmmo_create_MI_dd -             - Create MI dd MCs
%   bmmo_find_adel_sbc_output       - Find SBC output in LCP zip folder
%   bmmo_find_adel_SBC_xml          - Find SBC correction in a folder
%   bmmo_find_adels                 - Find required ADELS in LCP zip folder
%   bmmo_get_meas_data_bmmo         - Get ml from KT_wafers_out
%   bmmo_input_from_adels           - Given required ADEL files, generate BMMO input structure
%   bmmo_log_progress               - Log progress to progress bar or stdout
%   bmmo_parse_adel_timestamp       - Parse the timestamp used in ADEL files into Matlab datetime format
%   bmmo_parse_adelmetrology        - Parse raw overlay data from ADELmetrology
%   bmmo_parse_job_report           - Parse data from ADELlpcJobReport
%   bmmo_parse_wec                  - Parse raw data from ADELwaferErrorCorrection
%   bmmo_process_adelmetrology      - read ADELmetrology into smf ml structures
%   bmmo_read_lcp_output            - convert LCP output folder to BMMO-NXE model input and output
%   bmmo_read_lcp_zip               - convert LCP output zip to BMMO-NXE model input and output
%   bmmo_read_sbc_from_ADELrep      - read SBC2 correction from ADELsbcOverlayDriftControlNxerep
%   bmmo_res_from_SBC2rep           - read inline SDM residual from ADELsbcOverlayDriftControlNxerep
%   bmmo_xml_save                   - save matlab data to xml file
