#!/bin/bash

read1=$1
read2=$2

if [ "x$read2" == "x" ]
then
    echo "Usage: "`basename $0`" (read1.fastq.gz) (read2.fastq.gz)"
    exit
fi

#threePrime=GATCGGAAGAGCACACGTCTGAACTCCAGTCAC # idx adpt
#fivePrime=AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT # univ adpt
#threePrime=GATCGGAAGAGCACACGTCTGAACTCCAGTCAC
threePrime=AGAGCACACGTCTGAACTCCAGTCAC
fivePrime=AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT
threePrimeRevcomp=`echo $threePrime | revcomp`
fivePrimeRevcomp=`echo $fivePrime | revcomp`

cutadapt --trim-n -a $threePrime -g $fivePrime -A $fivePrimeRevcomp -G $threePrimeRevcomp -e 0.1 -O 6 -m 20 -o ${read1/.fastq.gz/.cleaned.fastq.gz} -p ${read2/.fastq.gz/.cleaned.fastq.gz} $read1 $read2

# Truseq:
# univ-adpt:    AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT
# univ-adpt-rv: TCTAGCCTTCTCGCAGCACATCCCTTTCTCACATCTAGAGCCACCAGCGGCATAGTAA
# univ-adpt-rc: AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT
# 
# idx-adpt:    GATCGGAAGAGCACACGTCTGAACTCCAGTCAC[index]ATCTCGTATGCCGTCTTCTGCTTG
# idx-adpt-rv: GTTCGTCTTCTGCCGTATGCTCTA[xedni]CACTGACCTCAAGTCTGCACACGAGAAGGCTAG
# idx-adpt-rc: CAAGCAGAAGACGGCATACGAGAT[XEDNI]GTGACTGGAGTTCAGACGTGTGCTCTTCCGATC
# 
#                            ACACGTCTGAACTCCAGTCAC[index]ATCTCGTATGCCGTCTTCTGCTTG
# idx-adpt:      GATCGGAAGAGC
# univ-adpt-rv: TCTAGCCTTCTCG
#                            CAGCACATCCCTTTCTCACATCTAGAGCCACCAGCGGCATAGTAA
# 
# univ-adpt: AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGAC
#                                                         GCTCTTCCGATCT
# idx-adpt-rv:                                            CGAGAAGGCTAG
#     GTTCGTCTTCTGCCGTATGCTCTA[xedni]CACTGACCTCAAGTCTGCACA
# 
# product:
#                       univ-adpt                                                              idx-adpt
# ----------------------------------------------------------          ----------------------------------------------------------------
# AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT [INSERT] GATCGGAAGAGCACACGTCTGAACTCCAGTCAC[index]ATCTCGTATGCCGTCTTCTGCTTG
