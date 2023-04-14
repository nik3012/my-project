function FP_KA = bmmo_construct_FPS_KA(ml, options)
%function FP_KA = bmmo_construct_FPS_KA(ml, options)
%
% The function generates the raw KA fingerprint for the combined model
%
% Input: 
%  ml: input ml structure
%  options: structure containing the fields 
%           KA_orders: KA orders
%           scaling_factor: scaling factor
% 
% Output: 
%  FP_KA: KA fingerprint (1xN cell array of ml structs}

dummy = ml;

% length_KA: the number of KA columns in the design matrix
length_KA = (sum(options.KA_orders)) * 2;
FP_KA = cell(1, length_KA);

% The first length_KA/2 columns are for dx; the next are for dy
ka_x_index = 1;
ka_y_index = 1 + (length_KA / 2);

% For each KA order
for i_order = options.KA_orders
    
    ka_mat = bmmo_get_ka_matrix(dummy, i_order);
    
    % generate x fingerprints for this order
    % select only exponent terms valid for x
    % we don't want the last  term; this is purely a polynomial of
    % y
    for i_exp = 1:(i_order)
        
        tmp = dummy;
        tmp.layer.wr.dx = ka_mat(:, i_exp); 

        FP_KA{ka_x_index} = ovl_combine_linear(tmp, 1/options.scaling_factor);
        ka_x_index = ka_x_index + 1;
    end
    
    % generate y fingerprints for this order
    % select only i_exp terms valid for y
    % we don't want the first i_exp term; this is purely a polynomial of
    % x
    for i_exp = 2:(i_order + 1)
        
        tmp = dummy;
        tmp.layer.wr.dy = ka_mat(:, i_exp); 

        FP_KA{ka_y_index} = ovl_combine_linear(tmp, 1/options.scaling_factor);
        ka_y_index = ka_y_index + 1;
    end
end
   