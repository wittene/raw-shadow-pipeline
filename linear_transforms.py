'''
Stage 2: Read linear RGB .tiff files, apply transforms, and output linear and sRGB versions
'''

import os
import argparse

import cv2
import numpy as np

from tqdm import tqdm




# SAVE/LOAD FUNCTIONS

def load_img(fp: str):
    return cv2.cvtColor(cv2.imread(fp, cv2.IMREAD_UNCHANGED), cv2.COLOR_BGR2RGB).astype(np.uint8)

def apply_srgb(im, max_val: int = 1):
    '''
    Apply srgb to a linear image.
    Input:
    im: a linear image. Needs to be scaled to the range [0, 1].
    Either input a linear image in the correct range or use the optional
    max_val parameter to scale the image.
    Output:
    The image with srgb applied in original range, as datatype float32.
    '''

    im /= max_val
    if np.max(im) > 1 or np.max(im) < 0:
        raise Exception("linear_img must be scaled to [0, 1]. Use max_val with the appropriate max_val to scale the image.")
    low_mask = im <= 0.0031308
    high_mask = im > 0.0031308
    im[low_mask] *= 12.92
    im[high_mask] = ((im[high_mask]*1.055)**(1/2.4)) - 0.055
    im[im > 1.0] = 1.0
    im[im < 0.0] = 0
    im *= max_val  # scale back to original
    return im


# TRANSFORMS

def affine_transform(target, shadow, border_size):
    # Settings
    warp_mode = cv2.MOTION_AFFINE
    termcrit = (cv2.TERM_CRITERIA_COUNT | cv2.TERM_CRITERIA_EPS, 200,  1e-10)
    crop_size = (750, 750)
    min_cc = 0.6
    # Prepare inputs
    target_input = cv2.cvtColor(target, cv2.COLOR_RGB2GRAY)
    shadow_input = cv2.cvtColor(shadow, cv2.COLOR_RGB2GRAY)
    # To avoid non-convergence due to the shadow, use corner crops for ECC algorithm
    corners = [(0, 0), (0, target_input.shape[1] - crop_size[1]), (target_input.shape[0] - crop_size[0], 0), (target_input.shape[0] - crop_size[0], target_input.shape[1] - crop_size[1])]
    best_cc = min_cc
    best_warp_matrix = None
    for corner in corners:
        try:
            target_crop = target_input[corner[0]:corner[0]+crop_size[0], corner[1]:corner[1]+crop_size[1]]
            shadow_crop = shadow_input[corner[0]:corner[0]+crop_size[0], corner[1]:corner[1]+crop_size[1]]
            # Run the ECC algorithm. The results are stored in warp_matrix.
            warp_matrix = np.eye(3, 3, dtype=np.float32) if warp_mode == cv2.MOTION_HOMOGRAPHY else np.eye(2, 3, dtype=np.float32)
            (cc, warp_matrix) = cv2.findTransformECC(shadow_crop, target_crop, warp_matrix, warp_mode, termcrit)
            # Check validity of warp_matrix
            # (1) Check that translations are not too extreme
            if np.max(np.abs(warp_matrix[:, 2])) > border_size:
                print(f"\tTranslation of {np.max(np.abs(warp_matrix[:, 2]))} is too large for border crop of {border_size}... Trying next set up.")
            # Finally, save best (highest correlation coeff)
            elif cc > best_cc:
                best_cc = cc
                best_warp_matrix = warp_matrix
        except cv2.error as e:
            # Handle specific error
            if 'Iterations do not converge' in str(e):
                print("\tECC algorithm failed to converge... Trying next set up.")
                continue  # Try the next crop
    if best_warp_matrix is not None:
        target = cv2.warpAffine(target, warp_matrix, (target.shape[1],target.shape[0]), flags=cv2.INTER_LINEAR + cv2.WARP_INVERSE_MAP)
    else:
        print('\tNo suitable transformation found. Returning original target.')
    return target

def border_crop(im, border_size):
    # Get even crop
    height, width = im.shape[:2]
    crop_top = border_size
    crop_bottom = height - border_size
    crop_left = border_size
    crop_right = width - border_size
    # Crop
    cropped_image = im[crop_top:crop_bottom, crop_left:crop_right]
    return cropped_image

def resize(im, height, width):
    '''
    Resize images, cropping excess
    '''
    # Scale using larger scaling factor
    scale_h = height / im.shape[0]
    scale_w = width / im.shape[1]
    scaling_factor = max(scale_h, scale_w)
    resized_im = cv2.resize(im, None, fx=scaling_factor, fy=scaling_factor, interpolation=cv2.INTER_AREA)
    # Crop long side if necessary
    if resized_im.shape[0] > height:
        # Crop from top and bottom
        crop_top = (resized_im.shape[0] - height) // 2
        crop_bottom = crop_top + height
        resized_im = resized_im[crop_top:crop_bottom, :]
    if resized_im.shape[1] > width:
        # Crop from left and right
        crop_left = (resized_im.shape[1] - width) // 2
        crop_right = crop_left + width
        resized_im = resized_im[:, crop_left:crop_right]
    # Return
    return resized_im




if __name__ == "__main__":
    # python linear_transforms.py --input_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset/linear --linear_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/linear --srgb_out_dir /work/SuperResolutionData/ShadowRemovalData/RawSR_Dataset_final/srgb

    # Handle args
    parser = argparse.ArgumentParser(description='RAW to linear')
    parser.add_argument('--input_dir', type=str, help='Directory for linear images (input)')
    parser.add_argument('--linear_out_dir', type=str, help='Directory for linear images (output)')
    parser.add_argument('--srgb_out_dir', type=str, help='Directory for sRGB images (output)')
    parser.add_argument('--noisy_dir', type=str, default="shadow", help='Sub-directory with shadow images')
    parser.add_argument('--clean_dir', default="clean", type=str, help='Sub-directory with shadow-free images')
    parser.add_argument('--linear_file_ext', type=str, default="tiff", help='Linear image file extension')
    parser.add_argument('--srgb_file_ext', type=str, default="png", help='sRGB image file extension')
    parser.add_argument('--border_size', type=int, default=100, help='Number of pixels to crop off the borders, after affine transform')
    parser.add_argument('--output_height', type=int, default=480, help='Height of output images')
    parser.add_argument('--output_width', type=int, default=640, help='Width of output images')
    args = parser.parse_args()

    input_dir  = args.input_dir
    linear_out_dir = args.linear_out_dir
    srgb_out_dir = args.srgb_out_dir
    noisy_dir = args.noisy_dir
    clean_dir = args.clean_dir
    linear_file_ext = args.linear_file_ext
    srgb_file_ext = args.srgb_file_ext
    border_size = args.border_size
    output_height = args.output_height
    output_width = args.output_width

    # Init output dirs
    input_clean_dir = os.path.join(input_dir, clean_dir)
    input_noisy_dir = os.path.join(input_dir, noisy_dir)
    linear_clean_dir = os.path.join(linear_out_dir, clean_dir)
    linear_noisy_dir = os.path.join(linear_out_dir, noisy_dir)
    srgb_clean_dir = os.path.join(srgb_out_dir, clean_dir)
    srgb_noisy_dir = os.path.join(srgb_out_dir, noisy_dir)
    os.makedirs(linear_clean_dir, exist_ok=True)
    os.makedirs(linear_noisy_dir, exist_ok=True)
    os.makedirs(srgb_clean_dir, exist_ok=True)
    os.makedirs(srgb_noisy_dir, exist_ok=True)

    # Align clean and noisy filenames
    clean_files = sorted(os.listdir(input_clean_dir))
    noisy_files = sorted(os.listdir(input_noisy_dir))
    if len(noisy_files) > len(clean_files):
        # Customize this
        clean_files = [f"{x.split('-')[0]}-1.{x.split('.')[-1]}" for x in noisy_files]  # 1-N relation between noisy and clean files
    filenames = zip(clean_files, noisy_files)
    print(f"Files to process: {len(clean_files)}")
    
    # Loop through shadow images
    for clean_fn, noisy_fn in tqdm(filenames):
        print(f"===> {noisy_fn}")
        
        # Load original images
        im_clean = load_img(os.path.join(input_clean_dir, clean_fn))
        im_noisy = load_img(os.path.join(input_noisy_dir, noisy_fn))
        assert(np.min(im_clean)>= 0 and np.max(im_clean) <= 255)
        assert(np.min(im_noisy)>= 0 and np.max(im_noisy) <= 255)

        # Output file paths -- use only noisy filename so final output is 1-1
        stripped_fn = os.path.splitext(noisy_fn)[0]
        linear_clean_fp = os.path.join(linear_clean_dir, f'{stripped_fn}.{linear_file_ext}')
        linear_noisy_fp = os.path.join(linear_noisy_dir, f'{stripped_fn}.{linear_file_ext}')
        srgb_clean_fp   = os.path.join(srgb_clean_dir,   f'{stripped_fn}.{srgb_file_ext}')
        srgb_noisy_fp   = os.path.join(srgb_noisy_dir,   f'{stripped_fn}.{srgb_file_ext}')

        #
        # Apply transforms
        # 
        # (1) Affine transform 
        im_clean = affine_transform(im_clean, im_noisy, border_size=border_size)
        assert(np.min(im_clean)>= 0 and np.max(im_clean) <= 255)
        # (2) Crop borders
        im_clean = border_crop(im_clean, border_size=border_size)
        im_noisy = border_crop(im_noisy, border_size=border_size)
        assert(np.min(im_clean)>= 0 and np.max(im_clean) <= 255)
        assert(np.min(im_noisy)>= 0 and np.max(im_noisy) <= 255)
        # (3) Resize for model input
        im_clean = resize(im_clean, output_height, output_width)
        im_noisy = resize(im_noisy, output_height, output_width)
        assert(np.min(im_clean)>= 0 and np.max(im_clean) <= 255)
        assert(np.min(im_noisy)>= 0 and np.max(im_noisy) <= 255)
        
        # Save linear versions
        im_clean = np.clip(cv2.cvtColor(im_clean, cv2.COLOR_RGB2BGR), 0., 255.).astype(np.uint8)
        im_noisy = np.clip(cv2.cvtColor(im_noisy, cv2.COLOR_RGB2BGR), 0., 255.).astype(np.uint8)
        assert(np.min(im_clean)>= 0 and np.max(im_clean) <= 255)
        assert(np.min(im_noisy)>= 0 and np.max(im_noisy) <= 255)
        cv2.imwrite(linear_clean_fp, im_clean)
        cv2.imwrite(linear_noisy_fp, im_noisy)

        # Save sRGB versions
        im_clean = apply_srgb(im_clean.astype(np.float32), max_val=255.).astype(np.uint8)
        im_noisy = apply_srgb(im_noisy.astype(np.float32), max_val=255.).astype(np.uint8)
        assert(np.min(im_clean)>= 0 and np.max(im_clean) <= 255)
        assert(np.min(im_noisy)>= 0 and np.max(im_noisy) <= 255)
        cv2.imwrite(srgb_clean_fp, im_clean)
        cv2.imwrite(srgb_noisy_fp, im_noisy)

    print('Done')