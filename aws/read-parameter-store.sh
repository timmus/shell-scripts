#!/usr/bin/env bash


function print_system_parameters {
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

	  echo "$response" | jq -r "$jq_filter"

	  next_token=$(echo "$response" | jq -r ".NextToken")

	  if [ "$next_token" == null ]
	    then
	      keep_paging=false
	  fi

	  ((page_count++))
	done
}

print_system_parameters prod-locbox us-east-1
print_system_parameters prod-locbox us-east-2
print_system_parameters prod-locbox us-west-1
print_system_parameters prod-locbox us-west-2

print_system_parameters prod-spotley us-east-1
print_system_parameters prod-spotley us-east-2
print_system_parameters prod-spotley us-west-1
print_system_parameters prod-spotley us-west-2



