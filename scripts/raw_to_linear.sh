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

python raw_to_linear.py \
    --raw_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/raw-1 \
    --tiff_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-1

python raw_to_linear.py \
    --raw_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/raw-2 \
    --tiff_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-2 \
    --file_ext dng

python raw_to_linear.py \
    --raw_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/raw-red \
    --tiff_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-red \
    --file_ext dng

python raw_to_linear.py \
    --raw_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/raw-3 \
    --tiff_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-3 \
    --file_ext dng
