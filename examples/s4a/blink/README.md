## Rundown

This is an early stage demo of at least the compile pathways we might use for ESP32.

There are a number of things that need to be addressed, primarily it doesn't compile yet!

There's work to do for incorporating the ESP-IDF in a functional and meaningful way. Currently the
swift code is more or less cut and dropped from equivalent AVR microcontroller ways of doing things,
at least from the earliest days 5-6 years ago when microswift code exclusively used our C function libraries
for hardware control/delay loops and various other utilites. (Modern S4A microswift uses pure Swift and is
a lot more sophisticated.)

To integrate this properly, we need to work out how to integrate this "hard coded" CMake approach
with more standard ESP-IDF building. At the moment all the ESP-IDF stuff is missing so the C code won't
compile.

I really want to remove all the hard-coded paths and especially the ones pointing to specific locations on my Mac!

Finally, the main.swift code needs to be turned into library code, -parse-as-library reintroduced
on the swift compile command and...

```swift
@_cdecl("app_main")
func app_main() {
	...
}
```

...wrapped around the main code so that it runs on ESP32 core 1 and cooperates with the FreeRTOS scheduler as normal for ESP.


### Getting started

Use cmake -B build -S . -G Ninja

