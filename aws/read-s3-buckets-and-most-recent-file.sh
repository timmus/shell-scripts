#!/usr/bin/env bash

function print_s3_buckets {
  local profile=$1
	local region=$2
	local bucket=$3
	local directory=$4

  for path in $(aws s3 ls s3://${bucket}/${directory}/ --profile ${profile} --region ${region});
    do
      if [[ "$path" != "PRE" ]]; then
        local file=$(get_most_recent_file locbox-prod us-west-2 "s3://${bucket}/${directory}/$path")
        echo "${path} - ${file}"
      fi
  done
}

function get_most_recent_file {
  local profile=$1
	local region=$2
	local path="${3}"
	# echo "$path"
  echo $(aws s3 ls ${path}  --profile ${profile} --region ${region} --recursive | sort | tail -n 1 | awk '{print $4}')
}

print_s3_buckets locbox-prod us-west-2 center-edge-uploads started
