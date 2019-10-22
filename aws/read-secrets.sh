#!/usr/bin/env bash

read -r -d '' jq_filter <<-EOT
	{ NextToken: .NextToken, Parameters: [.Parameters[] | 
	{ Name: .Name, Value: .Value }] }
EOT

profile_name="prod-locbox"

next_token=null
token_param=""
keep_paging=true
page_count=0
 
until [ "$keep_paging" == false ] || [ "$page_count" -eq 2 ]; do
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
		--region us-west-2 \
		--max-items 20 \
		${token_param})

	echo "$response" | jq -r "$jq_filter"

  next_token=$(echo "$response" | jq -r ".NextToken")

  if [ "$next_token" == null ]
	then
	    keep_paging=false
	fi

	let "page_count++"
	# echo "Page: ${page_count}"
done
