# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

# Setup Greenhills MULTI specific compilation information
# This will add the following to the cache:
# 	GHS_TOOLS_DIR -- calculated
# 	GHS_OS_DIR -- calculated
#	GHS_PRIMARY_TARGET -- defaulted to arm
# 	GHS_BSP_NAME -- defaulted to simarm
# 	GHS_CUSTOMIZATION -- optional customization to add to default.gpj
# 	GHS_GPJ_MACROS -- .gpj macros written to top of default.gpj

# First, is there an environment var set? If so take it
set (GHS_OS_DIR_ENV $ENV{GHS_OS_DIR})
if (GHS_OS_DIR_ENV)
  message(STATUS "Setting OS_DIR from env var GHS_OS_DIR")
  SET(GHS_OS_DIR $ENV{GHS_OS_DIR} CACHE PATH "INTEGRITY install directory")
endif ()

if (NOT GHS_OS_DIR)
  #Assume the C:/ghs/int#### directory that is latest is preferred
  if (win32)
    set(GHS_EXPECTED_ROOT "C:/ghs")
  else ()
    set(GHS_EXPECTED_ROOT "/usr/ghs")
  endif ()
  if (EXISTS ${GHS_EXPECTED_ROOT})
    FILE(GLOB GHS_CANDIDATE_INT_DIRS RELATIVE
      ${GHS_EXPECTED_ROOT} ${GHS_EXPECTED_ROOT}/*)
    string(REGEX MATCHALL  "int[0-9][0-9][0-9][0-9]" GHS_CANDIDATE_INT_DIRS
      ${GHS_CANDIDATE_INT_DIRS})
    if (GHS_CANDIDATE_INT_DIRS)
      list(SORT GHS_CANDIDATE_INT_DIRS)
      list(GET GHS_CANDIDATE_INT_DIRS -1 GHS_INT_DIRECTORY)
      string(CONCAT GHS_INT_DIRECTORY ${GHS_EXPECTED_ROOT} "/"
        ${GHS_INT_DIRECTORY})
    endif ()
  endif ()

  #Try to look for known registry values
  if (win32)
    if (NOT GHS_INT_DIRECTORY)
      find_path(GHS_INT_DIRECTORY INTEGRITY.ld PATHS
        "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\GreenHillsSoftware6433c345;InstallLocation]" #int1122
        "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\GreenHillsSoftware289b6625;InstallLocation]" #int1104
        )
    endif ()
  endif ()
  message(STATUS "Found OS_DIR ${GHS_INT_DIRECTORY}")
  set(GHS_OS_DIR ${GHS_INT_DIRECTORY} CACHE PATH "OS directory")
endif ()

# Find the tools

# First, is there an environment var set? If so take it
set(GHS_TOOLS_DIR_ENV $ENV{GHS_TOOLS_DIR})
if (GHS_TOOLS_DIR_ENV)
  message(STATUS "Setting GHS_TOOLS_DIR from env var GHS_TOOLS_DIR")
  SET(GHS_TOOLS_DIR $ENV{GHS_TOOLS_DIR} CACHE PATH "MULTI compiler install directory")
endif()

if (NOT GHS_TOOLS_DIR)
  # Nope, go hunting
  if (win32)
    set(GHS_EXPECTED_ROOT "C:/ghs")
  else ()
    set(GHS_EXPECTED_ROOT "/usr/ghs")
  endif ()
  if (EXISTS ${GHS_EXPECTED_ROOT})
    FILE(GLOB GHS_CANDIDATE_TOOLS_DIRS RELATIVE
      ${GHS_EXPECTED_ROOT} ${GHS_EXPECTED_ROOT}/*)
    string(REGEX MATCHALL  "comp_[0-9][0-9][0-9][0-9][0-9]+" GHS_CANDIDATE_REGEX_TOOLS_DIRS
      ${GHS_CANDIDATE_TOOLS_DIRS})
    if (GHS_CANDIDATE_REGEX_TOOLS_DIRS)
      list(SORT GHS_CANDIDATE_REGEX_TOOLS_DIRS)
      list(GET GHS_CANDIDATE_REGEX_TOOLS_DIRS -1 GHS_TOOLS_DIRECTORY)
      string(CONCAT GHS_TOOLS_DIRECTORY ${GHS_EXPECTED_ROOT} "/"
        ${GHS_TOOLS_DIRECTORY})
    endif ()
  endif ()

  #Try to look for known registry values
  if (win32)
    if (NOT GHS_TOOLS_DIRECTORY)
# Need to find keys for supported MULTI versions
#      find_path(GHS_TOOLS_DIRECTORY INTEGRITY.ld PATHS
#	"[HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\GreenHillsSoftware6433c345;InstallLocation]" #int1122
#	"[HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\GreenHillsSoftware289b6625;InstallLocation]" #int1104
#	)
    endif ()
  endif ()

  message(STATUS "Found tools at ${GHS_TOOLS_DIRECTORY}")
  set(GHS_TOOLS_DIR ${GHS_TOOLS_DIRECTORY} CACHE PATH
    "Path to GHS MULTI compiler directory")
endif ()

if (NOT GHS_TOOLS_DIR)
  message(ERROR " GHS_TOOLS_DIR could not be determined. Please set manually")
elseif (NOT GHS_OS_DIR)
  message(ERROR " GHS_OS_DIR could not be determined. Please set manually")
else ()
  set(CMAKE_C_COMPILER "${GHS_TOOLS_DIR}/ccint86")
  set(CMAKE_CXX_COMPILER "${GHS_TOOLS_DIR}/cxint86")
endif()


set(GHS_PRIMARY_TARGET "arm" CACHE STRING "target for compilation, one of arm, 86")
if (GHS_PRIMARY_TARGET EQUAL "86")
  set(GHS_BSP_NAME "pcx64" CACHE STRING "BSP name")
else ()
  set(GHS_BSP_NAME "sim${GHS_PRIMARY_TARGET}" CACHE STRING "BSP name")
endif()
set(GHS_CUSTOMIZATION "" CACHE FILEPATH "optional GHS customization")
mark_as_advanced(GHS_CUSTOMIZATION)
set(GHS_GPJ_MACROS "" CACHE STRING "optional GHS macros generated in the .gpjs for legacy reasons")
mark_as_advanced(GHS_GPJ_MACROS)
