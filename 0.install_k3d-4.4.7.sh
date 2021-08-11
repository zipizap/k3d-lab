#!/bin/bash
set -x
wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v4.4.7 bash


