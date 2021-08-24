BIDS whole brain scans
=====================
This tutorial will cover applications of HippUnfold to an entire BIDS-compliant dataset, meaning that the same scan types are expected for all subjects which will be processed in parallel. A typical call might look like this:
```
hippunfold  PATH_TO_BIDS_DIR PATH_TO_OUTPUT_DIR participant --cores all --use-singularity
```
