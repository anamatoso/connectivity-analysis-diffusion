#!/bin/bash
set -e

MAINDIR=$(pwd)

display_usage() {
	echo ""
	tput bold 
	echo "Description"
	tput sgr0
	echo ""
	echo "This script uses MRTrix and FSL to count the streamlines that pass through each ROI of a predefined atlas."
	echo ""
	tput bold 
	echo "Usage"
	tput sgr0
	echo ""
	echo "./$(basename $0) [Subject and type of session]"
	echo "It requires 1 argument: Subject DWI Directory (eg: sub-control019_ses-midcycle)."
	}

if [ $# -l 1 ] # if there is less than 1 argument
then
	display_usage
	exit 1
fi

DIR=$1 #example name: sub-control019_ses-midcycle
SUB=${DIR:0:14} # example name: sub-control019

ATLAS_NAME="JHUlabels"
ATLAS="${ATLAS_NAME}.nii.gz"
ANATDIR="${MAINDIR}/data/${SUB}" 
ANAT="${ANATDIR}/${SUB}_restored-MPRAGE_brain.nii.gz"

########################## STEP 1 ###################################
#            		  Coregister atlas to the data              #
#####################################################################

cd "${MAINDIR}/data/${DIR}/mrtrix_outputs"
applywarp -i $ATLAS -r $ANAT --out=atlas_2struct_${ATLAS_NAME} --warp="${ANATDIR}/reg_nonlinear_invwarp_T1tostandard_2mm.nii.gz"
mrconvert atlas_2struct_${ATLAS_NAME}.nii.gz atlas_2struct_${ATLAS_NAME}.mif -force
mrtransform atlas_2struct_${ATLAS_NAME}.mif -linear diff2struct_mrtrix.txt -inverse atlas_coreg_${ATLAS_NAME}.mif -force
mrcalc atlas_coreg_${ATLAS_NAME}.mif -round -datatype uint32 atlas_${ATLAS_NAME}.mif -force

rm -f atlas_coreg_${ATLAS_NAME}.mif atlas_2struct_${ATLAS_NAME}.mif atlas_2struct_${ATLAS_NAME}.nii.gz

cd $MAINDIR

########################## STEP 2 ###################################
#   Create files with each ROI and other important variables        #
#####################################################################

# Divide ROIs into separate files and set the input directory containing the ROI masks
./divide_atlas.sh "${MAINDIR}/data/${DIR}/mrtrix_outputs/atlas_${ATLAS_NAME}.mif" "${MAINDIR}/data/${DIR}" "${ATLAS_NAME}"
input_directory="${MAINDIR}/data/${DIR}/atlas_rois_${ATLAS_NAME}"

# Set the tract file from the tractography step
tract_file="${MAINDIR}/data/${DIR}/mrtrix_outputs/tracks.tck"

# Create output folder
mkdir -p "${MAINDIR}/streamline_count/streamlines_${ATLAS_NAME}"
rm -f streamline_count/streamlines_${ATLAS_NAME}/${DIR}_streamlines_${ATLAS_NAME}.txt

########################## STEP 3 ###################################
#         Count streamines in each ROI by masking tractogram        #
#####################################################################

# Loop through each ROI mask in the input directory and count streamlines that pass through each of them
for roi_mask in $(ls ${input_directory}/*.nii.gz); do
    
    # Define the output tract file for the selected tracts
    output_tract_file="${MAINDIR}/data/${DIR}/selected_tracts.tck"
    
    # Use tckedit to select the streamlines that pass through the ROI mask
    tckedit -mask $roi_mask "${tract_file}" "${output_tract_file}" -force
    
    # Use tckinfo to count the streamlines in the selected ROI
    info=$(tckinfo "$output_tract_file" -count)
    num_streamlines=$(echo $info | awk '{print $NF}')
    rm -f $output_tract_file
    
    # Print number of streamlines to txt
    printf "${num_streamlines}\n" >> "streamline_count/streamlines_${ATLAS_NAME}/${DIR}_streamlines_${ATLAS_NAME}.txt"
done

# Remove directory of the ROI masks
rm -rf "${MAINDIR}/data/${DIR}/atlas_rois_${ATLAS_NAME}"