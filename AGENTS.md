# Purpose

Package the benchmark-proven MiniMax H3 FL2VA four-step ComfyUI extension for a scale-to-zero Runpod Serverless worker.

# Ownership

- The pinned Runpod worker image and exact H3 custom node source.
- Model layout and deployment verification instructions.

# Local Contracts

- Use `runpod/worker-comfyui:5.10.0-base` and the exact benchmark H3 nodes.
- Bootstrap remote files with the image's Python runtime because the base image does not include `curl`.
- Store large model files on an attached Runpod network volume under `/runpod-volume/models`.
- Production requests use one approved start image, 768 by 1344 output, four steps, native audio, and no separate identity or voice references.
- Keep minimum workers at zero and maximum workers at one until measured category runs justify a change.
- Verify with one real external Runpod request before adding a playbook to the production allowlist.

# Work Guidance

- Opt-in `VIRALVIEWS_H3_KERNEL_MODE=cu128_sm89` restores the exact SHA-verified September 7 benchmark wheel only on CUDA 12.8 and SM89. Verify CUDA backend availability and the exact Comfy guard shape before enabling it. Default and 96 GB workers remain unchanged.

- The opt-in `VIRALVIEWS_H3_MEMORY_MODE=low_ram` experiment disables node caching and pinned memory after validating the pinned worker launch script and supported CLI flags. Keep it isolated to a test template until a complete clip and execution cost are verified.

- Tag images immutably. Never deploy `latest`.
- Preserve failed jobs and their measured cost.

# Verification

- Verify the official `linux/amd64` worker image, attached network volume, ready manifest, exact byte counts, and stored SHA-256 manifest.
- Confirm the endpoint returns a playable H.264 MP4 with AAC audio.
- Confirm no pods remain and endpoint minimum workers is zero after testing.

# Child DOX Index
