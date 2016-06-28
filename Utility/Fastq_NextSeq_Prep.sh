#!/bin/bash

PROJ_BASE="/home/andrew/BaseSpace/Projects/2016_016/Samples/"
OUTDIR="/home/andrew/Raw_WES/2016/June/"

mkdir -p $OUTDIR

for i in ${PROJ_BASE}*
do
    SAMPLE_ID=$(basename "$i")
    echo "New Sample ${SAMPLE_ID}"
    mkdir -p ${OUTDIR}Sample_${SAMPLE_ID}/Raw_Data/
    touch ${OUTDIR}Sample_${SAMPLE_ID}/Raw_Data/${SAMPLE_ID}_R1.fastq.gz
    touch ${OUTDIR}Sample_${SAMPLE_ID}/Raw_Data/${SAMPLE_ID}_R2.fastq.gz

    echo "Forward Reads"
    for x in ${i}/Files/*_R1_*
    do
        echo $x
        cat ${x} >> ${OUTDIR}Sample_${SAMPLE_ID}/Raw_Data/${SAMPLE_ID}_R1.fastq.gz
    done

    echo "Reverse Reads"
    for y in ${i}/Files/*_R2_*
    do
        echo $y
        cat ${y} >> ${OUTDIR}Sample_${SAMPLE_ID}/Raw_Data/${SAMPLE_ID}_R2.fastq.gz
    done
done
