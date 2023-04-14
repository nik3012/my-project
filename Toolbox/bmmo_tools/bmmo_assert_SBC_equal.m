function bmmo_assert_SBC_equal(sbc_struct1, sbc_struct2, out_file, ADEL_prec, tol, show_NOKs)
% function bmmo_assert_SBC_equal(sbc_struct1, sbc_struct2, out_file, ADEL_prec, tol, show_NOKs)
%
% Assert MATLAB and LIS SBCs as per the given spec
%
% Inputs:
% sbc_struct1 : out.corr, output of bmmo_nxe_drift_control_model 
% sbc_struct2 : LIS/OTAS SBC recipe parsed using bmmo_kt_process_SBC2
%
%
% Optional input:
% outfile: filename to output the assertion results,
% eg: 'output.txt' or provide outfile = stdout for printing to command line
% ADEL_prec, change precision of sbc_strcut as per ADEL schema, default is 1
% tol: tolerance for assertion of SBCs, default: 5e-13
% show_NOKs: List only NOKs from assertion if set to 1, default is 0
%
%20210107 ANBZ Creation

prev_state = warning('query', 'backtrace');
warning('backtrace', 'off');

title = 'sbc_struct 1 vs sbc_struct 2';

if nargin < 3
    outfile = stdout;
else
    if ischar(out_file)
        outfile = fopen(out_file, 'w');
        if contains(out_file, 'MATLABvsLIS')
            title = 'MATLAB vs LIS';
        end
    else
        outfile = out_file;
    end
end

if nargin < 4
    ADEL_prec = 1;
end

if nargin < 5
    tol = 5e-13;
end

if nargin < 6
    show_NOKs = 0;
end

% SBC
fprintf(outfile,['SBCs: ', title,'\n\n']);

if ADEL_prec == 1
    sbc_struct1 = bmmo_convert_SBC_to_ADELprecision(sbc_struct1);
else
    sbc_struct1 = sub_remove_config(sbc_struct1);
    sbc_struct2 = sub_remove_config(sbc_struct2);
end

if length(sbc_struct1.KA.grid_2de(1).dx) == length(sbc_struct2.KA.grid_2de(1).dx)
    [sbc_struct1.KA, sbc_struct2.KA] = sub_check_valids(sbc_struct1.KA, sbc_struct2.KA, outfile);
end

fprintf(outfile, [' (Delta expected to be less than : ' ,num2str(tol), ')\n']);
sub_assertion(sbc_struct1, sbc_struct2, outfile, tol, show_NOKs)

fclose('all');
warning(prev_state);
end



% SUB FUNCTIONS
function sub_warning(message, outfile)

if outfile == 1 %stdout case
    warning(message)
else % filename char case
    warning(message)
    fprintf(outfile, ['WARNING:', message,'\n']);
end
end


function sub_assertion(sbc1, sbc2, outfile, delta, show_NOKs)

try
    bmmo_assert_equal(sbc1, sbc2, delta, outfile, show_NOKs);
catch ME
    if strcmp(ME.identifier,'MATLAB:assertion:failed')
        sub_warning( 'Assertion Failed! Check the NOKs.', outfile);
    else
        rethrow(ME)
    end
end

end

function sbc = sub_remove_config(sbc)
if isfield(sbc,'Configurations')
    sbc = rmfield(sbc,'Configurations');
end
end

function [KA1, KA2] = sub_check_valids(KA1, KA2, outfile)

if isfield(KA1, 'grid_2dc')
    fdname = {'grid_2de', 'grid_2dc'};
else
    fdname = {'grid_2de'};
end

for ii =1:length(fdname)
    
    for i = 1:length(KA1.(fdname{ii}))
        dx1_valids(i) = sum(~isnan(KA1.(fdname{ii})(i).dx));
        dy1_valids(i) = sum(~isnan(KA1.(fdname{ii})(i).dy));
        dx2_valids(i) = sum(~isnan(KA2.(fdname{ii})(i).dx));
        dy2_valids(i) = sum(~isnan(KA2.(fdname{ii})(i).dy));
    end
    
    if ~isequal(dx1_valids(1), dy1_valids(1), dx2_valids(1), dy2_valids(1))
        
        sub_warning([(fdname{ii}) ' :sbc_struct1 and sbc_struct2 have different number of valids, choosing common marks for assertion'], outfile)
        
        fprintf(outfile, [fdname{ii},'             Ch1 dx  Ch1 dy  Ch2 dx  Ch2 dy\n']);
        fprintf(outfile, ['sbc_struct1 valids : ',num2str([dx1_valids(1), dy1_valids(1), dx1_valids(2), dy1_valids(2)]),'\n']);
        fprintf(outfile, ['sbc_struct2 valids : ',num2str([dx2_valids(1), dy2_valids(1), dx2_valids(2), dy2_valids(2)]),'\n\n']);
        
        if isequal(dx1_valids(1), dy1_valids(1)) && isequal(dx2_valids(1), dy2_valids(1))
            
            if dx1_valids(1) < dx2_valids(2)
                
                for i =1:length(KA1.(fdname{ii}))% KA1 lowest valids case
                    KA2.(fdname{ii})(i).dx = KA1.(fdname{ii})(i).dx*0 + KA2.(fdname{ii})(i).dx;
                    KA2.(fdname{ii})(i).dy = KA1.(fdname{ii})(i).dy*0 + KA2.(fdname{ii})(i).dy;
                end
                
            else
                
                for i =1:length(KA1.(fdname{ii}))% KA2 lowest valids case
                    KA1.(fdname{ii})(i).dx = KA2.(fdname{ii})(i).dx*0 + KA1.(fdname{ii})(i).dx;
                    KA1.(fdname{ii})(i).dy = KA2.(fdname{ii})(i).dy*0 + KA1.(fdname{ii})(i).dy;
                end
            end
            
        else
            error('Number of valids for dx and dy are different')
            
        end
        
    end
    
end

end


