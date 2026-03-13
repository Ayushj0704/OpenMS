# Validate that all expected TOPP binaries exist before creating KNIME payloads.
#
# Inputs (via -D):
# - TOPP_BIN_PATH: Directory containing TOPP tool binaries
# - TOOL_LIST:     Semicolon-separated list of tool target names
# - EXE_SUFFIX:    Executable suffix (usually empty on Unix)

if(NOT DEFINED TOPP_BIN_PATH)
  message(FATAL_ERROR "TOPP_BIN_PATH is not set")
endif()
if(NOT DEFINED TOOL_LIST)
  message(FATAL_ERROR "TOOL_LIST is not set")
endif()
if(NOT DEFINED EXE_SUFFIX)
  set(EXE_SUFFIX "")
endif()

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

