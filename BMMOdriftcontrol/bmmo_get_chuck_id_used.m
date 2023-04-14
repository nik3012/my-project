function chuck_usage = bmmo_get_chuck_id_used(chuck_usage)

% make sure chuck_id_used is sorted in the original order
[~, index] = unique(chuck_usage.chuck_id);
unique_chucks = chuck_usage.chuck_id(sort(index));

chuck_usage.chuck_id_used = reshape(unique_chucks, 1, []); % for R13 compatibility, ensure this is a horizontal array
chuck_usage.chuck_id = reshape(chuck_usage.chuck_id, 1, []);