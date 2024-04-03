#!/bin/bash
#SBATCH --job-name=raw
#SBATCH --time=1:00:00
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=8
#SBATCH --mem=50G
#SBATCH --output=./out/make_ISTD_RawSR.%j.out
#SBATCH --error=./out/make_ISTD_RawSR.%j.err
echo "Setting up..."
source raw_env/bin/activate

# Copy training files
python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/ISTD_Dataset/train \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/train \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-train.txt

python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb/all \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/train \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-train.txt

mv /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/train/clean /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/train/train_C
mv /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/train/mask /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/train/train_B
mv /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/train/shadow /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/train/train_A

# Copy test files
python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/ISTD_Dataset/test \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/test \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-test.txt

python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb/all \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/test \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-test.txt

mv /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/test/clean /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/test/test_C
mv /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/test/mask /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/test/test_B
mv /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/test/shadow /work/SuperResolutionData/ShadowRemovalData/ISTD_RawSR_Dataset/test/test_A
