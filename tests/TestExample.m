classdef TestExample < matlab.unittest.TestCase
    % TestExample - A simple example test class to demonstrate how to write unit tests in MATLAB.
    
    methods (Test)
        function testStupidExample(testCase)
            % This test checks if (1 + 1) * 3 equals 6.
            actual = (1 + 1) * 3;
            expected = 6;
            testCase.verifyEqual(actual, expected);
        end
    end
end