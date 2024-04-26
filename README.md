# RAW Shadow Image Pipeline
> Author: Elizabeth Witten (Spring 2024)

This pipeline was developed to process RAW images to linear and sRGB in a clean and consistent process. The pipeline has three stages: (1) RAW processing, (2) linear transforms, and (3) automatic mask generation.

For incorrectly generated masks, use `gen_shadow_masks.m` to manually annotate the shadow image(s).

## Setup
Set up a Python environment using `requirements.txt`.

## Running the pipeline
See the `scripts` folder for examples on running the pipeline from the command line.