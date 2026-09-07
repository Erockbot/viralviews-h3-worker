#!/usr/bin/env bash
set -euo pipefail

cache_root=/runpod-volume/huggingface-cache
node_root=/comfyui/custom_nodes/ComfyUI-MiniMax-H3

mkdir -p "$node_root"
curl --fail --silent --show-error --location \
  --retry 4 --retry-all-errors \
  https://raw.githubusercontent.com/Erockbot/viralviews-h3-worker/e7edb5cadff670eda2aea308a39695f25205fe65/custom_nodes/ComfyUI-MiniMax-H3/nodes.py \
  --output "$node_root/nodes.py"

link_cached_model() {
  local filename="$1"
  local model_dir="$2"
  local source
  source=$(find -L "$cache_root" -type f -name "$filename" -print -quit)
  if [[ -z "$source" ]]; then
    echo "viralviews-h3: required cached model is missing: $filename" >&2
    exit 1
  fi
  mkdir -p "/comfyui/models/$model_dir"
  ln -sfn "$(readlink -f "$source")" "/comfyui/models/$model_dir/$filename"
  echo "viralviews-h3: linked $filename"
}

link_cached_model minimax_h3_fl2va_pruned_int8_convrot.safetensors diffusion_models
link_cached_model qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors text_encoders
link_cached_model minimax_h3_fl2v_turbo_4step_v1.0_768p_comfyui_bf16.safetensors loras
link_cached_model minimax_h3_audio_vae_fp32.safetensors vae
link_cached_model minimax_h3_video_vae_fp16.safetensors vae

exec /start.sh
