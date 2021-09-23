
if(${CMAKE_MAJOR_VERSION} STREQUAL "3")
  # CMake 3.0 introduces VERSION variables for each Project.
  cmake_policy(SET CMP0048 NEW)
  # CMake 3.1 introduces if() policies on dereferencing variables in quotes
  cmake_policy(SET CMP0054 NEW)
endif()

cmake_minimum_required(VERSION 3.16.0)

project(DREAM3DSuperBuild VERSION 2.0.0.0 LANGUAGES C CXX)

# This allows us to just use the "include()" command and the name of the project
set(CMAKE_MODULE_PATH 
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake" 
        "${CMAKE_CURRENT_SOURCE_DIR}/projects" 
        ${CMAKE_MODULE_PATH})

set(BUILD_TYPE ${CMAKE_BUILD_TYPE})
if("${BUILD_TYPE}" STREQUAL "")
    set(BUILD_TYPE "Release" CACHE STRING "" FORCE)
endif()


# Set up some standard defaults, these will be passed down into external the
# projects.
include(BuildType)
include(BuildLocation)
include(ExternalProject)
include(download_dir)

# Use multiple CPU cores to build
include(ProcessorCount)
ProcessorCount(CoreCount)


if( "${DREAM3D_SDK}" STREQUAL "")
  message(FATAL_ERROR "Please specify the DREAM3D_SDK cmake variable which is the top level directory where all the DREAM.3D dependent libraries will be built")
endif()

if( "${DREAM3D_WORKSPACE}" STREQUAL "${DREAM3D_SDK}")
  message(STATUS "DREAM3D_SDK=${DREAM3D_SDK}")
  message(STATUS "DREAM3D_WORKSPACE=${DREAM3D_WORKSPACE}")
  message(FATAL_ERROR "Please specify a directory where the source codes for DREAM3D will be cloned into. That directory can not be the same as the DREAM3D_SDK directory")
endif()

set(DREAM3D_SDK_FILE ${DREAM3D_SDK}/NX.cmake)
set(download_dir ${DREAM3D_SDK})


message(STATUS "DREAM3D_SDK Folder: ${DREAM3D_SDK}")
message(STATUS "NX_SDK_FILE:   ${DREAM3D_SDK_FILE}")

#------------------------------------------------------------------------------
# Set the custom download location for all of the sources
# -----------------------------------------------------------------------------
option(DREAM3D_USE_CUSTOM_DOWNLOAD_SITE "Download Sources from a custom location" OFF)
set(DREAM3D_CUSTOM_DOWNLOAD_URL_PREFIX "http://dream3d.bluequartz.net/binaries/SDK/" CACHE STRING "Custom HTTP(s) URL")

set(BUILD_SHARED_LIBS ON)

if(APPLE)
  set(OSX_DEPLOYMENT_TARGET "10.15")
  set(OSX_SDK "NOT-FOUND")
  EXEC_PROGRAM(uname ARGS -v  OUTPUT_VARIABLE DARWIN_VERSION)
  STRING(REGEX MATCH "[0-9]+" DARWIN_VERSION ${DARWIN_VERSION})
  IF (DARWIN_VERSION LESS 19) 
    set(MACOS_NAME "Yosemite")
    set(OSX_DEPLOYMENT_TARGET "10.10")
    set(OSX_SDK "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk")
    message(STATUS "Found macOS ${OSX_DEPLOYMENT_TARGET} ${MACOS_NAME} as the host. Darwin Version:${DARWIN_VERSION}")
    message(FATAL_ERROR "MacOS ${OSX_DEPLOYMENT_TARGET} ${MACOS_NAME} NOT supported. macOS Catalina is the minimum system")
  ENDIF ()



  IF (DARWIN_VERSION EQUAL 19) # macOS 10.15 Catalina (Xcode 11.x or Xcode 12.x)
    set(MACOS_NAME "Catalina")
    set(OSX_DEPLOYMENT_TARGET "10.15")
    set(OSX_SDK "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk")
    message(STATUS "Found macOS ${OSX_DEPLOYMENT_TARGET} ${MACOS_NAME} as the host. Darwin Version:${DARWIN_VERSION}")
  ENDIF ()

  IF (DARWIN_VERSION EQUAL 20) # macOS 11.00 Big Sur (Xcode 12.x)
    set(MACOS_NAME "Big Sur")
    set(OSX_DEPLOYMENT_TARGET "11.00")
    set(OSX_SDK "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk")
    set(OSX_DEPLOYMENT_TARGET "11.00")
    message(STATUS "Found macOS ${OSX_DEPLOYMENT_TARGET} ${MACOS_NAME} as the host. Darwin Version:${DARWIN_VERSION}")
  ENDIF ()

  IF (DARWIN_VERSION EQUAL 21) # macOS 12.00 Monterey (Xcode 12.x)
    set(MACOS_NAME "Monterey")
    set(OSX_DEPLOYMENT_TARGET "12.00")
    set(OSX_SDK "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk")
    message(STATUS "Found macOS ${OSX_DEPLOYMENT_TARGET} ${MACOS_NAME} as the host. Darwin Version:${DARWIN_VERSION}")
  ENDIF ()

  if("${OSX_SDK}" STREQUAL "NOT-FOUND")
    message(FATAL_ERROR "This version of macOS (${DARWIN_VERSION}) is not recognized.\
      The following versions are supported:\n\
      (18) macOS 10.15 Mojave\n\
      (19) macOS 10.15 Catalina\n\
      (20) macOS 11.00 Big Sur\n\
      (21) macOS 12.00 Monterey\n\
      Please edit ${CMAKE_CURRENT_LIST_FILE} and add this version of macOS to the detection logic.
    ")

  endif()
  message(STATUS "CMAKE_HOST_SYSTEM_PROCESSOR: ${CMAKE_HOST_SYSTEM_PROCESSOR}")
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/projects/apple/OSX_DREAM3D_SDK.cmake
              ${DREAM3D_SDK}/NX.cmake @ONLY )
elseif(WIN32)

  if(MSVC_VERSION LESS 1910)
    message(FATAL_ERROR "Visual Studio Version 16 2017 or greater is required.")
  endif()
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/projects/win32/WIN_DREAM3D_SDK.cmake
              ${DREAM3D_SDK}/NX.cmake COPYONLY )
else()

  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/projects/unix/Linux_DREAM3D_SDK.cmake
              ${DREAM3D_SDK}/NX.cmake COPYONLY )
endif()

FILE(APPEND ${DREAM3D_SDK_FILE} "set(DREAM3D_SDK_VERSION ${DREAM3DSuperBuild_VERSION})\n")
FILE(APPEND ${DREAM3D_SDK_FILE} "\n")
FILE(APPEND ${DREAM3D_SDK_FILE} "set(BUILD_SHARED_LIBS ON CACHE BOOL \"\")\n")
FILE(APPEND ${DREAM3D_SDK_FILE} "set(NX_SDK_ROOT \"${DREAM3D_SDK}\")\n")


FILE(APPEND ${DREAM3D_SDK_FILE} "\n#--------------------------------------------------------------------------------------------------\n")
FILE(APPEND ${DREAM3D_SDK_FILE} "# Always write out the compile_commands.json file to help out things like QtCreator and VS Code\n")
FILE(APPEND ${DREAM3D_SDK_FILE} "set(CMAKE_EXPORT_COMPILE_COMMANDS ON)\n")


include(nlohmann_json)
include(HDF5)
include(Pybind11)
include(Eigen)
include(catch2)
include(fmt)
include(expected-lite)
include(VTK)
include(ITK5)
# include(Python)
# include(Discount)
# include(TBB)
# include(Haru)
# include(Boost)

#--------------------------------------------------------------------------------------------------
# If we are on Apple we need a FileSystem compatible with macOS < 10.15 or GCC < version 9
#--------------------------------------------------------------------------------------------------
include(ghcFileSystem)

#--------------------------------------------------------------------------------------------------
# Install or figure out where Qt5 is installed, then build Qwt based on that information
#--------------------------------------------------------------------------------------------------
include(Qt5)


