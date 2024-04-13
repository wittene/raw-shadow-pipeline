#!/bin/bash
#SBATCH --job-name=raw
#SBATCH --time=1:00:00
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=8
#SBATCH --mem=50G
#SBATCH --output=./out/split_RawSR.%j.out
#SBATCH --error=./out/split_RawSR.%j.err
echo "Setting up..."
source raw_env/bin/activate

# Copy training files
python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear_split/train \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-train.txt

python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_split/train \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-train.txt

python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_jpg \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_jpg_split/train \
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

python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_jpg/all \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_jpg/test \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-test.txt

# Re-organize
mv /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear_split/all
mv /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_split/all
mv /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_jpg /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_jpg_split/all
mv /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear_split /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear
mv /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_split /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb
mv /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_jpg_split /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_jpg