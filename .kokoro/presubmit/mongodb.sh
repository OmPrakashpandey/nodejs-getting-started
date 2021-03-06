#!/bin/bash

# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# NOTE:
# - Each system test uses a different script for system tests. This is due to the need for database/proxy commands
# - The end-to-end (E2E) tests don't need additional commands (GAE handles that), so they use a common test script

# Remove old logs/YAML files
rm -rf */*.log
rm -rf *-*.yaml

export NODE_ENV=development
export DATA_BACKEND="mongodb"

# Configure gcloud
GCLOUD_PROJECT=nodejs-getting-started-tests
export GOOGLE_APPLICATION_CREDENTIALS=${KOKORO_GFILE_DIR}/secrets-key.json
gcloud auth activate-service-account --key-file "$GOOGLE_APPLICATION_CREDENTIALS"
gcloud config set project $GCLOUD_PROJECT

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Use Node 10
nvm install 10

cd github/nodejs-getting-started/

# Copy secrets into subdirectories
find . -name package.json -maxdepth 2 -execdir sh -c "cp ${KOKORO_GFILE_DIR}/secrets-config.json config.json" \;
find . -name package.json -maxdepth 2 -execdir sh -c "cp $GOOGLE_APPLICATION_CREDENTIALS key.json" \;

# Test samples for Compute Engine (7-gce)
cd 7-gce

# Fail on error
set -e;

# Install dependencies (for running the tests, not the apps themselves)
npm install

# Test all steps locally
npm test

# Exit on error
if [[ $? -ne 0 ]]; then
  exit $?
fi

# Test samples for Kubernetes Engine (optional-kubernetes-engine)
cd ../optional-kubernetes-engine

# Install dependencies (for running the tests, not the apps themselves)
npm install

# Test all steps locally
npm test

# Exit on error
if [[ $? -ne 0 ]]; then
  exit $?
fi