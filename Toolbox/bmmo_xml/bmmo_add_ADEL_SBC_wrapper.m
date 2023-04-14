function bmmo_add_ADEL_SBC_wrapper(templatefolder, sbcfolder2, outfolder, factor)
% function bmmo_add_ADEL_SBC_wrapper(templatefolder, sbcfolder2, outfolder, factor)
%
% Wrspper for bmmo_add_ADEL_SBC, which searches for ADEL files in given
% folders
%
% Input:
%   template folder: folder containing template
%       ADELsbcOverlayDriftControlNxe
%   sbcfolder2: folder containing ADELsbcOverlayDriftControlNxe to add to
%       template
%   outfolder: path of output file
%   factor: scaling factor for sbcfolder2
%
% 201703 SBPR Creation

templatefile = bmmo_find_adel_SBC_xml(templatefolder);
sbcfile2 = bmmo_find_adel_SBC_xml(sbcfolder2);

outfile = [outfolder filesep 'ADELsbcOverlayDriftControlNxe.xml'];

bmmo_add_ADEL_SBC(templatefile, sbcfile2, outfile, factor);