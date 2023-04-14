function [B,C] = bmmo_interp_nans(A,X,Y, nb, step, max_loop_in)
%function [B,C] = bmmo_interp_nans(A,X,Y, nb, step, max_loop_in)
%
% This function interpolates the values of the NaNs in an input matrix
%
% Input:
%     A: wafer map (2d matrix)
%     X: vector of unique values in xw, used to calculate weights
%     Y: vector of unique values in yw
%
% Optional Input:
%     nb: optional neighbourhood type for interpolation algorithm
%         possible values are as follows:
%             'updown': look for neighbours in adjacent horizontal and vertical positions
%             'diagonal': same as updown, plus adjacent diagonal positions
%               (consumes more memory, slightly slower)
%     step: boolean 1 if nans with more non-nan neighbours are to be filled in
%           first. Can be faster for input matrices with lots of NaNs.
%     max_loop_in: maximum number of loops over which to iterate
%
%  Output:
%     B: interpolated wafer map with Nans replaced by interpolated values
%     C: logical map of interpolation marks in B

MAX_LOOP = 301; % quit the while loop (with an error) if this number of loop iterations is exceeded
MAX_WEIGHT = 1e4; % arbitrary large weight to replace infinity values



B = A; %First copy matrix
C = isnan(A); %logical index of interpolation marks; initialised to all NaNs

if nargin > 3
    nb_type = nb;
else
    nb_type = 'updown';
end

if nargin > 4
    use_step = step;
else
    use_step = 0;
end

if nargin > 5
    max_loop = max_loop_in;
    if max_loop < 1
        max_loop = 1;
    elseif max_loop > MAX_LOOP
        max_loop = MAX_LOOP;
    end
else
    max_loop = MAX_LOOP;
end

%check if matrix has only zeros and nans; if so, just return a matrix of
%zeros
if ~any(A(~C))
    B = zeros(size(A));
else
    %Make meshgrid X&Y
    [Xi,Yi] = meshgrid(X,Y);
    
    % ensure X and Y are vertical
    X = reshape(X, [], 1);
    Y = reshape(Y, [], 1);
    
    % make some vertical, horizontal weight matrices
    [xg_l, yg_u] = meshgrid([nan; X(1:end-1)], [nan; Y(1:end-1)]);
    [xg_r, yg_d] = meshgrid([X(2:end); nan], [Y(2:end); nan] );
    xg_l = abs(Xi - xg_l);
    xg_r = abs(Xi - xg_r);
    yg_u = abs(Yi - yg_u);
    yg_d = abs(Yi - yg_d);
    
    % make diagonal weight matrices too, if nb_type is diagonal
    if strcmp(nb_type, 'diagonal')
        g_lu = 1 ./ sqrt(xg_l .^2 + yg_u .^2);
        g_ru = 1 ./ sqrt(xg_r .^2 + yg_u .^2);
        g_ld = 1 ./ sqrt(xg_l .^2 + yg_d .^2);
        g_rd = 1 ./ sqrt(xg_r .^2 + yg_d .^2);
        g_lu(isnan(g_lu)) = 0;
        g_ru(isnan(g_ru)) = 0;
        g_ld(isnan(g_ld)) = 0;
        g_rd(isnan(g_rd)) = 0;
        g_lu(isinf(g_lu)) = MAX_WEIGHT;
        g_ru(isinf(g_ru)) = MAX_WEIGHT;
        g_ld(isinf(g_ld)) = MAX_WEIGHT;
        g_rd(isinf(g_rd)) = MAX_WEIGHT;
    end
    
    xg_l = 1 ./ xg_l;
    xg_r = 1 ./ xg_r;
    yg_u = 1 ./ yg_u;
    yg_d = 1 ./ yg_d;
    xg_l(isnan(xg_l)) = 0;
    xg_r(isnan(xg_r)) = 0;
    yg_u(isnan(yg_u)) = 0;
    yg_d(isnan(yg_d)) = 0;
    xg_l(isinf(xg_l)) = MAX_WEIGHT;
    xg_r(isinf(xg_r)) = MAX_WEIGHT;
    yg_u(isinf(yg_u)) = MAX_WEIGHT;
    yg_d(isinf(yg_d)) = MAX_WEIGHT;
    
    
    % make vertical and horizontal shifted input matrices
    Bl =  [zeros(size(B, 1), 1) *nan , B(:, 1:end-1)];
    Br =  [B(:, 2:end), zeros(size(B, 1), 1) *nan];
    Bu =  [zeros(1, size(B, 2)) *nan ; B(1:end-1, :)];
    Bd =  [B(2:end, :) ; zeros(1, size(B, 2)) *nan ];
    
    % make diagonal shifted input matrices too
    % if nb_type is diagonal
    if strcmp(nb_type, 'diagonal')
        Blu = [zeros(1, size(B, 2)) *nan; Bl(1:end-1, :)];
        Bru = [zeros(1, size(B, 2)) *nan ; Br(1:end-1, :)];
        Bld =  [Bl(2:end, :) ; zeros(1, size(B,2)) *nan];
        Brd =  [Br(2:end, :) ; zeros(1, size(B,2)) *nan];
    end
    
    %This interpolates the nans. It will sweep the wafer several times
    %filling in the nans.
    loop_iter = 0;
    
    while any(any(isnan(B)))
        
        %for each nan point, collect non-nan neighbors
        D = sub_count_nans_in_neighbourhood(B, nb_type);
        C = isnan(B);
        D(~C) = 0;
        maxnrnan = max(D(:));
        
        
        % for points-neighbors entry having max non-nan neighbors,
        % fill in weighted-average of non-nan neighbors
        index = (D == maxnrnan);
        
        if(any(any(index)))
            % sum the weights
            weights = [xg_l(index), xg_r(index), yg_u(index), yg_d(index)];
            buren = [Bl(index), Br(index), Bu(index), Bd(index)];
            if strcmp(nb_type, 'diagonal')
                weights = [weights, g_lu(index), g_ru(index), g_ld(index), g_rd(index)];
                buren = [buren, Blu(index), Bru(index), Bld(index), Brd(index)];
            end
            
            nanburen = isnan(buren);
            valid_rows = ~all(nanburen, 2);
            buren(nanburen) = 0;
            weights(nanburen) = 0;
            
            interp_val = zeros(size(valid_rows)) * nan;
            sumbw = sum((buren .* weights), 2);
            sumw = sum(weights, 2);
            interp_val(valid_rows) = sumbw(valid_rows) ./ sumw(valid_rows);
            
            % set the interpolated values
            B(index) = interp_val;
            
            % rebuild shifted input matrices
            Bl =  [zeros(size(B,1), 1) *nan , B(:, 1:end-1)];
            Br =  [B(:, 2:end), zeros(size(B,1), 1) * nan];
            Bu =  [zeros(1, size(B,2)) *nan ; B(1:end-1, :)];
            Bd =  [B(2:end, :) ; zeros(1, size(B,2)) * nan];
            if strcmp(nb_type, 'diagonal')
                Blu = [zeros(1, size(B,2)) *nan; Bl(1:end-1, :)];
                Bru = [zeros(1, size(B,2)) *nan; Br(1:end-1, :)];
                Bld =  [Bl(2:end, :) ; zeros(1, size(B,2))*nan];
                Brd =  [Br(2:end, :) ; zeros(1, size(B,2))*nan];
            end
        end
    end
    
    loop_iter = loop_iter + 1;
    if(loop_iter >= MAX_LOOP)
        error('bmmo_interp_nans: maximum number of loop iterations exceeded');
    end
end


function [D] = sub_count_nans_in_neighbourhood(B, nb)
% function [D] = sub_count_nans_in_neighbourhood(B, nb)
%
% This function counts the number of NaNs in the specified neighbourhood of each
% element in Matrix B.
%
% Input:
%    B: A 2d matrix, possibly containing NaNs
%
% Optional Input:
%   nb: A neighbourhood function (string)
%       Implemented functions are
%        'updown': count nans in horizontally and vertically adjacent
%                   positions
%        'diagonal': same as above, but also count diagonally adjacent
%                   positions
%
% Output:
%   D: Matrix of same size as B, where
%        D[i,j] == number of NaNs in the neighbourhood of B[i,j]
%
% This works by convolving the function isnan(B) with the specified neighbourhood
% function.
%
C = ~isnan(B);

if nargin == 2
    nb_type = nb;
else
    nb_type = 'updown';
end

%nsew neighbourhood
switch nb_type
    case 'updown'
        neighbourhood = [0 1 0; 1 0 1; 0 1 0];
    case 'diagonal'
        neighbourhood = [1 1 1; 1 0 1; 1 1 1];
    otherwise
        error(['sub_count_nans_in_neighbourhood: unknown neighbourhood type ' nb]);
end

D = conv2(double(C), neighbourhood, 'same');
