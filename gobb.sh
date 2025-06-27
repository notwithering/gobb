#!/bin/bash

input="$1"
cd "$(dirname "$input")" || exit 1
input_file="$(basename "$input")"

while IFS= read -r line; do
	if [[ "$line" == source* ]]; then
		source_arg=${line#source }
		resolved=""
		if resolved=$(eval "echo $source_arg" 2>/dev/null) && [[ -f "$resolved" ]]; then
			cat "$resolved" | grep -v '^#!'
		else
			echo "$line"
		fi
	else
		echo "$line"
	fi
done < "$input_file"
