set -e
MAINDIR=$(pwd)
display_usage() {
	echo "$(basename $0) [atlas file] [dir_of_atlas_rois] name"
	# echo "This script uses MRtrix to divide the atlas file into individual files each one with a single ROI. It requires 3 arguments: 
	# 	1) Atlas file
	#	2) directory to store the individual ROI files
	#   3) Name of atlas
	}

	 if [ $# -l 3 ] # if there are less than 3 arguments
	  then
	  	display_usage
	 	exit 1
	  fi

ATLAS=$1 
DIR=$2
name=$3
rm -rf "${DIR}/atlas_rois_${name}"
mkdir -p "${DIR}/atlas_rois_${name}"
ATLASDIR="${DIR}/atlas_rois_${name}"

rm -f "${MAINDIR}/${DIR}/list_rois.txt"

n_ROIs=$(mrstats $ATLAS -output max)

for ((i = 1 ; i <= n_ROIs ; i++)); do
	if [ "$i" -lt 10 ]; then
		idx="0${i}"
	else
		idx="${i}"
	fi
	#divide atlas into regions of interest
    mrcalc ${ATLAS} $i -eq "${ATLASDIR}/atlas_roi_${name}_${idx}.mif" -force # 1 if =i, 0 otherwise
	mrconvert "${ATLASDIR}/atlas_roi_${name}_${idx}.mif" "${ATLASDIR}/atlas_roi_${name}_${idx}.nii.gz" -force
	rm "${ATLASDIR}/atlas_roi_${name}_${idx}.mif"

	#list the files in a txt
	printf "${ATLASDIR}/atlas_roi${i}.nii.gz\n" >> "${DIR}/list_rois.txt"
done
