
if(${CMAKE_MAJOR_VERSION} STREQUAL "3")
  # CMake 3.0 introduces VERSION variables for each Project.
  cmake_policy(SET CMP0048 NEW)
  # CMake 3.1 introduces if() policies on dereferencing variables in quotes
  cmake_policy(SET CMP0054 NEW)
endif()

cmake_minimum_required(VERSION 3.16.0)

if(CMAKE_GENERATOR MATCHES "Ninja")
  message(WARNING "Using the Ninja Generator with the superbuild may cause problems when building due to\
  issues with HDF5 and dependencies. 'Unix Makefiles' is highly recommended for a smooth install.\
  This will NOT effect the generator that you use to build YOUR projects.")
endif()

project(NXSuperBuild VERSION 2.0.0.0 LANGUAGES C CXX)

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


if( "${NX_SDK}" STREQUAL "")
  message(FATAL_ERROR "Please specify the NX_SDK cmake variable which is the top level directory where all the DREAM.3D dependent libraries will be built")
endif()

set(NX_SDK_FILE ${NX_SDK}/NX.cmake)
set(download_dir ${NX_SDK})

message(STATUS "NX_SDK Folder: ${NX_SDK}")
message(STATUS "NX_SDK_FILE:   ${NX_SDK_FILE}")

#------------------------------------------------------------------------------
# Set the custom download location for all of the sources
# -----------------------------------------------------------------------------
option(NX_USE_CUSTOM_DOWNLOAD_SITE "Download Sources from a custom location" OFF)
set(NX_CUSTOM_DOWNLOAD_URL_PREFIX "http://dream3d.bluequartz.net/binaries/SDK/" CACHE STRING "Custom HTTP(s) URL")

set(BUILD_SHARED_LIBS ON)

if(APPLE)
  set(OSX_DEPLOYMENT_TARGET "11.0")
  execute_process(COMMAND uname -v
                  OUTPUT_VARIABLE DARWIN_VERSION)
                  string(REGEX MATCH "[0-9]+" DARWIN_VERSION ${DARWIN_VERSION})

  execute_process(COMMAND sw_vers -productVersion
                  OUTPUT_VARIABLE OSX_PRODUCT_VERSION)
                  string(STRIP "${OSX_PRODUCT_VERSION}" OSX_PRODUCT_VERSION)

  if(DARWIN_VERSION EQUAL 19) # macOS 10.15 Catalina (Xcode 11.x or Xcode 12.x)
    message(FATAL_ERROR "MacOS Big Sur (11.x) is the minimum version needed to compile DREAM.3D NX")
  endif()

  if(DARWIN_VERSION EQUAL 20) # macOS 11.00 Big Sur (Xcode 12.x)
    # message(STATUS "Found macOS 11.00 Big Sur as the host. Darwin Version:${DARWIN_VERSION}")
    set(CMAKE_MACOS_NAME "Big Sur")
    set(CMAKE_MACOS_VERSION "11.00")
  endif()

  IF (DARWIN_VERSION EQUAL 21) # macOS 12.00 Monterey (Xcode 12.x/Xcode 13.x)
    set(CMAKE_MACOS_NAME "Monterey")
    set(CMAKE_MACOS_VERSION "12.00")
  ENDIF ()

  IF (DARWIN_VERSION EQUAL 22) # macOS 13.00 Ventura (Xcode 13.x/Xcode 14.x)
    set(CMAKE_MACOS_NAME "Ventura")
    set(CMAKE_MACOS_VERSION "13.00")
  ENDIF ()

  message(STATUS "* System: MacOS ${CMAKE_MACOS_NAME} (${OSX_PRODUCT_VERSION}) Running on ${CMAKE_SYSTEM_PROCESSOR}")
  message(STATUS "* OSX_DEPLOYMENT_TARGET: ${OSX_DEPLOYMENT_TARGET}")

  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/projects/apple/OSX_NX_SDK.cmake
              ${NX_SDK}/NX.cmake @ONLY )
elseif(WIN32)

  if(MSVC_VERSION LESS 1910)
    message(FATAL_ERROR "Visual Studio Version 16 2017 or greater is required.")
  endif()
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/projects/win32/WIN_NX_SDK.cmake
              ${NX_SDK}/NX.cmake COPYONLY )
else()

  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/projects/unix/Linux_NX_SDK.cmake
              ${NX_SDK}/NX.cmake COPYONLY )
endif()

FILE(APPEND ${NX_SDK_FILE} "set(NX_SDK_VERSION ${NXSuperBuild_VERSION})\n")
FILE(APPEND ${NX_SDK_FILE} "\n")
FILE(APPEND ${NX_SDK_FILE} "set(BUILD_SHARED_LIBS ON CACHE BOOL \"\")\n")
FILE(APPEND ${NX_SDK_FILE} "set(NX_SDK_ROOT \"${NX_SDK}\")\n")


FILE(APPEND ${NX_SDK_FILE} "\n#--------------------------------------------------------------------------------------------------\n")
FILE(APPEND ${NX_SDK_FILE} "# Always write out the compile_commands.json file to help out things like QtCreator and VS Code\n")
FILE(APPEND ${NX_SDK_FILE} "set(CMAKE_EXPORT_COMPILE_COMMANDS ON)\n")

include(oneTBB)
include(nlohmann_json)
include(HDF5)
include(Pybind11)
include(Eigen)
include(catch2)
include(nod)
include(fmt)
include(expected-lite)
include(span-lite)
include(mp11)
include(reproc)

#--------------------------------------------------------------------------------------------------
# Install or figure out where Qt5 is installed
#--------------------------------------------------------------------------------------------------
include(Qt5)

#--------------------------------------------------------------------------------------------------
# Build VTK, which depends on finding Qt5
#--------------------------------------------------------------------------------------------------
include(VTK)

#--------------------------------------------------------------------------------------------------
# Build ITK
#--------------------------------------------------------------------------------------------------
include(ITK5)

#--------------------------------------------------------------------------------------------------
# If we are on Apple we need a FileSystem compatible with macOS < 10.15 or GCC < version 9
#--------------------------------------------------------------------------------------------------
include(ghcFileSystem)

#--------------------------------------------------------------------------------------------------
# Build EbsdLib
#--------------------------------------------------------------------------------------------------
include(H5Support)
include(EbsdLib)

