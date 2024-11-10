# Structural connectivity analysis in migraine patients

This repository provides the code used to analyze the data of migraine patients in the paper: [Involvement of the cerebellum in structural connectivity enhancement in episodic migraine](https://doi.org/10.1186/s10194-024-01854-8)

The overall pipeline can be seen in the picture below:

<img width="1267" alt="pipeline" src="https://github.com/anamatoso/connectivity-analysis-diffusion/assets/78906907/8a960a21-a836-41f2-aa18-b04db62963f6">

## How to use 

You'll need __MRtrix, FSL, and MATLAB installed__ on the computer you'll use to run the code. I used MRtrix version 3.0.3, FSL version 6.0.5 and MATLAB 2023a version (but older versions of MATLAB should also work).

Then download this repository into a folder of your choosing by going to that folder and then cloning it through the terminal:
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
|   ├── sub-controlXXX_ses-[SESSION]                           # Folder with the dMRI files
|   │   ├── sub-controlXXX_ses-[SESSION]_clean.nii.gz          # dMRI image (already preprocessed)
|   │   ├── sub-controlXXX_ses-[SESSION]_clean_mask.nii.gz     # dMRI image mask 
|   │   └── sub-controlXXX_ses-[SESSION]_rotated_bvecs.bvec    # b-vectors
|   ├── sub-controlXXX                                         # Anatomic imge folder
|   |   └── sub-controlXXX_restored-MPRAGE_brain.nii.gz        # T1-weighted image
|   └── ...
├── matrix_data                                                # Output data folder (will be created automatically)
|   ├── ALL116                                                 # Folder with the connectivity matrices using the AAL116 atlas
|   └── schaefer100cersubcort                                  # Folder with the connectivity matrices using the schaefer100cersubcort atlas
├── streamline_count                                           # Output streamline count folder (will be created automatically)
|   └── streamline_count_JHUlabels                            
|       ├── sub-controlXXX_ses-[SESSION]_JHUlabels.txt
|       └── ...
├── 03_connectivity_analysis.m                                 # MATLAB script for the connectivity analysis
├── 04_streamline_count_analysis.m                             # Matlab script to analyse the streamline count
├── dados_clinicos_[GROUP].csv                                 # CSVs that contain the clinical data of each group (patients and controls)
└── ...                                                        # Other files and folders
```

### Tractography
Run the file `01_tractography.sh` for every patient folder you have with dMRI data (sub-controlXXX_ses-[SESSION]).

Should your directory structure differ, change Step 1 accordingly so that the variables point to the correct files.

Then run the `02_count_streamlines.sh` file which will create the streamline_count folder that will store the number of streamlines in each region of the JHUlabels white matter atlas.

### Python setup
To make it easier and compartmentalized, create a Python environment using venv. In my case, pyenv is the name of the environment I chose, but you can name it whatever you want. However, but the rest of the code will assume that the name is pyenv, so change it appropriately if necessary.

```bash
python -m venv pyenv
```

Then activate it, install the packages from the requirements file, and deactivate it:

```bash
source ./pyenv/bin/activate
pip install -r requirements.txt
deactivate
```

### Connectivity Analysis
You'll need to install the NBS toolbox and add it to MATLAB's PATH.
Then open MATLAB, go into the repository and run `03_connectivity_analysis.m` and `04_streamline_count_analysis.m`. If it yields an error due to the name of the files that can be easily solved by renaming the files.

Note: don't forget to add the auxiliary functions folder to the PATH in MATLAB before running the files.


## Citation
If you want to cite our work please use:

Matoso, A., Fouto, A.R., Esteves, I. et al. Involvement of the cerebellum in structural connectivity enhancement in episodic migraine. J Headache Pain 25, 154 (2024). https://doi.org/10.1186/s10194-024-01854-8

```
@article{matoso2024involvement,
  title={Involvement of the cerebellum in structural connectivity enhancement in episodic migraine},
  author={Matoso, Ana and Fouto, Ana R and Esteves, In{\^e}s and Ruiz-Tagle, Amparo and Caetano, Gina and da Silva, Nuno A and Vilela, Pedro and Gil-Gouveia, Raquel and Nunes, Rita G and Figueiredo, Patr{\'\i}cia},
  journal={The Journal of Headache and Pain},
  volume={25},
  number={1},
  pages={1--11},
  year={2024},
  publisher={BioMed Central}
  doi={10.1186/s10194-024-01854-8}
}
```

## Help
If you need any help reproducing this work or if you encounter any bugs or not expected behaviour, feel free to reach out or to submit an issue or a pull request.
