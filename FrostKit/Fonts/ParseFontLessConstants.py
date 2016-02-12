#!/usr/bin/env python

'''
  ParseFontLessConstants.py
  FrostKit
  
  Created by James Barrow on 06/02/2015.
  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
  
  This script takes in a list of less file names that refer to files in the LessConstantsFiles
  directory. This script then loops though thouse files and converts them into a single Swift
  file that contains all the public constants for every icon font included.
  
  This script is run from the FontConstantsBuilder target.
'''

import datetime, sys

def todaysFormattedDate():
  today = datetime.datetime.now()
  return today.strftime('%d/%m/%Y %H:%M:%S')

def parseFontConsatnts(inputPath, outputPath):
  name = inputPath.split('.')[0]
  contents = ''
  contents += '\n/*\n------------------------------\n'
  contents += name
  contents += '\n------------------------------\n*/\n\n'
  contents += 'public struct ' + name + ' {\n'

  openObject = open('LessConstantsFiles/' + inputPath)
  openFile = openObject.read()
  
  for line in openFile.splitlines():
    if 'var' in line:
      line = line.split('-var-')[1]
      line = line.replace('-', '_')
      line = line.replace(' ', '')
      line = line.replace('\"', '')
      line = line.replace('\\', '')
      line = line.replace(';', '')

      components = line.split(':')

      # Fix Pre-Swift 2.2 phrases
      if components[0] in ['repeat', 'subscript', 'try']:
        components[0] = components[0] + "_"

      swiftLine = '\tpublic static let ' + components[0] +' = \"\\u{' + components[1] + '}\"\n'

      contents += swiftLine

  contents += '}\n'

  return contents

def parseFonts(fonts):
  outputPath = 'FontConstants.swift'
  contents = """//
//  FontConstants.swift
//  FrostKit
//
//  Created by James Barrow on 06/02/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//  Last updated on %s.
//
""" %(todaysFormattedDate())
  
  for font in fonts:
    contents += parseFontConsatnts(font, outputPath)

  writeObject = open(outputPath, 'wb')
  writeObject.write(contents)

def main():
  fileNames = sys.argv[1].split(' ')
  parseFonts(fileNames)

if __name__ == "__main__":
  main()
