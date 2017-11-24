import os
import sys
import subprocess
from zipfile import ZipFile

# Added by BCT for python 2/3 compatibility

def str_join(*args):
    return ''.join(map(str, args))

def unzipAll(dirpath):
	print( str_join( "Checking: ", dirpath ) )
	contents = os.listdir(dirpath)

	# Does dir contain any zip files?
	containsZips = 0
	for f in contents:
		if len(f) > 4 and f[-4:].lower() == ".zip":
			# Try to unzip them
			containsZips = 1
			zfname = os.path.join(dirpath, f)
			try:
				os.chdir(dirpath)
				zf = ZipFile(f)
				zf.extractall()
				print( str_join( "Unzipped ", zfname ) )
			except:
				print( str_join( "Failed to unzip ", zfname ) )
	
	contents = os.listdir(dirpath)
	for d in contents:
		fullpath = os.path.join(dirpath, d)
		if os.path.isdir(fullpath):
			unzipAll(fullpath)
			
def buildCompilers(dirpath, forceRebuild=False):
	cwd = os.getcwd()

	# Unzip first
	print( "Unzipping..." )
	unzipAll(dirpath)
	print( "Unzip complete\n\n\n" )

	# Build compilers and make a list of their full paths
	compilers = []

	print( "Building..." )
	for path, dirs, files in os.walk(dirpath, topdown=True):
		os.chdir(path)

		# Does it already contain a compiler? If so, skip unless force rebuild is true
		if not forceRebuild:
			compilerFound = 0
			for f in files:
				if f.lower() == "spl.exe":
					compilerFound = 1
					compiler = os.path.join(path, f)
					print( str_join("Found existing compiler: ", compiler) )
					compilers.append(compiler)
					break
			if compilerFound:
				continue

		# Build the .l file
		flex = 0
		for f in files:
			fullname = os.path.join(path, f)
			if f.lower() == "spl.l":
				# Flex it
				ok = subprocess.call(str_join("flex \"", fullname, "\""), shell=True)
				if ok == 0:
					print( str_join( "Flex OK       ", fullname) )
					flex = 1
				else:
					print( str_join( "Flex failed   ", fullname) )
				break
			if len(f) > 4 and f[-2:].lower() == ".l":
				# Flex it
				ok = subprocess.call( str_join("flex \"", fullname, "\""), shell=True)
				if ok == 0:
					print( str_join( "Flex OK       ", fullname) )
					flex = 1
				else:
					print( str_join( "Flex failed   ", fullname) )
				break

		if not flex:
			continue # skip this one

		# Build the .y file
		bison = 0
		bisonName = ""
		for f in files:
			fullname = os.path.join(path, f)
			if f.lower() == "spl.y":
				# Bison it
				ok = subprocess.call(str_join("bison \"", fullname, "\""), shell=True)
				if ok == 0:
					print( str_join( "Bison OK      ", fullname) )
					bison = 1
					bisonName = os.path.join(path, str_join(f[0:-1], "tab.c") )
				else:
					print( str_join( "Bison failed  ", fullname) )
				break
			if len(f) > 4 and f[-2:].lower() == ".y":
				# Bison it
				ok = subprocess.call( str_join( "bison \"", fullname, "\""), shell=True)
				if ok == 0:
					print( str_join( "Bison OK      ", fullname) )
					bison = 1
					bisonName = os.path.join(path, str_join(f[0:-1], "tab.c") )
				else:
					print( str_join( "Bison failed  ", fullname) ) 
				break

		if not bison:
			print( str_join( "Failed to build parser for ", path ) )
			continue # skip this one

		# Build the compiler and remember it
		gcc = 0
		splc = os.path.join(path, "spl.c")
		if sys.platform == "win32" or sys.platform == "windows":
			ok = subprocess.call( str_join("gcc \"", splc, "\" \"", bisonName, "\" -ospl.exe -lfl -Le:\\gnuwin32\lib"), shell=True)
		else:
			ok = subprocess.call( str_join("gcc \"", splc, "\" \"", bisonName, "\" -ospl.exe -ll"), shell=True)
		compilerName = os.path.join(path, "spl.exe")
		if ok == 0:
			compilers.append(compilerName)
			print( str_join( "GCC OK        ", compilerName) )
			print( str_join("Compiler found: ", compilerName, "\n") )
			gcc = 1
		else:
			print( str_join( "GCC failed    ", compilerName, "\n") )


	os.chdir(cwd)

	return compilers
