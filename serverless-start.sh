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
python3 - "$node_root/nodes.py" <<'PY'
from pathlib import Path
import sys
from urllib.request import urlopen

url = "https://raw.githubusercontent.com/Erockbot/viralviews-h3-worker/e7edb5cadff670eda2aea308a39695f25205fe65/custom_nodes/ComfyUI-MiniMax-H3/nodes.py"
Path(sys.argv[1]).write_bytes(urlopen(url, timeout=60).read())
PY

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

if [[ "${VIRALVIEWS_H3_KERNEL_MODE:-default}" == "cu128_sm89" ]]; then
  python3 - <<'PY'
from pathlib import Path
import hashlib
import subprocess
import sys
from urllib.request import urlopen
import torch

if torch.version.cuda != '12.8' or torch.cuda.get_device_capability() != (8, 9):
    raise SystemExit('viralviews-h3: benchmark kernel requires CUDA 12.8 and SM89')
name = 'comfy_kitchen-0.2.33-cp312-abi3-linux_x86_64.whl'
url = f'https://github.com/Erockbot/viralviews-h3-worker/releases/download/h3-cu128-sm89-20260907/{name}'
data = urlopen(url, timeout=60).read()
if hashlib.sha256(data).hexdigest() != 'fcfc38d2ef7a172206c7ea9c49a523dff1b6b8889e3cb26897bfa768c3821222':
    raise SystemExit('viralviews-h3: benchmark kernel SHA mismatch')
wheel = Path('/tmp') / name
wheel.write_bytes(data)
subprocess.run([sys.executable, '-m', 'pip', 'install', '--no-deps', '--force-reinstall', str(wheel)], check=True)
import comfy_kitchen as ck
if not ck.list_backends().get('cuda', {}).get('available'):
    raise SystemExit('viralviews-h3: benchmark CUDA backend is unavailable')
path = Path('/comfyui/comfy/quant_ops.py')
source = path.read_text()
needle = 'if cuda_version < (13,):'
if source.count(needle) != 1:
    raise SystemExit('viralviews-h3: quant_ops CUDA guard changed')
path.write_text(source.replace(needle, 'if cuda_version < (12, 8): # verified benchmark SM89 wheel'))
print('viralviews-h3: benchmark CUDA 12.8 SM89 kernel installed and enabled', flush=True)
PY
fi

if [[ "${VIRALVIEWS_H3_MEMORY_MODE:-default}" == "low_ram" ]]; then
  python3 - <<'PY'
from pathlib import Path

cli = Path('/comfyui/comfy/cli_args.py').read_text()
flags = '--cache-none --disable-pinned-memory'
for flag in flags.split():
    if flag not in cli:
        raise SystemExit(f'viralviews-h3: unsupported low-RAM flag: {flag}')
entry = Path('/start.sh')
source = entry.read_text()
needle = 'python -u /comfyui/main.py --disable-auto-launch'
if source.count(needle) != 2:
    raise SystemExit('viralviews-h3: official start.sh shape changed; refusing an unverified memory patch')
entry.write_text(source.replace(needle, f'python -u /comfyui/main.py {flags} --disable-auto-launch'))
print(f'viralviews-h3: isolated low-RAM experiment enabled: {flags}', flush=True)
PY
fi

exec /start.sh
