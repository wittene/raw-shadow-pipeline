#!/bin/bash
#SBATCH --job-name=raw
#SBATCH --time=8:00:00
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=8
#SBATCH --mem=50G
#SBATCH --output=./out/run_all.%j.out
#SBATCH --error=./out/run_all.%j.err
echo "Setting up..."
source raw_env/bin/activate

# 
# 1) RAW TO LINEAR
# 

python raw_to_linear.py \
    --raw_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/raw-1 \
    --tiff_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-1__16bit \
    --output_bps 16 \
    &

python raw_to_linear.py \
    --raw_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/raw-2 \
    --tiff_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-2__16bit \
    --output_bps 16 \
    --file_ext dng \
    &

python raw_to_linear.py \
    --raw_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/raw-red \
    --tiff_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-red__16bit \
    --output_bps 16 \
    --file_ext dng \
    &

python raw_to_linear.py \
    --raw_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/raw-3 \
    --tiff_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-3__16bit \
    --output_bps 16 \
    --file_ext dng \
    &

wait

# 
# 2) LINEAR TRANSFORMS
# 

python linear_transforms.py \
    --input_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-1__16bit \
    --linear_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear__16bit/all \
    --srgb_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb__16bit/all \
    --srgb_file_ext png \
    &

python linear_transforms.py \
    --input_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-2__16bit \
    --linear_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear__16bit/all \
    --srgb_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb__16bit/all \
    --srgb_file_ext png \
    &

python linear_transforms.py \
    --input_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-red__16bit \
    --linear_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear__16bit/all \
    --srgb_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb__16bit/all \
    --srgb_file_ext png \
    &

python linear_transforms.py \
    --input_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-3__16bit \
    --linear_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear__16bit/all \
    --srgb_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb__16bit/all \
    --srgb_file_ext png \
    &

wait

# 
# 3) GENERATE MASKS
# 

python gen_masks.py \
    --dataset_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear__16bit/all \
    --mask_file_ext png

cp -r /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear__16bit/all/mask /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb__16bit/all/mask

# 
# 4) TRAIN/TEST SPLIT
# 

# Copy training files
python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear__16bit/all \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear__16bit/train \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-train.txt

python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb__16bit/all \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb__16bit/train \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-train.txt

# Copy test files
python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear__16bit/all \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear__16bit/test \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-test.txt

python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb__16bit/all \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb__16bit/test \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-test.txt

