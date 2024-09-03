# Structural connectivity analysis in migraine patients

This repository provides the code used to analyze the data of migraine patients in the paper: [Involvement of the cerebellum in structural connectivity enhancement in episodic migraine](https://www.biorxiv.org/content/10.1101/2024.04.26.591265v2)

The overall pipeline can be seen in the picture below:

<img width="1267" alt="pipeline" src="https://github.com/anamatoso/connectivity-analysis-diffusion/assets/78906907/8a960a21-a836-41f2-aa18-b04db62963f6">

## How to use 

You'll need __MRtrix, FSL, and MATLAB installed__ on the computer you'll use to run the code. I used MRtrix version 3.0.3, FSL version 6.0.5 and MATLAB 2023a version (but older versions of MATLAB should also work).

Then download this repository into a folder of your choosing by going to that folder and then cloning it:
```bash
git clone https://github.com/anamatoso/connectivity-analysis-diffusion.git
```

### Prepare data
The data directory structure should be the following:
```bash
.
├── 01_tractography.sh                                         # Tractography script
├── 02_count_streamlines.sh                                    # Count streamlines script
├── bvals.bval                                                 # b-values file
├── data                                                       # Data folder
    ├── sub-controlXXX_ses-[SESSION]                           # Folder with the dMRI files
    │   ├── sub-controlXXX_ses-[SESSION]_clean.nii.gz          # dMRI image (already preprocessed)
    │   ├── sub-controlXXX_ses-[SESSION]_clean_mask.nii.gz     # dMRI image mask 
    │   └── sub-controlXXX_ses-[SESSION]_rotated_bvecs.bvec    # b-vectors
    ├── sub-controlXXX                                         # Anatomic imge folder
        └── sub-controlXXX_restored-MPRAGE_brain.nii.gz        # T1-weighted image
    └── ...
├── matrix_data                                                # Output data folder (will be created automatically)
    ├── ALL116                                                 # Folder with the connectivity matrices using the AAL116 atlas
    └── schaefer100cersubcort                                  # Folder with the connectivity matrices using the schaefer100cersubcort atlas
├── streamline_count                                           # Output streamline count folder (will be created automatically)
    └── streamline_count_JHUlabels                            
        ├── sub-controlXXX_ses-[SESSION]_JHUlabels.txt
        └── ...
├── 03_connectivity_analysis.m                                 # MATLAB script for the connectivity analysis
├── 04_streamline_count_analysis.m                             # Matlab script to analyse the streamline count
├── dados_clinicos_[GROUP].csv                                 # CSVs that contain the clinical data of each group (patients and controls)
└── ...                                                        # Other files and folders
```

### Tractography
Run the file `01_tractography.sh` for every patient folder you have with dMRI data (sub-controlXXX_ses-[SESSION]).

Should your directory structure be different, just change Step 1 accordingly so that the variables point to the correct files.

Then run the `02_count_streamlines.sh` file which will create the streamline_count folder that will store the number of streamlines in each region of the JHUlabels white matter atlas.

### Python setup
To make it easier and compartmentalized, create a python environment using. pyenv is the name of the environment, but you can name it how you want, but the rest of the code will assume that the name is pyenv, so change it appropriately if necessary.

```bash
python -m venv pyenv
```

Then activate it, install the packages from the requirements file and deactivate it:

```bash
source ./pyenv/bin/activate
pip install -r requirements.txt
deactivate
```

### Connectivity Analysis
You'll need MATLAB installed (I used the 2023a version, but older versions should also work) as well as the NBS toolbox.
Then open MATLAB, go into the repository and run `03_connectivity_analysis.m` and `04_streamline_count_analysis.m`.

Note: don't forget to add the NBS folder and the auxilliary functions folder to the PATH in MATLAB before running the files.
