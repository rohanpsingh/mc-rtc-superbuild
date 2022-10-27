# Common options for all package

###########################
# -- General options -- #
###########################
option(BUILD_BENCHMARKS "Build benchmarks" OFF)
option(INSTALL_SYSTEM_DEPENDENCIES "Install system dependencies" ON)
option(WITH_LSSOL "Enable LSSOL support" OFF)
if(UNIX AND NOT APPLE)
  set(WITH_ROS_SUPPORT_DEFAULT ON)
else()
  set(WITH_ROS_SUPPORT_DEFAULT OFF)
endif()
option(WITH_ROS_SUPPORT "Enable ROS support" ${WITH_ROS_SUPPORT_DEFAULT})
option(INSTALL_DOCUMENTATION "Install documentation of the projects" OFF)
option(MC_RTC_SUPERBUILD_VERBOSE "Output more information at configuration time" OFF)
option(VERBOSE_TEST_OUTPUT "Output more information while running unit tests" OFF)

if(WIN32)
  option(MC_RTC_SUPERBUILD_SET_ENVIRONMENT "Allow mc-rtc-superbuild to manipulate the PATH variable" ON)
endif()

option(LINK_BUILD_AND_SRC "Create symbolic links to/from build and src folders" ON)
option(LINK_COMPILE_COMMANDS "Create a symbolic to compile_commands.json in the source folder" ON)

#########################
# -- Python bindings -- #
#########################
set(PYTHON_BINDING_DEFAULT ON)
set(PYTHON_BINDING_FORCE_PYTHON3_DEFAULT ON)
set(PYTHON_BINDING_FORCE_PYTHON2_DEFAULT OFF)

find_program(MC_RTC_SUPERBUILD_DEFAULT_PYTHON python3)
if(NOT MC_RTC_SUPERBUILD_DEFAULT_PYTHON)
  set(PYTHON_BINDING_FORCE_PYTHON3_DEFAULT OFF)
  find_program(MC_RTC_SUPERBUILD_DEFAULT_PYTHON python)
  if(NOT MC_RTC_SUPERBUILD_DEFAULT_PYTHON)
    find_program(MC_RTC_SUPERBUILD_DEFAULT_PYTHON python2)
    if(MC_RTC_SUPERBUILD_DEFAULT_PYTHON)
      set(PYTHON_BINDING_FORCE_PYTHON2_DEFAULT ON)
    else()
      set(PYTHON_BINDING_DEFAULT OFF)
    endif()
  endif()
endif()

if(MC_RTC_SUPERBUILD_DEFAULT_PYTHON)
  message("-- Use Python for install: ${MC_RTC_SUPERBUILD_DEFAULT_PYTHON}")
endif()

option(PYTHON_BINDING "Generate Python binding" ${PYTHON_BINDING_DEFAULT})
if(WIN32)
  set(PYTHON_BINDING_USER_INSTALL_DEFAULT ON)
else()
  set(PYTHON_BINDING_USER_INSTALL_DEFAULT OFF)
endif()
option(PYTHON_BINDING_USER_INSTALL "Install the Python binding in user space" ${PYTHON_BINDING_USER_INSTALL_DEFAULT})
option(PYTHON_BINDING_FORCE_PYTHON2 "Force usage of python2 instead of python" ${PYTHON_BINDING_FORCE_PYTHON2_DEFAULT})
option(PYTHON_BINDING_FORCE_PYTHON3 "Force usage of python3 instead of python" ${PYTHON_BINDING_FORCE_PYTHON3_DEFAULT})
set(PYTHON_BINDING_BUILD_PYTHON2_AND_PYTHON3_DEFAULT OFF)
option(PYTHON_BINDING_BUILD_PYTHON2_AND_PYTHON3 "Build Python 2 and Python 3 bindings" ${PYTHON_BINDING_BUILD_PYTHON2_AND_PYTHON3_DEFAULT})
if(${PYTHON_BINDING_FORCE_PYTHON2} AND ${PYTHON_BINDING_FORCE_PYTHON3})
  message(FATAL_ERROR "Cannot enforce Python 2 and Python 3 at the same time")
endif()

###########################
# -- Clone destination -- #
###########################
if(NOT DEFINED SOURCE_DESTINATION)
  set(SOURCE_DESTINATION "${PROJECT_BINARY_DIR}/src")
endif()
if(NOT DEFINED PREVIOUS_SOURCE_DESTINATION)
  set(PREVIOUS_SOURCE_DESTINATION "${SOURCE_DESTINATION}")
endif()
if(EXISTS "${SOURCE_DESTINATION}" AND NOT EXISTS "${SOURCE_DESTINATION}/.mc-rtc-superbuild" AND NOT "${SOURCE_DESTINATION}" STREQUAL "${PREVIOUS_SOURCE_DESTINATION}")
  message(FATAL_ERROR "Cannot use ${SOURCE_DESTINATION} as SOURCE_DESTINATION. SOURCE_DESTINATION must be an empty folder or an existing superbuild folder")
endif()
set(PREVIOUS_SOURCE_DESTINATION "${SOURCE_DESTINATION}" CACHE INTERNAL "")
if(NOT EXISTS "${SOURCE_DESTINATION}/.git")
  add_custom_command(
    OUTPUT "${PROJECT_BINARY_DIR}/init-superbuild"
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${SOURCE_DESTINATION}"
    COMMAND "${CMAKE_COMMAND}" -E touch "${SOURCE_DESTINATION}/.mc-rtc-superbuild"
    COMMAND git init
    COMMAND "${CMAKE_COMMAND}" -E touch "${PROJECT_BINARY_DIR}/init-superbuild"
    WORKING_DIRECTORY "${SOURCE_DESTINATION}")
  add_custom_target(init-superbuild DEPENDS "${PROJECT_BINARY_DIR}/init-superbuild")
else()
  add_custom_target(init-superbuild)
endif()

###########################
# -- Location of build -- #
###########################
if(NOT DEFINED BUILD_DESTINATION)
  set(BUILD_DESTINATION "${PROJECT_BINARY_DIR}/build")
endif()
