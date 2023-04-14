function [coefficients, fps_fit, ml_res] = bmmo_fit_fingerprints(ml_ch, fps, options, C)
% function [coefficients, fps_fit, ml_res] = bmmo_fit_fingerprints(ml_ch, fps, options, C)
%
% This function fits the input struct to fps and returns the fit
% coefficients, residue after fitting and fitted fingerprints.
%
% Input :
% ml_ch: input structure, averaged per chuck
% fps : Fingerprints as a 1 * n cell array containing different mls each describing
% a fingerprint fps{1} = ml_fp1; fps{2} = ml_fp2; etc.
% options: BMMO/BL3 options structure
% C: Constraints matrix
% Note that ml_ch and fps should have the same layout.
%
% Output :
% coefficients : fit coefficients per chuck (2 * n cell array)
% fps_fit : fitted fingerprints per chuck (2 * n cell array)
% ml_res: residual, per chuck
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model
%
% Construct the design matrix from the FPS. The structure for two chucks is
% as follows:
%
%       W +++++++++++++++++++++++
%       H +          +          +
%       F +          +          +
%       P +  OTHER   +          +
%         +          +  ZEROS   +
%       C + FPS (CH1)+          +
%       H +          +          +
%       1 +          +          +
%       ------------------------+
%       W +          +          +
%       H +          +          +
%       F +          +  OTHER   +
%       P +  ZEROS   +          +
%         +          + FPS (CH2)+
%       C +          +          +
%       H +          +          +
%       2 +++++++++++++++++++++++
%
% For one chuck,
%
%         ++++++++++++
%         +          +
%         +          +
%       W +  OTHER   +
%       H +          +
%       F +   FPS    +
%       P +          +
%         +          +
%         ++++++++++++

fn = fieldnames(fps);
num_fps = length(fn);
% for KA sub model grid to test out fine
if size(fps,2) == 1
    fps(2).KA = [];
end
if options.chuck_usage.nr_chuck_used == 2
    for i = 1:num_fps
        if ~length(fps(2).(fn{i})) > 0
            fps(2).(fn{i})= fps(1).(fn{i});
        end
    end
    fps_c1 = fps_to_mat(fps(1),fn);
    ml_c = sub_make_columns(ml_ch(1));
    
    C_full = zeros(0, size(fps_c1,2)*options.chuck_usage.nr_chuck_used);
    
elseif  options.chuck_usage.chuck_id_used == 2
    for i = 1:num_fps
        if ~length(fps(2).(fn{i}))>0         
            fps(2).(fn{i})= fps(1).(fn{i});
        end
    end
end

% design matrix
if options.chuck_usage.nr_chuck_used == 1
    chuck_id = options.chuck_usage.chuck_id_used;
    fps_c1 = fps_to_mat(fps(chuck_id),fn);
    ml_c = sub_make_columns(ml_ch(chuck_id));
    fps_DM = fps_c1;
    C_full = zeros(0, size(fps_c1,2)*options.chuck_usage.nr_chuck_used);
elseif ~isfield(fps, 'WH')
    fps_c2 = fps_to_mat(fps(2),fn);
    fps_DM = [fps_c1 zeros(size(fps_c2));zeros(size(fps_c2)) fps_c2];
    ml_c = [ml_c ;sub_make_columns(ml_ch(2))];
elseif isfield(fps, 'WH')
    fps_c2=fps_to_mat(fps(2),fn);
    fpsWH_c2 = fps_c2(:,1);
    fps_c2(:,1) = [];
    fps_DM = [fps_c1 zeros(size(fps_c2)); fpsWH_c2 zeros(size(fps_c2)) fps_c2];
    ml_c = [ml_c ;sub_make_columns(ml_ch(2))];
    C_full = C_full(:,1:end-1);
end

mes_DM = size(fps_DM,1);

% no. of columns  of each fps
fps_col=zeros(1,num_fps);
for i = 1:num_fps
    fps_col(i)= size(fps(1).(fn{i}), 2);
end

if options.chuck_usage.nr_chuck_used == 1
    chuckid=options.chuck_usage.chuck_id_used;
    fps_index(chuckid)= indexing_fps(fn,fps_col);
    C_full = C_full_fun(C,C_full,fn,fps_index,chuckid); 
end

if options.chuck_usage.nr_chuck_used == 2
    fps_index= indexing_fps(fn,fps_col);
    fps_index_temp = structfun(@(x) x + size(fps_c2,2), fps_index, 'UniformOutput', false);
    fps_index(2) = fps_index_temp;
    if isfield(fps, 'WH')
        fps_index(2).WH = 1;
    end 
    C_full = C_full_fun(C,C_full,fn,fps_index,[1,2]);
end

% remove NaNs, else pinv --> error
rem1 = isnan(ml_c);
rem2 = any(isnan(fps_DM), 2); % true for any row which contains a NaN
rem = rem1 | rem2;
ml_c(rem) = [];
fps_DM(rem,:) = [];

T=null(C_full);

if isempty(C)
    temp = pinv(fps_DM);     % (pseudo)inverse of matrix
    coeff = temp * ml_c;    % get coefficients
else
    %   p = T t = T (M T)^(-p) v
    temp = pinv(fps_DM*T);
    coeff = T*temp*ml_c;
end

% fill output per chuck (ml_res- if requested)
if(nargout > 2)
    ml_res = ml_ch; %intializing
    fp = fps_DM * coeff;
    res = ml_c - fp;
    resdata = zeros(mes_DM, 1) * NaN;
    resdata(~rem) = res;
    
    if options.chuck_usage.nr_chuck_used == 1
        chuck_id = options.chuck_usage.chuck_id_used;
        ml_res(chuck_id).layer.wr.dx = resdata(1:(mes_DM/2));
        ml_res(chuck_id).layer.wr.dy = resdata(((mes_DM/2)+1):mes_DM);
    elseif  options.chuck_usage.nr_chuck_used == 2
        Ni = 1;
        for chuck_id = 1:2      
            ml_res(chuck_id).layer.wr.dx = resdata(Ni:(mes_DM/4) + Ni-1);
            ml_res(chuck_id).layer.wr.dy = resdata((((mes_DM/4) + Ni):mes_DM/2 + Ni-1));
            Ni = mes_DM/2+1;
        end
    end
end

% fill output per chuck (coefficients and fps_fit)
for chuck_id = options.chuck_usage.chuck_id_used
    for i = 1:length(fn)
        coefficients.(fn{i})(chuck_id) = {coeff(fps_index(chuck_id).(fn{i}))};
        fps_fit.(fn{i})(chuck_id) = sub_make_ml(ml_ch(chuck_id), fps(chuck_id).(fn{i}), coefficients.(fn{i})(chuck_id));
    end
end


%sub functions
function mat= fps_to_mat(fps_struct,fn)
mat=[];
for i = 1:length(fn)    
    mat=[mat fps_struct.(fn{i})];
end


function o = sub_make_columns(mli)
o = [mli.layer.wr.dx ; mli.layer.wr.dy];


function mlo = sub_make_ml(mlt, fps, coeff)
mlo = mlt;
fps_col = fps*coeff{:};
dx_last = length(fps_col)/2;
mlo.layer.wr.dx = fps_col(1:dx_last);
mlo.layer.wr.dy = fps_col((dx_last + 1):end);


function fps_index=indexing_fps(fn,fps_col)
current_index=1;
for i = 1:length(fn)
    new_index = current_index  + fps_col(i) - 1;
    fps_index.(fn{i}) = current_index:new_index;
    current_index = new_index + 1;
end


function C_full = C_full_fun(C,C_full,fn,fps_index,ii)
for nr_chuck= ii
    for i = 1:length(fn)
        if isfield(C, fn{i})
            C_full(end + (1:size(C.(fn{i}), 1)), fps_index(nr_chuck).(fn{i})) = C.(fn{i});
        end
    end
end
