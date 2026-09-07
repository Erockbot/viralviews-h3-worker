# ViralViews MiniMax H3 Runpod bootstrap

This public repository contains the exact custom ComfyUI node and startup script used by the ViralViews H3 Runpod endpoint. The endpoint runs `runpod/worker-comfyui:5.10.0-base` and attaches the `viralviews-h3-models` network volume containing the pinned `Comfy-Org/MiniMax-H3` revision `a98869194787969724c7425d95d0ed73ce9202af`.

This image adds the exact MiniMax H3 ComfyUI nodes used by the September 7 benchmark to Runpod's official Serverless ComfyUI worker. Model weights live on a Runpod network volume at `/runpod-volume/models`.

Required model files:

- `models/diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors`
- `models/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors`
- `models/vae/minimax_h3_audio_vae_fp32.safetensors`
- `models/vae/minimax_h3_video_vae_fp16.safetensors`
- `models/loras/minimax_h3_fl2v_turbo_4step_v1.0_768p_comfyui_bf16.safetensors`

The application adapter sends the official worker contract: `input.workflow` plus one base64 start image in `input.images`.
