function ml = bmmo_cet_to_ml(cet_res)
% function ml = bmmo_cet_to_ml(cet_res)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%
    ROUNDING_SF = 12;

    full_grid_size = numel(cet_res.xf_grid);
    number_of_exposures = numel(cet_res.xc);
    
    ml.wd.xf = round(repmat(reshape(cet_res.xf_grid, [], 1), number_of_exposures, 1), ROUNDING_SF);
    ml.wd.yf = round(repmat(reshape(cet_res.yf_grid, [], 1), number_of_exposures, 1), ROUNDING_SF);
    ml.wd.xc = round(reshape(repmat(reshape(cet_res.xc, 1, []), full_grid_size,1), [], 1), ROUNDING_SF);
    ml.wd.yc = round(reshape(repmat(reshape(cet_res.yc, 1, []), full_grid_size,1), [], 1), ROUNDING_SF);
    ml.wd.xw = ml.wd.xf + ml.wd.xc;
    ml.wd.yw = ml.wd.yf + ml.wd.yc;
    
    ml.nmark = full_grid_size;
    ml.nfield = number_of_exposures;
    ml.nlayer = 1;
    ml.nwafer = numel(cet_res.wafer);
    
    wr.dx = zeros(full_grid_size * number_of_exposures, 1);
    wr.dy = wr.dx;
    
    ml.layer.wr = repmat(wr, 1, ml.nwafer);
    for iw = 1:ml.nwafer
       ml.layer.wr(iw).dx = reshape(cet_res.wafer(iw).dx, [], 1);
       ml.layer.wr(iw).dy = reshape(cet_res.wafer(iw).dy, [], 1);
    end
    
    ml.tlgname = [];
end