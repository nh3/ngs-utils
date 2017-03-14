#!/bin/bash

read1=$1
read2=$2

if [ "x$read2" == "x" ]
then
    echo "Usage: "`basename $0`" (read1.fastq.gz) (read2.fastq.gz)"
    exit
fi

#threePrime=CTGTCTCTTATACACATCTCCGAGCCCACGAGAC
#fivePrime=TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG
threePrime=TCTCCGAGCCCACGAGAC
fivePrime=TCGTCGGCAGCGTCAGA
threePrimeRevcomp=`echo $threePrime | revcomp`
fivePrimeRevcomp=`echo $fivePrime | revcomp`

cutadapt --trim-n -a $threePrime -g $fivePrime -A $fivePrimeRevcomp -G $threePrimeRevcomp -e 0.1 -O 6 -m 20 -o ${read1/.fastq.gz/.cleaned.fastq.gz} -p ${read2/.fastq.gz/.cleaned.fastq.gz} $read1 $read2

# (+) AATGATACGGCGACCACCGAGATCTACAC[i5]TCGTCGGCAGCGTC
# (+)                                  TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG
# (+)                                                AGATGTGTATAAGAGACAGxxxxxxxxxxxxxxxxxxxxxxxxxGACAGAGAATATGTGTAGA
# (-)                                                TCTACACATATTCTCTGTCyyyyyyyyyyyyyyyyyyyyyyyyyCTGTCTCTTATACACATCT
# (-)                                                                                            CTGTCTCTTATACACATCTCCGAGCCCACGAGAC
# (-)                                                                                                               CCGAGCCCACGAGAC[i7]ATCTCGTATGCCGTCTTCTGCTTG
