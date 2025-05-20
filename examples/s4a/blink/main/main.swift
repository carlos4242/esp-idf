
// to mesh with IDF, we don't use the standard swift
// mechanism of putting your top level program in main.swift
// and the compiler turning that script like file into one
// function called main() that the c runtime calls

// instead, the IDF system implements main() and calls our
// app_main function on an appropriate core, already running
// within a suitable FreeRTOS task
@_cdecl("app_main")
func app_main() {
	// note: we're also doing all the heavy lifting in C
	// in the folder/component we call "s4alib"
	configure_led()

	while true {
		turn_led_on()
		wait(1_000)
		turn_led_off()
		wait(1_000)
	}
}
