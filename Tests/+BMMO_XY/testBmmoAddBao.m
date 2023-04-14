classdef testBmmoAddBao < BMMO_XY.tools.testSuite
    
    methods(Test)
        
        function Case1(obj)
            % Given
            load([bmmo_testdata_root filesep 'TC02_01_in.mat']);
            load([bmmo_testdata_root filesep 'TC02_01_out.mat']);
            
            % When
            test_out = bmmo_add_BAOs(in1, in2, in3);
            
            % Then
            obj.verifyWithinTol(out, test_out);
        end
        
        function Case2(obj)
            % Given
            load([bmmo_testdata_root filesep 'TC02_02_in.mat']);
            load([bmmo_testdata_root filesep 'TC02_02_out.mat']);
            
            % When
            test_out = bmmo_add_BAOs(in1, in2, in3);

            % Then
            obj.verifyWithinTol(out, test_out);
        end
        
        function Case3(obj)
            % Given
            load([bmmo_testdata_root filesep 'TC02_03_in.mat']);
            load([bmmo_testdata_root filesep 'TC02_03_out.mat']);
            
            % When
            test_out = bmmo_add_BAOs(in1, in2, in3);

            % Then
            obj.verifyWithinTol(out, test_out);
        end
    
    end

end