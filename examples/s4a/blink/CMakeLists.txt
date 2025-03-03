cmake_minimum_required(VERSION 3.16)

# include($ENV{IDF_PATH}/tools/cmake/project.cmake)
# "Trim" the build. Include the minimal set of components, main, and anything it depends on.
# idf_build_set_property(MINIMAL_BUILD ON)



        # -I "/Applications/S4A IDE unsandboxed.app/Contents/XPCServices/BuildEngine.xpc/Contents/Resources/uSwift-ARM/Embedded"


# Enable Swift support in CMake, force Whole Module builds (required by Embedded Swift), and use "CMAKE_Swift_COMPILER_WORKS" to
# skip the trial compilations which don't (yet) correctly work when cross-compiling.
set(CMAKE_Swift_COMPILER_WORKS YES)
set(CMAKE_Swift_COMPILATION_MODE_DEFAULT wholemodule)
set(CMAKE_Swift_COMPILATION_MODE wholemodule)
set(CMAKE_Swift_COMPILER "/Applications/S4A IDE unsandboxed.app/Contents/XPCServices/BuildEngine.xpc/Contents/MacOS/swift")
enable_language(Swift)

project(s4a_blink LANGUAGES C Swift)

add_executable(Blink main.swift)

target_compile_options(Blink PUBLIC "$<$<COMPILE_LANGUAGE:Swift>:SHELL:
        -target xtensa-none-none-eabi -nostdimport -enforce-exclusivity=unchecked -no-link-objc-runtime
        -Xfrontend -disable-reflection-metadata -Xfrontend -disable-stack-protector
        -Xfrontend -disable-implicit-concurrency-module-import -Xfrontend -disable-implicit-string-processing-module-import
        -Xfrontend -function-sections -enable-experimental-feature Embedded -wmo -parse-as-library -Osize
        -Xcc -fno-pic -Xcc -fno-pie
        -pch-output-dir /tmp
        -Xfrontend -enable-single-module-llvm-emission
        -I /Users/carl/Documents/Code/S4A/BuildEngine/uSwift-ARM 
        -import-bridging-header ${CMAKE_CURRENT_LIST_DIR}/main.h
    >")

# get_target_property(output Blink TYPE)
# message(STATUS "Blink target type: ${output}")

# add_subdirectory(main)
add_subdirectory(s4alib)

# get_property(targets DIRECTORY PROPERTY TARGETS)
# message(STATUS "Available targets: ${targets}")

# get_target_property(TARGET_TYPE Blink TYPE)
# message(STATUS "Blink target type: ${TARGET_TYPE}")
