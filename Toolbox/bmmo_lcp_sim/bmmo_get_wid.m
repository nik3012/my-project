function [wid,aux, hash] = bmmo_get_wid(mli)
% function [wid,aux, hash] = bmmo_get_wid(mli)
%
% Given an mli struct encoding wafer IDs, and a wafer number, return the
% encoded wafer ID
%
% Input: mli: ml struct with wafer ID encoding
%
% Output: wid: wafer id (cell array of strings)
%   aux: aux data for wafer
%   hash: hash wid readout for wafer
%
%
% See D000110254 for a description of the encoding
%
% 20160407 SBPR modified from ovl_get_wid

% conversion char,bit-array to decimal array and back, with symbols of 2^m
bit2num = @(x,m) arrayfun(@(i) bin2dec(x(i+(0:(m-1)))),1:m:length(x));
num2bit = @(x,m) strjoin(arrayfun(@(i) dec2bin(x(i),m),1:length(x),'un',0),'');
bit_locations.ecc1 =    [41:44 57:60 73:76 89:92 105:108 121:124];
bit_locations.ecc2 =    [137:140 153:156];
bit_locations.ecc3 =     177:184;
bit_locations.wid =     [29:40 45:56 61:72 77:88 93:104 109:120 125:136 141:152];
bit_locations.aux =     [1:28 157:176];

nwafer = mli.nwafer;
for iw = 1:nwafer

    %shifts = mli.layer(1).wr(wafer).dx(2:2:end);
    
    [sorted_x, in_x] = sort(mli.wd.xw*1e3, 1, 'ascend');
    shifts = mli.layer(1).wr(iw).dx(~isnan(mli.layer(1).wr(iw).dx));
    shifts = shifts(in_x);
    
    % check using first mark if it concerns a yield star readout
%     [dist2] = min(sqrt((mli.wd.xw-1e-3.*xw(1)).^2 + (mli.wd.yw-1e-3.*yw(1)).^2));
%     if dist2 < 1e-5, % if no mark than it must be a twinscan readout and marks are shifted:
%     else
%         yw = yw + 40e-3; % shifts marks to match awe mark positions i.s.o. ys mark positions
%         xw = xw + 180e-3;
%     end
    
    num_out = zeros(1,length(shifts));
    num_nok  = zeros(1,length(shifts));
    for i = 1:length(shifts),
%         tol = 7;
%         if abs(1e9.*shifts(i)       - (-30)) < tol,
%             num_out(i) = 0;
% 
%         elseif abs(1e9.*shifts(i)   - (-10)) < tol,
%             num_out(i) = 1;
% 
%         elseif abs(1e9.*shifts(i)   - ( 10)) < tol,
%             num_out(i) = 2;
% 
%         elseif abs(1e9.*shifts(i)   - ( 30)) < tol,
%             num_out(i) = 3;            
%         else
%             num_nok(i) = 3;
%         end
          num_out(i) = round((1e9.*shifts(i)+30)/20); 
          if num_out(i)<0
              num_out(i) = 0;
          elseif num_out(i)>3
              num_out(i) = 3;
          end
    end

    bit_out = num2bit(num_out,2);
%     bit_nok = num2bit(num_nok,2);

    for fname = fieldnames(bit_locations)',
        bit_result.(fname{1})       = bit_out(bit_locations.(fname{1}));
        %bit_result_nok.(fname{1})   = bit_nok(bit_locations.(fname{1}));
    end

    bit_result_corr = bit_result;

    wid_num = bit2num(bit_result_corr.wid, 8);
    wid{iw} = char(wid_num(wid_num ~= 0));
    aux{iw} = bit_result_corr.aux;

    hash_num = bit2num(bit_result_corr.ecc1, 4);
    num2hash = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
    hash{iw} = strjoin(num2hash(hash_num+1),'');

    
    
end