
clear; close all;

hippunfolddir = '/data/mica3/BIDS_BigBrain/derivatives/hippunfold_v0.6.0/';
sub = 'bbhist';
hemi = 'R';
midthick = gifti([hippunfolddir '/results/sub-' sub '/surf_cropseg/sub-' sub '_hemi-' hemi '_space-corobl_den-32k_midthickness.surf.gii']);

vertices = reshape(midthick.vertices,[254,126,3]);
vRec = CosineRep_2Dsurf(vertices,24,0.01);

midthick.vertices = vRec;
plot_gifti(midthick);
save(midthick,'tpl-avg_space-canonical_den-32k_midthickness.surf.gii');

% downsample to match various surfaces
resources = '/host/percy/local_raid/jordand/opt/hippunfold/hippunfold/resources/unfold_template/';
template32 = gifti([resources '/tpl-avg_space-unfold_den-32k_midthickness.surf.gii']);
desnities = {'400', '2k', '7k'};
for d = 1:length(desnities)
    den = desnities{d};
    template = gifti([resources '/tpl-avg_space-unfold_den-' den '_midthickness.surf.gii']);
    ind = dsearchn(template32.vertices,template.vertices);
    template.vertices = vRec(ind,:);
    figure; plot_gifti(template);
    save(template,['tpl-avg_space-canonical_den-' den '_midthickness.surf.gii']);
end
