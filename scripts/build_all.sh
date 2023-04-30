#!/bin/bash

# Maintainer: blek <me@blek.codes>

abspath() {
	OLDPWD="$(pwd)"
	cd "$(dirname "$1")"
	printf "%s/%s\n" "$(pwd)" "$(basename "$1")"
	cd "$OLDPWD"
}

msg() {
	echo -e "\033[1;36m ===> \033[0m$*\033[0m"
}

section() {
	echo -e "\033[1;91m => \033[2;36m$*\033[0m"
}
errcho() {
	echo $* >&2
}

REPOS=('core' 'extra')
REPO_PATHS=()

for repo in "${REPOS[@]}"; do
	REPO_PATHS+=("$(abspath "../packages/${repo}")")
done

PKGBUILDS=()

if [[ `git status --porcelain` ]]; then
	errcho "Warning: You have changes in the git repository."
	errcho -n "Are you sure that you want to build all packages? (Y/n): "
	read confirm
	if [[ $confirm == [nN] || $confirm == [nN][oO] ]]; then
		exit 0
	fi
fi
echo a
exit 1

for path in "${REPO_PATHS[@]}"; do
	PKGBUILDS+=($(find "$path" -type f -name PKGBUILD))
done

OLDPWD=$(pwd)

for repo in "${REPO_PATHS[@]}"; do
	for path in $(find "$repo" -name x86_64); do
		section "Building $path"
	
		cd "$path"

		# keys to be imported
		if [ -d "$path/keys/pgp" ]; then
			msg "Found gpg keys, importing..."
			for file in $(find "$path/keys/pgp/"); do
				msg "Importing key \033[0m\033[36m$(echo "$file" | grep -Po '[A-F0-9]+(?=\.asc$)')"
				gpg --import "$file"
			done
		fi
		makepkg
	done
done
