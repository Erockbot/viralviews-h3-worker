#!/usr/bin/env bash
set -euo pipefail

model_root=/runpod-volume/models
ready_manifest=/runpod-volume/h3-models-ready.json
node_root=/comfyui/custom_nodes/ComfyUI-MiniMax-H3

if [[ ! -s "$ready_manifest" ]]; then
  echo "viralviews-h3: verified model manifest is missing: $ready_manifest" >&2
  exit 1
fi

mkdir -p "$node_root"
curl --fail --silent --show-error --location \
  --retry 4 --retry-all-errors \
  https://raw.githubusercontent.com/Erockbot/viralviews-h3-worker/e7edb5cadff670eda2aea308a39695f25205fe65/custom_nodes/ComfyUI-MiniMax-H3/nodes.py \
  --output "$node_root/nodes.py"

link_verified_model() {
  local filename="$1"
  local model_dir="$2"
  local expected_size="$3"
  local source="$model_root/$model_dir/$filename"
  if [[ ! -f "$source" ]]; then
    echo "viralviews-h3: required volume model is missing: $source" >&2
    exit 1
  fi
  if [[ "$(stat -c %s "$source")" != "$expected_size" ]]; then
    echo "viralviews-h3: volume model has wrong size: $source" >&2
    exit 1
  fi
  mkdir -p "/comfyui/models/$model_dir"
  ln -sfn "$(readlink -f "$source")" "/comfyui/models/$model_dir/$filename"
  echo "viralviews-h3: linked $filename"
}

link_verified_model minimax_h3_fl2va_pruned_int8_convrot.safetensors diffusion_models 20970379616
link_verified_model qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors text_encoders 15687142551
link_verified_model minimax_h3_fl2v_turbo_4step_v1.0_768p_comfyui_bf16.safetensors loras 1956192992
link_verified_model minimax_h3_audio_vae_fp32.safetensors vae 605254808
link_verified_model minimax_h3_video_vae_fp16.safetensors vae 5207808496

exec /start.sh
