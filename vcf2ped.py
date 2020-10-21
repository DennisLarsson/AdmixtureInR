#!/usr/bin/python3
#convert vcf to plink
#Made by Dennis Larsson @ University of Vienna 2020
#Because the ped format require "proper" chromosome names I have made a script that will first fix this issue in a Stacks generated vcf file (chromosome names are numbers, which plink confuses with actual chromosome number).
#Then then script runs a command that runs plink and converts the vcf to ped format in the 12-format that is needed for Admixture 

#run like this: path/to/vcf2ped.py -i path/to/myOrganism.vcf -o path/to/myOrganism
#not that there should be not file ending on the outputfile, plink creates multiple files and assigns file ending automatically.

import sys
import os

for i in sys.argv:
	if i == "-i":
		index = sys.argv.index(i)
		input_filename = sys.argv[index+1]
		mod_infile = input_filename.split(".")[0] + "_mod.vcf"
	elif i == "-o":
		index = sys.argv.index(i)
		output_filename = sys.argv[index+1]
	elif i == "-h":
		sys.exit("run like this: path/to/convertVcf2Plink.py -i path/to/myOrganism.vcf -o path/to/myOrganism")

outputfile = open(mod_infile,"w")
with open (input_filename) as inputfile:
	for i in inputfile:
		if "#" in i:
			outputfile.write(i)
		else:
			outputfile.write("n" + i)

os.system("plink --vcf " + mod_infile + " --double-id --aec --recode12 --out " + output_filename)
