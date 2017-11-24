import os
import sys
import subprocess
from datetime import datetime

# Set system dependant file slash
# print( sys.platform )
if sys.platform == "win32" or sys.platform == "windows":
	S = "\\"
	DEL = "del"
else:
	S = "/"
	DEL = "rm"

# Added by BCT for python 2/3 compatibility
def str_join(*args):
    return ''.join(map(str, args))

script = sys.argv[0]
path = os.path.dirname(os.path.abspath(script))
sys.path.insert(0, path)
from buildTheCompilers import *	
	
allTestFiles = os.listdir(str_join(path, S, "Tests") )
testSPLfiles = []
compilers = []

if len(sys.argv) < 2:
	print( "Usage: runTests <SPL compiler exe> [report=<file>]\n\t\t(will test compiler)" )
	print( "or:	  runTests all <dir name> [report=<file>]\n\t\t(will unzip, build, and test all compilers in <dir>)" )
	print( "or:	  runTests clean 				\n\t\t(will clean test directory)" )
	print( "If [report=<file>] is present, test program will write results to that file" )
	sys.exit(1)
elif sys.argv[1] == "clean":
	# Clean up
	print( "Tidying up test directory" )
	# An obscure fact that quotes can be in the middle of globbed strings in windows and linux
	subprocess.call(str_join( DEL, " \"", path, S, "Tests", S, "\"*.log"), shell=True)
	subprocess.call(str_join( DEL, " \"", path, S, "Tests", S, "\"*.exe"), shell=True)
	subprocess.call(str_join( DEL, " \"", path, S, "Tests", S, "\"*.c"), shell=True)
	sys.exit(0)
elif sys.argv[1] == "all":
	if len(sys.argv) < 3:
		print( "Missing directory specifier" )
	else:
		fullpath = os.path.abspath(sys.argv[2])

		print( fullpath )
		compilers = buildCompilers(fullpath)
		print( str_join(len(compilers), " compilers detected" ) )

report = None
for n in sys.argv:
	if n[0:7].lower() == "report=":
		report = file(n[7:], "w")

if len(compilers) == 0:
	compilers.append(sys.argv[1])

# Find SPL files to test
for f in allTestFiles:
	if f.find(".") != -1:
		dotIndex = f.rfind(".")
		extension = f[dotIndex+1:]
		if extension.lower() == "spl":
			testSPLfiles.append(f)

print( "\n\n" )
startTime = datetime.now()

########################################
# Begin Testing 
########################################

# Note
# ----
# There are four types of tests:
# - Tests that should definitely compile and execute; if compilation fails, or the output doesn't match, the test fails
# - Tests that may not compile, depending on assumptions made about SPL (if it does compile, output is compared)
# - Tests that should not compile really, but could potentially compile and produce a warning (e.g. final semicolon)
# - Thats that should definitely not compile, e.g. due to syntax errors etc
#
# Category 1 are 'codegen' tests, meaning they should generate code
# Category 2 are 'option' tests, meaning they could or could not generate code
# - Includes things like typing; some compilers may choose to prevent type coercion, for example
# - Other possibilities include quitting on any semantic error, e.g. program identifiers not matching
# Category 3 are 'warning' tests; they can produce code but if so should produce a warning (check error output)
# - Includes relaxation of syntax errors, e.g. the final semicolon
# - Again, may include semantic errors, e.g. technically assigning a non-letter to a character type should fail
# Category 4 are 'error' tests and simply should not produce any .c files; if they do, this is a fail
#
# Test rules
# - For the output comparison to work, floating point numbers should be output to their own line; the test
#   harness will then try to match them even if the precision in each file differs
# - The first line of the test output file should be one of the above category descriptors prefixed with 
#   a hash # (if absent, then codegen is assumed)
# - All tests should be listed and described in tests.txt

def readfile(filename):
	if sys.version_info[0] > 2:
		f = open(filename,"r")
	else:
		f = file(filename,"r")
	text = ""
	r = f.readline()
	while len(r) > 0:
		text += r
		r = f.readline()
	f.close()
	return text

def reportEntry(reportFile, message, ignoreEndline=False):
	if not ignoreEndline:
		print( message )
	else:
		sys.stdout.write( str_join( message, " " ) )
		sys.stdout.flush()
	if reportFile:
		if not ignoreEndline:
			reportFile.write(str_join(message, "\n") )
		else:
			reportFile.write(str_join(message, " ") )

def runTest(compiler, testFile, report):

	sanitisedCompiler = str_join("\"", compiler, "\"")

	testName = testFile[0:testFile.find(".")]
	reportEntry(report, str_join( "Running test: ", testName), True)

	##################################
	# Try to find expected output file
	testExpectedOutput = str_join(path, S, "Tests", S, testName, "-output.txt")
	testType = 1 # codegen
	testExpectedOutputFile = open(testExpectedOutput, "r")
	if testExpectedOutputFile:
		r = testExpectedOutputFile.readline()
		r = r.strip()
		if r == "#error":
			testType = 4 # Should not compile; don't read expected output file
			testExpectedOutputFile.close()
			testExpectedOutputFile = None
		elif r == "#warning":
			testType = 3 # No compile is acceptable, but could also produce results
		elif r == "#option":
			testType = 2 # No compile is acceptable, but could also produce results
		elif r == "#codegen":
			testType = 1 
		else: # No hash identifier - assume test type 1
			testExpectedOutputFile.seek(0)

	########################################
	# Try to compile SPL file using compiler
	cfile = str_join(path, S, "Tests", S, testName, ".c")
	tfile = str_join(path, S, "Tests", S, testFile )
	lfile = str_join(path, S, "Tests", S, testName, "-spl_errors.log" )
	cmdStr = str_join(compiler, " < \"", tfile, "\" > \"", cfile, "\" 2> \"", lfile, "\"")
	# print( cmdStr )
	try:
		result = subprocess.call(cmdStr, shell=True)
	except:
		print(str_join("Compiler failed: ", cmdStr) )
		
	# Can't rely on result here, so check for presence of non-empty C file
	ansiCompliant = "[ No file made ]"

	if os.access(cfile, os.R_OK):
		# C file was generated; check number of braces to find out whether it is complete or not
		try:    
			if sys.version_info[0] > 2:
				cf = open(cfile, "r")
			else:
				cf = file(cfile, "r")
			data = cf.readlines()
			# print( data )
			cf.close()
			data = "".join(data)
			numOpenBraces = data.count("{")
			numCloseBraces = data.count("}")
			# print( str_join( numOpenBraces, numCloseBraces, data) )
			if numCloseBraces == 0 or numOpenBraces != numCloseBraces:
				if testType == 1: # Should be valid file
					reportEntry(report, str_join("Failed\t", ansiCompliant, " - Empty or incomplete C file generated from SPL file") )
					return 0
				elif testType == 2:
					reportEntry(report, str_join( "Passed?\t", ansiCompliant, " - Optional test (may codegen or not) - incomplete or empty C file generated, possible abort on error?") )
					return 1
				elif testType == 3:
					reportEntry(report, str_join("Passed?\t", ansiCompliant, " - Warning test (may codegen or not) - incomplete or empty C file generated, possible abort on error?") )
					return 1
				else: # testType == 4
					reportEntry(report, str_join("Passed?\t", ansiCompliant, " - Error test - SPL file should not compile. Incomplete or empty C file generated, possible abort on error?") )
					return 1
			else:
				cfileOK = 1
		except:
			reportEntry(report, str_join( "Error \t", ansiCompliant, " - Error while reading generated C file") )
	else:
		# No C file generated
		if testType == 1: # Should be valid file
			reportEntry(report, str_join( "Failed\t", ansiCompliant, " - No C file produced by SPL compiler") )
			return 0
		elif testType == 2:
			reportEntry(report, str_join( "Passed\t", ansiCompliant, " - Optional test - SPL compiler may choose not to compile this test; no C file generated") )
			return 1
		elif testType == 3:
			reportEntry(report, str_join( "Passed\t", ansiCompliant, " - Warning test - SPL compiler may choose not to compile this test; no C file generated") )
			return 1
		else: # testType == 4
			reportEntry(report, str_join( "Passed\t", ansiCompliant, " - Error test - SPL file should not compile; no C file generated") )
			return 1

	# If a C file was generated for a #warning test, are there any warnings generated on stderr?
	#if testType == 3:
	#	# Does compiler generate a non-empty warning file?
	#	warnings = readfile("Tests/" + testName + "-spl_errors.log")
	#	if len(warnings) == 0:
	#		reportEntry(report, "Failed\t - SPL file may compile, but should produce compilation warnings -- file compiled and no warnings detected")
	#		return 0
	#	else:
	#		pass # OK for now
	
	# If a C file was generated for an #error test, this is wrong!
	ansiCompliant = "[Built bad SPL!]"
	if testType == 4:
		reportEntry(report, str_join( "Failed\t", ansiCompliant, " - SPL file is invalid and should not have compiled, but it did") )
		return 0

	#################################
	# Try to compile C file using GCC
	ansiCompliant = "[ Built bad C! ]"
	cmdStr = str_join( "gcc \"", path, S, "Tests", S, testName, ".c\" -o \"", path, S, "Tests", S, testName, ".exe\" 2> \"", path, S, "Tests", S, testName, "-gcc_errors.log\"" )
	result = subprocess.call(cmdStr, shell=True)
	if result != 0: 
		reportEntry(report, str_join( "Failed\t", ansiCompliant, " - Could not compile C file with GCC") )
		return 0

	#########################################
	# Check ANSI compliance if compile worked
	if sys.version_info[0] > 2:
		fnull = open(os.devnull, 'w')
	else:
		fnull = file(os.devnull, 'w')
	ansiCompliant = "[ - Not ANSI - ]"
	cmdStr = str_join("gcc -ansi \"", path, S, "Tests", S, testName, ".c\"")
	result = subprocess.call(cmdStr, stdout=fnull, stderr=fnull, shell=True)
	if result == 0: 
		ansiCompliant = "[ANSI compliant]"
		#reportEntry(report, "C file compiled but is not strict ANSI compliant")
		#return 0
	fnull.close()

	############################################
	# Try to execute compiled file using timeout

	# Note - the error level cannot necessarily be trusted, so check for output (or exceptions) instead
	# A file with int main but no return will likely give errorlevel 10
	# A file with void main will likely give errorlevel 0
	# A file that throws an exception will likely give a big negative number errorlevel
	if sys.platform == "win32" or sys.platform == "windows":
		cmdStr = str_join("\"", path, S, "Tests", S, testName, ".exe\"")
	else:
		cmdStr = str_join(path, S, "Tests", S, testName, ".exe")
	# print ( cmdStr )
	# Is there an input file?
	inputFileStr = str_join(path, S, "Tests", S, testName, "-input.txt") 
	inputFile = None
	if os.access(inputFileStr, os.R_OK):
		if sys.version_info[0] > 2:
			inputFile = open(inputFileStr, "r")
		else:
			inputFile = file(inputFileStr, "r")

	# Spawn new process and wait 5 seconds for it to complete, then kill it
	progOutputFileStr = str_join(path, S, "Tests", S, testName, "-execute.log")
	if sys.version_info[0] > 2:
		progOutputFile = open(progOutputFileStr, "w")
	else:
		progOutputFile = file(progOutputFileStr, "w")
	waitTimer = datetime.now()
	process = subprocess.Popen(cmdStr, shell=False, stdin=inputFile, stdout=progOutputFile)
	terminated = 0
	# Allow manual interrupt
	try:
		while process.poll() == None:
			# V2.7 timeElapsed = (datetime.now() - waitTimer).total_seconds()
			td = (datetime.now() - waitTimer)
			# See http://stackoverflow.com/questions/10339593/computing-total-seconds-in-python-for-datetime-module-with-true-division-enabled
			# and https://docs.python.org/2/library/datetime.html
			timeElapsed = (td.microseconds + (td.seconds + td.days * 24 * 3600) * 10**6) / 10.0**6
			if timeElapsed > 5:
				try:
					process.terminate() # May throw exception if already finished by this point
					terminated = 1
				except:
					pass
	except:
		terminated = 1
	result = process.poll()
	if inputFile:
		inputFile.close()
	if progOutputFile:
		progOutputFile.close()
	#result = subprocess.call(cmdStr, shell=True)
	if terminated:
		reportEntry(report, str_join("Failed\t", ansiCompliant, " - SPL program appeared to hang and was terminated") )
		return 0
	if result < 0: # Exception
		reportEntry(report, str_join("Failed\t", ansiCompliant, " - SPL program threw exception during execution") )
		return 0

	######################################
	# Check output against expected output
	if testExpectedOutputFile:
		r1 = testExpectedOutputFile.readline().rstrip('\r\n')

		# Open output
		actualOutputStr = str_join(path, S, "Tests", S, testName, "-execute.log")
		actualOutput = None
		if os.access(actualOutputStr, os.R_OK):
			if sys.version_info[0] > 2:
				actualOutput = open(actualOutputStr, "r")
			else:
				actualOutput = file(actualOutputStr, "r")
		else:
			reportEntry(report, str_join( "Error\t ", ansiCompliant, " - Cannot open program output ", testName, "-execute.log"))
			return 0
		if not actualOutput:
			reportEntry(report, str_join( "Error\t ", ansiCompliant, " - Cannot open program output ", testName, "-execute.log"))
			return 0
		# read line removing line end chars
		r2 = actualOutput.readline().rstrip('\r\n')

		while len(r1) > 0:
			if r1.find(".") != -1 or r2.find(".") != -1:
				# Contains real numbers on this line -- check the hard way
				try:
					float1 = float(r1)
					float2 = float(r2)
				except:
					reportEntry(report, str_join( "Failed\t", ansiCompliant, " - Test output contains invalid float") )
					actualOutput.close()
					return 0
				if float1 != float2:
					reportEntry(report, str_join( "Failed\t", ansiCompliant, " - Test output different to expected output (in real numbers)") )
					actualOutput.close()
					return 0
			elif r1 != r2: # Normal lines
				reportEntry(report, str_join( "Failed\t", ansiCompliant, " - Test output different to expected output") )
				actualOutput.close()
				return 0

			# Read next lines - trim line ends for portability
			r1 = testExpectedOutputFile.readline().rstrip('\r\n')
			r2 = actualOutput.readline().rstrip('\r\n')
			if len(r2) == 0 and len(r1) > 0:
				reportEntry(report, str_join( "Failed\t", ansiCompliant, " - Test output different length to expected output") )
				actualOutput.close()
				return 0
			elif len(r1) == 0 and len(r2) > 0:
				reportEntry(report, str_join( "Failed\t", ansiCompliant, " - Test output different length to expected output") )
				actualOutput.close()
				return 0
	else:
		reportEntry(report, str_join( "Error\t ", ansiCompliant, " - Cannot verify program output -- expected output file ", testExpectedOutput, " missing") )
		return 0

	# All done
	if testType == 1:
		reportEntry(report, str_join( "Passed\t", ansiCompliant) )
	elif testType == 2:
		reportEntry(report, str_join( "Passed\t", ansiCompliant, " - Optional test - SPL compiler may choose to compile or not, and chose to compile") )
	elif testType == 3:
		reportEntry(report, str_join( "Passed\t", ansiCompliant, " - Warning test - SPL compiler can compile this code, but should produce warnings") )
	if testExpectedOutputFile:
		testExpectedOutputFile.close()
	return 2

compilersTested = 0

print( "------------------------" )
print( "Testing all compilers..." )
print( "------------------------\n" )
for compiler in compilers:

	# Try to extract student name from compiler path if we can
	searchStr = "08348 Compilers Assessment"
	nameIndex = compiler.find(searchStr)
	prelen = len(searchStr)
	studentName = ""
	if nameIndex > 0:
		# Get the path and print the name
		studentName = compiler[nameIndex + prelen + 1:compiler.find(S, nameIndex + prelen + 2)]
		reportEntry(report, studentName)

	reportEntry(report, str_join( "Testing compiler: ", compiler) )
	if not os.access(compiler, os.X_OK):
		reportEntry(report, str_join( "Cannot find compiler: ", compiler) )
		continue # Skip it
	# Check for plain localname, make relative path for shell
	if os.path.basename(compiler) == compiler:
		compiler = str_join(".", S, compiler)
		
	# Test function
	passed = 0

	# Run all tests
	numExecutedTests = 0
	for f in testSPLfiles:
		result = runTest(compiler, f, report)
		if result > 0:
			passed += 1
			if result == 2:
				numExecutedTests += 1

	# Output summary
	if studentName != "":
		reportEntry(report, studentName + "'s compiler ")
	percent = passed * 100 / len(testSPLfiles)
	reportEntry(report, str_join("Passed ", passed, " tests out of ", len(testSPLfiles), " (", percent, "%)") )
	#reportEntry(report, "Executed " + numExecutedTests + " test programs successfully")
	compilersTested += 1

	if len(compilers) > 1:
		print( "Tidying up test directory" )
		# An obscure fact that quotes can be in the middle of globbed strings in windows and linux
		subprocess.call(str_join(DEL, " \"", path, S, "Tests", S, "\"*.log"), shell=True)
		subprocess.call(str_join(DEL, " \"", path, S, "Tests", S, "\"*.exe"), shell=True)
		subprocess.call(str_join(DEL, " \"", path, S, "Tests", S, "\"*.c"), shell=True)	
	reportEntry(report, "\n------------------------\n")

	# Flush if we can
	if report:
		report.flush()

reportEntry(report, str_join( "Done: " , compilersTested,  " compilers tested out of ", len(compilers) ) )

# if sys.version_info[0] > 2: 
    # timeElapsed = (td.microseconds + (td.seconds + td.days * 24 * 3600) * 10**6) / 10.0**6
	# mins = int(diffTime.total_seconds() / 60)
	# secs = int(diffTime.total_seconds() - mins * 60)
# else: 
endTime = datetime.now()
diffTime = endTime - startTime
mins = (diffTime.seconds / 60.0)
secs = diffTime.seconds
	
reportEntry(report, str_join( "Time elapsed: ", mins, "m ", secs, "s") )

if report:
	report.close()
