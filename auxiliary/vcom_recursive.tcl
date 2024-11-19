proc vcom_recursive {files} {
	set break_code 0
	while {$break_code == 0} {
		set err_cnt 0
		foreach file $files {
			set err_cnt [expr {[catch {vcom -2002 $file}] + 1}]
		}
		set break_code $err_cnt
	}
}
