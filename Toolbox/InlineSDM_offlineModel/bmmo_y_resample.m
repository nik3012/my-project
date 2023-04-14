function [ml_y_resample, hoc_field] = bmmo_y_resample(ml_hoc_field, field_geo, image_y_shift)
% <help_update_needed>
%  for the class and for the function
%
% 

%%
% Create HOC field
ml                = ml2SWLayout_local(ml_hoc_field);                                            
hoc_field.size_x  = length(unique(ml.wd.xf));
hoc_field.size_y  = length(unique(ml.wd.yf));
hoc_field.W       = max(ml.wd.xf) - min(ml.wd.xf);
hoc_field.H       = max(ml.wd.yf) - min(ml.wd.yf);
hoc_field.x = ml.wd.xf;
hoc_field.y = ml.wd.yf;
range = [1 length(ml.wd.xf)];
for i = 1:ml.nwafer
    hoc_field.disto(i).x = ml.layer.wr(i).dx;
    hoc_field.disto(i).y = ml.layer.wr(i).dy;
end


%%
% Create data element to be filled in the loop
ml_y_resample =  ovl_average_fields(ovl_create_dummy(...
            '13x19', 'nlayer', 1, 'nwafer', ml.nwafer));

% Constants for the loop
step_x = field_geo.W/(field_geo.x_resol - 1);
step_y = field_geo.H/(field_geo.y_resol - 1);
step_Y = hoc_field.H/(hoc_field.size_y - 1);
res_x  = field_geo.x_resol;
res_y  = field_geo.y_resol;
mid_W  = 1/2 * field_geo.W;
mid_H  = 1/2 * field_geo.H;
epsilon = 1e-12;


% Loop over the indices of the HOC field
for iy = 1:res_y
    for ix = 1:res_x
        % Determine position
        x = (ix - 1) * step_x - mid_W;
        y = (iy - 1) * step_y - mid_H;
        v = y + image_y_shift;
        v = extrapolate_outside_sdm_field(v, hoc_field, epsilon);

        % Calculate the weigths
        [round_down, round_up, wd, wu] = calculate_weigths_local(v, step_Y, epsilon);
        
        % Convert to index in SW layout
        index_down = (round_down + (hoc_field.size_y + 1)/2 - 1) * res_x + ix;
        index_up   = (round_up + (hoc_field.size_y + 1)/2 - 1) * res_x + ix;
        
        check_index_range(index_down, range)
        check_index_range(index_up, range)

        index = (iy - 1) * res_x + ix;
        
        % Calculate dx and dy 
        for i =1:length(hoc_field.disto)
            dx(i) = (wu * hoc_field.disto(i).x(index_up) + wd * hoc_field.disto(i).x(index_down));
            dy(i) = (wu * hoc_field.disto(i).y(index_up) + wd * hoc_field.disto(i).y(index_down));
            ml_y_resample.layer.wr(i).dx(index) = dx(i);
            ml_y_resample.layer.wr(i).dy(index) = dy(i);
        end
        
        % Insert the data
        
        ml_y_resample.wd.xf(index)       = x;
        ml_y_resample.wd.yf(index)       = y;
        ml_y_resample.wd.xw(index)       = ml_y_resample.wd.xf(index);
        ml_y_resample.wd.yw(index)       = ml_y_resample.wd.yf(index);
        ml_y_resample.nwafer = numel(hoc_field.disto);

 
    end
end
        ml_y_resample.nmark = numel(ml_y_resample.layer.wr.dy);
end

function ml_sw = ml2SWLayout_local(ml)

ml_sw = ml;

x = unique(ml.wd.xf);
y = unique(ml.wd.yf);
l = length(x);

for iy = 1:length(y)
    for ix = 1:l
        if mod(iy,2) == 0         
            index_1 = l*(iy - 1) + ix;
            index_2 = l*(iy - 1) + (13 - ix + 1);         
            ml_sw.wd.xf(index_1) = ml.wd.xf(index_2);
            ml_sw.wd.yf(index_1) = ml.wd.yf(index_2);
            ml_sw.wd.xw(index_1) = ml.wd.xw(index_2);
            ml_sw.wd.yw(index_1) = ml.wd.yw(index_2);
            for i = 1:ml.nwafer
            ml_sw.layer.wr(i).dx(index_1) = ml.layer.wr(i).dx(index_2);
            ml_sw.layer.wr(i).dy(index_1) = ml.layer.wr(i).dy(index_2); 
            end
        end
    end
end

end


function [round_down, round_up, wd, wu] = calculate_weigths_local(v, step_Y, epsilon)

% Constants
alpha = (v/step_Y);
beta  = floor(alpha);
gamma = (epsilon/step_Y);

% Compare delta to epsilon
if (alpha - beta) <= gamma 
    % Close enough to round down, take value of round_down.
    round_down = beta;
    round_up   = round_down;
    wd         = 1;
    wu         = 0;
elseif ((1 + beta) - alpha) <= gamma 
    % Close enough to round up, take value of round_up.
    round_down = beta + 1;
    round_up   = round_down;
    wd         = 0;
    wu         = 1;
else
    % Calculate weigths.
    round_down = beta;
    round_up   = round_down + 1;
    wu         = (v - round_down * step_Y)/step_Y;
    wd         = (round_up * step_Y - v)/step_Y;

end

end


function v = extrapolate_outside_sdm_field(v, hoc_field, epsilon)
% In order to keep the calculation of the indices and weights easy, we
% manipulate the "v" coordinate instead.
% If the HOC field covers the full field, then this function has no effect.

full_field_y_dimension = 33e-3;

bottom_edge_of_full_field = -full_field_y_dimension / 2;
bottom_edge_of_sdm_field = -hoc_field.H / 2;
if (v > bottom_edge_of_full_field - epsilon) && (v < bottom_edge_of_sdm_field)
    v = bottom_edge_of_sdm_field;
end

top_edge_of_full_field = +full_field_y_dimension / 2;
top_edge_of_sdm_field = +hoc_field.H / 2;
if (v > top_edge_of_sdm_field) && (v < top_edge_of_full_field + epsilon)
    v = top_edge_of_sdm_field;
end

end

function check_index_range(index, range)
if index > range(2) || index < range(1)
    error('Indexes of resampled SDM disto is out of range.')
end
end


