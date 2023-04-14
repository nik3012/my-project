function mlo = bmmo_import_ADELwaferdatamap(ADEL_wdm, wdm_type, select_corrs, make_ppt)
% function mlo = bmmo_import_ADELwaferdatamap(ADEL_wdm, wdm_type, select_corrs, make_ppt)
%
% Load the waferdata maps from an ADELwaferdatamap xml file generated
% by a BMMO NXE job into an ml structure with the same layout as the
% input_struct to BMMO NXE drift control model
%
% If the function is run without any input, a dialog box is opened to choose the
% options
%
% Input:    ADEL_wdm: full path of ADEL_waferdatamap file
%           wdm_type: cell array of the wdms to import, containing (a subset
%           of):
%           {'total_unfiltered', 'total_filtered', 'uncontrolled'};
%
%           select_corrs: cell array with the corrections to import,
%           containing (a subset of): {'WH','MI','KA','BAO','Intrafield','TotalSBCcorrection'}
%           make_ppt: Generates ppt if true (default)
%
%
% Output:   mlo:    matlab struct containing the different waferdatamaps
%                   as substructures
%
% Example usage: bmmo_import_ADELwaferdatamap to choose ADEL file and wdms
%                to import in the gui, ppt creation enabled by default
%
%                mlo = bmmo_import_ADELwaferdatamap(ADEL_wdm_file_path,...
%                       {uncontrolled}, {''}, false) to import only the
%                       uncontrolled wdms into an ml struct (no ppt
%                       generated)             
%
% 20190726 SELR Creation
% 20191213 SELR Same scale for per chuck correction set
% 20200417 SELR Bugfix


% Show popup dialog if no file specified
wdm_type_list = {'total_unfiltered', 'total_filtered', 'uncontrolled'};
corr_list = {'WH','MI','KA','BAO','Intrafield','TotalSBCcorrection'};
if nargin < 1 || isempty(ADEL_wdm)
    [filename, pathname, ~] = uigetfile( ...
        {'*.xml', 'ADELwaferDataMap (*.xml)'},...   % File pattern
        'Select ADELwaferDataMap',...               % Dialog title
        '',...                                      % Default filename
        'MultiSelect', 'off'...                      % Allow multiple?
        );
    if isnumeric(filename) && filename == 0
        mlo = [];
        warning('bmmo_import_ADELwaferdatamap:file_selection_aborted','Operation cancelled by user.');
        return;
    else
        ADEL_wdm = fullfile(pathname, filename);
    end
end
if nargin < 2
    wdm_type_index = listdlg('PromptString', 'Select an image:',...
        'ListSize', [300, 100], 'ListString', wdm_type_list);
    wdm_type = wdm_type_list(wdm_type_index);
end
if nargin < 3 && (wdm_type_index(1) ~= 3 && wdm_type_index(1) ~= 4)
    select_corrections_index = listdlg('PromptString', 'Select an image:',...
        'ListSize', [300, 200], 'ListString', corr_list);
    select_corrs = corr_list(select_corrections_index);
elseif nargin < 3
    select_corrs = {};
end
if nargin < 4
    make_ppt = 1;
end

mlo = bmmo_parse_ADELwaferdatamap(ADEL_wdm);
mlo = sub_remove_not_selected(mlo, wdm_type, wdm_type_list, select_corrs, corr_list);
n_wdm_types = length(wdm_type);
n_corrs = length(select_corrs);
if n_corrs > 3
    n_corr_plot = 3;
else
    n_corr_plot = n_corrs;
end
field_names = fieldnames(mlo);
if make_ppt
    openppt('new');
    close all;
    for iwdm_type = 1:n_wdm_types
        title = sub_get_slide_title(wdm_type(iwdm_type), wdm_type_list);
        newslide(title);
        if strcmp(wdm_type(iwdm_type), 'uncontrolled')
            scale.(wdm_type{iwdm_type}) = sub_get_scale(mlo.uncontrolled_meas(1), mlo.uncontrolled_meas(2));
            figure;bmmo_plot(mlo.uncontrolled_meas(1), 'scale', scale.(wdm_type{iwdm_type}), 'title', 'Uncontrolled c1');
            figppt(1,[1,2,1],'bitmap');
            figure;bmmo_plot(mlo.uncontrolled_meas(2), 'scale', scale.(wdm_type{iwdm_type}), 'title', 'Uncontrolled c2');
            figppt(2,[1,2,2],'bitmap');
            close all
        else
            for icorr = 1:n_corrs
                if icorr == 4
                    newslide([title '(2)']);
                    iplot = icorr - 3;
                elseif icorr > 4
                    iplot = icorr - 3;
                else
                    iplot = icorr;
                end
                
                plot_ind = contains(field_names, wdm_type(iwdm_type)) & contains(field_names, select_corrs(icorr));
                plot_field = field_names{plot_ind};
                
                if ~strcmp(select_corrs(icorr), 'WH')
                    scale.(plot_field) = sub_get_scale(mlo.(plot_field)(1), mlo.(plot_field)(2));
                    figure;bmmo_plot(mlo.(plot_field)(1), 'scale', scale.(plot_field), 'title', [select_corrs{icorr} ' c1']);
                    figppt(1,[2,n_corr_plot,iplot],'bitmap');
                    figure;bmmo_plot(mlo.(plot_field)(2), 'scale', scale.(plot_field), 'title', [select_corrs{icorr} ' c2']);
                    figppt(2,[2,n_corr_plot,iplot+n_corr_plot],'bitmap');
                else
                    figure;bmmo_plot(mlo.(plot_field)(1), 'scale', 0, 'title', [select_corrs{icorr} ' c1']);
                    figppt(1,[2,n_corr_plot,iplot],'bitmap');
                end
                close all
            end
        end
    end
end


function title = sub_get_slide_title(wdm_type, wdm_type_list)

wdm_title_list = {'Total unfiltered', 'Total filtered', 'Uncontrolled measurement'};
index = strcmp(wdm_type, wdm_type_list);
title = wdm_title_list{index};


function mlo = sub_remove_not_selected(mlo, wdm_type, wdm_type_list, select_corrs, corr_list)

wdm_remove = setdiff(wdm_type_list, wdm_type);
corr_remove = setdiff(corr_list, select_corrs);

field_names = fieldnames(mlo);

remove_ind = contains(field_names, wdm_remove) | contains(field_names, corr_remove);
remove_field_names = field_names(remove_ind);
mlo = rmfield(mlo, remove_field_names);


function scale = sub_get_scale(ml1, ml2)

mli = ovl_combine_wafers(ml1, ml2);
ovl = ovl_calc_overlay(mli);
scale = 1e-9*ceil(1e9*max([ovl.ox997 ovl.oy997]));
% when content is sub-nm, zoom in even further
if scale < 1.1e-9
    scale = 1e-10*ceil(1e10*max([ovl.ox997 ovl.oy997]));
end
% catch net: MINIMUM scale is 0.1 nm (unless explicitly overriden through option)
if scale < 0.1e-9
    scale = 0.1e-9;
end