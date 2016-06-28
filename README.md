# PID-WES-GATK3.4-SGE
This repository is designed to provide a path from (WES) fastq files, to a multi-sample VCF in a sun grid engine (SGE) cluster environment. GATK best practices have been followed to ensure high quality processing. Modularity is kept in mind with GATKs rapid development, new tools may be added / replaced, and others dropped completely, the modular design allows for adjustments to be made seamlessly. 

## Considerations
Input samples are from patients with suspected Primary Immunodeficiency (PID), where clues to diagnosis could be found. Patients are sequenced primarily, however trios and healthy siblings have been sequenced in some cases, it's also worth noting that these samples have been sequenced across batches, in some cases. This repository considers that samples from the same pedigree could have been sequenced across batches, with a different sequencing instruments, and different capture kits.

## Repository Structure

```
project root
└───README.md

└───Core
    └── Preprocess_Exomes.sh
    └── JointCalling.sh

└───Modules
    └── Module_Fastqc.sh
    └── Module_PicardNT.sh
    └── Module_GATKRecal.sh
    └── Module_BWA_MEM_P.sh
    └── Module_GATKgVCF.sh

└───Utility
    └── Fastq_NextSeq_Prep.sh
```

## Sample Preprocessing
Preprocessing is broken down into five main modules, with others to deal with particular cases such as adapter presence, or unsorted fastq files. Some modules are designed to run simultaneously, however the Core scripts
