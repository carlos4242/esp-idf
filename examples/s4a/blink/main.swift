import Swift

configure_led()

while true {
	turn_led_on()
	wait(1_000)
	turn_led_off()
	wait(1_000)
}
