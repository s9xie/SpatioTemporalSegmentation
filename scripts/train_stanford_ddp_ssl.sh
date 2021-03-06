#!/bin/bash

set -x
# Exit script when a command returns nonzero state
set -e

set -o pipefail

SAVEPATH=/checkpoint/jgu/space/3d_ssl2
DATAPATH=${3:-"/private/home/jgu/data/3d_ssl2/Stanford3D/"}
PRETRAIN="/checkpoint/s9xie/pointcontrast_scannet_logs/POINTCONTRAST_SCN_-default/2020-01-29_17-03-45/checkpoint_ep35.pth"
MODEL=Res16UNet34C

export PYTHONUNBUFFERED="True"
# export CUDA_VISIBLE_DEVICES=$1
export BATCH_SIZE=${BATCH_SIZE:-6}
export TIME=$(date +"%Y-%m-%d_%H-%M-%S")
export LOG_DIR=${SAVEPATH}/outputs/StanfordArea5Dataset/slurm/SSL_${MODEL}_$TIME

# Save the experiment detail and dir to the common log file
mkdir -p $LOG_DIR
LOG="$LOG_DIR/$TIME.txt"


python -m ddp_main \
    --dataset StanfordArea5Dataset \
    --batch_size $BATCH_SIZE \
    --stat_freq 1 --val_freq 100 --save_freq 100 \
    --scheduler PolyLR \
    --model ${MODEL} \
    --conv1_kernel_size 3 \
    --log_dir $LOG_DIR \
    --lr 1e-1 \
    --max_iter 8000 \
    --data_aug_color_trans_ratio 0.05 \
    --data_aug_color_jitter_std 0.005 \
    --train_phase train \
    --weights ${PRETRAIN} --lenient_weight_loading "True" \
    --stanford3d_path ${DATAPATH} 2>&1 | tee -a "$LOG"
