find_program(LSB_RELEASE lsb_release)

if(NOT LSB_RELEASE)
  message(FATAL_ERROR "lsb_release must be installed before running this script")
endif()

execute_process(COMMAND lsb_release -sc OUTPUT_VARIABLE DISTRO OUTPUT_STRIP_TRAILING_WHITESPACE)

if(EXISTS ${PROJECT_SOURCE_DIR}/cmake/linux/${DISTRO}.cmake)
  include(${PROJECT_SOURCE_DIR}/cmake/linux/${DISTRO}.cmake)
else()
  message(WARNING "Unknown distribution ${DISTRO}. This script will continue assuming you have all system dependencies available already")
  message(AUTHOR_WARNING "You can add a file: ${PROJECT_SOURCE_DIR}/cmake/linux/${DISTRO}.cmake to inform this script about the distribution.")
endif()

if(WITH_ROS_SUPPORT AND NOT ROS_DISTRO AND NOT DEFINED ENV{ROS_DISTRO})
  message(FATAL_ERROR "Unknown ROS_DISTRO for ${DISTRO} and ROS environment has not been sourced.")
endif()

find_program(DPKG dpkg)
if(DPKG)
  include(${PROJECT_SOURCE_DIR}/cmake/apt.cmake)
  if(APT_DEPENDENCIES)
    list(APPEND APT_DEPENDENCIES curl git)
    install_apt_dependencies(${APT_DEPENDENCIES})
  endif()
endif()

if(WITH_ROS_SUPPORT AND ROS_DISTRO)
  if(DPKG)
    set(ROS_APT_DEPENDENCIES "ros-${ROS_DISTRO}-ros-base" "ros-${ROS_DISTRO}-rosdoc-lite" "ros-${ROS_DISTRO}-common-msgs" "ros-${ROS_DISTRO}-tf2-ros" "ros-${ROS_DISTRO}-xacro" "ros-${ROS_DISTRO}-rviz")
    if(NOT EXISTS /etc/apt/sources.list.d/ros-latest.list)
      message(STATUS "Adding ROS APT mirror for your system")
      execute_process(COMMAND sudo ${CMAKE_COMMAND} -E make_directory /etc/apt/sources.list.d RESULT_VARIABLE BASH_FAILED)
      if(BASH_FAILED)
        message(FATAL_ERROR "Failed to create /etc/apt/sources.list.d")
      endif()
      execute_process(COMMAND sudo bash -c "echo \"deb http://packages.ros.org/ros/ubuntu ${DISTRO} main\" > /etc/apt/sources.list.d/ros-latest.list" RESULT_VARIABLE BASH_FAILED)
      if(BASH_FAILED)
        message(FATAL_ERROR "Failed to add ros-latest.list")
      endif()
      execute_process(COMMAND bash -c "curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -" RESULT_VARIABLE BASH_FAILED OUTPUT_QUIET ERROR_QUIET)
      if(BASH_FAILED)
        message(FATAL_ERROR "Failed to add ROS signing key")
      endif()
    endif()
    install_apt_dependencies(${ROS_APT_DEPENDENCIES})
    if(NOT DEFINED ENV{ROS_DISTRO})
      set(ENV{PATH} "/opt/ros/${ROS_DISTRO}/bin:$ENV{PATH}")
      set(ENV{ROS_DISTRO} ${ROS_DISTRO})
      set(ENV{ROS_ETC_DIR} /opt/ros/${ROS_DISTRO}/etc/ros)
      set(ENV{ROS_ROOT} /opt/ros/${ROS_DISTRO}/share/ros)
      if(EXISTS /opt/ros/${ROS_DISTRO}/lib/python3)
        set(ENV{ROS_PYTHON_VERSION} 3)
      endif()
      AppendROSWorkspace(/opt/ros/${ROS_DISTRO} /opt/ros/${ROS_DISTRO}/share/)
    endif()
  else()
    if(NOT DEFINED ENV{ROS_DISTRO})
      message(FATAL_ERROR "This script only knows how to install ROS on Debian derivatives, source your ROS setup before running CMake again.")
    endif()
  endif()
endif()

if(COMMAND mc_rtc_extra_steps)
  mc_rtc_extra_steps()
endif()
