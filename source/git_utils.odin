package game

import "core:strings"

GitCommitHash :: proc(str: string) -> string {
	strings, err := strings.split_after(str, "\n")
	defer delete(strings)
	if err != nil {
		return "SPLIT_ERR"
	}

	size := len(&strings)
	last := strings[size - 2]
	return last[41:48]
}
