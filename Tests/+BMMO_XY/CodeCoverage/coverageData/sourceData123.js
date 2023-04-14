var sourceData123 = {"FileContents":["function pi_struct = bmmo_get_hoc_pi_struct(input_kfactors, pi_text, options)\r","% function pi_struct = bmmo_get_hoc_pi_struct(input_kfactors, pi_text, options)\r","%\r","% Generate a (K)PI struct containing k-factor data\r","%\r","% Input:\r","%   input_kfactors: 1*2 struct of k-factor coefficients, per chuck\r","%   pi_text: text to use in pi struct field name. e.g. for chuck 2 k7: ovl_k7_chk2(pi_text)\r","%   options: BMMO/BL3 options structure\r","%\r","% Output:\r","%   pi_struct: (K)PI structure containing KPI values\r","\r","k_translation = sub_k_factor_translation;\r","kfactors = options.intraf_hoc_pi.kfactors;\r","\r","for ic = options.chuck_usage.chuck_id_used\r","    chuckstr = num2str(ic);\r","    for ik = 1:length(kfactors)\r","        kf = kfactors{ik};\r","        pi_struct.(['ovl_' k_translation.(kf) '_chk' chuckstr pi_text]) = input_kfactors(ic).(kf);\r","    end\r","end\r","\r"," \r","%% map k-factor names and their PI scaling\r","function translation = sub_k_factor_translation\r","\r","translation = struct('d2', 'k7',...\r","                   'k8', 'k8',...\r","                   'k9', 'k9',...\r","                  'k10', 'k10',...\r","                'bowxf', 'k11',...\r","                'bowyf', 'k12',...\r","                   'd3', 'k13',...\r","                'mag3y', 'k14',...\r","                 'accx', 'k15',...\r","                 'accy', 'k16',...\r","                'cshpx', 'k17',...\r","                'cshpy', 'k18',...\r","                'flw3x', 'k19',...\r","                'flw3y', 'k20',...\r","                  'k22', 'k22',...\r","                  'k24', 'k24',...\r","                  'k25', 'k25',...\r","                  'k26', 'k26',...\r","                  'k27', 'k27',...\r","                  'k29', 'k29',...\r","                  'k32', 'k32',...\r","                  'k34', 'k34',...\r","                  'k36', 'k36',...\r","                  'k37', 'k37',...\r","                  'k39', 'k39',...\r","                  'k41', 'k41',...\r","                  'k46', 'k46',...\r","                  'k48', 'k48',...\r","                  'k51', 'k51');\r",""],"CoverageData":{"CoveredLineNumbers":[14,15,17,18,19,20,21,29],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,733,733,0,733,1454,1454,20356,20356,0,0,0,0,0,0,0,733,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}