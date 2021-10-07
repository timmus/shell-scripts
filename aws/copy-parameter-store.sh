#!/usr/bin/env bash


function copy_system_parameters {
	read -r -d '' jq_filter <<-EOT
	  { NextToken: .NextToken, Parameters: [.Parameters[] |
	  { Name: .Name, Value: .Value }] }
	EOT

	from_profile=$1
	from_region=$2
	to_profile=$3
	to_region=$4

	next_token=null
	token_param=""
	keep_paging=true
	page_count=0

	echo "#################################### ${from_profile} ${from_region} - ${to_profile} ${to_region} ####################################"

	until [ "$keep_paging" == false ] || [ "$page_count" -eq 100 ]; do
	  if [ "$next_token" != null ]
	    then
	      token_param="--starting-token ${next_token}"
	  fi

	  response=$(aws ssm get-parameters-by-path \
	    --path "/" \
	    --recursive \
	    --with-decryption \
	    --output json \
	    --profile "${from_profile}" \
	    --region "${from_region}" \
	    --max-items 20 \
	    "${token_param}")

	  x=$(echo "$response" | jq -r "$jq_filter")

    parameters=$(echo "${x}" | jq -r -c '.Parameters | .[] | @base64')

	  for row in $parameters; do
        name=$(echo $row | base64 --decode | jq -r '.Name')
        value=$(echo $row | base64 --decode | jq -r '.Value')

        aws ssm put-parameter --profile "${to_profile}" --region "${to_region}" --no-cli-pager \
          --name "${name}" --value "${value}" --type String --overwrite
    done

	  next_token=$(echo "$response" | jq -r ".NextToken")

	  if [ "$next_token" == null ]
	    then
	      keep_paging=false
	  fi

	  ((page_count++))
	done
}

# copy all the params from one region to another
copy_system_parameters hownd-staging us-west-1 hownd-staging us-west-2




