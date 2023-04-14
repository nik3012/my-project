function bmmo_kt_compare_mirror_plots(out, p_legend)
% function bmmo_kt_compare_mirror_plots(out, p_legend)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%
for ip = 1:length(out)
    
    if  ip == 1
        mixc1(1, :) = out(ip).corr.MI.wse(1).x_mirr.y;
        mixc2(1, :) = out(ip).corr.MI.wse(2).x_mirr.y;  
        miyc1(1, :) = out(ip).corr.MI.wse(1).y_mirr.x;
        miyc2(1, :) = out(ip).corr.MI.wse(2).y_mirr.x;
    end
    
    mixc1(ip + 1, :) = out(ip).corr.MI.wse(1).x_mirr.dx;
    mixc2(ip + 1, :) = out(ip).corr.MI.wse(2).x_mirr.dx;  
    miyc1(ip + 1, :) = out(ip).corr.MI.wse(1).y_mirr.dy;
    miyc2(ip + 1, :) = out(ip).corr.MI.wse(2).y_mirr.dy;
    
end


close all;

figure; hold;
title('mix chuck 1');
for ip = 1:length(out)
   plot(mixc1(1, :), mixc1(ip + 1, :));
end

legend(p_legend);

figure; hold;
title('mix chuck 2');
for ip = 1:length(out)
   plot(mixc1(1, :), mixc2(ip + 1, :));
end

legend(p_legend);

figure; hold;
title('miy chuck 1');
for ip = 1:length(out)
   plot(miyc1(1, :), miyc1(ip + 1, :));
end

legend(p_legend);

figure; hold;
title('miy chuck 2');
for ip = 1:length(out)
   plot(miyc1(1, :), miyc2(ip + 1, :));
end

legend(p_legend);

newslide('MI sub-model');
for i=1:4;figppt(i,[2,2,i],'bitmap_hd');end
