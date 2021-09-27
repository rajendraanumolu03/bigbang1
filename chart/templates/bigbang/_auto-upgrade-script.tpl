#!/bin/sh

set -e

notify() {
  echo "$1"
  echo -n "$1 " >> /dev/termination-log
}

# greater_version()
# {
#   test "$(printf '%s\n' "$@" | sort -V | tail -n 1)" = "$1";
# }

# # For the PostgreSQL upgrade, you either need both secrets, or no secrets.
# # If there are no secrets, we will create them for you.
# # If the secrets aren't in either of these states, we assume you are upgrading from an older version
# # This is running ahead of version checks to ensure this always runs. This is to account for
# # installations outside of the official helm repo.
# secrets_dir="/etc/secrets/postgresql"
# if [ -d "${secrets_dir}" ]; then
#   if [ ! "$(ls -A ${secrets_dir}/..data/)" = "" ]; then
#     if [ ! -f "${secrets_dir}/postgresql-postgres-password" ] || [ ! -f "${secrets_dir}/{{ include "gitlab.psql.password.key" . | trimAll "\"" }}" ]; then
#       notify "You seem to be upgrading from a previous version of GitLab using the bundled PostgreSQL chart"
#       notify "There are some manual steps which need to be performed in order to upgrade the database"
#       notify "Please see the upgrade documentation for instructions on how to proceed:"
#       notify "https://docs.gitlab.com/charts/installation/upgrade.html"
#       exit 1
#     fi
#   fi
# fi
# MIN_VERSION=14.0
# CHART_MIN_VERSION=5.0

# # Only run check for semver releases
# if ! awk 'BEGIN{exit(!(ARGV[1] ~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/))}' "$GITLAB_VERSION"; then
#   exit 0
# fi

# NEW_MAJOR_VERSION=$(echo $GITLAB_VERSION | awk -F "." '{print $1}')
# NEW_MINOR_VERSION=$(echo $GITLAB_VERSION | awk -F "." '{print $1"."$2}')

# NEW_CHART_MAJOR_VERSION=$(echo $CHART_VERSION | awk -F "." '{print $1}')
# NEW_CHART_MINOR_VERSION=$(echo $CHART_VERSION | awk -F "." '{print $1"."$2}')

# if [ ! -f /chart-info/gitlabVersion ]; then
#   notify "It seems you are attempting an unsupported upgrade path."
#   notify "Please follow the upgrade documentation at https://docs.gitlab.com/ee/update/README.html#upgrade-paths"
#   exit 1
# fi

OLD_VERSION_STRING=$(cat /chart-info/gitlabVersion)
OLD_CHART_VERSION_STRING=$(cat /chart-info/gitlabChartVersion)

# # Skip check if old version wasn't semver
# if ! awk 'BEGIN{exit(!(ARGV[1] ~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/))}' "$OLD_VERSION_STRING"; then
#   exit 0
# fi

# OLD_MAJOR_VERSION=$(echo $OLD_VERSION_STRING | awk -F "." '{print $1}')
# OLD_MINOR_VERSION=$(echo $OLD_VERSION_STRING | awk -F "." '{print $1"."$2}')
# OLD_CHART_MAJOR_VERSION=$(echo $OLD_CHART_VERSION_STRING | awk -F "." '{print $1}')
# OLD_CHART_MINOR_VERSION=$(echo $OLD_CHART_VERSION_STRING | awk -F "." '{print $1"."$2}')


echo "old gitlab version " $OLD_VERSION_STRING
echo "old chart version " $OLD_CHART_VERSION_STRING
echo "new gitlab version: " $GITLAB_VERSION
echo "new chart version: " $CHART_VERSION
echo

if [[ ${OLD_VERSION_STRING} == "13.12.9" && ${GITLAB_VERSION} == "14.1.0" ]]; then
  echo  "Auto upgrade to 14.0.5 will be attempted"
  kubectl patch gitrepository gitlab -n bigbang --type=merge -p '{"spec":{"ref":{"branch":"102-gitlab-upgrade-to-14-1-0"}}}'

  # wait for helmrelease lastAppliedRevision to be 5.0.5
  while true; do
    version=$(kubectl get helmrelease gitlab -n bigbang -o jsonpath='{.status.lastAppliedRevision}')
    echo "lastAppliedRevision : ${version}"
    if [[ ${version} == "5.0.5-bb.0" ]]; then
      echo "auto upgrade to chart version 5.0.5-bb.0 completed"
      break
    fi

    echo "waiting for last lastAppliedRevision to be: 5.0.5-bb.0..."
    sleep 10

  done

  # then patch gitrepository ref to new 5.1.0
  echo  "Auto upgrade to 14.1.0 will be attempted"
  kubectl patch gitrepository gitlab -n bigbang --type=merge -p '{"spec":{"ref":{"branch":"gitlab-test-auto-upgrade"}}}'

else
  echo "No auto upgrade"
fi


# # Checking Version
# # (i) if it is a major version jump
# # (ii) if existing version is less than required minimum version
# if [ ${OLD_MAJOR_VERSION} -lt ${NEW_MAJOR_VERSION} ] || [ ${OLD_CHART_MAJOR_VERSION} -lt ${NEW_CHART_MAJOR_VERSION} ]; then
#   if ( ! greater_version $OLD_MINOR_VERSION $MIN_VERSION ) || ( ! greater_version $OLD_CHART_MINOR_VERSION $CHART_MIN_VERSION ); then
#     notify "It seems you are upgrading the GitLab Helm Chart from ${OLD_CHART_VERSION_STRING} (GitLab ${OLD_VERSION_STRING}) to ${CHART_VERSION} (GitLab ${GITLAB_VERSION})."
#     notify "It is required to upgrade to the latest ${CHART_MIN_VERSION}.x version first before proceeding."
#     notify "Please follow the upgrade documentation at https://docs.gitlab.com/charts/releases/5_0.html"
#     notify "and upgrade to GitLab Helm Chart version ${CHART_MIN_VERSION}.x before upgrading to ${CHART_VERSION}."
#     exit 1
#   fi
# fi
