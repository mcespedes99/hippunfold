
rule template_shape_reg:
    inputs:
        in_lbl = bids(root='work',datatype='seg_{modality}',**config['subj_wildcards'], suffix='dseg.nii.gz', desc='nnunet', space='corobl', hemi='{hemi}')
    params:
	   in_ref = templateShape.nii.gz,
       preserve_labels = 7
    outputs:
        postproc = bids(root='work',**config['subj_wildcards'],suffix='autotop/labelmap-postProcess.nii.gz', desc='cropped', space='corobl', hemi='{hemi,Lflip|R}', modality='{modality}'),
	postproc_tmpdir = bids(root='work',**config['subj_wildcards'],suffix='autotop/labelmap-postProcess', desc='cropped', space='corobl', hemi='{hemi,Lflip|R}', modality='{modality}'),
    shell:
        'tools/ANTsTools/template_shape_inject.sh {params.in_ref} {in_lbl} {outputs.postproc_tmpdir} -L {params.preserve_labels}'

rule initialize_coords:
    inputs:
        in_aff = bids(root='work',**config['subj_wildcards'],suffix='autotop/labelmap-postProcess_tmp/ants_0GenericAffine.mat ', desc='cropped', space='corobl', hemi='{hemi,Lflip|R}', modality='{modality}'),
        in_warp = bids(root='work',**config['subj_wildcards'],suffix='autotop/labelmap-postProcess_tmp/ants_1Warp.nii.gz ', desc='cropped', space='corobl', hemi='{hemi,Lflip|R}', modality='{modality}'),
        in_ref = bids(root='work',**config['subj_wildcards'],suffix='autotop/labelmap-postProcess.nii.gz', desc='cropped', space='corobl', hemi='{hemi,Lflip|R}', modality='{modality}'),
    params:
        ap = templateShape_coords-AP.nii.gz,
        pd = templateShape_coords-PD.nii.gz,
        io = templateShape_coords-IO.nii.gz,
        interp = NearestNeighbor
    outputs:
        ap = expand(bids(root='work',suffix='autotop/labelmap-postProcess_tmp/init_coords-AP.nii.gz',desc='cropped', space='corobl',hemi='{hemi,Lflip|R}',modality='seg{modality}', **config['subj_wildcards']),allow_missing=True),
        pd = expand(bids(root='work',suffix='autotop/labelmap-postProcess_tmp/init_coords-PD.nii.gz',desc='cropped', space='corobl',hemi='{hemi,Lflip|R}',modality='seg{modality}', **config['subj_wildcards']),allow_missing=True),
        io = expand(bids(root='work',suffix='autotop/labelmap-postProcess_tmp/init_coords-IO.nii.gz',desc='cropped', space='corobl',hemi='{hemi,Lflip|R}',modality='seg{modality}', **config['subj_wildcards']),allow_missing=True),
    shell:
        'antsApplyTransforms -d 3 -i {params.ap} -r {in_ref} -o {outputs.ap} -n {interp} -t {inputs.warp} -t {inputs.aff}; antsApplyTransforms -d 3 -i {params.pd} -r {in_ref} -o {outputs.pd} -n {interp} -t {inputs.warp} -t {inputs.aff}; antsApplyTransforms -d 3 -i {params.io} -r {in_ref} -o {outputs.io} -n {interp} -t {inputs.warp} -t {inputs.aff}'

rule laplace_coords:
    inputs:
        in_lbl = bids(root='work',**config['subj_wildcards'],suffix='autotop/labelmap-postProcess.nii.gz', desc='cropped', space='corobl', hemi='{hemi,Lflip|R}', modality='{modality}')
    params:
        init_ap = expand(bids(root='work',suffix='autotop/labelmap-postProcess_tmp/init_coords-AP.nii.gz',desc='cropped', space='corobl',hemi='{hemi,Lflip|R}',modality='seg{modality}', **config['subj_wildcards']),allow_missing=True),
        init_pd = expand(bids(root='work',suffix='autotop/labelmap-postProcess_tmp/init_coords-PD.nii.gz',desc='cropped', space='corobl',hemi='{hemi,Lflip|R}',modality='seg{modality}', **config['subj_wildcards']),allow_missing=True),
        init_io = expand(bids(root='work',suffix='autotop/labelmap-postProcess_tmp/init_coords-IO.nii.gz',desc='cropped', space='corobl',hemi='{hemi,Lflip|R}',modality='seg{modality}', **config['subj_wildcards']),allow_missing=True),
        maxiters = [100,100,100] # this should be enough with a good initialization
    outputs:
        ap = expand(bids(root='work',suffix='autotop/labelmap-postProcess_tmp/coords-AP.nii.gz',desc='cropped', space='corobl',hemi='{hemi,Lflip|R}',modality='seg{modality}', **config['subj_wildcards']),allow_missing=True),
        pd = expand(bids(root='work',suffix='autotop/labelmap-postProcess_tmp/coords-PD.nii.gz',desc='cropped', space='corobl',hemi='{hemi,Lflip|R}',modality='seg{modality}', **config['subj_wildcards']),allow_missing=True),
        io = expand(bids(root='work',suffix='autotop/labelmap-postProcess_tmp/coords-IO.nii.gz',desc='cropped', space='corobl',hemi='{hemi,Lflip|R}',modality='seg{modality}', **config['subj_wildcards']),allow_missing=True),
    python:
        laplace_coords.py {inputs} {params.init_ap} {params.init_pd} {params.init_io} {params.maxiters}
