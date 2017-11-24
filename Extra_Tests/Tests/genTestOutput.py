import os

files = os.listdir(".")
highestTest = 0
for f in files:
	if f.lower().endswith("-output.txt"):
		testNum = f[4:7]
		testNum = int(testNum)
		if testNum > highestTest:
			highestTest = testNum

highestTest += 1
if highestTest < 100:
	highestTest = "0" + `highestTest`
else:
	highestTest = `highestTest`

# Generate that file
print "1. #codegen"
print "2. #option"
print "3. #warning"
print "4. #error"
print "Enter test type"
testtype = raw_input().strip()
if testtype == "1":
	testtype = "#codegen"
elif testtype == "2":
	testtype = "#option"	
elif testtype == "3":
	testtype = "#warning"
elif testtype == "4":
	testtype = "#error"	
else:
	print "Error!"
	os.exit(1)
print "Enter expected output"
output = raw_input().strip()

tf = file("Test" + highestTest + "-output.txt","w")
tf.write(testtype + "\n")
tf.write(output + "\n")
tf.close()
os.system("type " + "Test" + highestTest + "-output.txt")