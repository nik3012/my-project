
function ml_exp = bmmo_kt_ml_from_expinfo(expinfo, layoutname)
% function ml_exp = bmmo_kt_ml_from_expinfo(expinfo, layoutname)
%
% Convert an expinfo structure (containing a list of field centres) to a
% full overlay structure based on the optional input layout name. If no
% layout name is provided, a 13x19 XPA layout will be generated
% 
% Input:
%   expinfo: structure containing the following fields
%       xc: n * 1 vector of x field centre coordinates
%       yc: n * 1 vector of y field centre coordinates
%
% Optional input:
%   layoutname: name of layout as used in ovl_create_dummy (default:
%               '13X19')
%
% Output:
%   ml_exp: overlay structure with n fields, field centres taken from
%       expinfo, intrafield coordinates taken from layout, overlay values
%       all zero
%
% 20170726: SBPR Added documentation

if nargin < 2
    layoutname = '13X19';
end
    

% construct a template full-field ml structure based on the input

full_dummy = ovl_create_dummy('layout', layoutname, 'nlayer', 1, 'nwafer', 1);
full_field = ovl_get_fields(full_dummy, 1);

ml_exp.nmark = full_dummy.nmark;
ml_exp.nfield = length(expinfo.xc);

ml_exp.wd.xc = reshape(repmat(expinfo.xc, 1, ml_exp.nmark)',[],1);
ml_exp.wd.yc = reshape(repmat(expinfo.yc, 1, ml_exp.nmark)',[],1);
ml_exp.wd.xf = reshape(repmat(full_field.wd.xf,[ml_exp.nfield 1]),[],1);
ml_exp.wd.yf = reshape(repmat(full_field.wd.yf,[ml_exp.nfield 1]),[],1);
ml_exp.wd.xw = ml_exp.wd.xc + ml_exp.wd.xf;
ml_exp.wd.yw = ml_exp.wd.yc + ml_exp.wd.yf;

ml_exp.nwafer = 1;
ml_exp.nlayer = 1;

ml_exp.layer.wr.dx = zeros(size(ml_exp.wd.xw));
ml_exp.layer.wr.dy = ml_exp.layer.wr.dx;
