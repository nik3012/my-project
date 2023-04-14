function [ml, wafer_ids, cet_res, xml_data] = bmmo_read_adelexposetrajectories(xml_filepath)
% Given the file path for ADELexposureTrajectoriesReportProtected, the
% function decrypts and parses to output full CET NCE.
%
% Input
%   adel_file: ADELexposureTrajectoriesReportProtected path
%
% Output:
%   ml       : CET residual in overlay structure format
%  wafer     : Exposure wader Ids
%  cet_res   : CET residual in ndgrid format
%  xml_data  : decrypted ADEL in xml_load format

% 20201008 SBPR Creation

%load in the residual report
xml_data = bmmo_load_ADEL(xml_filepath);

ROUNDING_SF = 12;

for i=1:length(xml_data.Results.WaferResultList)
    wafer_ids{i} = xml_data.Results.WaferResultList(i).elt.WaferId;
end

% build an index of grid definitions
grid_ids = arrayfun(@(x) str2double(x.elt.GridId), xml_data.Input.GridList);
grid_sizes = arrayfun(@(x) numel(x.elt.GridDefinition), xml_data.Input.GridList);
number_of_grids = numel(grid_ids);

% find the main grid definition
[full_grid_size, full_grid_id] = max(grid_sizes);
grid_map = zeros(full_grid_size, number_of_grids);

x_full_grid = reshape(str2double(arrayfun(@(x) (x.elt.X), xml_data.Input.GridList(full_grid_id).elt.GridDefinition, 'UniformOutput', false)) * 1e-3, [], 1);
y_full_grid = reshape(str2double(arrayfun(@(x) (x.elt.Y), xml_data.Input.GridList(full_grid_id).elt.GridDefinition, 'UniformOutput', false)) * 1e-3, [], 1);
full_xy = [x_full_grid, y_full_grid];

% map all the grids to the main grid
for i_grid = 1:number_of_grids
    x_grid = reshape(str2double(arrayfun(@(x) (x.elt.X), xml_data.Input.GridList(i_grid).elt.GridDefinition, 'UniformOutput', false)) * 1e-3, [], 1);
    y_grid = reshape(str2double(arrayfun(@(x) (x.elt.Y), xml_data.Input.GridList(i_grid).elt.GridDefinition, 'UniformOutput', false)) * 1e-3, [], 1);
    
    [~, grid_indices] = pdist2(full_xy, [x_grid y_grid], 'Euclidean','Smallest',1);
    grid_map(1:length(grid_indices), i_grid) = grid_indices;
end

exposures_per_wafer = arrayfun(@(x) numel(x.elt.ImageResultList(1).elt.ExposureResultList), xml_data.Results.WaferResultList);
if ~(sum(diff(exposures_per_wafer)) == 0)
    error('Error parsing ADELexposeTrajectoriesReport: different number of exposures per wafer');
end

% ensure all grids are in ndgrid format
[x_full_grid, y_full_grid, mapping_index, nx] = bmmo_fix_nd_grid(x_full_grid, y_full_grid);

% reshape grids and indices to columns
x_full_grid = reshape(x_full_grid, [], 1);
y_full_grid = reshape(y_full_grid, [], 1);
mapping_index = reshape(mapping_index, [], 1);

% build a exposures * max grid size 'wd.xf' matrix
number_of_exposures = exposures_per_wafer(1);
xf = repmat(x_full_grid, 1, number_of_exposures);
yf = repmat(y_full_grid, 1, number_of_exposures);

% build xc, yc
xc = str2double(arrayfun(@(x) (x.elt.FieldPosition.X), xml_data.Results.WaferResultList(1).elt.ImageResultList(1).elt.ExposureResultList, 'UniformOutput', false)) * 1e-3;
yc = str2double(arrayfun(@(x) (x.elt.FieldPosition.Y), xml_data.Results.WaferResultList(1).elt.ImageResultList(1).elt.ExposureResultList, 'UniformOutput', false)) * 1e-3;

% build the base ml structure
ml.wd.xf = round(reshape(xf, [], 1), ROUNDING_SF);
ml.wd.yf = round(reshape(yf, [], 1), ROUNDING_SF);
ml.wd.xc = round(reshape(repmat(xc, full_grid_size,1), [], 1), ROUNDING_SF);
ml.wd.yc = round(reshape(repmat(yc, full_grid_size,1), [], 1), ROUNDING_SF);
ml.wd.xw = ml.wd.xf + ml.wd.xc;
ml.wd.yw = ml.wd.yf + ml.wd.yc;

ml.nmark = full_grid_size;
ml.nfield = number_of_exposures;
ml.nlayer = 1;
ml.nwafer = numel(exposures_per_wafer);

wr.dx = zeros(full_grid_size * number_of_exposures, 1);
wr.dy = wr.dx;

ml.layer.wr = repmat(wr, 1, ml.nwafer);
ml.tlgname = 'CET residual';


% build residual data per wafer
for iw = 1:ml.nwafer
    grid_map_per_field = str2double(arrayfun(@(x) (x.elt.GridId), xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList, 'UniformOutput', false));
    dx_wafer = NaN * xf;
    dy_wafer = NaN * yf;
    
    for i_exp = 1:number_of_exposures   
        % map the residuals in each exposed field to a grid definition
        dx = str2double(arrayfun(@(x) (x.elt.Dx), xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList(i_exp).elt.Residuals, 'UniformOutput', false)) * 1e-9;
        dy = str2double(arrayfun(@(x) (x.elt.Dy), xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList(i_exp).elt.Residuals, 'UniformOutput', false)) * 1e-9;
        
        ndx = 1:numel(dx);
        grid_id = grid_map(ndx, (grid_ids == grid_map_per_field(i_exp)));
        dx_wafer(grid_id, i_exp) = dx;
        dy_wafer(grid_id, i_exp) = dy;
    end
    
    % ensure dx_wafer, dywafer are in ndgrid format
    dx_wafer = dx_wafer(mapping_index, :);
    dy_wafer = dy_wafer(mapping_index, :);
    
    ml.layer.wr(iw).dx = reshape(dx_wafer, [], 1);
    ml.layer.wr(iw).dy = reshape(dy_wafer, [], 1);
    cet_res.wafer(iw).dx = dx_wafer;
    cet_res.wafer(iw).dy = dy_wafer;
end

% extra info: field centers and grid definition
cet_res.xc = reshape(xc, [], 1);
cet_res.yc = reshape(yc, [], 1);
cet_res.xf_grid = reshape(x_full_grid, nx, []);
cet_res.yf_grid = reshape(y_full_grid, nx, []);
end