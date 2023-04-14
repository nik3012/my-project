function scaled = DCO_budget_noise(ml, varargin)

%% Description:
% Generates an ml struct with weighted noise according to the specified
% budget. Specifically:
% - point-by-point Gaussian noise is generated on the layout of 'ml'
% - a DCO budget breakdown is calculated using ovl_calc_breakdown
% - the components are weighted according to the budget and added up
% - if necessary, a scaling is performed to ensure the 3 sigma ovl number
%   equals 'noise3s'
% Input:
% - ml: to provide the layout
% - nwafer: the number of wafers (with independent noise) to be returned;
%   default = 3
% - noise3s: provide a noise level; default = 1.5 / sqrt(2)
% - budget: provide a custom budget; default = 3350 DCO budget / sqrt(2)
% - no_wec: do not add WEC error-like noise; default = 0 (i.e. do add WEC)
% - wec_3s: 3 sigma value of WEC error; default = 0.8 nm (as taken from
%   typical YS WEC data)
% Output:
% - scaled: collection of mls with scaled noise:
%   - cob: batch correctables
%   - cov: correctables variation
%   - mf: mean field
%   - f2f: field-to-field variation
%   - ma: moving average (3 par per row fit)
%   - nma: remainder
%   - total: sum of six components above
%   - wec: if 'no_wec' is set to 0, the total WEC-like error added to
%     'total'

%% Changes:
% 20141028: removed factor of sqrt(2) from default output level, to account
%           for the fact that DCO uses two layers, whereas only one layer is
%           generated
% 20141105: added WEC error generation
% 20141105: moved argument processing to sub function

%% process arguments
    [budget, nwafer, noise3s, no_wec, wec_3s] = process_varargin(varargin{:});
    
%% generate noise mls
    ml_noise = noise_ml(ml, noise3s);
    for i = 1:nwafer-1
        ml_noise = ovl_combine_wafers(ml_noise, noise_ml(ml, noise3s));
    end
    fns = fieldnames(budget);

%% compute DCO breakdown
    [ov, mlo] = ovl_calc_breakdown(ml_noise,'f2n','nxe','parlist','12par');
    [ovnnsa, mlonnsa] = ovl_calc_breakdown(ml_noise,'f2n','nxe','parlist','12par','noise');
    noise.cob = mlo.correctables.mean.batch;
    noise.cov = mlo.correctables.variation.perwafer;
    noise.mf = mlo.residuals.field.mean;
    noise.f2f = mlonnsa.noise.residuals.step_nofldavg;
    noise.ma = mlonnsa.noise.filter.difference;
    noise.nma = mlonnsa.noise.filter.scanner;

    ovl_breakdown = [ov.correctables.mean.batch.oxm3s ov.correctables.mean.batch.oym3s
        ov.correctables.variation.perwafer.oxm3s ov.correctables.variation.perwafer.oym3s
        ov.residuals.field.mean.oxm3s ov.residuals.field.mean.oym3s
        ovnnsa.noise.residuals.step_nofldavg.oxm3s ovnnsa.noise.residuals.step_nofldavg.oym3s
        ovnnsa.noise.filter.difference.oxm3s ovnnsa.noise.filter.difference.oym3s
        ovnnsa.noise.filter.scanner.oxm3s ovnnsa.noise.filter.scanner.oym3s];
    ovl_breakdown = max(ovl_breakdown');
   
    noise.cob = copy_wafers(noise.cob, nwafer);
    noise.mf = copy_wafers(noise.mf, nwafer);

%% scale components according to budget
    scaled.total = copy_wafers(ovl_create_dummy(ml), nwafer);
    for i = 1:length(fns)
        breakdown.(fns{i}) = ovl_breakdown(i);
        factor.(fns{i}) = budget.(fns{i}) / breakdown.(fns{i});
        scaled.(fns{i}) = ovl_combine_linear(noise.(fns{i}), factor.(fns{i}));
        scaled.total = ovl_add(scaled.total, scaled.(fns{i}));
    end

    scaled.ovl = ovl_calc_overlay(scaled.total);
    if abs(max(scaled.ovl.ox997, scaled.ovl.oy997) - noise3s * 1e-9) > 5e-11
        scaling = (noise3s * 1e-9) / max(scaled.ovl.ox997, scaled.ovl.oy997);
        for i = 1:length(fns)
            scaled.(fns{i}) = ovl_combine_linear(scaled.(fns{i}), scaling);
        end
        scaled.total = ovl_combine_linear(scaled.total, scaling);
    end
    
%% add WEC error noise if requested
    if ~no_wec
        wec_budget.nma = .25;
        wec_budget.ma = .45;
        wec_budget.f2f = .45;
        wec_budget.mf = .04;
        wec_budget.cov = .4;
        wec_budget.cob = .13;
        wec_err = DCO_budget_noise(ml, 'nwafer', nwafer, 'noise3s', wec_3s, 'budget', wec_budget, 'no_wec');
        scaled.total = ovl_add(scaled.total, wec_err.total);
        scaled.wec = wec_err.total;
    end
    
end

function [budget, nwafer, noise3s, no_wec, wec_3s] = process_varargin(varargin)
    i = 1;
    while i <= length(varargin)
        switch varargin{i}
            case 'budget'
                budget = varargin{i+1};
                i = i + 2;
            case 'nwafer'
                nwafer = varargin{i+1};
                i = i + 2;
            case 'noise3s'
                noise3s = varargin{i+1};
                i = i + 2;
            case 'no_wec'
                no_wec = 1;
                i = i + 1;
            case 'wec_3s'
                wec_3s = varargin{i+1};
                i = i + 2;
        end
    end
    if exist('budget') ~= 1
        budget.cob = 0.2e-9;
        budget.cov = 0.4e-9;
        budget.mf = 0.3e-9;
        budget.f2f = 1.0e-9;
        budget.ma = 0.7e-9;
        budget.nma = 0.7e-9;
    end
    if exist('nwafer') ~= 1
        nwafer = 3;
    end
    if exist('noise3s') ~= 1
        noise3s = 1.5 / sqrt(2);
    end
    if exist('no_wec') ~= 1
        no_wec = 0;
    end
    if exist('wec_3s') ~= 1
        wec_3s = .8;
    end
end

function ml_noise = noise_ml(mli, noise3s)
    ml_noise = mli;
    dx = randn(size(ml_noise.layer(1).wr(1).dx));
    dy = randn(size(ml_noise.layer(1).wr(1).dy));
    dx(isnan(ml_noise.layer(1).wr(1).dx)) = NaN;
    dy(isnan(ml_noise.layer(1).wr(1).dy)) = NaN;
    ml_noise.layer(1).wr(1).dx = dx;
    ml_noise.layer(1).wr(1).dy = dy;

    ovl = ovl_calc_overlay(ml_noise);
    ml_noise = ovl_combine_linear(ml_noise, noise3s/(max(ovl.oxm3s,ovl.oym3s)));
end

function quad_sum = add_quadratically(budget)
    fns = fieldnames(budget);
    quad_sum = 0;
    for i = 1:length(fns)
        quad_sum = quad_sum + (budget.(fns{i}))^2;
    end
    quad_sum = sqrt(quad_sum);
end

function mlo = copy_wafers(mli, nwafer)
    mlo = mli;
    for i = 1:nwafer-1
        mlo = ovl_combine_wafers(mlo, mli);
    end
end