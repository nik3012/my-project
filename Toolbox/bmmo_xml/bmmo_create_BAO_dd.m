function bmmo_create_BAO_dd(sbc)
% function bmmo_create_BAO_dd(sbc)
%
% Create .dd file BMMO_drift_BAO.dd in current folder with BAO MCs from sbc2
%
% Input:
%   sbc2: SBC2 correction in BMMO-NXE format (cf.
%       bmmo_default_output_structure)
%
% 20160928 SBPR Creation

filename = 'BMMO_drift_BAO.dd';
fh = fopen(filename, 'w');

fprintf(fh, '{\nchuck =\n[\n');

for ic = 1:2
    sub_print_bao(fh, sbc.BAO(ic));
    if ic == 1
        fprintf(fh, ',\n');
    else
        fprintf(fh, '\n');
    end
end

fprintf(fh, ']\n}\n');

fclose(fh);


function sub_print_bao(fh, bao)

fprintf(fh, '{\n');
fprintf(fh, 'intra_field = {\n');
fprintf(fh, 'translation = {\n');
fprintf(fh, ['x = ', num2str(bao.TranslationX), ',\n']);
fprintf(fh, ['y = ', num2str(bao.TranslationY), '\n']);
fprintf(fh, '},\n');
fprintf(fh, ['rotation = ', num2str(bao.Rotation), ',\n']);
fprintf(fh, ['magnification = ', num2str(bao.Magnification + 1), ',\n']);
fprintf(fh, ['asymmetrical_rotation = ', num2str(bao.AsymRotation), ',\n']);
fprintf(fh, ['asymmetrical_magnification = ', num2str(bao.AsymMagnification + 1), '\n']);
fprintf(fh, '},\n');
fprintf(fh, ['inter_field_Mx = ', num2str(bao.ExpansionX + 1), ',\n']);
fprintf(fh, ['inter_field_My = ', num2str(bao.ExpansionY + 1), ',\n']);
fprintf(fh, ['inter_field_R = ', num2str(bao.InterfieldRotation), ',\n']);
fprintf(fh, ['inter_field_dRy = ', num2str(bao.NonOrtho), '\n']);

fprintf(fh, '}');