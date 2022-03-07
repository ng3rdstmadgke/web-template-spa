#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
PROJECT_ROOT=$(cd $(dirname $0)/..; pwd)
FRONT_DIR=$(cd "${PROJECT_ROOT}/front"; pwd)

cd $FRONT_DIR

npm run dev
