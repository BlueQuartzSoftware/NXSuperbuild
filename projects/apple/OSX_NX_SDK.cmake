# This is the NX_SDK File. This file contains all the paths to the dependent libraries.
# This was generated for Version 6.3 Development of NX. This SDK has C++11 Support ENABLED
if(NOT DEFINED NX_FIRST_CONFIGURE)
  message(STATUS "*******************************************************")
  message(STATUS "* NX First Configuration Run                    *")
  message(STATUS "* NX_SDK Loading from ${CMAKE_CURRENT_LIST_DIR}  *")
  message(STATUS "*******************************************************")
  if("${CMAKE_HOST_SYSTEM_PROCESSOR}" STREQUAL "x86_64")
    set(CMAKE_CXX_FLAGS_INIT "-Wmost -Wno-four-char-constants -Wno-unknown-pragmas -Wno-inconsistent-missing-override -mfpmath=sse")
    set(CMAKE_OSX_ARCHITECTURES "x86_64")
  else()
    set(CMAKE_CXX_FLAGS_INIT "-Wmost -Wno-four-char-constants -Wno-unknown-pragmas -Wno-inconsistent-missing-override")
    set(CMAKE_OSX_ARCHITECTURES "arm64")
  endif()

  # Set our Deployment Target to match Qt
  set(CMAKE_OSX_DEPLOYMENT_TARGET "@OSX_DEPLOYMENT_TARGET@" CACHE STRING "" FORCE)
  set(CMAKE_OSX_SYSROOT "@OSX_SDK@" CACHE STRING "" FORCE)
endif()

#--------------------------------------------------------------------------------------------------
# These settings are specific to DREAM3D. DREAM3D needs these variables to
# configure properly.

set(BUILD_TYPE ${CMAKE_BUILD_TYPE})
if("${BUILD_TYPE}" STREQUAL "")
    set(BUILD_TYPE "Release" CACHE STRING "" FORCE)
endif()

message(STATUS "The Current Build type being used is ${BUILD_TYPE}")
