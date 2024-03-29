#--------------------------------------------------------------------------------------------------
# Are we building Haru (ON by default)
#--------------------------------------------------------------------------------------------------
OPTION(BUILD_HARU "Build Haru" ON)
if("${BUILD_HARU}" STREQUAL "OFF")
  return()
endif()

set(extProjectName "haru")
set(haru_VERSION "2.0.0")
message(STATUS "Building: ${extProjectName} ${haru_VERSION}: -DBUILD_HARU=${BUILD_HARU}" )

if(WIN32)
  set(haru_INSTALL "${NX_SDK}/${extProjectName}-${haru_VERSION}")
else()
  set(haru_INSTALL "${NX_SDK}/${extProjectName}-${haru_VERSION}-${CMAKE_BUILD_TYPE}")
endif()

if(NOT APPLE AND NOT WIN32)
  set(LINUX_COMPILE_OPTIONS "-fPIC")
endif()


if(NX_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${haru_VERSION}.zip
    URL ${NX_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${haru_VERSION}.zip
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY "https://github.com/BlueQuartzSoftware/libharu.git"
    GIT_PROGRESS 1
    GIT_TAG develop
  )
endif()

ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}

  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${haru_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${haru_VERSION}/Stamp"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${haru_VERSION}/Download
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${haru_VERSION}/Source"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${haru_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${haru_INSTALL}"

  CMAKE_ARGS
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

    -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${OSX_SDK}
    -DCMAKE_CXX_STANDARD=11 
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -Wno-dev
    -DLIBHPDF_BUILD_SHARED_LIBS=ON 

  LOG_DOWNLOAD 1
  LOG_UPDATE 1
  LOG_CONFIGURE 1
  LOG_BUILD 1
  LOG_TEST 1
  LOG_INSTALL 1
)

#-- Append this information to the NX_SDK CMake file that helps other developers
#-- configure DREAM3D for building
FILE(APPEND ${NX_SDK_FILE} "\n")
FILE(APPEND ${NX_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
FILE(APPEND ${NX_SDK_FILE} "# haru\n")
FILE(APPEND ${NX_SDK_FILE} "set(libharu_VERSION \"${haru_VERSION}\" CACHE STRING \"\")\n")
if(APPLE)
  FILE(APPEND ${NX_SDK_FILE} "set(libharu_DIR \"\${NX_SDK_ROOT}/${extProjectName}-\${libharu_VERSION}-\${BUILD_TYPE}/cmake/lib${extProjectName}\" CACHE PATH \"\")\n")
elseif(WIN32)
  FILE(APPEND ${NX_SDK_FILE} "set(libharu_DIR \"\${NX_SDK_ROOT}/${extProjectName}-\${libharu_VERSION}/cmake/lib${extProjectName}\" CACHE PATH \"\")\n")
else()
  FILE(APPEND ${NX_SDK_FILE} "set(libharu_DIR \"\${NX_SDK_ROOT}/${extProjectName}-\${libharu_VERSION}-\${BUILD_TYPE}/cmake/lib${extProjectName}\" CACHE PATH \"\")\n")
endif()
FILE(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${libharu_DIR})\n")
