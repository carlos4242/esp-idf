cmake_minimum_required(VERSION 3.16)

# include($ENV{IDF_PATH}/tools/cmake/project.cmake)
# "Trim" the build. Include the minimal set of components, main, and anything it depends on.
# idf_build_set_property(MINIMAL_BUILD ON)

# This causes an early fail, for now we are overriding all of Cmake's approach to Swift anyway.
# project(s4a_blink LANGUAGES C Swift)
project(s4a_blink LANGUAGES C)

# ESP-IDF does add_executable(${project_elf} "${project_elf_src}")

add_executable(blink.elf dummy.c)
set_source_files_properties(dummy.c PROPERTIES HEADER_FILE_ONLY TRUE)

# add_custom_target(blink ALL
#     # DEPENDS ${EXE_FILE}
# )

# add_subdirectory(s4alib)
add_subdirectory(main)

# set(EXE_FILE "${CMAKE_BINARY_DIR}/blink.elf")



