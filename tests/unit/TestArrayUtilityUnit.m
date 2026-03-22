classdef TestArrayUtilityUnit < matlab.unittest.TestCase
    % BICEP-oriented unit tests for array utility functions.

    methods (TestClassSetup)
        function addProjectPath(~)
            if exist('setup_test_path', 'file') ~= 2
                thisFile = mfilename('fullpath');
                testsDir = fileparts(fileparts(thisFile)); % .../tests
                addpath(fullfile(testsDir, 'ci'));
            end
            setup_test_path();
        end
    end

    methods (Test)
        %% B - Boundary
        function testBmColBoundaryEmpty(testCase)
            out = bmCol([]);
            testCase.verifyEqual(size(out), [0, 1]);
        end

        // function testBmColBoundaryShape(testCase)
        //     a = [1, 2; 3, 4];
        //     out = bmCol(a);
        //     testCase.verifyEqual(size(out), [4, 1]);
        //     testCase.verifyEqual(out, [1; 3; 2; 4]);
        // end

        function testBmPointReshapeBoundaryVectorToRow(testCase)
            out1 = bmPointReshape((1:5).'); % column vector -> row vector
            out2 = bmPointReshape(1:5);      % row vector -> row vector
            testCase.verifyEqual(size(out1), [1, 5]);
            testCase.verifyEqual(size(out2), [1, 5]);
            testCase.verifyEqual(out1, 1:5);
            testCase.verifyEqual(out2, 1:5);
        end

        function testBmBlockReshapeBoundaryEmpty(testCase)
            out = bmBlockReshape([], [2, 2, 2]);
            testCase.verifyEqual(out, []);
        end

        function testBmIsScalarBoundary(testCase)
            testCase.verifyTrue(bmIsScalar(4));
            testCase.verifyTrue(bmIsScalar(1 + 1i));
            testCase.verifyFalse(bmIsScalar([1, 2]));
            testCase.verifyFalse(bmIsScalar(ones(1, 1, 2)));
            testCase.verifyFalse(bmIsScalar({1}));
        end

        %% I - Inverse relationships
        function testBmColInverseByReshape(testCase)
            a = randn(7, 5, 3);
            col = bmCol(a);
            back = reshape(col, size(a));
            testCase.verifyEqual(back, a, 'AbsTol', 1e-12);
        end

        function testBmPointReshapeInverseToRawOrdering(testCase)
            raw = reshape(1:24, [3, 8]);
            p = bmPointReshape(raw, 3);
            back = reshape(p, size(raw));
            testCase.verifyEqual(back, raw);
        end

        %% C - Cross-check
        function testBmPointReshapeCrossCheck(testCase)
            raw = reshape(1:12, [3, 4]);
            out = bmPointReshape(raw, 3);
            expected = reshape(raw, [3, 4]);
            testCase.verifyEqual(out, expected);
        end

        function testBmPointReshapeCrossCheckRecursiveCell(testCase)
            raw1 = reshape(1:12, [3, 4]);
            raw2 = reshape(13:24, [3, 4]);
            c = {raw1, raw2};
            out = bmPointReshape(c, 3);
            testCase.verifyEqual(out{1}, raw1);
            testCase.verifyEqual(out{2}, raw2);
        end

        function testBmBlockReshapeCrossCheck(testCase)
            raw = 1:24;
            out = bmBlockReshape(raw, [2, 3, 2]);
            expected = reshape(raw, [2, 3, 2, 2]);
            testCase.verifyEqual(out, expected);
        end

        %% E - Error conditions
        function testBmPointReshapeErrorInconsistentChannels(testCase)
            % Use non-vector data so bmPointReshape cannot early-return as row.
            % 10 elements cannot be reshaped with nCh=3.
            f = @() bmPointReshape(reshape(1:10, [2, 5]), 3);
            testCase.assertThrowsAny(f);
        end

        function testBmBlockReshapeErrorIncompatibleShape(testCase)
            f = @() bmBlockReshape(1:10, [3, 3]);
            testCase.assertThrowsAny(f);
        end

        %% P - Performance characteristics
        function testBmColPerformanceScaling(testCase)
            aSmall = rand(128, 128);
            aLarge = rand(512, 512);
            tSmall = timeit(@() bmCol(aSmall));
            tLarge = timeit(@() bmCol(aLarge));
            testCase.verifyLessThan(tLarge / max(tSmall, eps), 100);
        end
    end

    methods
        function assertThrowsAny(testCase, f)
            didThrow = false;
            try
                f();
            catch
                didThrow = true;
            end
            testCase.verifyTrue(didThrow, 'Expected an exception, but none was thrown.');
        end
    end
end
