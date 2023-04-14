function chuck_usage = bmmo_determine_chuck_usage(mli)
%function chuck_usage = bmmo_determine_chuck_usage(mli)
%
% This function will determine the chuck usage from an mli.info.F.chuck_id
% and mli.info.F.chuck_operation
%
% Input :
% mli    :   ml struct with the necessary fields in mli.info
%
% Ouput :
% chuck_usage.chuck_id_used: chucks in use
% chuck_usage.chuck_id:      chuck each wafer was exposed on, in the wafer exposed order

chuck_usage.nr_chuck_used = 1;
if strcmp(mli.info.F.chuck_operation,'USE_BOTH_CHUCK')
    chuck_usage.nr_chuck_used = 2;
end
chuck_usage.chuck_id = zeros(mli.nwafer,1);
for iwafer = 1:mli.nwafer
    switch(mli.info.F.chuck_id{iwafer})
        case 'CHUCK_ID_1'
            chuck_usage.chuck_id(iwafer) = 1;
        case 'CHUCK_ID_2'
            chuck_usage.chuck_id(iwafer) = 2;
        otherwise
            error('No chuck id exists.: sub_determine_chuck_usage');
    end
end

chuck_usage = bmmo_get_chuck_id_used(chuck_usage);