# PID-WES-GATK3.4-SGE
This repository is designed to provide a path from (WES) fastq files, to a multi-sample VCF in a sun grid engine (SGE) cluster environment. GATK best practices have been followed to ensure high quality processing. Modularity is kept in mind with GATKs rapid development, new tools may be added / replaced, and others dropped completely, the modular design allows for adjustments to be made seamlessly.

## Considerations
Input samples are from patients with suspected Primary Immunodeficiency (PID), where clues to diagnosis could be found. Patients are sequenced primarily, however trios and healthy siblings have been sequenced in some cases, it's also worth noting that these samples have been sequenced across batches, in some cases. This repository considers that samples from the same pedigree could have been sequenced across batches, with a different sequencing instruments, and different capture kits.

## Repository Structure

```
Project Root
└───README.md

└───Core
    └── Core_Preprocess.sh
    └── Core_JointCalling.sh
    └── Core_Pedigrees.sh

└───Modules
    └── Module_Fastqc.sh
    └── Module_PicardNT.sh
    └── Module_GATKRecal.sh
    └── Module_BWA_MEM_P.sh
    └── Module_GATKgVCF.sh
    └── Module_GenderCov.sh
    └── Module_Genotyping_gVCF.sh
    └── Module_PedigreeGen.sh
    └── Module_VQSR_Indels_gVCF.sh
    └── Module_VQSR_SNP_gVCF.sh

└───Ref
    └── SampleMap.txt

└───Utility
    └── Fastq_NextSeq_Prep.sh
    └── Gender.R
    └── Module_PedigreeCheck.sh
    └── Relatedness.R
```

## 1.0 Sample Preprocessing
Preprocessing is broken down into five main modules, with others to deal with particular cases such as adapter presence, or unsorted fastq files. Some modules are designed to run simultaneously using SGE's queuing system, and wait for predecessor jobs to complete before initialising. An additional step is implemented around blocks of jobs in the preprocessing stage, to avoid repeated processing, by checking if the known output if present, before submitting the job to the queue.

### 1.1 Expected Folder Struture for Raw Data
An example is illustrated below, with the root directory named `Preprocessing`. A variable (`BASE_DIR`), in the `Core_Preprocess.sh` file should be set as the parent directory of the samples, in the case below this would be `~/Preprocessing/2015/December`, or `~/Preprocessing/2016/March`.
```
Preprocessing
└───2015
    └── December
        └── Sample_ABC
            └── Raw_Data
                └── ABC_R1.fastq.gz
                └── ABC_R2.fastq.gz
        └── Sample_DEF
            └── Raw_Data
                └── DEF_R1.fastq.gz
                └── DEF_R2.fastq.gz

└───2016
    └── March
        └── Sample_UVW
            └── Raw_Data
                └── UVW_R1.fastq.gz
                └── UVW_R2.fastq.gz
        └── Sample_XYZ
            └── Raw_Data
                └── XYZ_R1.fastq.gz
                └── XYZ_R2.fastq.gz
```

### 1.2 Essential Variables
* `PROJ_BASE` - Directory root of the project containing the `Preprocessing` directory.
* `SCRIPTS` - Directory containing this repository
* `BUNDLE` - GATK bundle of truth and reference sets
* `BASE_DIR` - Root directory of a set of samples to preprocess
* `BATCH` - Unique name of the batch that's being processed (used in the read group)
* `CAP_KIT` - A bed file containing the targets of the capture kit used

### 1.3 Read Groups
Read groups are essential to the GATK pipeline, and something that has to be very precise to work. GATK seems to be the only framework that makes use of the feature, however it can be inserted in the alignment process using BWA. The read group is broken up into five elements:
* `ID` **Read Group Identifier** - Identifies the batch of samples that were sequenced together, essential to the BQSR calculation, as sequence batch can bias the results.
* `SM` - **Sample** - The sample ID, this is hugely essential if there is more than one copy of the sample processed.
* `PL` - **Platform Used** - The type of technology used, i.e `ILLUMINA`
* `LB` - **DNA preparation library identifier** - Utilised by `MarkDuplicates` in cases where the same molecular sample is sequenced across different lanes.
* `PU` **Platform Unit** - Not required by GATK, but used in some cases. Typical notation is `FlowcellID.Lane`, which can be extracted from the fastq files.

**A Note on the `PU` Field** - Extracting the precise string from the fastq file is still to be implemented, as such manual input of the sequencer type (from the flowcell ID), is required.

[Read Group Reference](https://www.broadinstitute.org/gatk/guide/article?id=6472)

### 1.4 Padding length
GATK requires a `--interval_padding` variable as an engine-level parameter. This is automatically derived in this pipeline by taking the longest line from a sample of 10,000 lines in each fastq file. This is implemented on a sample by sample basis. The parameter is used to extend the span of the `-L` (Capture Kit Bed File) parameter to make sure that low coverage areas, outside target regions are still considered in the analysis.  
