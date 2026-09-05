#!/usr/bin/env bash

set -Eeuo pipefail

[[ -d patches/feeds ]] || exit 0

while IFS= read -r -d '' patch_file; do
	feed_path="${patch_file#patches/feeds/}"
	feed_name="${feed_path%%/*}"
	feed_dir="feeds/$feed_name"
	patch_path="$PWD/$patch_file"

	if [[ ! -d "$feed_dir" ]]; then
		echo "feed directory not found for patch: $patch_file" >&2
		exit 1
	fi

	if git -C "$feed_dir" apply --check "$patch_path" 2>/dev/null; then
		echo "Applying feed patch: $patch_file"
		git -C "$feed_dir" apply "$patch_path"
	elif git -C "$feed_dir" apply --reverse --check "$patch_path" 2>/dev/null; then
		echo "Feed patch already applied: $patch_file"
	else
		echo "Feed patch does not apply cleanly: $patch_file" >&2
		exit 1
	fi
done < <(find patches/feeds -type f -name '*.patch' -print0 | sort -z)
