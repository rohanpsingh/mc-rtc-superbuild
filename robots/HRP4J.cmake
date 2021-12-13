option(WITH_HRP4J "Build HRP4J support, requires access to mc-hrp4 group on gite.lirmm.fr" OFF)

if(NOT WITH_HRP4J)
  return()
endif()

AddCatkinProject(hrp4j_description
  GITE mc-hrp4/hrp4j_description
  GIT_TAG master
  WORKSPACE "${CATKIN_DATA_WORKSPACE}"
  GIT_USE_SSH
)

AddProject(mc_hrp4j
  GITE mc-hrp4/mc_hrp4j
  GIT_TAG master
  GIT_USE_SSH
  DEPENDS hrp4j_description mc_rtc
)
