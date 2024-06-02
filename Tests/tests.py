import os
import re
import unittest
from colorama import Fore, Style
import pyfiglet
from collections import defaultdict

# Initialize colorama
from colorama import init
init()

path = './'

current_path = os.getcwd().split('/')[-1]
if current_path != "Tests":
    path = 'Tests/'

PathTestsTrue = path + "result-True.txt"
PathTestsFalse = path + "result-False.txt"
files_dir = path + "test-files"
true_dir = "True"
false_dir = "False"
testSepartor = "-TEST-\n"
error_message = 'ERROR: syntax error'

ascii_art = pyfiglet.figlet_format(" Tests")
print(Fore.BLUE + Style.BRIGHT + ascii_art + Fore.RESET + Style.RESET_ALL)

def count_files(directory):
    return len(os.listdir(directory))

class TestPDFValidity(unittest.TestCase):
    def test_true_cases(self):
        with open(PathTestsTrue, "r") as f:
            content = f.read()
            tests = content.split(testSepartor)[1:]
            self.assertEqual(len(tests), count_files(files_dir + "/" + true_dir))
            for test_index, test in enumerate(tests, 1):
                lines = test.strip().split('\n')
                file = lines[0]
                with self.subTest(test_index=test_index):
                    for line in lines:
                        if line.startswith('LAST LINE:'):
                            last_line = line.split(': ')[1]
                        elif line.startswith('REF:'):
                            ref = line.split(': ')[1]
                        elif line.startswith('Version:'):
                            version = line.split(': ')[1]
                    with open(path + '/'.join(file.split("/")[1:]), "rb") as f:
                        lines = f.readlines()
                        last_line_f = lines[-1].decode('utf-8').strip("\n")
                        second_last_line_f = lines[-2].decode('utf-8').strip("\n")
                        first_line = lines[0].decode('utf-8').strip("\n")
                        self.assertEqual(last_line, last_line_f)
                        self.assertEqual(first_line, version)
                        self.assertEqual(second_last_line_f, ref)
                        self.assertTrue(re.match(r'%PDF-\d+\.\d+', version))

    def test_false_cases(self):
        with open(PathTestsFalse, "r") as f:
            content = f.read()
            tests = content.split(testSepartor)[1:]
            self.assertEqual(len(tests), count_files(files_dir + "/" + false_dir))
            for test_index, test in enumerate(tests, 1):
                lines = test.strip().split('\n')
                file = lines[0]
                result = lines[1:]
                with self.subTest(test_index=test_index):
                    self.assertEqual(len(result), 1)
                    self.assertEqual(result[0], error_message)


if __name__ == '__main__':
    # Custom Test Runner to add color to test results and generate a summary report
    class ColoredTextTestResult(unittest.TextTestResult):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, **kwargs)
            self.successes = []
            self.subtest_successes = []
            self.subtest_failures = []

        def addSuccess(self, test):
            super().addSuccess(test)
            self.successes.append(test)
            print(Fore.GREEN + Style.BRIGHT + '✓ ' + Fore.RESET + Style.RESET_ALL + str(test))

        def addFailure(self, test, err):
            super().addFailure(test, err)
            print(Fore.RED + Style.BRIGHT + '✗ ' + Fore.RESET + Style.RESET_ALL + str(test))

        def addSubTest(self, test, subtest, outcome):
            super().addSubTest(test, subtest, outcome)
            if outcome is None:
                self.subtest_successes.append(subtest)
                print(Fore.GREEN + Style.BRIGHT + '✓ ' + Fore.RESET + Style.RESET_ALL + str(subtest))
            else:
                self.subtest_failures.append((subtest, outcome))
                print(Fore.RED + Style.BRIGHT + '✗ ' + Fore.RESET + Style.RESET_ALL + str(subtest))

        def print_summary(self):
            print(Fore.BLUE + Style.BRIGHT + "\nTest Summary Report" + Fore.RESET + Style.RESET_ALL)
            print(Fore.GREEN + Style.BRIGHT + f"Successful Tests: {len(self.successes)}" + Fore.RESET + Style.RESET_ALL)
            print(Fore.GREEN + Style.BRIGHT + f"Successful Subtests: {len(self.subtest_successes)}" + Fore.RESET + Style.RESET_ALL)
            print(Fore.RED + Style.BRIGHT + f"Failed Subtests: {len(self.subtest_failures)}" + Fore.RESET + Style.RESET_ALL)

            if self.subtest_failures:
                print(Fore.RED + Style.BRIGHT + "\nFailed Subtests Details:" + Fore.RESET + Style.RESET_ALL)
                for subtest, outcome in self.subtest_failures:
                    print(Fore.RED + f"{subtest} - {outcome}" + Fore.RESET)

            # Generate and print the bar chart
            total_subtests = len(self.subtest_successes) + len(self.subtest_failures)
            success_rate = (len(self.subtest_successes) / total_subtests) * 100 if total_subtests else 0
            failure_rate = (len(self.subtest_failures) / total_subtests) * 100 if total_subtests else 0

            print(Fore.BLUE + Style.BRIGHT + "\nTest Results Chart" + Fore.RESET + Style.RESET_ALL)
            print("Successes: " + Fore.GREEN + Style.BRIGHT + "|" * int(success_rate // 2) + Fore.RESET + Style.RESET_ALL + f" {success_rate:.2f}%")
            print("Failures:  " + Fore.RED + Style.BRIGHT + "|" * int(failure_rate // 2) + Fore.RESET + Style.RESET_ALL + f" {failure_rate:.2f}%")

    class ColoredTextTestRunner(unittest.TextTestRunner):
        resultclass = ColoredTextTestResult

        def run(self, test):
            result = super().run(test)
            result.print_summary()
            return result

    unittest.main(testRunner=ColoredTextTestRunner())
