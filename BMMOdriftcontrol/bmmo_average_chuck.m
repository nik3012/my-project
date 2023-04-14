function mlo = bmmo_average_chuck(mli, options)
% function mlo = bmmo_average_chuck(mli, options)
%
% Given a ml structure with M wafers, or an M * N overlay matrix,
% return the average overlay values per chuck
%
% Input: 
%   mli: either a structure, or an M * N matrix of overlay values
%   options: structure containing the field chuck_info
%
% Output:
%   mlo: either a 1 * 2 struct array, or 2 * N matrix of overlay
%        values averaged per chuck. If the input is provided as an ml 
%        structure then mlo(1) and mlo(2) represent the wafers averaged for
%        chuck 1 and chuck 2, respectively   

MAX_CHUCK = 2;

% ensure options.chuck_usage.chuck_id is horizontal (for compatibility with
% unit tests)
options.chuck_usage.chuck_id = reshape(options.chuck_usage.chuck_id, 1, []);
options.chuck_usage.chuck_id_used = reshape(options.chuck_usage.chuck_id_used, 1, []);

if isstruct(mli)
    % generate the input matrix from the mli structure; consists of
    % concatenated dx,dy data from the input wafers
    in_matrix = [horzcat(mli.layer.wr.dx); horzcat(mli.layer.wr.dy)];
    mlo = ovl_create_dummy(ovl_get_wafers(mli, 1));
    mlo = repmat(mlo, 1, MAX_CHUCK);
else
    in_matrix = mli;
end

out_matrix = zeros(size(in_matrix, 1), MAX_CHUCK);

% get the average per chuck
for chuck_id = options.chuck_usage.chuck_id_used
    wafer_on_this_chuck = find(options.chuck_usage.chuck_id == chuck_id);

    mean_input = (in_matrix(:, wafer_on_this_chuck)); 
    out_matrix(:, chuck_id) = (nanmean_r12(mean_input,2)); 
end

if isstruct(mli)     
    for chuck_id = options.chuck_usage.chuck_id_used
       tmp = ovl_get_wafers(mli, 1);
       lenx = length(tmp.layer.wr.dx);
       tmp.layer.wr.dx = out_matrix(1:lenx, chuck_id);
       tmp.layer.wr.dy = out_matrix((lenx+1):end, chuck_id);
       mlo(chuck_id) = tmp;
    end
else
    mlo = out_matrix;
end
