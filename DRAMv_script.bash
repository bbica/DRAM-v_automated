#!/bin/bash

#--------------------------------
# Script Name: automated viral metagenomics annotation using the progrem DRAM-v
#
# Author: Bernardo Bica
# Date : 14-9-2020
# Note: This scipr runs on the directory where the output of the virsorter(concatenated) is, ./virsorter
# Note2: #To concatenate virsorter fasta files use: cat /path/to/virsorter/contigs/*.fasta >> new .fasta


#Create StartTime (DRAM-v annotate)
StartTime=$(date +%s)

#awk separates the name for the "_" and prints the divided fist and second element 
#Example: 14_230_combined.fasta bacames 14_230; Water_1_concatenated.fasta bacames Water_1
#Creates file id.txt with the id's from the .fasta that mach the id of the .tab files
#I order to correcly create the id.txt, the id's given to the .tab :
#1)two "_" in the whole name (one in the id);
#2)id's in the .fasta and .tab must mach.

for i in *.fasta
do 
	echo "$i" | awk -F'[_]' '{print $1"_"$2}'>> id.txt
	
done

#Run Dram-v annotate
#The input of DRAM-v annotate corresponds to the output of virsorter, with categories merged together (file_1_concatenated.fasta) 
#and the (file_1_VIRSorter_affi-contigs.tab).

echo DRAM started annotating...
cat id.txt | while read line 
do 
	DRAM-v.py annotate --threads 26 -i ./${line}_combined.fasta -v ${line}_VIRSorter_affi-contigs.tab -o ${line}_annotate
   
done

echo DRAM annotation finished

#Create EndTime 
EndTime=$(date +%s)
#tell the time Dram-v annotate took:
echo Dram-v annotate took:
echo $((EndTime-StartTime)) | awk '{printf "%d:%02d:%02d", $1/3600, ($1/60)%60, $1%60}'


echo DRAM distill is starting...

#Create StartTime (DRAM-v distill)
StartTime=$(date +%s)

#Run DRAM-v distill

for d in *_annotate/
do
    DRAM-v.py distill -i ${d}annotations.tsv -o ${d}distilled
done

#Create the EndTime 
EndTime=$(date +%s)
#tell the time DRAM-v distill took 
echo DRAM-v distill took:
echo $((EndTime-StartTime)) | awk '{printf "%d:%02d:%02d", $1/3600, ($1/60)%60, $1%60}'

exit

