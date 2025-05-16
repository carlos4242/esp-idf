cmake_minimum_required(VERSION 3.16)

# Enable Swift support in CMake, force Whole Module builds (required by Embedded Swift), and use "CMAKE_Swift_COMPILER_WORKS" to
# skip the trial compilations which don't (yet) correctly work when cross-compiling.
set(CMAKE_Swift_COMPILER_WORKS YES)
set(CMAKE_Swift_COMPILATION_MODE_DEFAULT wholemodule)
set(CMAKE_Swift_COMPILATION_MODE wholemodule)

# enable_language(Swift)

# This approach won't work while we have custom commands in a chain.
# target_compile_options(Blink PUBLIC ...)

# Set the compiler options in a variable
# Use our ARM microswift standard library as a general 32-bit version, here for Xtensa.
# Similarly, we are using an arm target triple just for generating bitcode, just because the current off-the-shelf
# version of our microswift compiler doesn't have xtensa as a target triple. It shouldn't matter in this part of
# the pipeline (generally the only difference in the bitcode is pointer width), and we can correct it properly later.
# The actual code generation is done by our custom built Xtensa llvm in a later step.

# Note: there must be a better way to get the standard include directories but I'm not familiar
# enough with cmake and the IDF/ESP ways.

# If you have the normal basic product, downloaded from the App Store.
# set(S4A_APP "/Applications/S4A IDE.app")

# If you have the Pro version (non sandboxed) downloaded from the website.
set(S4A_APP "/Applications/S4A IDE Pro.app")

set(S4A_BUILD_ENGINE ${S4A_APP}/Contents/XPCServices/BuildEngine.xpc/Contents)
set(S4A_ARM_STDLIB ${S4A_BUILD_ENGINE}/Resources/uSwift-ARM/Embedded)
set(S4A_SHIMS ${S4A_BUILD_ENGINE}/Resources/uSwiftShims)
# There should be a constant from the ESP-IDF we can use here, probably.
set(ESP_XTENSA_ELF /Users/carl/.espressif/tools/xtensa-esp-elf/esp-14.2.0_20241119/xtensa-esp-elf)

# At the moment this points to my hand-built llc but in the ultima,
# will be something like /Applications/S4A IDE Pro.app ... MacOS/llc-xtensa
set(LLC_PATH "/Users/carl/Documents/Code/llvm-project/llvm/build/bin/llc")

set(CMAKE_Swift_COMPILER ${S4A_BUILD_ENGINE}/MacOS/swiftc)


set(SWIFT_COMPILE_OPTIONS
    -target arm-none-linux-gnueabihf
    -nostdimport
    -enforce-exclusivity=unchecked
    -no-link-objc-runtime
    -Xfrontend -disable-reflection-metadata
    -Xfrontend -disable-stack-protector
    -Xfrontend -disable-implicit-concurrency-module-import
    -Xfrontend -disable-implicit-string-processing-module-import
    -Xfrontend -function-sections
    -enable-experimental-feature Embedded
    -wmo
    -Osize
    -Xcc -fno-pic
    -Xcc -fno-pie
    -pch-output-dir /tmp
    -Xfrontend -enable-single-module-llvm-emission
    -I ${S4A_ARM_STDLIB}
    -I ${S4A_SHIMS}
    -I ${ESP_XTENSA_ELF}/lib/gcc/xtensa-esp-elf/14.2.0/include
    -I ${ESP_XTENSA_ELF}/xtensa-esp-elf/include
    -I ${ESP_XTENSA_ELF}/xtensa-esp-elf/include/sys
    -I ${ESP_XTENSA_ELF}/picolibc/include/sys
    -import-bridging-header ${CMAKE_CURRENT_LIST_DIR}/main.h
)

find_program(SWIFTC swiftc 
        PATHS ${S4A_BUILD_ENGINE}/MacOS
        NO_DEFAULT_PATH  # Ignore system default paths
        REQUIRED)

# find_program(SWIFTC swiftc 
#         PATHS "/Applications/S4A IDE Pro.app/Contents/XPCServices/BuildEngine.xpc/Contents/MacOS"
#         NO_DEFAULT_PATH  # Ignore system default paths
#         REQUIRED)


set(BC_DIR "${CMAKE_BINARY_DIR}/bitcode")
set(OBJ_DIR "${CMAKE_BINARY_DIR}/objects")
set(EXE_FILE "${CMAKE_BINARY_DIR}/blink.elf")

# Ensure output directories exist
file(MAKE_DIRECTORY ${BC_DIR})
file(MAKE_DIRECTORY ${OBJ_DIR})

# List of Swift source files
set(SWIFT_SOURCES main.swift)

set(BC_FILES "")
set(OBJ_FILES "")

# add_executable(blink.elf main.swift)

# Step 1 & 2: Compile Swift to LLVM bitcode and object files
foreach(SRC_FILE ${SWIFT_SOURCES})
    # Extract filename without extension
    get_filename_component(FNAME ${SRC_FILE} NAME_WE)

    # Define bitcode and object file paths
    set(BC_FILE "${BC_DIR}/${FNAME}.bc")
    set(OBJ_FILE "${OBJ_DIR}/${FNAME}.o")

    # Compile Swift to LLVM bitcode
    add_custom_command(
        OUTPUT ${BC_FILE}
        COMMAND ${SWIFTC} ${SWIFT_COMPILE_OPTIONS} -emit-bc ${CMAKE_CURRENT_SOURCE_DIR}/${SRC_FILE} -o ${BC_FILE}
        DEPENDS ${SRC_FILE}
        COMMENT "Generating LLVM bitcode for ${SRC_FILE}"
    )

    # Convert LLVM bitcode to object file
    add_custom_command(
        OUTPUT ${OBJ_FILE}
        COMMAND ${LLC_PATH} -mtriple=xtensa -mcpu=esp32s2 ${BC_FILE} -filetype=obj -o ${OBJ_FILE}
        DEPENDS ${BC_FILE}
        COMMENT "Converting ${BC_FILE} to object file"
    )

    # Collect output files
    list(APPEND BC_FILES ${BC_FILE})
    list(APPEND OBJ_FILES ${OBJ_FILE})
endforeach()

add_library(custom_objects OBJECT ${OBJ_FILES})
set_target_properties(custom_objects PROPERTIES LINKER_LANGUAGE C)

# Step 3: Link object files to create the executable
# add_custom_command(
#     # TARGET blink.elf
#     POST_BUILD
#     OUTPUT ${EXE_FILE}
#     COMMAND ${CMAKE_LINKER} ${OBJ_FILES} -o ${EXE_FILE}
#     DEPENDS ${OBJ_FILES}
#     COMMENT "Linking object files to create ${EXE_FILE}"
# )

# Temporary hack, because I can't get add_executable() to work yet
# add_custom_target(blink_main_subdir.elf DEPENDS ${OBJ_FILES})
target_link_libraries(blink.elf custom_objects)

# add_custom_target(blink.elf ALL
#     DEPENDS ${EXE_FILE}
# )

# idf_component_register(
#     SRCS "main.swift"
#     # INCLUDE_DIRS "include"
# )

# target_sources(Blink PRIVATE main.swift)
