'''
Stage 3: Read linear RGB .tiff files and generate binary shadow masks
'''

import os
import argparse

import cv2
import numpy as np

from tqdm import tqdm




# HELPER FUNCTIONS

def load_img(fp: str):
    return cv2.cvtColor(cv2.imread(fp, cv2.IMREAD_UNCHANGED), cv2.COLOR_BGR2RGB).astype(np.float32)

def estimate_shadow_mask(target, shadow, kernel_size=8):
    # Estimate binary shadow mask using thresholded difference image
    diff_image = cv2.absdiff(shadow, target).astype(np.uint8)
    diff_image = cv2.cvtColor(diff_image, cv2.COLOR_BGR2GRAY)
    _, binary_mask = cv2.threshold(diff_image, 0, 255, cv2.THRESH_OTSU)
    # _, binary_mask = cv2.threshold(diff_image, threshold, 255, cv2.THRESH_BINARY)
    # Clean up the binary mask (close -> open)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (kernel_size, kernel_size))
    binary_mask = cv2.morphologyEx(binary_mask, cv2.MORPH_CLOSE, kernel)
    binary_mask = cv2.morphologyEx(binary_mask, cv2.MORPH_OPEN, kernel)
    # Return
    return binary_mask




if __name__ == "__main__":
    # python linear_transforms.py --input_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear --linear_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear --srgb_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb

    # Handle args
    parser = argparse.ArgumentParser(description='RAW to linear')
    parser.add_argument('--dataset_dir', type=str, help='Directory for dataset (parent of clean/noisy/mask subdirectories)')
    parser.add_argument('--noisy_dir', type=str, default="shadow", help='Sub-directory with shadow images (input)')
    parser.add_argument('--clean_dir', default="clean", type=str, help='Sub-directory with shadow-free images (input)')
    parser.add_argument('--mask_dir', default="mask", type=str, help='Sub-directory with binary shadow mask images (output)')
    parser.add_argument('--linear_file_ext', type=str, default="tiff", help='Linear image file extension')
    parser.add_argument('--mask_file_ext', type=str, default="png", help='Binary shadow mask image file extension')
    args = parser.parse_args()

    dataset_dir  = args.dataset_dir
    noisy_dir = args.noisy_dir
    clean_dir = args.clean_dir
    mask_dir = args.mask_dir
    linear_file_ext = args.linear_file_ext
    mask_file_ext = args.mask_file_ext

    # Init output dirs
    input_noisy_dir = os.path.join(dataset_dir, noisy_dir)
    input_clean_dir = os.path.join(dataset_dir, clean_dir)
    output_mask_dir = os.path.join(dataset_dir, mask_dir)
    os.makedirs(output_mask_dir, exist_ok=True)
    
    # Loop through shadow images
    noisy_files = sorted(os.listdir(input_noisy_dir))
    for noisy_fn in tqdm(noisy_files):
        
        # Load original images
        im_noisy = load_img(os.path.join(input_noisy_dir, noisy_fn))
        im_clean = load_img(os.path.join(input_clean_dir, noisy_fn))

        # Output file path -- use noisy filename
        stripped_fn = os.path.splitext(noisy_fn)[0]
        noisy_fp = os.path.join(input_noisy_dir, f'{stripped_fn}.{linear_file_ext}')
        clean_fp = os.path.join(input_clean_dir, f'{stripped_fn}.{linear_file_ext}')
        mask_fp  = os.path.join(output_mask_dir, f'{stripped_fn}.{mask_file_ext}')

        # Generate and save mask
        mask = estimate_shadow_mask(im_clean, im_noisy).astype(np.uint8)
        cv2.imwrite(mask_fp, mask)

    print('Done')