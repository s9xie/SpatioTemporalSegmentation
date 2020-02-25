#!/bin/bash
JOB_NAME="Scannet_scratch_bs9_ks3"
EXP_NAME="Scannet_scratch_bs9_ks3"

# basic configurations
NUM_GPU=1
NUM_JOB=1
WALL_TIME=72
TASK_PER_NODE=1
QUEUE=dev
CPU_PER_GPU=10
NICE=0
NUM_CPU=$((${NUM_GPU} * ${CPU_PER_GPU}))
LOG_DIR="/checkpoint/s9xie/${EXP_NAME}"
DRIVER_DIR="/private/home/s9xie/3d_ssl/launch_scripts/"
USER=s9xie

mkdir -p ${LOG_DIR}

pushd /private/home/s9xie/3d_ssl/SpatioTemporalSegmentation

# print job summary
echo "JOB ${JOB_NAME} | EXP ${EXP_NAME}"
echo "LOG DIR ${LOG_DIR}"

# launch
echo "Launch job ..."
sbatch --nodes=1 \
       --cpus-per-task=${NUM_CPU} \
       --mem=512GB \
       --array=1-${NUM_JOB} \
       --ntasks-per-node=${TASK_PER_NODE} \
       --gres=gpu:${NUM_GPU} \
       --time=${WALL_TIME}:00:00 \
       --partition=${QUEUE} \
       --output="${LOG_DIR}/cluster_log_j%A_%a_%N.out" \
       --error="${LOG_DIR}/cluster_log_j%A_%a_%N.err" \
       --job-name=${JOB_NAME} \
       --nice=${NICE} \
       --signal=B:USR1@600 \
       --mail-user=${USER}@fb.com \
       --mail-type=BEGIN,END,FAIL,REQUEUE \
       --constraint=volta32gb \
       --export=ALL,BATCH_SIZE=9 \
       /private/home/s9xie/3d_ssl/SpatioTemporalSegmentation/scripts/train_scannet.sh 0 -default "--scannet_path /private/home/s9xie/3d_ssl/SpatioTemporalSegmentation/data --conv1_kernel_size=3"

echo "Finished launching job ..."

popd
