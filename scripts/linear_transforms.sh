#!/bin/bash
#SBATCH --job-name=raw
#SBATCH --time=8:00:00
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=8
#SBATCH --mem=50G
#SBATCH --output=./out/linear_transforms.%j.out
#SBATCH --error=./out/linear_transforms.%j.err
echo "Setting up..."
source raw_env/bin/activate

# python linear_transforms.py \
#     --input_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-1 \
#     --linear_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear \
#     --srgb_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb

# python linear_transforms.py \
#     --input_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-2 \
#     --linear_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear \
#     --srgb_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb

# python linear_transforms.py \
#     --input_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-red \
#     --linear_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear \
#     --srgb_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb

# python linear_transforms.py \
#     --input_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear-3 \
#     --linear_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear \
#     --srgb_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb