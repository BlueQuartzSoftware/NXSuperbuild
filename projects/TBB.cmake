#--------------------------------------------------------------------------------------------------
# Are we building TBB (ON by default)
#--------------------------------------------------------------------------------------------------
OPTION(BUILD_TBB "Build TBB" ON)
if("${BUILD_TBB}" STREQUAL "OFF")
  return()
endif()

set(extProjectName "tbb")
set(tbb_VERSION "2020.1")

#https://github.com/intel/tbb/releases/download/v2020.1/tbb-2020.1-lin.tgz

message(STATUS "Building: ${extProjectName} ${tbb_VERSION}: -DBUILD_TBB=${BUILD_TBB}" )


if(NX_USE_CUSTOM_DOWNLOAD_SITE)
  set(tbb_url_server "${NX_CUSTOM_DOWNLOAD_URL_PREFIX}")
else()
  set(tbb_url_server "https://github.com/intel/tbb/releases/download/v2020.1/")
endif()


set(tbb_os_name "")
set(tbb_os_ext "")

if(APPLE)
  set(tbb_os_name "mac")
  set(tbb_os_ext "tgz")
elseif(WIN32)
  set(tbb_os_name "win")
  set(tbb_os_ext "zip")
else()
  set(tbb_os_name "lin")
  set(tbb_os_ext "tgz")
endif()

set(tbb_URL "${tbb_url_server}tbb-${tbb_VERSION}-${tbb_os_name}.${tbb_os_ext}")

set(tbb_INSTALL "${NX_SDK}/tbb-${tbb_VERSION}-${tbb_os_name}")

set_property(DIRECTORY PROPERTY EP_BASE ${NX_SDK}/superbuild)

#------------------------------------------------------------------------------
# Linux has TBB Compiled and installed
if(WIN32 OR APPLE OR "${BUILD_TBB}" STREQUAL "ON" )
  ExternalProject_Add(${extProjectName}
    URL ${tbb_URL}

    TMP_DIR "${NX_SDK}/superbuild/${extProjectName}/tmp/${CMAKE_BUILD_TYPE}"
    STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}/Stamp"
    DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}
    SOURCE_DIR "${tbb_INSTALL}"
    BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}/Build/${CMAKE_BUILD_TYPE}"
    INSTALL_DIR "${tbb_INSTALL}"
    
    
    CONFIGURE_COMMAND "" 
    BUILD_COMMAND "" 
    INSTALL_COMMAND ""

    LOG_DOWNLOAD 1
    LOG_UPDATE 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_TEST 1
    LOG_INSTALL 1
  )

  #-- Append this information to the NX_SDK CMake file that helps other developers
  #-- configure DREAM3D for building
  #-- Starting with TBB 2018 U5 the Parallel STL is included which is why we need 
  #-- the double path to the TBB cmake directory
  FILE(APPEND ${NX_SDK_FILE} "\n")
  FILE(APPEND ${NX_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
  FILE(APPEND ${NX_SDK_FILE} "# Intel Threading Building Blocks Library\n")
  FILE(APPEND ${NX_SDK_FILE} "set(SIMPL_USE_MULTITHREADED_ALGOS ON CACHE BOOL \"\")\n")
  FILE(APPEND ${NX_SDK_FILE} "set(TBB_INSTALL_DIR \"\${NX_SDK_ROOT}/tbb-${tbb_VERSION}-${tbb_os_name}/${extProjectName}\" CACHE PATH \"\")\n")
  FILE(APPEND ${NX_SDK_FILE} "set(TBB_DIR \"\${NX_SDK_ROOT}/tbb-${tbb_VERSION}-${tbb_os_name}/${extProjectName}/cmake\" CACHE PATH \"\")\n") 
  FILE(APPEND ${NX_SDK_FILE} "set(TBB_ARCH_TYPE \"intel64\" CACHE STRING \"\")\n")
else()
  message(STATUS "LINUX: Please use your package manager to install Threading Building Blocks (TBB)")
  #------------------------------------------------------------------------------
  # Linux has an acceptable TBB installation
  FILE(APPEND ${NX_SDK_FILE} "\n")
  FILE(APPEND ${NX_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
  FILE(APPEND ${NX_SDK_FILE} "# Intel Threading Building Blocks Library\n")
  FILE(APPEND ${NX_SDK_FILE} "set(SIMPL_USE_MULTITHREADED_ALGOS ON CACHE BOOL \"\")\n")
  FILE(APPEND ${NX_SDK_FILE} "set(TBB_INSTALL_DIR \"/usr\" CACHE PATH \"\")\n")
  FILE(APPEND ${NX_SDK_FILE} "set(TBB_DIR \"/usr\" CACHE PATH \"\")\n")
  FILE(APPEND ${NX_SDK_FILE} "set(TBB_ARCH_TYPE \"intel64\" CACHE STRING \"\")\n")
endif()

FILE(APPEND ${NX_SDK_FILE} "set(TBB_VERSION \"${tbb_VERSION}\" CACHE STRING \"\")\n")
