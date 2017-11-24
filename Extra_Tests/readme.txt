Martin Walker's automated ACW testing scripts
---------------------------------------------

Designed to run on python 2.x and 3.x on al operating systems. 
Please advise of any portability issues.

Usage:

 runTests <spl compiler exe> [report=<file>]  -- Will test an individual compiler and produce an optional report file
 runTests all <directory> [report=<file>]     -- Will unzip, build, and test all compilers in the given directory
 runTests clean                               -- Cleans up the test directory

The tests are all found in the Tests subdirectory. In general there is:

- A test .SPL file
- An output.txt file that contains the expected output of the compiled SPL program (assuming it compiles)
- An input.txt file containing input that will be piped to the compiled SPL program (most tests do not have this)

The Tests.txt file contains a list of the tests and summarises what they are testing for. Different types of tests expect/allow different results:

#codegen = To pass this test, the given compiler should produce valid C code that can be compiled and executed.
#warning = In most cases, failing to produce valid C code here would be an error, but if the compiler is unusually strict in its semantics checking it could be valid to fail.
#error   = This test is expected to cause an error. This should be handled gracefully rather than simply crashing.
#option  = A less strict version of #warning; failing to produce C code here is acceptable (as long as it failed gracefully).
