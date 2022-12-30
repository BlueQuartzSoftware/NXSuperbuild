#--------------------------------------------------------------------------------------------------
# Are we building fmt (ON by default)
#--------------------------------------------------------------------------------------------------
option(BUILD_FMT "Build fmt" ON)
if(NOT BUILD_FMT)
  return()
endif()

set(extProjectName "fmt")
set(fmt_GIT_TAG "7.1.3")
set(fmt_VERSION "7.1.3")
message(STATUS "Building: ${extProjectName} ${fmt_VERSION}: -DBUILD_FMT=${BUILD_FMT}")
if (CMAKE_GENERATOR MATCHES "Visual Studio")
  set(fmt_INSTALL "${NX_SDK}/${extProjectName}-${fmt_VERSION}")
else()
  set(fmt_INSTALL "${NX_SDK}/${extProjectName}-${fmt_VERSION}-${CMAKE_BUILD_TYPE}")
endif()

if(NX_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${fmt_VERSION}.zip
    URL ${NX_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${fmt_VERSION}.zip
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY "https://github.com/fmtlib/fmt"
    GIT_PROGRESS 1
    GIT_TAG ${fmt_GIT_TAG}
  )
endif()

if(NOT APPLE AND NOT WIN32)
  set(COMPILE_FLAGS "-fPIC")
endif()


ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}

  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${fmt_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${fmt_VERSION}/Stamp"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${fmt_VERSION}/Download
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${fmt_VERSION}/Source"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${fmt_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${fmt_INSTALL}"

  CMAKE_ARGS
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_CXX_FLAGS:STRING=${COMPILE_FLAGS}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

    -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${OSX_SDK}
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -Wno-dev
    -DFMT_CMAKE_DIR=share/fmt
    -DFMT_TEST=OFF
    -DFMT_DOC=OFF

  LOG_DOWNLOAD 1
  LOG_UPDATE 1
  LOG_CONFIGURE 1
  LOG_BUILD 1
  LOG_TEST 1
  LOG_INSTALL 1
)

set(fmt_CMAKE_MODULE_DIR "${fmt_INSTALL}/share/${extProjectName}" CACHE PATH "" FORCE)


#-- Append this information to the NX_SDK CMake file that helps other developers
#-- configure DREAM3D for building
file(APPEND ${NX_SDK_FILE} "\n")
file(APPEND ${NX_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
file(APPEND ${NX_SDK_FILE} "# fmt\n")
file(APPEND ${NX_SDK_FILE} "set(fmt_VERSION \"${fmt_VERSION}\" CACHE STRING \"\")\n")
if (CMAKE_GENERATOR MATCHES "Visual Studio")
  file(APPEND ${NX_SDK_FILE} "set(fmt_DIR \"\${NX_SDK_ROOT}/${extProjectName}-\${fmt_VERSION}/share/${extProjectName}\" CACHE PATH \"\")\n")
else()
  file(APPEND ${NX_SDK_FILE} "set(fmt_DIR \"\${NX_SDK_ROOT}/${extProjectName}-\${fmt_VERSION}-\${BUILD_TYPE}/share/${extProjectName}\" CACHE PATH \"\")\n")
endif()
file(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${fmt_DIR})\n")
