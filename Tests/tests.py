import os
import re
import unittest
from colorama import Fore, Style
import pyfiglet

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


class TestPDFValidity(unittest.TestCase):
    def test_true_cases(self):
        with open(PathTestsTrue, "r") as f:
            content = f.read()
            tests = content.split(testSepartor)[1:]
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
            for test_index, test in enumerate(tests, 1):
                lines = test.strip().split('\n')
                file = lines[0]
                result = lines[1:]
                with self.subTest(test_index=test_index):
                    self.assertEqual(len(result), 1)
                    self.assertEqual(result[0], error_message)

if __name__ == '__main__':
    # Custom Test Runner to add color to test results
    class ColoredTextTestResult(unittest.TextTestResult):
        def addSuccess(self, test):
            super().addSuccess(test)
            print(Fore.GREEN + Style.BRIGHT + '✓ ' + Fore.RESET + Style.RESET_ALL + str(test))

        def addFailure(self, test, err):
            super().addFailure(test, err)
            print(Fore.RED + Style.BRIGHT + '✗ ' + Fore.RESET + Style.RESET_ALL + str(test))

    unittest.main(testRunner=unittest.TextTestRunner(resultclass=ColoredTextTestResult))
