#!/usr/bin/env bash

# Default config vars
CURL="$(which curl)"
DADAPUSH_URL="https://www.dadapush.com/api/v1/message"
TOKEN=""
CURL_OPTS=""


json_escape () {
    printf '%s' "$1" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

send_message() {
    curl_cmd="\"${CURL}\" --silent --write-out "HTTPSTATUS:%{http_code}" -X POST \"${DADAPUSH_URL}\" \
        ${CURL_OPTS} \
        -H 'content-type: application/json' \
        -H 'x-channel-token: ${TOKEN}' \
        -d '${message}'
        "
    # echo $curl_cmd
    # execute and return exit code from curl command
    HTTP_RESPONSE="$(eval "${curl_cmd}")"
    # extract the body
    HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

    # extract the status
    HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

    # print the body
    echo "$HTTP_BODY"

    # example using the status
    if [ ! $HTTP_STATUS -eq 200  ]; then
    echo "Error [HTTP status: $HTTP_STATUS]"
    exit 1
    fi

    r="${?}"
    if [ "${r}" -ne 0 ]; then
        echo "${0}: Failed to send message" >&2
    fi

    return "${r}"
}

# Option parsing

optstring="T:a:b:c:d:e:f:g:"

# Process the remaining options
OPTIND=1
while getopts ${optstring} c; do
    case ${c} in
        T) TOKEN="${OPTARG}" ;;
        a) NOTIFICATIONTYPE=$OPTARG ;;
        b) CLIENT=$OPTARG ;;
        c) HOSTSTATE=$OPTARG ;;
        d) HOSTOUTPUT=$OPTARG ;;
        e) SERVICEDESC=$OPTARG ;;
        f) SERVICESTATE=$OPTARG ;;
        g) SERVICEOUTPUT=$OPTARG ;;
        [h\?]) usage ;;
    esac
done
shift $((OPTIND-1))


TITLE=""
CONTENT=""

if [ -x $HOSTSTATE ]; then
  TITLE="[${NOTIFICATIONTYPE}]: ${CLIENT} ${SERVICEDESC}"
  CONTENT="[${NOTIFICATIONTYPE}]: ${CLIENT} ${SERVICEDESC} is ${SERVICESTATE}. ${SERVICEOUTPUT}"
else
  TITLE="[${NOTIFICATIONTYPE}]: ${CLIENT}"
  CONTENT="[${NOTIFICATIONTYPE}]: ${CLIENT} is ${HOSTSTATE}. ${HOSTOUTPUT}"
fi

TITLE=`json_escape "$TITLE"`
CONTENT=`json_escape "$CONTENT"`
# echo $TITLE
# echo $CONTENT
message="{\"title\":${TITLE},\"content\":${CONTENT},\"needPush\":true}"
# echo $message

# Check for required config variables
if [ ! -x "${CURL}" ]; then
    echo "CURL is unset, empty, or does not point to curl executable. This script requires curl!" >&2
    exit 1
fi

send_message
r=${?}

exit "${r}"
