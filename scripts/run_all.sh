#!/bin/bash
#SBATCH --job-name=raw
#SBATCH --time=8:00:00
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=8
#SBATCH --mem=50G
#SBATCH --output=./out/raw_to_linear.%j.out
#SBATCH --error=./out/raw_to_linear.%j.err
echo "Setting up..."
source raw_env/bin/activate

# 
# 1) RAW TO LINEAR
# 

python raw_to_linear.py \
    --raw_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/raw-1 \
    --tiff_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-1 \
    &

python raw_to_linear.py \
    --raw_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/raw-2 \
    --tiff_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-2 \
    --file_ext dng \
    &

python raw_to_linear.py \
    --raw_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/raw-red \
    --tiff_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-red \
    --file_ext dng \
    &

python raw_to_linear.py \
    --raw_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/raw-3 \
    --tiff_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-3 \
    --file_ext dng \
    &

wait

# 
# 2) LINEAR TRANSFORMS
# 

python linear_transforms.py \
    --input_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-1 \
    --linear_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear \
    --srgb_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb \
    &

python linear_transforms.py \
    --input_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-2 \
    --linear_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear \
    --srgb_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb \
    &

python linear_transforms.py \
    --input_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-red \
    --linear_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear \
    --srgb_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb \
    &

python linear_transforms.py \
    --input_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-3 \
    --linear_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear \
    --srgb_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb \
    &

wait

# 
# 3) GENERATE MASKS
# 

python gen_masks.py \
    --dataset_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear \
    --mask_file_ext png

cp -r /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear/mask /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb/mask

# 
# 4) TRAIN/TEST SPLIT
# 

# Copy training files
python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear_split/train \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-train.txt

python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_split/train \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-train.txt

# Copy test files
python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear_split/test \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-test.txt

python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_split/test \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-test.txt

# Re-organize
mv /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear_split/all
mv /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_split/all
mv /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear_split /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear
mv /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_split /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb