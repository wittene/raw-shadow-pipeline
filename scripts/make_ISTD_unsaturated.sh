#!/bin/bash
#SBATCH --job-name=raw
#SBATCH --time=1:00:00
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=8
#SBATCH --mem=50G
#SBATCH --output=./out/make_ISTD_unsaturated.%j.out
#SBATCH --error=./out/make_ISTD_unsaturated.%j.err
echo "Setting up..."
source raw_env/bin/activate

# Copy training files
python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/ISTD_Dataset/train \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/ISTD_Dataset/train-unsaturated \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-train.txt


# Copy test files
python copy_files.py \
    --in_dir /work/SuperResolutionData/ShadowRemovalData/ISTD_Dataset/test \
    --out_dir /work/SuperResolutionData/ShadowRemovalData/ISTD_Dataset/test-unsaturated \
    --filenames_txt /home/witten.e/Shadow_Removal/raw-shadow-pipeline/files/ISTD_RawSR-test.txt
