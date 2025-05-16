cmake_minimum_required(VERSION 3.16)

# ESP-IDF approach...
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
# idf_build_set_property(MINIMAL_BUILD ON)
project(blink)


# Our standard CMake approach...
# project(s4a_blink LANGUAGES C)
# add_executable(blink.elf dummy.c)
# set_source_files_properties(dummy.c PROPERTIES HEADER_FILE_ONLY TRUE)
# # add_subdirectory(s4alib)
# add_subdirectory(main)


# storage for old ideas...
# This causes an early fail, for now we are overriding all of Cmake's approach to Swift anyway.
# project(s4a_blink LANGUAGES C Swift)
# note ESP-IDF does something like add_executable(${project_elf} "${project_elf_src}")
