# Structural connectivity analysis in migraine patients

This repository provides the code used to analyze the data of migraine patients in the paper: [Structural connectome changes in episodic migraine: the role of the cerebellum](https://doi.org/10.1101/2024.04.26.591265)

The overall pipeline can be seen in the picture below:

<img width="1267" alt="pipeline" src="https://github.com/anamatoso/connectivity-analysis-diffusion/assets/78906907/8a960a21-a836-41f2-aa18-b04db62963f6">

## How to use 

You'll need MRtrix, FSL, and MATLAB installed on the computer you'll use to run the code. Then download this repository into a folder of your choosing by going to that folder and then cloning it:
```bash
git clone https://github.com/anamatoso/connectivity-analysis-diffusion.git
```

### Prepare data
The data directory structure should be the following:
```bash
.
├── tractography.sh                                            # DWI Script
├── bvals.bval                                                 # b-values file
├── data                                                       # Data folder
    ├── sub-controlXXX_ses-[SESSION]                           # Folder with the dMRI files
    │   ├── sub-controlXXX_ses-[SESSION]_clean.nii.gz          # dMRI image (already preprocessed)
    │   ├── sub-controlXXX_ses-[SESSION]_clean_mask.nii.gz     # dMRI image mask 
    │   └── sub-controlXXX_ses-[SESSION]_rotated_bvecs.bvec    # b-vectors
    ├── sub-controlXXX                                         # Anatomic imge folder
        └── sub-controlXXX_restored-MPRAGE_brain.nii.gz        # T1-weighted image
    └── ...
├── matrix_data                                                # Output data folder (created automatically)
├── main.m                                                     # Main MATLAB Script
└── ...                                                        # Other MATLAB files and folders
```

### Tractography
Run the file `tractography.sh` for every patient folder you have with dMRI data (sub-controlXXX_ses-[SESSION]).

Should your directory structure be different, just change Step 1 accordingly so that the variables point to the correct files.

### Connectivity Analysis
You'll need MATLAB installed (I used the 2023a version, but older versions should also work) as well as the NBS toolbox.
Then open MATLAB, go into the repository and run main.m in the command window of MATLAB:
```MATLAB
run main.m
```
Note: don't forget to add the NBS folder to PATH in MATLAB before running the file.
