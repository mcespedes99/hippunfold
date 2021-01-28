Outputs of hippunfold
=====================


Results
-------

The `results` folder is a BIDS-derivatives dataset that contains the pre-processed anatomicals used for the segmentation, segmentatioons and hippocampal coordinate images, and HCP-style surfaces of the hippocampus in native and unfolded configurations::

    results/
    ├── dataset_description.json
    └── sub-{subject}
        ├── anat
        ├── seg_T2w
        └── surf_T2w 

        
Volumetric outputs
^^^^^^^^^^^^^^^^^^


Anatomical images that have been non-uniformity corrected, motion-corrected, averaged and registered to the `T1w` space are placed in each subject's `anat` subfolder::

    sub-{subject}
     └── anat
         ├── sub-{subject}_desc-preproc_T1w.nii.gz
         └── sub-{subject}_space-T1w_desc-preproc_T2w.nii.gz


Segmentations are derived from the U-net segmentation, which is by default performed on the `T2w` image, but can also be performed on the `T1w` image (or other modalities) using the `--modality` parameter. To distinguish between these outputs, segmentations are placed in each subject's `seg_{modality}` subfolder::

    sub-{subject}
     └── seg_T2w
        ├── sub-{subject}_dir-{AP,PD,IO}_hemi-{L,R}_space-cropT1w_coords.nii.gz
        ├── sub-{subject}_hemi-{L,R}_space-cropT1w_desc-preproc_T2w.nii.gz
        └── sub-{subject}_hemi-{L,R}_space-{T1w,cropT1w}_desc-subfields_dseg.nii.gz

Image in this folder are provided in the `T1w` space (same resolution and FOV as the `T1w` image, as well as in a 0.2mm upsampled FOV cropped around each hippocampus, but still aligned to the `T1w` image, which is denoted as the `cropT1w` space.

Subfield segmentations
""""""""""""""""""""""

Hippocampal subfield segmentations are suffixed with `desc-subfields_dseg.nii.gz`, and have the following look-up table:

=====   =================== ============
index   name                abbreviation
=====   =================== ============
1       subiculum           Sub
2       CA1                 CA1
3       CA2                 CA2
4       CA3                 CA3
5       CA4                 CA4
6       dentate gyrus       DG
7       SRLM or 'dark band' SRLM
8       cysts               Cyst
=====   =================== ============

Coordinate images
"""""""""""""""""

Hippunfold also provides images that represent anatomical gradients along the 3 principal axes of the hippocampus, longitudinal from anterior to posterior, lamellar from proximal (dentate gyrus) to distal (subiculum), and laminar from inner (SRLM) to outer. These are provided in the images suffixed with `coords.nii.gz` with the direction indicated by `dir-{direction}` as `AP`, `PD` or `IO`, and intensities from 0 to 100, e.g. 0 representing the Anterior end and 100 the Posterior end.



Surface-based outputs
^^^^^^^^^^^^^^^^^^^^^


TODO: describe CIFTI/GIFTI outputs here

Transforms
^^^^^^^^^^

TODO: add these to workflow and document them here



Additional Files
----------------

The top-level folder structure of hippunfold is::

    ├── config
    ├── logs
    ├── results
    └── work

The `config` folder contains the hippunfold `snakebids.yml` config file, and `inputs_config.yml` that contain a record of the parameters used, and paths to the inputs.

Workflow steps that write logs to file are stored in the `logs` subfolder, with file names based on the rule wildcards (e.g. subject, hemi, etc..).

Intermediate files are stored in the `work` folder. These files and folders, similar to results, are generally  named according to BIDS.


