# Purpose

Package the benchmark-proven MiniMax H3 FL2VA four-step ComfyUI extension for a scale-to-zero Runpod Serverless worker.

# Ownership

- The pinned Runpod worker image and exact H3 custom node source.
- Model layout and deployment verification instructions.

# Local Contracts

- Use `runpod/worker-comfyui:5.10.0-base` and the exact benchmark H3 nodes.
- Store large model files on an attached Runpod network volume under `/runpod-volume/models`.
- Production requests use one approved start image, 768 by 1344 output, four steps, native audio, and no separate identity or voice references.
- Keep minimum workers at zero and maximum workers at one until measured category runs justify a change.
- Verify with one real external Runpod request before adding a playbook to the production allowlist.

# Work Guidance

- Tag images immutably. Never deploy `latest`.
- Preserve failed jobs and their measured cost.

# Verification

- Build the image for `linux/amd64`.
- Confirm the endpoint returns a playable H.264 MP4 with AAC audio.
- Confirm no pods remain and endpoint minimum workers is zero after testing.

# Child DOX Index
