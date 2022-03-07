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
 -d | --daemon:
   バックグラウンドで起動
 -a | --api-env <ENV_PATH>:
   apiコンテナ用の環境変数ファイルを指定(default=./api/.env)
 -f | --front-env <ENV_PATH>:
   frontコンテナ用の環境変数ファイルを指定(default=./front/.env)
 --debug:
   デバッグモードで起動
EOS
exit 1
}

SCRIPT_DIR="$(cd $(dirname $0); pwd)"
PROJECT_ROOT="$(cd ${SCRIPT_DIR}/..; pwd)"
API_DIR="$(cd ${PROJECT_ROOT}/api; pwd)"
FRONT_DIR="$(cd ${PROJECT_ROOT}/front; pwd)"
CONTAINER_DIR="$(cd ${PROJECT_ROOT}/docker; pwd)"
DEBUG=

source "${SCRIPT_DIR}/lib/utils.sh"

OPTIONS=
API_ENV_PATH="${API_DIR}/.env"
FRONT_ENV_PATH="${FRONT_DIR}/.env"
args=()
while [ "$#" != 0 ]; do
  case $1 in
    -h | --help      ) usage;;
    -d | --daemon    ) shift;OPTIONS="$OPTIONS -d";;
    -a | --api-env   ) shift;API_ENV_PATH="$1";;
    -f | --front-env ) shift;FRONT_ENV_PATH="$1";;
    --debug          ) DEBUG="1";;
    -* | --*         ) error "$1 : 不正なオプションです" ;;
    *                ) args+=("$1");;
  esac
  shift
done

[ "${#args[@]}" != 0 ] && usage
[ -z "$API_ENV_PATH" ] && error "-a | --api-env でapiコンテナ用の環境変数ファイルを指定してください"
[ -r "$API_ENV_PATH" -a -f "$API_ENV_PATH" ] || error "apiコンテナ用の環境変数ファイルを読み込めません: $API_ENV_PATH"
[ -z "$FRONT_ENV_PATH" ] && error "-f | --front-env でapiコンテナ用の環境変数ファイルを指定してください"
[ -r "$FRONT_ENV_PATH" -a -f "$FRONT_ENV_PATH" ] || error "frontコンテナ用の環境変数ファイルを読み込めません: $FRONT_ENV_PATH"

api_env_tmp="$(mktemp)"
cat "$API_ENV_PATH" > "$api_env_tmp"
front_env_tmp="$(mktemp)"
cat "$FRONT_ENV_PATH" > "$front_env_tmp"

trap "docker-compose -f docker-compose.yml down; rm -f $api_env_tmp $front_env_tmp" EXIT
invoke export API_DIR="$API_DIR"
invoke export FRONT_DIR="$FRONT_DIR"
invoke export API_ENV_PATH="$api_env_tmp"
invoke export FRONT_ENV_PATH="$front_env_tmp"
invoke export APP_NAME=$(cat ${PROJECT_ROOT}/.app_name | tr '[A-Z]' '[a-z]')
cd "$CONTAINER_DIR"

cat $API_ENV_PATH
if [ -n "$DEBUG" ]; then
  invoke docker-compose -f docker-compose.yml down
  invoke docker-compose -f docker-compose.yml up $OPTIONS
else
  invoke docker-compose -f docker-compose-prd.yml down
  invoke docker-compose -f docker-compose-prd.yml up $OPTIONS
fi
