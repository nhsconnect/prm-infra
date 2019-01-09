#! /bin/bash

unset_vars() {
    echo unset AWS_ACCESS_KEY_ID
    echo unset AWS_SECRET_ACCESS_KEY
    echo unset AWS_SESSION_TOKEN
}

assume() {
    $(unset_vars)
    export SESSION_NAME=$(date +%s)
    temp_role=$(aws sts assume-role \
                        --role-arn "$ROLE_ARN" \
                        --role-session-name "$SESSION_NAME")

    if [ $? -eq 0 ]; then
        export TEMPWORD="AWS"
        echo export $TEMPWORD"_ACCESS_KEY_ID"=$(echo $temp_role | jq .Credentials.AccessKeyId | xargs)
        echo export $TEMPWORD"_SECRET_ACCESS_KEY"=$(echo $temp_role | jq .Credentials.SecretAccessKey | xargs)
        echo export $TEMPWORD"_SESSION_TOKEN"=$(echo $temp_role | jq .Credentials.SessionToken | xargs)
    fi
}

usage () {
  echo "Parameters:"
  echo "  -r [aws role arn]   to assume specified role"
  echo "  -u|--unset          to unset AWS_* variables"
  echo "  -h|--help           for this help message"
}

if [ $# -eq 0 ]; then
  usage
  exit 1
fi

while [ $# -gt 0 ]; do
    case $1 in
        -r | --role)
           shift
           ROLE_ARN=$1
           assume
           ;;
        -h | --help)
           usage
           exit 0
           ;;
        -u | --unset)
           unset_vars
           exit 0
           ;;
        *)
           usage
           exit 1
           ;;
    esac
    shift
done
