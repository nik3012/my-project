function bmmo_create_MI_dd(sbc)
% function bmmo_create_MO_dd(sbc)
%
% Create  4 .dd files  in current folder with MI MCs from sbc2
%
% Input:
%   sbc2: SBC2 correction in BMMO-NXE format (cf.
%       bmmo_default_output_structure)
%
% 20160928 SBPR Creation

mn = {{'x_mirr', 'y', 'dx', 'ytx', 'YTX'}, {'y_mirr', 'x', 'dy', 'xty', 'XTY'}};

for im = 1:2
    for ic = 1:2
        mirr = sbc.MI.wse(ic).(mn{im}{1});
            
        filename = ['BMMO_drift_MI_c', num2str(ic), '_', mn{im}{4}, '.dd'];
        fh = fopen(filename, 'w');
        
        sub_write_header(fh);
        
        sub_write_map(fh, mirr, mn{im});
        
        fprintf(fh, '}\n');
        fclose(fh);
    end
end



function sub_write_map(fh, mirr, mn)
    
fprintf(fh, [mn{5}, ' = [\n']);
nn = length(mirr.(mn{2}));
for ii = 1:nn
    fprintf(fh, num2str(mirr.(mn{3})(ii)));
    if ii < nn
        fprintf(fh, ',\n');
    else
        fprintf(fh, '\n]\n');
    end
end



function sub_write_header(fh)

    fprintf(fh, '{\n');
    fprintf(fh, 'X0 = -200.0e-3,\n');
    fprintf(fh, 'deltaX = 1.0e-3,\n');
    fprintf(fh, 'nx = 401,\n');
