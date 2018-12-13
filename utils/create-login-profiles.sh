#!/usr/bin/env bash

# This script:
# - reads a list of IAM users from stdin
# - configures a login profile for those users who do not yet have one
# - creates a temporary password for each of those users

while IFS= read -r user
do
    if (aws iam get-login-profile --user-name="$user") 2>/dev/null
    then
        echo "user: $user - already configured"
    else
        pass=$(pwgen)
        (aws iam create-login-profile --password-reset-required --user-name="$user" --password="$pass" --password-reset-required) >/dev/null
        echo "user: $user password: $pass"
    fi
done
