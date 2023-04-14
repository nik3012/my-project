var sourceData321 = {"FileContents":["classdef testBmmoParseLcpReport < BMMO_XY.tools.testSuite\r","    \r","    methods(Test)\r","    \r","        %% Test Case 1\r","        function test_bmmo_parse_lcp_job_report_lis_sp18(obj)\r","            % Given\r","            load([bmmo_testdata_root filesep 'test_bmmo_parse_lcp_report'])\r","            job_report = [bmmo_testdata_root filesep 'ADELbmmoOverlayJobReport_LIS_SP18.xml'];\r","            \r","            % When\r","            test_kpi_struct = bmmo_parse_lcp_report(job_report);\r","            \r","            % Then\r","            obj.verifyWithinTol(test_kpi_struct, kpi_struct, 'tol', 5e-13);\r","        end\r","        \r","        %% Test Case 2\r","        function test_bmmo_parse_lcp_job_report_lis_sp22(obj)\r","            % Given\r","            load([bmmo_testdata_root filesep 'test_sp22_jobreport'])\r","            job_report = [bmmo_testdata_root filesep 'ADELbmmoOverlayJobReport_LIS_SP22.xml'];\r","            \r","            % When\r","            test_kpi_struct = bmmo_parse_lcp_report(job_report);\r","            \r","            % Then\r","            obj.verifyWithinTol(test_kpi_struct, kpi_struct, 'tol', 5e-13);\r","        end\r","        \r","    end\r","    \r","end"],"CoverageData":{"CoveredLineNumbers":[8,9,12,15,21,22,25,28],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,1,1,0,0,1,0,0,1,0,0,0,0,0,1,1,0,0,1,0,0,1,0,0,0,0,0]}}