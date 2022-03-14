#!/bin/bash
shopt -s expand_aliases
[ -f "$HOME/.bashrc" ] && source $HOME/.bashrc

function usage {
cat >&2 <<EOS
コンテナ起動コマンド

[usage]
 $0 [options]

[options]
 -h | --help:
   ヘルプを表示
 -t | --tag <TAG>:
   イメージのタグを指定(default=latest)
 -d | --daemon:
   バックグラウンドで起動
EOS
exit 1
}

SCRIPT_DIR="$(cd $(dirname $0); pwd)"
PROJECT_ROOT="$(cd ${SCRIPT_DIR}/..; pwd)"
CONTAINER_DIR="$(cd ${PROJECT_ROOT}/docker; pwd)"
API_DIR="$(cd ${PROJECT_ROOT}/api; pwd)"
BIN_DIR="$(cd ${PROJECT_ROOT}/bin; pwd)"

source "${SCRIPT_DIR}/lib/utils.sh"

OPTIONS=
DAEMON=
TAG=latest
args=()
while [ "$#" != 0 ]; do
  case $1 in
    -h | --help   ) usage;;
    -t | --tag    ) shift;TAG="$1";;
    -d | --daemon ) shift;DAEMON=1;OPTIONS="$OPTIONS -d";;
    -* | --*      ) error "$1 : 不正なオプションです" ;;
    *             ) args+=("$1");;
  esac
  shift
done

[ "${#args[@]}" != 0 ] && usage


set -e
export $(cat ${API_DIR}/test_env | grep -v -e "^ *#.*")
APP_NAME=$(cat ${PROJECT_ROOT}/.app_name | tr '[A-Z]' '[a-z]')
trap 'docker rm -f ${APP_NAME}-mysql ${APP_NAME}-mysql-check; echo "[$BASH_SOURCE:$LINENO] - "$BASH_COMMAND" returns not zero status"' ERR
cd "$CONTAINER_DIR"

invoke docker run $OPTIONS \
  --rm \
  --name ${APP_NAME}-mysql \
  --network host \
  -e MYSQL_ROOT_PASSWORD=$DB_PASSWORD \
  -e MYSQL_USER=$DB_USER \
  -e MYSQL_PASSWORD=$DB_PASSWORD \
  -e MYSQL_DATABASE=$DB_NAME \
  "${APP_NAME}/mysql:${TAG}"

if [ -n "$DAEMON" ]; then
  invoke docker run \
    --rm \
    --name ${APP_NAME}-mysql-check \
    --network host \
    -v "${API_DIR}:/opt/app" \
    -v "${BIN_DIR}:/opt/bin" \
    -e MYSQL_ROOT_PASSWORD=$DB_PASSWORD \
    -e MYSQL_USER=$DB_USER \
    -e MYSQL_PASSWORD=$DB_PASSWORD \
    -e MYSQL_DATABASE=$DB_NAME \
    "${APP_NAME}/tool:${TAG}" \
    /opt/bin/lib/check_mysql_boot.sh
fi