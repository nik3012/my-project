function averageFingerPrint = getAverageFingerPrintsFromGroupedFingerPrints(cellOfFingerPrints, location, amount)
% averageFingerPrint = getAverageFingerPrintsFromGroupedFingerPrints(cellOfFingerPrints, location, amount)
%
% Function to get the average fingerprint from a set of
% fingerprints. The selection is either starting from the first ("start")
% or the last ("end") dataset and contains 'amount' number of sets selected
% in a linear order.
%
% Input arguments:
% -cellOfFingerPrints    [ cell array of structs ]  Cell containing the
%                                                       field fingerprints of the jobs.
%                                                       The ffps can be extracted using the function extractArrayFromStruct.m
% -location              [ string ]                 String specifying whether the data selection starts 
%                                                       from the first wafer ("start") or ends at
%                                                       the last ("end") wafer
% -amount                [ double ]                 Specifies the amount of
%                                                       wafers in the set
% Output arguments:
% - averageFingerPrint   [ struct ]                 Struct containing the
%                                                       average field fingerprint of the selected data sets
%

if string(location) ~= "start" && string(location) ~= "end"
    error('Input argument "location" can only be "start" or "end"');
end

selection = num2cell(cellOfFingerPrints{1});
slice     = getSliceFromLocationAndAmount(location, amount, length(selection));
try
    averageFingerPrint = ovl_combine_wafers(selection{slice});
catch
    averageFingerPrint = ovl_combine_wafers(selection{:});
end

for index = 2 : length(cellOfFingerPrints)    
    selection = num2cell(cellOfFingerPrints{index});
    slice     = getSliceFromLocationAndAmount(location, amount, length(selection));
    try
        averageFingerPrint = ovl_combine_wafers(averageFingerPrint, selection{slice});
    catch
        averageFingerPrint = ovl_combine_wafers(averageFingerPrint, selection{:});
    end
end

averageFingerPrint = ovl_average(averageFingerPrint);

end


function slice = getSliceFromLocationAndAmount(location, amount, nrOfWafers)

if string(location) == "start"
    sliceStart = 1;
    sliceEnd   = amount;
else
    sliceStart = nrOfWafers - amount + 1;
    sliceEnd   = nrOfWafers;
end

slice = sliceStart : sliceEnd;

end