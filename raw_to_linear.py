'''
Stage 1: Processing RAW files into linear RGB .tiff files
'''

import os
import argparse

import cv2
import numpy as np
import rawpy




def process_raw(fp: str):
    return rawpy.imread(fp).postprocess().astype(np.float32)




if __name__ == "__main__":
    # python raw_to_linear.py --raw_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/raw --tiff_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear

    # Handle args
    parser = argparse.ArgumentParser(description='RAW to linear')
    parser.add_argument('--raw_dir', type=str, help='Directory for RAW images (input)')
    parser.add_argument('--tiff_dir', type=str, help='Directory for linear .tiff images (output)')
    parser.add_argument('--file_ext', type=str, default="CR2", help='RAW image file extension')
    args = parser.parse_args()

    raw_dir  = args.raw_dir
    tiff_dir = args.tiff_dir
    file_ext = args.file_ext

    # Init output dir
    os.makedirs(tiff_dir, exist_ok=True)

    # Loop through subdirectories
    for root, dirs, files in os.walk(raw_dir):

        print(f'Processing {root}...')

        # Mimic directory structure
        rel_path = os.path.relpath(root, raw_dir)
        output_root = os.path.join(tiff_dir, rel_path)
        os.makedirs(output_root, exist_ok=True)
        
        # Process each image file
        for file in files:
            if file.endswith(file_ext):
                raw_fp = os.path.join(root, file)
                tiff_fp = os.path.join(output_root, f'{os.path.splitext(file)[0]}.tiff')
                im = process_raw(raw_fp)
                im = cv2.cvtColor(im, cv2.COLOR_RGB2BGR)
                cv2.imwrite(tiff_fp, im)
