#!/bin/bash

minify() {
	exec 3<&0

	local c
	local buffer=""
	local in_quote=0
	local quote_char=""
	local escaped=0
	local prev_char=""
	local brace_depth=0

	while IFS= read -r -d '' -n1 -u 3 c; do
		if (( in_quote )); then
			buffer+="$c"

			if [[ $quote_char == '"' ]]; then
				if [[ $c == "\\" ]]; then
					((backslashes++))
				elif [[ $c == '"' ]]; then
					if (( backslashes % 2 == 0 )); then
						in_quote=0
						quote_char=""
					fi
					backslashes=0
				else
					backslashes=0
				fi
			elif [[ $quote_char == "'" && $c == "'" ]]; then
				in_quote=0
				quote_char=""
			fi

			continue
		fi

		case "$c" in
			'"'|"'")
				in_quote=1
				quote_char="$c"
				buffer+="$c"
				;;
			'#')
				if [[ brace_depth -eq 0 ]]; then
					while IFS= read -r -d '' -n1 -u 3 c && [[ $c != $'\n' ]]; do :; done
					buffer+=$'\n'
				else
					buffer+="$c"
				fi
				;;
			$'\n')
				[[ ! $buffer =~ ^[[:space:]]*$ ]] && echo "$buffer"
				buffer=""
				;;
			[[:space:]])
				if [[ ! $prev_char =~ [[:space:]] ]]; then
					buffer+="$c"
				fi
				;;
			"{")
				[[ prev_char == "\$" ]] && ((brace_depth++))
				buffer+="$c"
				;;
			"}")
				((brace_depth--))
				buffer+="$c"
				;;
			*)
				buffer+="$c"
				;;
		esac
		prev_char="$c"
	done

	if [[ -n "$buffer" && ! $buffer =~ ^[[:space:]]*$ ]]; then
		echo "$buffer"
	fi

	exec 3<&-
}


input="$1"
cd "$(dirname "$input")" || exit 1
input_file="$(basename "$input")"
tmpfile=$(mktemp)

while IFS= read -r line; do
	if [[ "$line" == source* ]]; then
		source_arg=${line#source }
		resolved=""
		if resolved=$(eval "echo $source_arg" 2>/dev/null) && [[ -f "$resolved" ]]; then
			cat "$resolved" >> "$tmpfile"
		else
			echo "$line" >> "$tmpfile"
		fi
	else
		echo "$line" >> "$tmpfile"
	fi
done < "$input_file"

echo "#!/bin/bash"
minify < "$tmpfile"

rm "$tmpfile"
