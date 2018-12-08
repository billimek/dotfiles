# Makes git auto completion faster favouring for local completions
__git_files () {
    _wanted files expl 'local files' _files
}

gfork() {
  local branch=$1
  git checkout -b $branch origin/$branch
}

# gets the url for the given fork
__addremote_url() {
  # shellcheck disable=SC2039
  local fork remote current
  fork="$1"
  if ! git config --get remote.origin.url > /dev/null 2>&1; then
    echo "A remote called 'origin' doesn't exist. Aborting." >&2
    return 1
  fi
  remote="$(git config --get remote.origin.url)"
  current="$(echo "$remote" | sed -e 's/.*github.com\://' -e 's/\/.*//')"
  echo "$remote" | sed -e "s/$current/$fork/"
}

# adds a remote
# shellcheck disable=SC2039
add-remote() {
  # shellcheck disable=SC2039
  local fork="$1" name="$2" url
  test -z "$name" && name="$fork"
  url="$(__addremote_url "$fork")" || return 1
  git remote add "$name" "$url"
}

# adds an upstream remote
# shellcheck disable=SC2039
add-upstream() {
  add-remote "$1" "upstream"
}

git_update() {
	# Update repository.
	if (`git branch -r| grep -q origin`); then
		git pull origin master;
	fi
	if (`git branch -r| grep -q upstream`); then
		git fetch upstream;
		git merge upstream/master
	fi
}
