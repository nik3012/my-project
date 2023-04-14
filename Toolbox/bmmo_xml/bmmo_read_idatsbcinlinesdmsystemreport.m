function [ml_in, ml_out] = bmmo_read_idatsbcinlinesdmsystemreport(idatsbcinline_filepath, adelexposetraj_filepath)
% function [ml_in, ml_out] = bmmo_read_idatsbcinlinesdmsystemreport(idatsbcinline_filepath, adelexposetraj_filepath)
%
% Given the filepath for IDATsbcInlineSdmSystemReportProtected, the function decrypts and parses to 2 ml-structs.
%
% Input:
%   idatsbcinline_filepath               :    IDATsbcInlineSdmSystemReport(Protected) filepath
%   adelexposetraj_filepath [Optional]   :    ADELexposureTrajectoriesReportProtected
%                                             filepath. Required to obtain y-resampled grid layout.
% Output:
%   ml_in                                :    System part of the inlineSDM corrections from the input SBC recipe. 
%                                             ChuckId is contained in ml_in.info.F.chuck_id
%   ml_out                               :    The model data output. The system corrections provided to CET after 
%                                             applying the inlineSDM model.

% Load and decrypt the IDATsbcInlineSdmSystemReport
parsed_IDAT = bmmo_load_ADEL(idatsbcinline_filepath);

% Check whether only a single image is contained within the IDAT
nr_of_images = length(parsed_IDAT.SystemModelOutput.RequestedScaledCorrections(1).elt.Corrections);
if nr_of_images ~= 1
    error('bmmo_read_idatsbcinlinesdmsystemreport currently only supports single images. The supplied IDAT contains multiple/no images')
else
end

% Check whether an ADELexposureTrajectoriesReportProtected is given.
if nargin == 2
    ADEL_provided = 1;
elseif nargin == 1
    ADEL_provided = 0;
    warning('Only one input given. Assuming 25.4x33.0 mm layout grid. If this is not allowed, provide an ADELexposuretrajectoriesreport')
    x_step_out  = 12;
    x_pitch_out = 2.12;
    x_ini_out   = -12.72;
    y_step_out  = 18;
    y_pitch_out = 11/6;
    y_ini_out   = -16.5;
else
    error('Incorrect number of input arguments. Check the documentation of this function')
end

% Populate metadata.
ml_in.nmark              = length(parsed_IDAT.SystemModelInput.Corrections(1).elt.Offsets);
ml_in.nlayer             = 1;
ml_in.nfield             = length(parsed_IDAT.SystemModelOutput.RequestedScaledCorrections(1).elt.Corrections);
ml_in.nwafer             = length(parsed_IDAT.SystemModelInput.Corrections);
ml_in.info.machine_type  = parsed_IDAT.Header.MachineType;
ml_in.info.MachineID     = parsed_IDAT.Header.MachineID;
ml_in.info.LotStarttime  = parsed_IDAT.DocumentMetaData.LotStartTime;

% Extract the chuckid order and place in info.F.chuck_id
for index = 1 : length(parsed_IDAT.SystemModelInput.Corrections)
    ml_in.info.F.chuck_id{index} = parsed_IDAT.SystemModelInput.Corrections(index).elt.Header.ChuckId;
end

% Create the second output ml-struct and append tlgname to ml-structs.
ml_out  = ml_in;
ml_in.tlgname     = 'InlineSDM System part input';
ml_out.tlgname    = 'InlineSDM System part output';

% First ml_in is populated.
% Grid layout is constructed using information contained in the IDAT, which is obtained here.
y_step  = str2double(parsed_IDAT.SystemModelInput.Corrections(1).elt.Header.Steps.Y);
x_step  = str2double(parsed_IDAT.SystemModelInput.Corrections(1).elt.Header.Steps.X);
y_ini   = str2double(parsed_IDAT.SystemModelInput.Corrections(1).elt.Header.InitialPosition.Y);
x_ini   = str2double(parsed_IDAT.SystemModelInput.Corrections(1).elt.Header.InitialPosition.X);
y_pitch = str2double(parsed_IDAT.SystemModelInput.Corrections(1).elt.Header.Pitch.Y);
x_pitch = str2double(parsed_IDAT.SystemModelInput.Corrections(1).elt.Header.Pitch.X);

% Create the grid for ml_in using several sub-functions.
% Be aware: xf and yf are meandering from starting from the bottom left to the bottom right.
ml_in.wd.xf = sub_xf_matrix(x_step, y_step, x_pitch, x_ini);
ml_in.wd.yf = sub_yf_matrix(x_step, y_step, y_pitch, y_ini);
ml_in.wd.xc = zeros(ml_in.nmark, 1);
ml_in.wd.yc = zeros(ml_in.nmark, 1);
ml_in.wd.xw = ml_in.wd.xf + ml_in.wd.xc;
ml_in.wd.yw = ml_in.wd.yf + ml_in.wd.yc;

% Populate dx and dy for ml_in. 
ml_in = sub_get_dx_dy(ml_in, parsed_IDAT, "in", x_step, y_step);

% Next, populate ml_out.
% If ADELExposureTrajectoriesReport is provided the y-resampled CET grid is obtained from the ADEL. 
% The ADEL is loaded and the correct grid layout is extracted using sub_xf_yf_ADELtraject.
if ADEL_provided
    xml_data                       = bmmo_load_ADEL(adelexposetraj_filepath);
    [ml_out.wd.xf, ml_out.wd.yf ]  = sub_xf_yf_ADELtraject(xml_data, ml_out.nmark, x_step, y_step);
    
% If no ADEL is provided, the 25.4x33.0 mm CET grid is automatically assumed. 
% This is calculated using the previously determined values.
else
    ml_out.wd.xf = sub_xf_matrix(x_step_out, y_step_out, x_pitch_out, x_ini_out);
    ml_out.wd.yf = sub_yf_matrix(x_step_out, y_step_out, y_pitch_out, y_ini_out);                                    
end

% Populate xc, yc, xw and yw. Be aware: since we are regarding intrafield, xc and yc are hardcoded to be zero.
ml_out.wd.xc = zeros(ml_out.nmark, 1);
ml_out.wd.yc = zeros(ml_out.nmark, 1);
ml_out.wd.xw = ml_out.wd.xf + ml_out.wd.xc;
ml_out.wd.yw = ml_out.wd.yf + ml_out.wd.yc;
    
% Populate dx and dy for ml_out.
ml_out = sub_get_dx_dy(ml_out, parsed_IDAT, "out", x_step, y_step);

end



function yf_mat = sub_yf_matrix(x_step, y_step, y_pitch, y_ini)
% Generate the matrix for yf: a 13x19 field with the y-coordinates as values. 
for index = 1 : x_step + 1
    yf_mat(:, index) = linspace(y_ini, y_ini + y_step * y_pitch, y_step + 1) * 1e-3;
end
yf_mat = reshape(yf_mat', [], 1);

end

function xf_mat = sub_xf_matrix(x_step, y_step, x_pitch, x_ini)
% Generate the matrix for xf: a meandering 13x19 field with the x-coordinates as values. Due to the meandering uneven rows are flipped.
for index = 1 : y_step + 1
    if mod(index, 2)
        xf_mat(index, :) = linspace( x_ini, x_ini + (x_step * x_pitch), x_step + 1) * 1e-3;
    else
        xf_mat(index, :) = linspace( x_ini + (x_step * x_pitch), x_ini, x_step + 1) * 1e-3;
    end
end
xf_mat = reshape(xf_mat', [], 1);

end

function out = sub_linear_to_meander(column, x_step, y_step)
% Sub-function to meander the data. The data is placed in a 13x19 matrix, then
% the uneven rows are flipped and the matrix is made into a column vector
% again.
to_matrix = reshape(column, [x_step + 1, y_step + 1]);
for index = 1 : size(to_matrix, 2)
    if ~mod(index, 2)
        to_matrix(:, index) = flip(to_matrix(:, index));
    else
    end
end
out = reshape(to_matrix, 1, [])';

end

function [out_x, out_y] = sub_xf_yf_ADELtraject(xml_data, nmark, x_step, y_step)
% Sub-function to determine the grid with 247 marks in
% ADELexposuretrajectoriesreport, grab the coordinates and place them in a
% meandering column vector.
for index = 1 : length(xml_data.Input.GridList)
    field_information(index, 1) = length(xml_data.Input.GridList(index).elt.GridDefinition);
end
field_index = find(field_information(:, 1) == 247);

for index = 1 : nmark
    x_column_holder(index, 1) = str2num(xml_data.Input.GridList(field_index).elt.GridDefinition(index).elt.X) * 1e-3;
    y_column_holder(index, 1) = str2num(xml_data.Input.GridList(field_index).elt.GridDefinition(index).elt.Y) * 1e-3;
end
out_x = sub_linear_to_meander(x_column_holder, x_step, y_step);
out_y = sub_linear_to_meander(y_column_holder, x_step, y_step);

end

function ml = sub_get_dx_dy(ml, parsed_IDAT, type, x_step, y_step)
% Sub-function to extract the data from parsed_IDAT. Type is
% used to distinguish between the input- and output data
if string(type) == "in"
    fhandle = @(i_wafer, i_mark, XY) (str2double(parsed_IDAT.SystemModelInput.Corrections(i_wafer).elt.Offsets(i_mark).elt.(XY)) * 1e-9);
elseif string(type) == "out"
    fhandle = @(i_wafer, i_mark, XY) (str2double(parsed_IDAT.SystemModelOutput.RequestedScaledCorrections(i_wafer).elt.Corrections.elt.Offsets(i_mark).elt.(XY)) * 1e-9);
else
    error('Wrong type provided. Only "in" and "out" are allowed, but found: %s', string(type));
end

for i_wafer = 1 : ml.nwafer
    for i_mark = 1 : ml.nmark
        column_x(i_wafer, i_mark) = feval(fhandle, i_wafer, i_mark, 'X');
        column_y(i_wafer, i_mark) = feval(fhandle, i_wafer, i_mark, 'Y');
    end
ml.layer.wr(i_wafer).dx = sub_linear_to_meander(column_x(i_wafer, :), x_step, y_step);
ml.layer.wr(i_wafer).dy = sub_linear_to_meander(column_y(i_wafer, :), x_step, y_step);
end

end