export USER_HTTP_PROXY=${USER_HTTP_PROXY:-'http://127.0.0.1:1080'}
export USER_SOCKS_PROXY=${USER_SOCKS_PROXY:-'socks5://127.0.0.1:1080'}

proxy() {
  local proxy_ip=${1:-127.0.0.1}
  local user_http_proxy=${USER_HTTP_PROXY/127.0.0.1/$proxy_ip}

  export http_proxy=$user_http_proxy
  export HTTP_PROXY=$user_http_proxy
  export https_proxy=$user_http_proxy
  export HTTPS_PROXY=$user_http_proxy
}

unproxy() {
  unset http_proxy
  unset HTTP_PROXY
  unset https_proxy
  unset HTTPS_PROXY
}

brew() {
  http_proxy=$USER_HTTP_PROXY \
    HTTP_PROXY=$USER_HTTP_PROXY \
    https_proxy=$USER_HTTP_PROXY \
    HTTPS_PROXY=$USER_HTTP_PROXY \
    all_proxy=$USER_HTTP_PROXY \
    ALL_PROXY=$USER_HTTP_PROXY \
    command brew "$@"
}

git_ssh_proxy() {
  if [ "$(uname)" = "Darwin" ]; then
    gsed -i "s/# ProxyCommand/ProxyCommand/" ~/.ssh/config
    gsed -i -E "s/ProxyCommand nc -v -x [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+/ProxyCommand nc -v -x ${USER_SOCKS_PROXY}/" ~/.ssh/config
  else
    sed -i "s/# ProxyCommand/ProxyCommand/" ~/.ssh/config
    sed -i -E "s/ProxyCommand nc -v -x [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+/ProxyCommand nc -v -x ${USER_SOCKS_PROXY}/" ~/.ssh/config
  fi
}

git_ssh_unproxy() {
  if [ "$(uname)" = "Darwin" ]; then
    gsed -i "s/ProxyCommand/# ProxyCommand/" ~/.ssh/config
  else
    sed -i "s/ProxyCommand/# ProxyCommand/" ~/.ssh/config
  fi
}
