function FP_WH = bmmo_construct_FPS_WH(ml, options)
% function FP_WH = bmmo_construct_FPS_WH(ml, options)
%
% Generate the raw WH fingerprint for the combined model
%
% Input: 
%  ml: input ml structure
%  options: structure containing the fields
%           WH.input_fp_per_chuck: input wafer heating fingerprint, averaged
%               per chuck (1 * 2 struct array)
%           chuck_usage.chuck_id_used: horizontal array of chuck ids used,
%               in order of wafers
%           chuck_usage.nr_chuck_used: Number of chucks where the wafers are 
%               exposed (1 or 2)
%           resample_options: structure constaining details of
%               interpolation
%
% Output: 
%  FP_WH: WH fingerprint (1x2 cell array of ml structs}, resampled
%           to input size if necessary

FP_WH = num2cell(options.WH.input_fp_per_chuck);

for ic = options.chuck_usage.chuck_id_used
    FP_WH{ic} = ovl_get_fields(options.WH.input_fp_per_chuck(ic), 1:ml.nfield);
    if options.WH.input_fp_per_chuck(ic).nmark ~= ml.nmark
        FP_WH{ic} = bmmo_resample(FP_WH{ic}, ml, options.WH_resample_options);
    end
end

if options.chuck_usage.nr_chuck_used==2
    FP_WH = FP_WH';
end
