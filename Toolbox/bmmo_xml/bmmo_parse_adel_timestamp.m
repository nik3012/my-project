function dt = bmmo_parse_adel_timestamp(ts)
% function dt = bmmo_parse_adel_timestamp(ts)
%
% Return Matlab datetime from ADEL timestamp string
%
% Input:
%   ts: timestamp in ADEL format
%
% Output: 
%   dt: Matlab datetime parsed from ADEL file
%
% 20170131 SBPR Creation

ADELformat1 = 'yyyy-MM-dd''T''HH:mm:ssZZZZZ';
ADELformat2 = 'yyyy-MM-dd''T''HH:mm:ss.SSZZZZZ';
ADELformat3 = 'yyyy-MM-dd''T''HH:mm:ss';

try
    dt = datetime(ts, 'TimeZone', 'local', 'InputFormat', ADELformat1);
catch
    try
        dt = datetime(ts, 'TimeZone', 'local', 'InputFormat', ADELformat2);
    catch
        dt = datetime(ts, 'TimeZone', 'local', 'InputFormat', ADELformat3);
    end
end