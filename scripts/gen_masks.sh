#!/bin/bash
#SBATCH --job-name=raw
#SBATCH --time=1:00:00
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=8
#SBATCH --mem=50G
#SBATCH --output=./out/gen_masks.%j.out
#SBATCH --error=./out/gen_masks.%j.err
echo "Setting up..."
source raw_env/bin/activate
python gen_masks.py \
    --dataset_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear/all \
    --mask_file_ext png