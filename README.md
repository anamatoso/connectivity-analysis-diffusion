# Structural connectivity analysis in migraine patients

This repository provides the code used to analyse the data of migraine patients in the paper: [TBC]

The overall pipeline can be seen the picture below:

<img width="1267" alt="pipeline" src="https://github.com/anamatoso/connectivity-analysis-diffusion/assets/78906907/8a960a21-a836-41f2-aa18-b04db62963f6">

## How to use 

### Tractography
You'll need MRtrix and FSL installed and then run the file `tractography.sh` for every patient folder you have with dMRI data (images, bvecs). In this case, the bvals were the same for all patients and the T1 structural images were in a different anat folder. Should your directory structure be different, change Step 1 accordingly so that the variables point to the correct files.

### Analysis
You'll need MATLAB installed (I used the 2023a version, but older versions should  also work) as well as the NBS toolbox.

To run the code run the following commands:
1) Clone this repository:
    ```bash
    git clone https://github.com/anamatoso/connectivity-analysis-diffusion
    ```
2) Open MATLAB, go into the repository (the folder you just downloaded) and run main.m in the command window of MATLAB:
    ```MATLAB
    run main.m
    ```
Note: don't forget to add the NBS folder to PATH in MATLAB.
