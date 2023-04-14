var sourceData748 = {"FileContents":["function mlo = bmmo_get_l1_input(mli, options)\r","% function mlo = bmmo_get_l1_input(mli)\r","%\r","% Extract the specified 89 fields from 174 field input\r","%\r","% Input:\r","%   mli: input structure with 174 fields, WEC applied\r","%   options: bmmo options structure with the following fields\r","%       layer_fields{1}: vector of field ids of layer 1\r","%       edge_fields: vector of edge fields from layer 2\r","%\r","% Output:\r","%   mlo: layer_fields{1} from mli combined with inverted edge_fields from\r","%               mli\r","%\r","% 20160421 SBPR Creation\r","\r","mlo = mli;\r","\r","if mli.nfield >= max(options.edge_fields)\r","    mlo = ovl_get_fields(mli, [options.layer_fields{1}, options.edge_fields]);\r","end"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[18,20,21],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}