#!/usr/bin/env bash


function copy_system_parameters {
	read -r -d '' jq_filter <<-EOT
	  { NextToken: .NextToken, Parameters: [.Parameters[] |
	  { Name: .Name, Value: .Value }] }
	EOT

	profile_name=$1
	region=$2

	next_token=null
	token_param=""
	keep_paging=true
	page_count=0

	echo "#################################### ${profile_name} ${region} ####################################"

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
	    --profile ${profile_name} \
	    --region ${region} \
	    --max-items 20 \
	    ${token_param})

	  x=$(echo "$response" | jq -r "$jq_filter")

    parameters=$(echo "${x}" | jq -r -c '.Parameters | .[] | @base64')

	  for row in $parameters; do
        name=$(echo $row | base64 --decode | jq -r '.Name')
        value=$(echo $row | base64 --decode | jq -r '.Value')

        aws ssm put-parameter --profile beakon-staging --region us-west-2 --no-cli-pager \
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

copy_system_parameters hownd-staging us-west-1
copy_system_parameters hownd-staging us-west-2



