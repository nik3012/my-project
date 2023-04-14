var sourceData762 = {"FileContents":["function [reduced_output, removed_structs] = bmmo_remove_k_factors_from_output(output_struct)\r","\r","reduced_output = output_struct;\r","fn = fieldnames(reduced_output.report.KPI.correction);\r","fn(contains(fn, 'monitor')) = [];\r","\r","fd = fieldnames(reduced_output.report.KPI.uncontrolled.intrafield); \r","idx = contains(fd, 'ovl_k');\r","Kfactors_fn = fd(idx);\r","\r","for j = 1:length(Kfactors_fn) \r","    % uncontrolled k-factors\r","    removed_structs.uncontrolled.intrafield.(Kfactors_fn{j}) = reduced_output.report.KPI.uncontrolled.intrafield.(Kfactors_fn{j});\r","    reduced_output.report.KPI.uncontrolled.intrafield.(Kfactors_fn{j}) = [];\r","   \r","    % corrections k-factors\r","    for i = 1:length(fn)\r","        removed_structs.(fn{i}).k_factors.(Kfactors_fn{j}) = reduced_output.report.KPI.correction.(fn{i}).k_factors.(Kfactors_fn{j});\r","        reduced_output.report.KPI.correction.(fn{i}).k_factors.(Kfactors_fn{j}) = [];\r","    end\r","end\r","\r","% monitor k-factors\r","removed_structs.intra_delta = reduced_output.report.KPI.correction.monitor.intra_delta;\r","reduced_output.report.KPI.correction.monitor.intra_delta = [];\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[3,4,5,7,8,9,11,13,14,17,18,19,24,25],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}