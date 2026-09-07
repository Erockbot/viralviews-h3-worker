FROM runpod/worker-comfyui:5.10.0-base

COPY custom_nodes/ComfyUI-MiniMax-H3 /comfyui/custom_nodes/ComfyUI-MiniMax-H3

# Import the exact H3 extension during the build so a missing ComfyUI API fails
# before a paid worker starts.
RUN cd /comfyui && python -c "import sys; sys.path.insert(0, '/comfyui'); import importlib.util; p='/comfyui/custom_nodes/ComfyUI-MiniMax-H3/nodes.py'; s=importlib.util.spec_from_file_location('h3_nodes', p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); assert hasattr(m, 'MiniMaxH3ImageToVideo')"
