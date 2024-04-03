'''
Copy given files from all sub-directories of a given directory 
to a new directory, mimicking file structure.
Used for combining datasets.
'''

import os
import shutil
import argparse


def copy_files(in_dir, out_dir, filenames_txt):
    
    # Read filenames
    with open(filenames_txt, 'r') as file:
        filenames = file.read().splitlines()

    # Walk subdirectories in in_dir
    for curr_root, _, curr_files in os.walk(in_dir):

        print(f'Processing {curr_root}...')

        # Mimic directory structure
        rel_path = os.path.relpath(curr_root, in_dir)
        output_root = os.path.join(out_dir, rel_path)
        os.makedirs(output_root, exist_ok=True)
        
        # Copy each file
        for fn in curr_files:
            stripped_fn = os.path.splitext(fn)[0]
            if stripped_fn in filenames:
                src_path = os.path.join(curr_root, fn)
                dst_path = os.path.join(output_root, fn)
                shutil.copyfile(src_path, dst_path)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Copy files from given list preserving directory structure.")
    parser.add_argument("--in_dir", help="Input directory path")
    parser.add_argument("--out_dir", help="Output directory path")
    parser.add_argument("--filenames_txt", help="Path to the text file containing filenames")
    args = parser.parse_args()
    
    copy_files(args.in_dir, args.out_dir, args.filenames_txt)
    print("Done.")
