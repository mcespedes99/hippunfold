Outputs of hippunfold
=====================


Results
-------

The `results` folder is a BIDS-derivatives dataset that contains the pre-processed anatomicals used for the segmentation, segmentatioons and hippocampal coordinate images, and HCP-style surfaces of the hippocampus in native and unfolded configurations.

Pre-processed Anatomicals
^^^^^^^^^^^^^^^^^^^^^^^^^

Anatomical images that have been non-uniformity corrected, motion-corrected, averaged and registered to the T1w space are placed in each subject's `anat` subfolder::

    results
    └── sub-{subject}[/ses-{session}]
        ├── anat
        │   ├── sub-{subject}_desc-preproc_T1w.nii.gz
        │   └── sub-{subject}_space-T1w_desc-preproc_T2w.nii.gz
        ...

Volumetric Segmentations
^^^^^^^^^^^^^^^^^^^^^^^^

Volumetric segmentations... 


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



BIDS App for Hippocampal AutoTop (automated hippocampal unfolding and subfield segmentation)

Requirements
------------

* Docker (Mac/Windows/Linux) or Singularity (Linux)

* BIDS dataset with T1w and T2w images. 3D T2w TSE images with 0.8mm isotropic or higher resolution images are highly recommended. The T1w images are only used for linear registration in the default workflow, with the T2w images used for the convolutional neural network segmentation.

Notes:
^^^^^^

#. T1w-only workflow is available too with ``--modality T1w``\ , however, this is discouraged unless you have high resolution (~0.7mm or better) T1w data, and performance will still likely be sub-optimal. This is currently being evaluated more thoroughly.

#. dwi workflows are also available but currently experimental


Running with Docker
-------------------

Pull the container::

   docker pull khanlab/hippunfold:latest

do a dry run, printing the command at each step::

   docker run -it --rm -v PATH_TO_BIDS_DIR:/bids:ro -v PATH_TO_OUTPUT_DIR:/output khanlab/hippunfold:latest /bids /output participant -np 

run it with maximum number of cores::

   docker run -it --rm -v PATH_TO_BIDS_DIR:/bids:ro -v PATH_TO_OUTPUT_DIR:/output khanlab/hippunfold:latest /bids /output participant -p --cores all


Running with Singularity
------------------------

Pull the container::
   
   singularity pull khanlab_hippunfold_latest.sif docker://khanlab/hippunfold:latest

do a dry run, printing the command at each step::

   singularity run -e khanlab_hippunfold_latest.sif khanlab/hippunfold:latest PATH_TO_BIDS_DIR PATH_TO_OUTPUT_DIR participant -np 

run it with maximum number of cores::

   singularity run -e khanlab_hippunfold_latest.sif khanlab/hippunfold:latest PATH_TO_BIDS_DIR PATH_TO_OUTPUT_DIR participant  -p --cores all


Additional instructions for specific Khan Lab / Compute Canada environments
---------------------------------------------------------------------------

Setting up a dev environment on graham:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Here are some instructions to get your python environment set-up on graham to run hippunfold:

#. create a virtualenv and activate it::

      mkdir $SCRATCH/hippdev
      cd $SCRATCH/hippdev
      module load python/3
      virtualenv venv
      source venv/bin/activate

#. 
   clone the source repos (so you can make/pull changes easily, or change to branch)::

      git clone --recursive http://github.com/khanlab/hippunfold

#. 
   install snakebids using pip, with the -e option (for development mode)::

      pip install -e ./hippunfold

Now hippunfold will be installed for you and can run with::

   hippunfold  <args here> 


Any containers used are included in the hippunfold workflow, and if in khanlab group on graham, will already be good to go..  If you log out, you just need to re-activate the virtualenv to start again. 

If you ever want the latest code, can just pull it::

   cd hippunfold
   git pull

or if you need a branch, can: ``git checkout <name of branch>``

Running hippunfold jobs on graham:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In an interactive job (for testing)::

   regularInteractive -n 8
   hippunfold bids_dir out_dir participant --participant_label CC110037 -j 8


Submitting a job (for larger cores, more subjects), still single job, but snakemake will parallelize over the 32 cores::

   regularSubmit -j Fat hippunfold bids_dir out_dir participant  -j 32


Scaling up to ~hundred subjects (needs cc-slurm snakemake profile installed), submits 1 16core job per subject::

   hippunfold bids_dir out_dir participant  --profile cc-slurm


Scaling up to even more subjects (uses group-components to bundle multiple subjects in each job), 1 32core job for N subjects (e.g. 10)::

   hippunfold bids_dir out_dir participant  --profile cc-slurm --group-components subj=10

Note that this requires `neuroglia-helpers <https://github.com/khanlab/neuroglia-helpers>`_ for regularSubmit or regularInteractive wrappers, and the `cc-slurm <https://github.com/khanlab/cc-slurm>`_ snakemake profile for graham cluster execution with slurm. You can use the same command with any other execution profile to run hippunfold on any cluster or cloud platform supported by snakemake (see https://github.com/snakemake-profiles/doc and https://snakemake.readthedocs.io/en/stable/executing/cloud.html for more details on cluster profiles and cloud execution respectively).

