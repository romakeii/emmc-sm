proc find_files {basedir pattern} {

	set basedir [string trimright [file join [file normalize $basedir] { }]]
	set file_list {}

	foreach file_name [glob -nocomplain -type {f r} -path $basedir $pattern] {
		lappend file_list $file_name
	}

	foreach dir_name [glob -nocomplain -type {d  r} -path $basedir *] {
		set subdir_list [find_files $dir_name $pattern]
		if { [llength $subdir_list] > 0 } {
			foreach subdir_file $subdir_list {
				lappend file_list $subdir_file
			}
		}
	}
	return $file_list
}
