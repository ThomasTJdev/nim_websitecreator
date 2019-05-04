#!/bin/bash
cd base
docker build -t nimwc_base . # Build the base to always use latest nimwc version
cd ..
docker build -t nimwc:1.0 . # Build a Docker from the Dockerfile.
