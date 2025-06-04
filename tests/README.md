# 🧪 Unit Tests for This Project

This folder contains all **unit tests** for the project. Unit testing helps us catch bugs early, ensure code behaves as expected, and enables safe, confident refactoring.

---

## 📌 Good Practices for Writing Tests

- Group tests for the **same function or component** into the **same test file** (class).
- A test file should ideally not exceed **200–300 lines**.
- **Write meaningful failure messages** (e.g., use `verifyEqual(a, b, "a should match b because...")`).
- **Comment your tests** to explain **what you're testing and why**.
- **Use clear naming**: test methods should describe the behavior being verified (e.g., `testHandlesEmptyInput`).
- **Make light tests**: tests are supposed to be light and fast, really fast.
- **Before pushing to main new tests**: test your tests on the ci-testing branch.

---

## ✍️ How to Write a New Test

Create a new file in this folder (e.g., `TestMyFunction.m`) using the following structure:

```matlab
classdef TestMyFunction < matlab.unittest.TestCase
    % TestMyFunction - Unit tests for the myFunction utility

    methods (Test)
        function testBasicCase(testCase)
            % This test verifies that myFunction behaves correctly on a basic input.
            input = 3;
            actual = myFunction(input);
            expected = 9;
            testCase.verifyEqual(actual, expected, ...
                "myFunction(3) should return 9 (3 squared)");
        end
    end
end
```

The file name and class name must match exactly (including capitalization).
Every test method inside the class should be a small, independent test case.
Use assertions like:
verifyEqual(a, b)
verifyTrue(condition)
verifyError(@() code, 'ErrorID')
For more, see the MATLAB Unit Test documentation at:
https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html

# ▶️ How to Run the Tests Locally (to test you tests)

From within this folder, run:

run_all_tests

This will automatically:

- Discover all test classes in the folder (and subfolders).
- Display detailed results including test names, outcomes, and execution time.

# 📂 Summary

run_all_tests.m: Script to run all tests with detailed output.
TestExample.m: A minimal example test — feel free to copy it as a starting point.
Your own test files go here (e.g., TestSignalProcessing.m, TestImportData.m, etc.)
If you're unsure where to start, copy TestExample.m, rename it, and modify it to test your own function.

# Advanced Information / Something went wrong in Deployment?
When you want to test tests, you should not do it on the main branch. Use the brach named ci-testing made for that. Whenever you push to that brach or to main, test will be run on a cloud server using a GitHub action workflow. You can see the test workflow under .github/workflows/matlab-unit-tests.yml. 

As you can see in the GitHub actions workflow, we are using actions to run matlab tests:

- name: Run Tests
    uses: matlab-actions/run-tests@v2 # In theory this triggers all tests in the /tests folder
    with:
        source-folder: tests
        select-by-folder: tests

All the information about this GitHub Action is here https://github.com/marketplace/actions/run-matlab-tests. 