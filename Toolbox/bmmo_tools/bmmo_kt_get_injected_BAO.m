function bao = bmmo_kt_get_injected_BAO( drift_path)
% function bao = bmmo_kt_get_injected_BAO
%
% Return the injected BAO parameters
%
% Input:    
%           drift_path: path of directory containing drift dd files
%
% Output: bao: bao correction per chuck

baopath = [drift_path filesep 'BMMO_drift_BAO.dd'];

baomat = dd2mat(0, baopath);

for ic = 1:2
   bao(ic).TranslationX = baomat.chuck(ic).intra_field.translation.x;
   bao(ic).TranslationY = baomat.chuck(ic).intra_field.translation.y;
   bao(ic).Magnification = baomat.chuck(ic).intra_field.magnification - 1;
   bao(ic).AsymMagnification = baomat.chuck(ic).intra_field.asymmetrical_magnification - 1;
   bao(ic).Rotation = baomat.chuck(ic).intra_field.rotation;
   bao(ic).AsymRotation = baomat.chuck(ic).intra_field.asymmetrical_rotation;
   bao(ic).ExpansionX = baomat.chuck(ic).inter_field_Mx - 1;
   bao(ic).ExpansionY = baomat.chuck(ic).inter_field_My - 1;
   bao(ic).NonOrtho = baomat.chuck(ic).inter_field_dRy;
   bao(ic).InterfieldRotation = baomat.chuck(ic).inter_field_R; 
end

