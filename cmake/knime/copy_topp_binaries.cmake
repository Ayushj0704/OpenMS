# Copy TOPP binaries into KNIME payload folders.
#
# Inputs (via -D):
# - TOPP_BIN_PATH: Directory containing TOPP binaries
# - PAYLOAD_BIN_PATH: Destination for OpenMS core tools
# - TP_PAYLOAD_BIN_PATH: Destination for third-party adapter tools
# - TOOL_LIST_FILE: Path to newline-separated tool names to copy
# - THIRDPARTY_LIST_FILE: Path to newline-separated third-party adapter names
# - EXE_SUFFIX: Executable suffix (e.g. ".exe" on Windows, empty on Unix)

if(POLICY CMP0007)
  # Avoid dev warnings with empty list elements (e.g., from trailing newlines).
  cmake_policy(SET CMP0007 NEW)
endif()

if(NOT DEFINED TOPP_BIN_PATH)
  message(FATAL_ERROR "TOPP_BIN_PATH is not set")
endif()
if(NOT DEFINED PAYLOAD_BIN_PATH)
  message(FATAL_ERROR "PAYLOAD_BIN_PATH is not set")
endif()
if(NOT DEFINED TP_PAYLOAD_BIN_PATH)
  message(FATAL_ERROR "TP_PAYLOAD_BIN_PATH is not set")
endif()
if(NOT DEFINED TOOL_LIST_FILE)
  message(FATAL_ERROR "TOOL_LIST_FILE is not set")
endif()
if(NOT DEFINED THIRDPARTY_LIST_FILE)
  message(FATAL_ERROR "THIRDPARTY_LIST_FILE is not set")
endif()
if(NOT EXISTS "${TOOL_LIST_FILE}")
  message(FATAL_ERROR "TOOL_LIST_FILE does not exist: '${TOOL_LIST_FILE}'")
endif()
if(NOT EXISTS "${THIRDPARTY_LIST_FILE}")
  message(FATAL_ERROR "THIRDPARTY_LIST_FILE does not exist: '${THIRDPARTY_LIST_FILE}'")
endif()
if(NOT DEFINED EXE_SUFFIX)
  set(EXE_SUFFIX "")
endif()

file(READ "${TOOL_LIST_FILE}" TOOL_LIST)
file(READ "${THIRDPARTY_LIST_FILE}" THIRDPARTY_LIST)

# Normalize incoming strings to CMake lists.
string(REPLACE "," ";" TOOL_LIST "${TOOL_LIST}")
string(REGEX REPLACE "[ \t\r\n]+" ";" TOOL_LIST "${TOOL_LIST}")
string(REPLACE "," ";" THIRDPARTY_LIST "${THIRDPARTY_LIST}")
string(REGEX REPLACE "[ \t\r\n]+" ";" THIRDPARTY_LIST "${THIRDPARTY_LIST}")

# Drop empty elements (typically caused by a trailing newline in the list files).
string(REGEX REPLACE ";+" ";" TOOL_LIST "${TOOL_LIST}")
string(REGEX REPLACE "^;" "" TOOL_LIST "${TOOL_LIST}")
string(REGEX REPLACE ";$" "" TOOL_LIST "${TOOL_LIST}")
string(REGEX REPLACE ";+" ";" THIRDPARTY_LIST "${THIRDPARTY_LIST}")
string(REGEX REPLACE "^;" "" THIRDPARTY_LIST "${THIRDPARTY_LIST}")
string(REGEX REPLACE ";$" "" THIRDPARTY_LIST "${THIRDPARTY_LIST}")

set(copied_core 0)
set(copied_thirdparty 0)

foreach(tool IN LISTS TOOL_LIST)
  if(tool STREQUAL "")
    continue()
  endif()

  set(source_binary "${TOPP_BIN_PATH}/${tool}${EXE_SUFFIX}")
  if(NOT EXISTS "${source_binary}")
    message(FATAL_ERROR "Missing TOPP binary during KNIME payload copy: '${source_binary}'")
  endif()

  list(FIND THIRDPARTY_LIST "${tool}" tool_is_thirdparty)
  if(tool_is_thirdparty GREATER -1)
    set(destination_dir "${TP_PAYLOAD_BIN_PATH}")
  else()
    set(destination_dir "${PAYLOAD_BIN_PATH}")
  endif()

  execute_process(
    COMMAND "${CMAKE_COMMAND}" -E copy "${source_binary}" "${destination_dir}/"
    RESULT_VARIABLE copy_result
    OUTPUT_VARIABLE copy_stdout
    ERROR_VARIABLE copy_stderr
  )

  if(NOT copy_result EQUAL 0)
    message(FATAL_ERROR
      "Failed to copy TOPP binary '${source_binary}' to '${destination_dir}'\n"
      "copy_result='${copy_result}'\n"
      "stdout='${copy_stdout}'\n"
      "stderr='${copy_stderr}'")
  endif()

  if(tool_is_thirdparty GREATER -1)
    math(EXPR copied_thirdparty "${copied_thirdparty} + 1")
  else()
    math(EXPR copied_core "${copied_core} + 1")
  endif()
endforeach()

message(STATUS
  "KNIME payload copy completed: core='${copied_core}', thirdparty='${copied_thirdparty}'")
