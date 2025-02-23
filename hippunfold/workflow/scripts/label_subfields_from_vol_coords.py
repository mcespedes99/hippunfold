import numpy as np
from scipy.io import loadmat
from scipy.interpolate import interpn
import nibabel as nib

# this function labels subfields using the labels in unfolded space, and native space coords (ap, pd) images

label_nii = snakemake.input.label_nii

nii_ap = snakemake.input.nii_ap
nii_pd = snakemake.input.nii_pd
nii_io = snakemake.input.nii_io
nii_label = snakemake.output.nii_label

# get labels from volumetric unfolded labels
labels = nib.load(label_nii).get_fdata()  # shape [256, 128, 16]


# setup the interpolating grid
spacing_ap = np.linspace(0, 1, labels.shape[0])
spacing_pd = np.linspace(0, 1, labels.shape[1])
spacing_io = np.linspace(0, 1, labels.shape[2])
points = (spacing_ap, spacing_pd, spacing_io)

# load up the coords
ap_nib = nib.load(nii_ap)
pd_nib = nib.load(nii_pd)
io_nib = nib.load(nii_io)
ap_img = ap_nib.get_fdata()
pd_img = pd_nib.get_fdata()
io_img = io_nib.get_fdata()

# create mask (TODO: maybe load a separate mask instead, so valid coords=0 are not discarded)
mask = np.logical_or(ap_img > 0, pd_img > 0, io_img > 0)


# interpolate
query_points = np.vstack((ap_img[mask], pd_img[mask], io_img[mask])).T
labelled_points = interpn(points, labels, query_points, method="nearest")

# put back into image
label_img = np.zeros(ap_img.shape, dtype="uint16")
label_img[mask] = labelled_points

# save label img
label_nib = nib.Nifti1Image(label_img, ap_nib.affine, ap_nib.header)
nib.save(label_nib, nii_label)
