parent=$1
subject=$2

mkdir -p ${parent}/5tt/brain_mask ${parent}/5tt/wm_mask ${parent}/edge/t1
mkdir -p ${parent}/5tt_qc/brain_mask ${parent}/5tt_qc/wm_mask/all_edges ${parent}/5tt_qc/wm_mask/top_edges
echo ________
echo $subject
echo ________

start=$SECONDS

echo "Generate brain mask, WM mask and edges from T1 ..."
echo " Mrtrix 5 tissues type from T1 ..."
5ttgen fsl ${parent}/acpc/nii/sub-${subject}_T1w_RAS.nii.gz /tmp/5tt_sub-${subject}_T1w_RAS.nii.gz -nocrop -nocleanup -tempdir /tmp/5tt_sub-${subject} -quiet
mrconvert /tmp/5tt_sub-${subject}/wm.mif  ${parent}/5tt/wm_mask/sub-${subject}_T1w_RAS_wm_mask.nii.gz -strides +1,+2,+3 -quiet
mrconvert /tmp/5tt_sub-${subject}/T1_BET.nii.gz /tmp/5tt_sub-${subject}/sub-${subject}_T1w_RAS_brain.nii.gz -strides +1,+2,+3 -quiet
fslmaths  /tmp/5tt_sub-${subject}/sub-${subject}_T1w_RAS_brain.nii.gz -bin ${parent}/5tt/brain_mask/sub-${subject}_T1w_RAS_brain_mask.nii.gz
echo " AFNI edges from T1 ..."
3dedge3 -input ${parent}/acpc/nii/sub-${subject}_T1w_RAS.nii -prefix ${parent}/edge/t1/sub-${subject}_T1w_RAS_edges.nii.gz >> /tmp/sub-${subject}_stdout.txt 

echo " QC screenshots ..."
fsleyes render --outfile ${parent}/5tt_qc/brain_mask/sub-${subject}_T1w_RAS_brain_mask.png ${parent}/acpc/nii/sub-${subject}_T1w_RAS.nii.gz ${parent}/5tt/brain_mask/sub-${subject}_T1w_RAS_brain_mask.nii.gz --alpha 50 --cmap yellow
fsleyes render --outfile ${parent}/5tt_qc/wm_mask/all_edges/sub-${subject}_T1w_RAS_wm_mask.png  ${parent}/edge/t1/sub-${subject}_T1w_RAS_edges.nii.gz ${parent}/5tt/wm_mask/sub-${subject}_T1w_RAS_wm_mask.nii.gz --alpha 50 --cmap red 
fsleyes render --outfile ${parent}/5tt_qc/wm_mask/top_edges/sub-${subject}_T1w_RAS_wm_mask_5_30.png  ${parent}/edge/t1/sub-${subject}_T1w_RAS_edges.nii.gz --displayRange 5 30 ${parent}/5tt/wm_mask/sub-${subject}_T1w_RAS_wm_mask.nii.gz --alpha 50 --cmap red 

end=$SECONDS
duration=$(( end - start ))
durationmn=$(( duration / 60))
restsec=$(( duration % 60))
echo "Maks and edges generated in" $durationmn "mn" $restsec "seconds."
#    rm -rf /tmp/5tt_sub-${subject}

