function out = bmmo_add_BAOs(varargin)
% function out = bmmo_add_BAOs(varargin)
%
% This function combines the BAOs calibrated at different stages during the 
% NXE BMMO/BL3 drift control model.
%
% Input:
% varargin: Several inputs of BAO, this should include:
%               10par calibrated before MI model
%               6par interfield calibrated from FF BAO model
%               10par calibrated after MI model
%               10par calibrated after KA model
%
% Output:
% Out: Combined/added 10par
% 
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model
% 
% Linear model parameters:
% Par         dx     dy       Name
% --------------------------------------------------------------------------
% tx           1              Translation X
% ty                  1       Translation Y
% ms           x      y       Symmetrical magnification
% ma           x     -y       A-symmetrical magnification
% rs          -y      x       Symmetrical rotation
% ra          -y     -x       A-symmetrical rotation
% mws          x      y       Symmetrical Wafer scaling
% mwa          x     -y       A-symmetrical wafer scaling
% rws         -y      x       Symmetrical wafer rotation
% rwa         -y     -x       A-symmetrical wafer rotation
   
parlist = {'tx','ty','rs','ra','ms','ma','rws','rwa','mws','mwa'};
LPar = length(parlist);
for ipar = 1:LPar;
    out.(parlist{ipar}) = 0;
end

LInput = length(varargin);

for i = 1:LInput;
    this_par = varargin{i};
    for ipar = 1:LPar;
        if isfield(this_par, parlist{ipar});
            out.(parlist{ipar}) = out.(parlist{ipar}) + this_par.(parlist{ipar});
        end
    end
end

