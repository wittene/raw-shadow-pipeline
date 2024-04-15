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
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear/all \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear/train \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-train.txt

python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb/all \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb/train \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-train.txt

python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_jpg/all \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_jpg/train \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-train.txt

# Copy test files
python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear/all \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear/test \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-test.txt

python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb/all \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb/test \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-test.txt

python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_jpg/all \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb_jpg/test \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-test.txt
