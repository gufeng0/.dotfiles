# gfo xxx => git fetch origin xxx:xxx
gfo() {
  if [ -z "$1" ]; then
    echo "usage: gfo <branch>"
    return 1
  fi
  git fetch origin "$1:$1"
}
