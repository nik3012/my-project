function FP_BAO = bmmo_construct_FPS_BAO(ml, options)
%function FP_BAO = bmmo_construct_FPS_BAO(ml, options)
%
% Generate the raw BAO fingerprint for the combined model
%
% Input: 
%  ml: input ml structure
%  options: structure containing the fields 
%           INTRAF.name: 1xN cell array of intrafield parameter names
%           INTRAF.scaling: 1xN double vector of scaling factors
%
% Output: 
%  FP_INTRAF: INTRAF fingerprint (1xN cell array of ml structs}

parnames = {'tx','ty','ms','ma','rs','ra','mws','mwa','rws','rwa'};
FP_BAO = bmmo_construct_FPS_parlist(ml, parnames, ones(length(parnames)));

end
   