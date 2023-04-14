function intraf_out = bmmo_correct_intrafield_shift(intraf_in, options, intraf_rint)
% function intraf_out = bmmo_correct_intrafield_shift(intraf_in, options, intraf_rint)
%
% Correct intrafield shift and remove 6par
%
% Input
%   intraf_in  : overlay structure
%   options    : options structure
%   intraf_rint: option target overlay structure
%
% Output
%   intraf_out : overlay structure resampled at RINT/XPA positions
%
%   Any layout except 1x1
%   Resampling for platform : LIS
%      XPA (any layout)   to RINT
%      RINT (any layout)  to XPA & 6 par removed
%
%   Resampling for platform : OTAS
%      Interpolate to shifted layout (any layout) & 6 par removed
%

% determine if LIS
if strcmp(options.platform, 'LIS')
    rd = 7; % round covers upto RINT shift values
    if round(mean(intraf_in.wd.xf),rd) == 0 % XPA to RINT case

        % Get ml RINT layout & define bounding box in XPA
        [bbx, bby]  = bmmo_get_bounding_box(intraf_in);
        if nargin < 3
            intraf_rint = bmmo_shift_fields(intraf_in, options.x_shift, options.y_shift);
        end
        options.intraf_resample_options.bounding_box = [bbx; bby]';
        % resample XPA to RINT
        intraf_out  = bmmo_resample(intraf_in, intraf_rint, options.intraf_resample_options);
        
        
    else  %RINT to XPA case
        % get XPA marks for bounding box
        intraf_xpa = bmmo_shift_fields(intraf_in, -options.x_shift, -options.y_shift);
        % define bounding box in RINT
        [bbx, bby] = bmmo_get_bounding_box(intraf_xpa);
        bbx        = bbx + options.x_shift(1, 2);
        bby        = bby + options.y_shift(1, 2);
        options.intraf_resample_options.bounding_box = [bbx; bby]';
        % resample RINT to XPA
        intraf_out = bmmo_resample(intraf_in, intraf_xpa, options.intraf_resample_options);
        % Remove intrafield 6par and discard (result will not be added to BAO)
        intraf_out     = bmmo_fit_model_perwafer(intraf_out, options, 'tx', 'ty', 'ms', 'ma', 'rs', 'ra');
    end
    
    % determine if OTAS
elseif strcmp(options.platform, 'OTAS')
    intraf_shifted = bmmo_shift_fields(intraf_in, -options.x_shift, -options.y_shift);
    intraf_out     = bmmo_resample(intraf_in, intraf_shifted, options.intraf_resample_options);
    intraf_out     = bmmo_shift_fields( intraf_out,  options.x_shift, options.y_shift);
    % Remove intrafield 6par and discard (result will not be added to BAO)
    intraf_out     = bmmo_fit_model_perwafer(intraf_out, options, 'tx', 'ty', 'ms', 'ma', 'rs', 'ra');
end
