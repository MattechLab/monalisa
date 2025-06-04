import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.DiagnosticsOutputPlugin

% Create the test suite (NOTE THIS MIGHT NOT BE DESIRED FOR CI, MAYBE WE SHOULD SPLIT LIGHT AND HEAVY TESTS)
suite = TestSuite.fromFolder('.', 'IncludingSubfolders', true);

% Create a test runner with text output to the console
runner = TestRunner.withTextOutput('OutputDetail', matlab.unittest.Verbosity.Detailed);

% Optionally add diagnostics output (more info if a test fails)
runner.addPlugin(DiagnosticsOutputPlugin);

% Run the test suite
results = runner.run(suite);

% Display results as a table
disp(table(results))