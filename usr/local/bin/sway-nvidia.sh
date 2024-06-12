#!/usr/bin/env bash

## Export Environment Variables
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=sway
export XDG_CURRENT_DESKTOP=sway
export XDG_CURRENT_SESSION=sway

## Qt environment
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_QPA_PLATFORM=xcb
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

# Hardware cursors not yet working on wlroots
export WLR_NO_HARDWARE_CURSORS=1
# Set wlroots renderer to Vulkan to avoid flickering
#export WLR_RENDERER=vulkan
# General wayland environment variables
# Firefox wayland environment variable
#export MOZ_ENABLE_WAYLAND=1
#export MOZ_USE_XINPUT2=1
# OpenGL Variables
#export GBM_BACKEND=nvidia-drm
#export __GL_GSYNC_ALLOWED=0
#export __GL_VRR_ALLOWED=0
#export __GLX_VENDOR_LIBRARY_NAME=nvidia
# Xwayland compatibility
#export XWAYLAND_NO_GLAMOR=1

sway --unsupported-gpu

