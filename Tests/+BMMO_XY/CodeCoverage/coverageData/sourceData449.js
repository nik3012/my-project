var sourceData449 = {"FileContents":["function [wid,aux, hash] = bmmo_get_wid(mli)\r","% function [wid,aux, hash] = bmmo_get_wid(mli)\r","%\r","% Given an mli struct encoding wafer IDs, and a wafer number, return the\r","% encoded wafer ID\r","%\r","% Input: mli: ml struct with wafer ID encoding\r","%\r","% Output: wid: wafer id (cell array of strings)\r","%   aux: aux data for wafer\r","%   hash: hash wid readout for wafer\r","%\r","%\r","% See D000110254 for a description of the encoding\r","%\r","% 20160407 SBPR modified from ovl_get_wid\r","\r","% conversion char,bit-array to decimal array and back, with symbols of 2^m\r","bit2num = @(x,m) arrayfun(@(i) bin2dec(x(i+(0:(m-1)))),1:m:length(x));\r","num2bit = @(x,m) strjoin(arrayfun(@(i) dec2bin(x(i),m),1:length(x),'un',0),'');\r","bit_locations.ecc1 =    [41:44 57:60 73:76 89:92 105:108 121:124];\r","bit_locations.ecc2 =    [137:140 153:156];\r","bit_locations.ecc3 =     177:184;\r","bit_locations.wid =     [29:40 45:56 61:72 77:88 93:104 109:120 125:136 141:152];\r","bit_locations.aux =     [1:28 157:176];\r","\r","nwafer = mli.nwafer;\r","for iw = 1:nwafer\r","\r","    %shifts = mli.layer(1).wr(wafer).dx(2:2:end);\r","    \r","    [sorted_x, in_x] = sort(mli.wd.xw*1e3, 1, 'ascend');\r","    shifts = mli.layer(1).wr(iw).dx(~isnan(mli.layer(1).wr(iw).dx));\r","    shifts = shifts(in_x);\r","    \r","    % check using first mark if it concerns a yield star readout\r","%     [dist2] = min(sqrt((mli.wd.xw-1e-3.*xw(1)).^2 + (mli.wd.yw-1e-3.*yw(1)).^2));\r","%     if dist2 < 1e-5, % if no mark than it must be a twinscan readout and marks are shifted:\r","%     else\r","%         yw = yw + 40e-3; % shifts marks to match awe mark positions i.s.o. ys mark positions\r","%         xw = xw + 180e-3;\r","%     end\r","    \r","    num_out = zeros(1,length(shifts));\r","    num_nok  = zeros(1,length(shifts));\r","    for i = 1:length(shifts),\r","%         tol = 7;\r","%         if abs(1e9.*shifts(i)       - (-30)) < tol,\r","%             num_out(i) = 0;\r","% \r","%         elseif abs(1e9.*shifts(i)   - (-10)) < tol,\r","%             num_out(i) = 1;\r","% \r","%         elseif abs(1e9.*shifts(i)   - ( 10)) < tol,\r","%             num_out(i) = 2;\r","% \r","%         elseif abs(1e9.*shifts(i)   - ( 30)) < tol,\r","%             num_out(i) = 3;            \r","%         else\r","%             num_nok(i) = 3;\r","%         end\r","          num_out(i) = round((1e9.*shifts(i)+30)/20); \r","          if num_out(i)<0\r","              num_out(i) = 0;\r","          elseif num_out(i)>3\r","              num_out(i) = 3;\r","          end\r","    end\r","\r","    bit_out = num2bit(num_out,2);\r","%     bit_nok = num2bit(num_nok,2);\r","\r","    for fname = fieldnames(bit_locations)',\r","        bit_result.(fname{1})       = bit_out(bit_locations.(fname{1}));\r","        %bit_result_nok.(fname{1})   = bit_nok(bit_locations.(fname{1}));\r","    end\r","\r","    bit_result_corr = bit_result;\r","\r","    wid_num = bit2num(bit_result_corr.wid, 8);\r","    wid{iw} = char(wid_num(wid_num ~= 0));\r","    aux{iw} = bit_result_corr.aux;\r","\r","    hash_num = bit2num(bit_result_corr.ecc1, 4);\r","    num2hash = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};\r","    hash{iw} = strjoin(num2hash(hash_num+1),'');\r","\r","    \r","    \r","end"],"CoverageData":{"CoveredLineNumbers":[19,20,21,22,23,24,25,27,28,32,33,34,44,45,46,62,63,65,70,73,74,78,80,81,82,84,85,86],"UnhitLineNumbers":[64,66],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,4,4,4,4,4,0,4,4,0,0,0,16,16,16,0,0,0,0,0,0,0,0,0,16,16,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1472,1472,0,1472,0,0,0,0,16,0,0,16,80,0,0,0,16,0,16,16,16,0,16,16,16,0,0,0,0]}}