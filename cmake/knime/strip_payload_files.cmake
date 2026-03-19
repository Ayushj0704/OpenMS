# Strip binaries/libraries in a directory without relying on external tools like `find`.
#
# Inputs (via -D):
# - STRIP_TOOL: strip executable (prefer absolute path)
# - STRIP_ARGS: arguments passed to strip (optional, e.g. "-S" or "-x")
# - TARGET_DIR: directory to process
# - RECURSE: "ON" to recurse, otherwise only direct children
# - GLOB_PATTERN: optional glob pattern (use sparingly; avoid '*' on the command line)
# - GLOB_PREFIX: optional prefix to match (used with GLOB_SUFFIX if GLOB_PATTERN unset)
# - GLOB_SUFFIX: optional suffix to match (used with GLOB_PREFIX if GLOB_PATTERN unset)

cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

if(NOT DEFINED STRIP_TOOL OR STRIP_TOOL STREQUAL "")
  message(FATAL_ERROR "STRIP_TOOL is not set")
endif()
if(NOT DEFINED TARGET_DIR OR TARGET_DIR STREQUAL "")
  message(FATAL_ERROR "TARGET_DIR is not set")
endif()
if(NOT EXISTS "${TARGET_DIR}")
  message(STATUS "strip_payload_files.cmake: TARGET_DIR does not exist, skipping: '${TARGET_DIR}'")
  return()
endif()

if(NOT DEFINED STRIP_ARGS)
  set(STRIP_ARGS "")
endif()
if(NOT DEFINED RECURSE)
  set(RECURSE "OFF")
endif()
if(NOT DEFINED GLOB_PATTERN OR GLOB_PATTERN STREQUAL "")
  if(NOT DEFINED GLOB_PREFIX)
    set(GLOB_PREFIX "")
  endif()
  if(NOT DEFINED GLOB_SUFFIX)
    set(GLOB_SUFFIX "")
  endif()
  set(GLOB_PATTERN "${GLOB_PREFIX}*${GLOB_SUFFIX}")
endif()

set(candidates "")
if(RECURSE)
  file(GLOB_RECURSE candidates "${TARGET_DIR}/${GLOB_PATTERN}")
else()
  file(GLOB candidates "${TARGET_DIR}/${GLOB_PATTERN}")
endif()

set(stripped 0)
foreach(path IN LISTS candidates)
  if(IS_DIRECTORY "${path}")
    continue()
  endif()
  if(IS_SYMLINK "${path}")
    continue()
  endif()

  execute_process(
    COMMAND "${STRIP_TOOL}" ${STRIP_ARGS} "${path}"
    RESULT_VARIABLE strip_result
    OUTPUT_VARIABLE strip_stdout
    ERROR_VARIABLE strip_stderr
  )
  if(NOT strip_result EQUAL 0)
    message(FATAL_ERROR
      "Failed to strip '${path}' using '${STRIP_TOOL} ${STRIP_ARGS}'\n"
      "strip_result='${strip_result}'\n"
      "stdout='${strip_stdout}'\n"
      "stderr='${strip_stderr}'")
  endif()

  math(EXPR stripped "${stripped} + 1")
endforeach()

message(STATUS "Stripped '${stripped}' file(s) under '${TARGET_DIR}' (pattern='${GLOB_PATTERN}', recurse='${RECURSE}').")
