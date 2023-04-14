function kmatrix  = bmmo_pars_to_k_factor_matrix(pars, nmark, nfield)
% function kmatrix  = bmmo_pars_to_k_factor_matrix(pars, nmark, nfield)
%
% Generate a correctly-scaled 18 * (nmark * nfield) K-factor matrix
% from the input 18par 1 * nfield structure
%
% Input: 
%        pars: 1 * nfield ( or nfield * 1) 18 par structure with fields
%              as defined in EDS D000323756/D000810611
%        nfield: number of fields for which there are k-factors
%        nmark: number of marks per field
%
% Output: 
%        Kmatrix: 18 * (nmark * nfield) K-factor matrix

% Scaling factors
NM = 1;
UM = 1;
NM_CM2 = 1;
NM_CM3 = 1;

% Template output matrix column with scaling factors
%      K1 K2 K3 K4 K5 K6 K7     K8     K9     K10    K11    K12    K14    K15    K16    K17    K18    K19   
col = [NM NM UM UM UM UM NM_CM2 NM_CM2 NM_CM2 NM_CM2 NM_CM2 NM_CM2 NM_CM3 NM_CM3 NM_CM3 NM_CM3 NM_CM3 NM_CM3]';

% Tile the column to the size of the output matrix
kmatrix = repmat(col, 1, nfield);

knames = fieldnames(pars(1));
numk = length(knames);

% Generate a K-factor matrix for all fields in this wafer 
for ik = 1:numk
   kmatrix(ik, :) = kmatrix(ik,:) .* [pars(1:nfield).(knames{ik})];
end

% replace rows 3-6
k3 = kmatrix(3, :) + kmatrix(4,:); % K3 = ms + ma;
k4 = kmatrix(3, :) - kmatrix(4,:); % K4 = ms - ma;
k5 = -kmatrix(5,:) - kmatrix(6,:); % K5 = -rs - ra;
k6 = kmatrix(5,:) - kmatrix(6,:);  % K6 = rs - ra;


kmatrix(3,:) = k3;
kmatrix(4,:) = k4;
kmatrix(5,:) = k5;
kmatrix(6,:) = k6;

% tile to nmark size
kmatrix = repmat(kmatrix, nmark, 1);

% reshape to put marks per field in columns
kmatrix = reshape(kmatrix, numk, []);

