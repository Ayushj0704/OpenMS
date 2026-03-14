# Validate that all expected TOPP binaries exist before creating KNIME payloads.
#
# Inputs (via -D):
# - TOPP_BIN_PATH: Directory containing TOPP tool binaries
# - TOOL_LIST:     Semicolon-separated list of tool target names
# - TOOL_LIST_FILE: Path to a file containing tool names (one per line)
# - EXE_SUFFIX:    Executable suffix (usually empty on Unix)

if(NOT DEFINED TOPP_BIN_PATH)
  message(FATAL_ERROR "TOPP_BIN_PATH is not set")
endif()
if(NOT DEFINED TOOL_LIST)
  if(DEFINED TOOL_LIST_FILE)
    if(NOT EXISTS "${TOOL_LIST_FILE}")
      message(FATAL_ERROR "TOOL_LIST_FILE does not exist: '${TOOL_LIST_FILE}'")
    endif()
    file(READ "${TOOL_LIST_FILE}" TOOL_LIST)
  else()
    message(FATAL_ERROR "TOOL_LIST is not set")
  endif()
endif()
if(NOT DEFINED EXE_SUFFIX)
  set(EXE_SUFFIX "")
endif()

# `TOOL_LIST` should be a CMake list (semicolon-separated). Depending on how it
# is passed (CLI, file, build tool), it may arrive as whitespace/newline- or
# delimiter-separated string. Normalize to a proper list.
string(REPLACE "," ";" TOOL_LIST "${TOOL_LIST}")
string(REGEX REPLACE "[ \t\r\n]+" ";" TOOL_LIST "${TOOL_LIST}")

set(missing_tools "")
foreach(tool IN LISTS TOOL_LIST)
  set(tool_path "${TOPP_BIN_PATH}/${tool}${EXE_SUFFIX}")
  if(NOT EXISTS "${tool_path}")
    list(APPEND missing_tools "${tool_path}")
  endif()
endforeach()

list(LENGTH missing_tools missing_count)
if(missing_count GREATER 0)
  string(REPLACE ";" "\n  " missing_lines "${missing_tools}")
  message(FATAL_ERROR
    "KNIME packaging preflight failed: missing TOPP binaries:\n"
    "  ${missing_lines}\n"
    "This usually indicates that TOPP tools were not built before the KNIME payload copy step.")
endif()

message(STATUS "KNIME preflight: all TOPP binaries present in '${TOPP_BIN_PATH}'.")
