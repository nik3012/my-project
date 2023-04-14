var sourceData279 = {"FileContents":["classdef testBmmoFixNdGrid < BMMO_XY.tools.testSuite\r","    \r","    methods(Test)\r","        \r","        %% test with intrafield grid (i.e. a grid with a pointless meander in it]\r","        function test_bmmo_fix_nd_grid_intrafield(obj)\r","            % Given\r","            input_struct = bmmo_default_input;\r","            \r","            % When\r","            intrafield_grid = input_struct.info.previous_correction.ffp(1);            \r","            [grid_out_x, grid_out_y, index_out] = bmmo_fix_nd_grid(intrafield_grid.x, intrafield_grid.y);     \r","            \r","            % Then\r","            obj.verifyWithinTol(intrafield_grid.x(index_out), grid_out_x);\r","            obj.verifyWithinTol(intrafield_grid.y(index_out), grid_out_y);\r","        end\r","        \r","        %% test with a meshgrid\r","        function test_bmmo_fix_nd_grid_meshgrid(obj)\r","            % Given\r","            xvector = -5:5;\r","            yvector = -11:11; \r","            \r","            % When\r","            [meshx, meshy] = meshgrid(xvector, yvector);\r","            [ndx, ndy] = ndgrid(xvector, yvector);            \r","            [grid_out_x, grid_out_y, index_out, numx] = bmmo_fix_nd_grid(meshx, meshy); \r","            \r","            % Then\r","            obj.verifyWithinTol(meshx(index_out), grid_out_x);\r","            obj.verifyWithinTol(meshy(index_out), grid_out_y);\r","            obj.verifyWithinTol(ndx, grid_out_x);\r","            obj.verifyWithinTol(ndy, grid_out_y);\r","            obj.verifyWithinTol(numx, length(xvector));\r","        end\r","        \r","        %% verify that it does not break an ndgrid\r","        function test_bmmo_fix_nd_grid_ndgrid(obj)\r","            % Given\r","            xvector = -8:7;\r","            yvector = -5:6;            \r","            \r","            % When\r","            [ndx, ndy] = ndgrid(xvector, yvector);            \r","            [grid_out_x, grid_out_y, index_out, numx] = bmmo_fix_nd_grid(ndx, ndy);\r","            \r","            % Then\r","            obj.verifyWithinTol(ndx, grid_out_x);\r","            obj.verifyWithinTol(ndy, grid_out_y);\r","            obj.verifyWithinTol(ndx(index_out), ndx);\r","            obj.verifyWithinTol(ndy(index_out), ndy);\r","            obj.verifyWithinTol(numx, length(xvector));            \r","        end\r","        \r","    end\r","    \r","end"],"CoverageData":{"CoveredLineNumbers":[8,11,12,15,16,22,23,26,27,28,31,32,33,34,35,41,42,45,46,49,50,51,52,53],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,1,0,0,1,1,0,0,1,1,0,0,0,0,0,1,1,0,0,1,1,1,0,0,1,1,1,1,1,0,0,0,0,0,1,1,0,0,1,1,0,0,1,1,1,1,1,0,0,0,0,0]}}