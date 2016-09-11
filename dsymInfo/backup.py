#!/usr/bin/env python
# -*- coding: utf-8 -*-

# http://wufawei.com/2014/03/symbolicating-ios-crash-logs/
# http://maxao.free.fr/xcode-plugin-interface/build-settings.html#variables

import os
import sys
import time
import shutil
import commands
from stat import *

MAX_DSYM_COUNT = 4
MAX_LIFE_TIME = 3 * 24 * 60

def dsymFilePath():
	execName = os.environ["EXECUTABLE_NAME"]
	dsymPath = os.environ["BUILT_PRODUCTS_DIR"] + "/" + os.environ["PRODUCT_NAME"] + ".app.dSYM"
	print 'dsymPath: ' + dsymPath
	return dsymPath

def workDir():
	currentDir = os.path.dirname(os.path.realpath(__file__))
	print "workDir: " + currentDir
	return currentDir

def addSpotlightIndex(dirPath):
	if not os.path.exists(dirPath):
		return
	cmdStr = "mdimport " + dirPath
	print "add index cmdStr: " + cmdStr
	s, ret = commands.getstatusoutput(cmdStr)
	print "cmdStr ret: " + str(s)

def createDSymFile():
	execName = os.environ["EXECUTABLE_NAME"]
	execPath = os.environ["BUILT_PRODUCTS_DIR"] + "/" + os.environ["PRODUCT_NAME"] + ".app" + "/" + execName
	outPath = os.environ["BUILT_PRODUCTS_DIR"] + "/" + os.environ["PRODUCT_NAME"] + ".dSYM.gy"
	cmdStr = "xcrun dsymutil " + execPath + " -o " + outPath + " 2> /dev/null"
	print "dsymutil cmdStr: " + cmdStr
	s, ret = commands.getstatusoutput(cmdStr)
	print "cmdStr ret: " + str(s)
	return outPath

def uuidOfFile(file):
	if len(file) <= 0:
		return ""
	cmdStr = "xcrun dwarfdump -u " + file
	print "uuid cmdStr: " + cmdStr
	s, ret = commands.getstatusoutput(cmdStr)
	print "cmdStr ret: " + ret
	return ret.split()[1]

def deleteDSymFile():
	destDir = workDir() + "/dSYM"
	print destDir
	if not os.path.exists(destDir):
		print "no destDir: " + destDir
		return

	files = []
	for f in os.listdir(destDir):
		if f.endswith(".dSYM"):
			path = destDir + "/" + f
			files.append(path)
	files.sort(key=lambda x: os.path.getmtime(x))
	files.reverse()
	print "files: ", files
	count = len(files)
	if count > MAX_DSYM_COUNT:
		for i in range(MAX_DSYM_COUNT, count):
			print "delete dsym file 1: " + files[i]
			shutil.rmtree(files[i])

	currentTime = time.time()
	print "currentTime: " + str(currentTime)
	for f in files:
		if not os.path.exists(f):
			continue
		modifyTime = os.stat(f)[ST_MTIME]
		print "f: %s, modifyTime: %s, diff: %s" % (f, str(modifyTime), str(currentTime - modifyTime))
		if currentTime - modifyTime > MAX_LIFE_TIME:
			print "delete dsym file 2: " + f
			shutil.rmtree(f)

def copyDSymFile():
	isGen = False
	srcPath = dsymFilePath()
	if not os.path.exists(srcPath):
		isGen = True
		srcPath = createDSymFile()

	if not os.path.exists(srcPath):
		print "source dSYM not found: " + srcPath
		return
	else:
		print "source dSYM found: " + srcPath

	destDir = workDir() + "/dSYM"
	execName = os.environ["EXECUTABLE_NAME"]
	uuid = uuidOfFile(srcPath + "/Contents/Resources/DWARF/" + execName)
	destPath = destDir + "/" + execName + "_" + uuid + ".dSYM"
	print "destPath: " + destPath
	if os.path.exists(destPath):
		print "destPath alread exists"
	else:
		shutil.copytree(srcPath, destPath)
		addSpotlightIndex(destDir)

	if isGen:
		shutil.rmtree(srcPath)

def canRun():
	if os.environ["EFFECTIVE_PLATFORM_NAME"] == "-iphonesimulator":
		print "is iphonesimulator build, just return"
		return False
	return True

if __name__ == '__main__':
	print "backup.py main start"
	if canRun():
		print "can run"
		try:
			deleteDSymFile()
			copyDSymFile()
		except Exception, err:
			print "warning: unhandled exception:"
			print Exception, err
	else:
		print "cannot run"
	print "backup.py main end"
