# Contributing to Hippunfold

Hippunfold dependencies are managed with Poetry, which you\'ll need
installed on your machine. You can find instructions on the [poetry
website](https://python-poetry.org/docs/master/#installation).

## Set-up your development environment:

Clone the repository and install dependencies and dev dependencies with
poetry:

    git clone http://github.com/khanlab/hippunfold
    cd hippunfold
    poetry install

Poetry will automatically create a virtual environment. To customize where 
these virtual environments are stored see poetry docs 
[here](https://python-poetry.org/docs/configuration/)

Then, you can run hippunfold with:

    poetry run hippunfold

or you can activate a virtualenv shell and then run hippunfold directly:

    poetry shell
    hippunfold

You can exit the poetry shell with `exit`.

## Running code format quality checking and fixing:

Hippunfold uses [poethepoet](https://github.com/nat-n/poethepoet) as a
task runner. You can see what commands are available by running:

    poetry run poe

We use `black` and `snakefmt` to ensure
formatting and style of python and Snakefiles is consistent. There are
two task runners you can use to check and fix your code, and can be
invoked with:

    poetry run poe quality_check
    poetry run poe quality_fix

Note that if you are in a poetry shell, you do not need to prepend
`poetry run` to the command.

## Dry-run testing your workflow:

Using Snakemake\'s dry-run option (`--dry-run`/`-n`) is an easy way to verify any
changes to the workflow are working correctly. The `test_data` folder contains a 
number of *fake* bids datasets (i.e. datasets with zero-sized files) that are useful
for verifying different aspects of the workflow. These dry-run tests are
part of the automated github actions that run for every commit.

You can use the hippunfold CLI to perform a dry-run of the workflow,
e.g. here printing out every command as well:

    hippunfold test_data/bids_singleT2w test_out participant --modality T2w -np

As a shortcut, you can also use `snakemake` instead of the
hippunfold CLI, as the `snakebids.yml` config file is set-up
by default to use this same test dataset, as long as you run snakemake
from the `hippunfold` folder that contains the
`workflow` folder:

    cd hippunfold
    snakemake -np

## Instructions for Compute Canada

This section provides an example of how to set up a `pip installed` copy
of HippUnfold on CompateCanada\'s `graham` cluster.

### Setting up a dev environment on graham:

Here are some instructions to get your python environment set-up on
graham to run HippUnfold:

1.  Create a virtualenv and activate it:

        mkdir $SCRATCH/hippdev
        cd $SCRATCH/hippdev
        module load python/3.8
        virtualenv venv
        source venv/bin/activate

2.  Install HippUnfold

        git clone https://github.com/khanlab/hippunfold.git
        pip install hippunfold/
        
3. Run hippunfold:

        hippunfold ...
        
Note if you want to run hippunfold with modifications to your cloned 
repository, you either need to pip install again, or run hippunfold the following, since 
an `editable` pip install is not allowed with pyproject:

        python <YOUR_HIPPUNFOLD_DIR>/hippunfold/run.py

### Running hippunfold jobs on graham:

Note that this requires
[neuroglia-helpers](https://github.com/khanlab/neuroglia-helpers) for
regularSubmit or regularInteractive wrappers, and the
[cc-slurm](https://github.com/khanlab/cc-slurm) snakemake profile for cluster execution with slurm.

In an interactive job (for testing):

    regularInteractive -n 8
    hippunfold PATH_TO_BIDS_DIR PATH_TO_OUTPUT_DIR participant \
    --participant_label 001 -j 8

Here, the last line is used to specify only one subject from a BIDS
directory presumeably containing many subjects.

Submitting a job (for larger cores, more subjects), still single job,
but snakemake will parallelize over the 32 cores:

    regularSubmit -j Fat \
    hippunfold PATH_TO_BIDS_DIR PATH_TO_OUTPUT_DIR participant  -j 32

Scaling up to \~hundred subjects (needs cc-slurm snakemake profile
installed), submits 1 16core job per subject:

    hippunfold PATH_TO_BIDS_DIR PATH_TO_OUTPUT_DIR participant \
    --profile cc-slurm

Scaling up to even more subjects (uses group-components to bundle
multiple subjects in each job), 1 32core job for N subjects (e.g. 10):

    hippunfold PATH_TO_BIDS_DIR PATH_TO_OUTPUT_DIR participant \
    --profile cc-slurm --group-components subj=10


    
## Deep learning nnU-net model files

The trained model files we use for hippunfold are large and thus are not
included directly in this github repository, and instead are downloaded
from Zenodo releases. If you are using the docker/singularity 
container, `docker://khanlab/hippunfold`, they are pre-downloaded there, in `/opt/hippunfold_cache`.

If you are not using this container, you will need to download the models before running hippunfold, by running:

    hippunfold_download_models
    
This console script (installed when you install hippunfold) downloads all the models to a cache dir on your system, 
which on Linux is typically `~/.cache/hippunfold`. To override this, you can set the `HIPPUNFOLD_CACHE_DIR` environment
variable before running `hippunfold_download_models` and `hippunfold`.


## Overriding Singularity cache directories

By default, singularity stores image caches in your home directory when you run `singularity pull` or `singularity run`. As described above, hippunfold also stores deep learning models in your home directory. If your home directory is full or otherwise inaccessible, you may want to change this with the following commands:

    export SINGULARITY_CACHEDIR=/YOURDIR/.cache/singularity
    export SINGULARITY_BINDPATH=/YOURDIR:/YOURDIR
    export HIPPUNFOLD_CACHE_DIR=/YOURDIR/.cache/hippunfold/
    
If you are running `hippunfold` with the `--use-singularity` option, hippunfold will download the required singularity containers for rules that require it. These containers are placed in the `.snakemake` folder in your hippunfold output directory, but this can be overriden with the Snakemake option: `--singularity-prefix DIRECTORY`
  

