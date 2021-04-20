#!/bin/bash
# splits reference and floating images into binary labels and then performs multicontrast highly deformable registration (ie. template shape injection)

in_ref=$1
in_flo=$2
out_dir=$3

if [ "$#" -lt 3 ]
then
	 echo "Usage: $0 <in_imperfect_seg_nii> <in_template_seg_nii> <out_dir>  [optional arguments]"
	 echo ""
	 echo " -L \"label1 label2 ...\" (labels use in floating image, default all)"
	 echo " -P \"label1 label2 ...\" (labels to preserve from floating image, default none)"
	 echo ""

	 exit 1
 fi

 shift 3

use_labels=''
preserve_labels=''
convergence_aff="[50x50x50,1e-6,10]"
shrink_factors_aff="8x4x2"
smoothing_sigmas_aff="8x4x2vox"
convergence="[500x500x250,1e-6,50]"
shrink_factors="4x2x1"
smoothing_sigmas="8x4x2vox" 
radiusnbins=3
stepsize=0.1 
updatefield=5 
totalfield=0 
cost=MeanSquares

while getopts "L:P:" options; do
 case $options in
  L ) echo "Using labels $OPTARG"
	  use_labels=$OPTARG;;
  P ) echo "Preserving labels $OPTARG"
	  preserve_labels=$OPTARG;;
    * ) usage
	exit 1;;
 esac
done

out_dir_tmp=$out_dir\_tmp
mkdir -p $out_dir_tmp

# get labels from reference
if [ -z "$use_labels" ]
then
use_labels=$(fslstats $in_ref -R)
fi

metric=""
for labelfloats in $use_labels
do
label=${labelfloats%.*}

# binarize label
ref_bin=$out_dir_tmp/ref_label-$label.nii.gz
flo_bin=$out_dir_tmp/flo_label-$label.nii.gz
fslmaths $in_ref -thr $label -uthr $label -bin $ref_bin
fslmaths $in_flo -thr $label -uthr $label -bin $flo_bin

# ignore missing labels (i.e., no non-zero voxels)
v1=$(fslstats $ref_bin -V) ; v1=(${v1// / })
v2=$(fslstats $flo_bin -V) ; v2=(${v2// / })
if [ "$v1" == "0" ] || [ "$v2" == "0" ] ;
then
echo "skipping label $label"
else
echo "including label $label"
metric="$metric --metric ${cost}[${ref_bin},${flo_bin},1,${radiusnbins}]"
fi
done

multires_aff="--convergence $convergence_aff --shrink-factors $shrink_factors_aff --smoothing-sigmas $smoothing_sigmas_aff"
multires="--convergence $convergence --shrink-factors $shrink_factors --smoothing-sigmas $smoothing_sigmas"
rigid="$multires_aff $metric --transform Rigid[0.1]"
affine="$multires_aff $metric --transform Affine[0.1]"
syn="$multires $metric --transform SyN[${stepsize},$updatefield,$totalfield]"
out="--output [$out_dir_tmp/ants_]"

if [ ! -f $out_dir_tmp/ants_0GenericAffine.mat ]
then
antsRegistration -d 3 --interpolation Linear $rigid $affine $syn $out -v
fi

antsApplyTransforms \
    -d 3 \
    --interpolation MultiLabel \
    -i $in_flo\
    -o $out_dir.nii.gz\
    -r $in_ref\
    -t $out_dir_tmp/ants_1Warp.nii.gz \
    -t $out_dir_tmp/ants_0GenericAffine.mat 

# add back in any preserved labels
if [ ! -z "$preserve_labels" ] 
then
cp $out_dir.nii.gz $out_dir\_preserved.nii.gz

for labelfloats in $preserve_labels
do
lbl=${labelfloats%.*}
ref_bin=$out_dir_tmp/ref_label-$lbl.nii.gz
fslmaths $in_ref -thr $lbl -uthr $lbl -bin $ref_bin

fslmaths $out_dir_tmp/ref_label-$lbl.nii.gz -mul -1 -add 1 $out_dir_tmp/ref_label-$lbl\_inv.nii.gz
fslmaths $out_dir\_preserved.nii.gz -mas $out_dir_tmp/ref_label-$lbl\_inv.nii.gz $out_dir\_preserved.nii.gz
fslmaths $out_dir_tmp/ref_label-$lbl.nii.gz -mul $lbl $out_dir_tmp/ref_label-$lbl.nii.gz
fslmaths $out_dir\_preserved.nii.gz -add $out_dir_tmp/ref_label-$lbl.nii.gz $out_dir\_preserved.nii.gz
done
fi
mv $out_dir\_preserved.nii.gz $out_dir.nii.gz
#rm $out_dir_tmp/ref_label*  $out_dir_tmp/flo_label*
