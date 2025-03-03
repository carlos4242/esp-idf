# idf_component_register(SRCS "blink_example_main.c"
#                        INCLUDE_DIRS ".")

# idf_component_register(
#     SRCS "blink_example_main.c"
#     # INCLUDE_DIRS "include"
# )

target_sources(Blink PRIVATE blink_example_main.c)
