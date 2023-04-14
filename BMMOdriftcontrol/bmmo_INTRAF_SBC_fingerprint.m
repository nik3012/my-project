function [mlo, ml_intra] = bmmo_INTRAF_SBC_fingerprint(mli, fingerprint, options)
% function [mlo, ml_intra] = bmmo_INTRAF_SBC_fingerprint(mli, fingerprint, options)
%
% This function returns an ml structure corresponding to the input SBC
% INTRAF fingerprint
%
% Input:
%  mli: input ml structure
%  fingerprint: INTRAF fingerprint (1x2 struct array)
%  options: BMMO/BL3 options structure
% 
% Output:
%  mlo: output ml structure containing the INTRAF fingerprint in the same layout as mli
%  ml_intra: INTRAF fingerprint in same layout as mli, averaged per chuck
% 
% options.intraf_actuation.fnhandle = @bmmo_INTRAF_resampled_fingerprint
% will resample the input fingerprint to mli. 
% The default options.intraf_actuation.fnhandle = @bmmo_INTRAF_par_fingerprint
% will calculate 18par or 33par of the input fingerprint, depending on
% options.intraf_CETpar.name, and distribute it onto mli.

[mlo, ml_intra] = feval(options.intraf_actuation.fnhandle, mli, fingerprint, options);
