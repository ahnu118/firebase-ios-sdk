# Copyright 2021 Google LLC
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

DATABASE_PATHS=("FirebaseDatabase.*" \
  ".github/workflows/database\\.yml" \
  "Example/Database/" \
  "Interop/Auth/Public/\.\*.h")
FUNCTIONS_PATHS=("Functions.*" \
  ".github/workflows/functions\\.yml" \
  "Interop/Auth/Public/\.\*.h" \
  "FirebaseMessaging/Sources/Interop/\.\*.h")

# Set default flag variables which will determine if an sdk workflow will be triggererd.
echo "::set-output name=database_run_job::false"
echo "::set-output name=functions_run_job::false"

# Get most rescent ancestor commit.
common_commit=$(git merge-base remotes/origin/${pr_branch} remotes/origin/master)
echo "The common commit is ${common_commit}."
echo "::set-output name=base_commit::${common_commit}"

# List changed file from the base commit. This is generated by comparing the
# head of the branch and the common commit from the master branch.
echo "=============== list changed files ==============="
cat < <(git diff --name-only $common_commit remotes/origin/${pr_branch})

echo "============= paths of changed files ============="
git diff --name-only $common_commit remotes/origin/${pr_branch} > updated_files.txt

# Loop over updated files if their path match patterns then flags to trigger
# SDK pod test workflow will be set to true.
while IFS= read -r file
do
  for path in "${DATABASE_PATHS[@]}"
  do
    if [[ "${file}" =~ $path ]]; then
      echo "This file is updated under the path, ${path}"
      echo "::set-output name=database_run_job::true"
      break
    fi
  done
  for path in "${FUNCTIONS_PATHS[@]}"
  do
    if [[ "${file}" =~ $path ]]; then
      echo "This file is updated under the path, ${path}"
      echo "::set-output name=functions_run_job::true"
      break
    fi
  done
done < updated_files.txt