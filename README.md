## shell-scripts
#### Required Dependencies

1. jq - json parser
    ```shell script
    brew install jq
    ```

2. AWS CLI - I assume you have an account and have setup up credentials

#### One Time Setup
You need to make the shell scripts executable.

    ```shell script
    chmod +x ./aws/read-parameter-store.sh
    ```

#### Comments

- **/aws/read-parameter-store.sh**
  - [x] I needed to track down all of the application config we have stored in AWS.
  - [x] I wanted to learn how to handle paging in the aws cli so I included the max-items param to trigger it.
  - [ ] I also want to search across all regions so that is coming soon.
