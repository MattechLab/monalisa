classdef TestMathPipelineIntegration < matlab.unittest.TestCase
    % Integration tests combining multiple utility + math functions.

    properties
        Cases
    end

    methods (TestClassSetup)
        function addProjectPath(~)
            if exist('setup_test_path', 'file') ~= 2
                thisFile = mfilename('fullpath');
                testsDir = fileparts(fileparts(thisFile)); % .../tests
                addpath(fullfile(testsDir, 'ci'));
            end
            setup_test_path();
        end

        function loadCases(testCase)
            dataDir = getenv('MONALISA_CI_DATA_DIR');
            if isempty(dataDir)
                repoRoot = getenv('MONALISA_REPO_ROOT');
                if isempty(repoRoot)
                    thisFile = mfilename('fullpath');
                    testsDir = fileparts(fileparts(thisFile)); % .../tests
                    repoRoot = fileparts(testsDir);
                end
                dataDir = fullfile(repoRoot, 'temp', 'ci_data');
            end

            p = fullfile(dataDir, 'synthetic_cases.mat');
            testCase.assumeTrue(exist(p, 'file') == 2, ...
                sprintf('Missing synthetic dataset: %s', p));
            s = load(p, 'cases');
            testCase.Cases = s.cases;
        end
    end


    methods (Test)
        function testTutorial8DataAvailableWhenEnabled(testCase)
            useTutorial8 = strcmpi(strtrim(getenv('MONALISA_USE_TUTORIAL8_DATA')), 'true');
            if ~useTutorial8
                testCase.assumeFail('Tutorial-8 dataset check disabled by env.');
            end

            dataDir = getenv('MONALISA_CI_DATA_DIR');
            if isempty(dataDir)
                repoRoot = getenv('MONALISA_REPO_ROOT');
                if isempty(repoRoot)
                    thisFile = mfilename('fullpath');
                    testsDir = fileparts(fileparts(thisFile)); % .../tests
                    repoRoot = fileparts(testsDir);
                end
                dataDir = fullfile(repoRoot, 'temp', 'ci_data');
            end

            tutorialDir = fullfile(dataDir, 'tutorial8');
            required = {'bodyCoil.dat', 'brainScan.dat', 'surfaceCoil.dat'};
            for i = 1:numel(required)
                p = fullfile(tutorialDir, required{i});
                testCase.verifyTrue(exist(p, 'file') == 2, sprintf('Missing tutorial file: %s', p));
                info = dir(p);
                testCase.verifyGreaterThan(info.bytes, 0, sprintf('Tutorial file is empty: %s', p));
            end
        end

        function testWeightedSelfInnerProductPipeline(testCase)
            c = testCase.Cases(1);
            x = bmPointReshape(c.raw, c.nCh);
            h = c.weight;
            lhs = bmEuclideProd(x, x, h);
            rhs = real(x(:)' * (h(:) .* x(:)));
            testCase.verifyEqual(lhs, rhs, 'AbsTol', 1e-10);
        end

        function testCellPipeline(testCase)
            c = testCase.Cases(2);
            sumCell = bmPlus(c.cellX, c.cellY);
            diffCell = bmMinus(sumCell, c.cellY);
            prodCell = bmMult(diffCell, c.cellY);

            testCase.verifyEqual(diffCell{1}, c.cellX{1}, 'AbsTol', 1e-10);
            testCase.verifyEqual(diffCell{2}, c.cellX{2}, 'AbsTol', 1e-10);
            testCase.verifyEqual(prodCell{1}, c.cellX{1} .* c.cellY{1}, 'AbsTol', 1e-10);
        end
    end
end
