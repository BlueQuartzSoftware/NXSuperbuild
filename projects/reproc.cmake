#--------------------------------------------------------------------------------------------------
# Are we building reproc++ (ON by default)
#--------------------------------------------------------------------------------------------------
option(BUILD_REPROC "Build reproc++" ON)
if(NOT BUILD_REPROC)
  return()
endif()

set(extProjectName "reproc")
set(reproc_GIT_TAG "v14.2.4")
set(reproc_VERSION "14.2.4")
message(STATUS "Building: ${extProjectName} ${reproc_VERSION}: -DBUILD_REPROC=${BUILD_REPROC}")
if (CMAKE_GENERATOR MATCHES "Visual Studio")
  set(reproc_INSTALL "${NX_SDK}/${extProjectName}-${reproc_VERSION}")
else()
  set(reproc_INSTALL "${NX_SDK}/${extProjectName}-${reproc_VERSION}-${CMAKE_BUILD_TYPE}")
endif()

if(NX_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${reproc_VERSION}.zip
    URL ${NX_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${reproc_VERSION}.zip
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY "https://github.com/DaanDeMeyer/reproc"
    GIT_PROGRESS 1
    GIT_TAG ${reproc_GIT_TAG}
  )
endif()

if(NOT APPLE AND NOT WIN32)
  set(COMPILE_FLAGS "-fPIC")
endif()


ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}

  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${reproc_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${reproc_VERSION}/Stamp"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${reproc_VERSION}/Download
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${reproc_VERSION}/Source"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${reproc_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${reproc_INSTALL}"

  CMAKE_ARGS
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_C_FLAGS:STRING=${COMPILE_FLAGS}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_CXX_FLAGS:STRING=${COMPILE_FLAGS}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

    -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${OSX_SDK}
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -DREPROC++=ON
    -DREPROC_INSTALL_PKGCONFIG=OFF
    -DREPROC_INSTALL_CMAKECONFIGDIR=share
    -DCMAKE_DEBUG_POSTFIX:STRING=_debug

  LOG_DOWNLOAD 1
  LOG_UPDATE 1
  LOG_CONFIGURE 1
  LOG_BUILD 1
  LOG_TEST 1
  LOG_INSTALL 1
)

set(reproc_CMAKE_MODULE_DIR "${reproc_INSTALL}/share/${extProjectName}" CACHE PATH "" FORCE)


#-- Append this information to the NX_SDK CMake file that helps other developers
#-- configure DREAM3D for building
file(APPEND ${NX_SDK_FILE} "\n")
file(APPEND ${NX_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
file(APPEND ${NX_SDK_FILE} "# reproc++ ${reproc_VERSION}\n")
file(APPEND ${NX_SDK_FILE} "set(reproc_VERSION \"${reproc_VERSION}\" CACHE STRING \"\")\n")
if (CMAKE_GENERATOR MATCHES "Visual Studio")
  file(APPEND ${NX_SDK_FILE} "set(reproc_DIR \"\${NX_SDK_ROOT}/${extProjectName}-\${reproc_VERSION}/share/${extProjectName}\" CACHE PATH \"\")\n")
  file(APPEND ${NX_SDK_FILE} "set(reproc++_DIR \"\${NX_SDK_ROOT}/${extProjectName}-\${reproc_VERSION}/share/${extProjectName}++\" CACHE PATH \"\")\n")
else()
  file(APPEND ${NX_SDK_FILE} "set(reproc_DIR \"\${NX_SDK_ROOT}/${extProjectName}-\${reproc_VERSION}-\${BUILD_TYPE}/share/${extProjectName}\" CACHE PATH \"\")\n")
  file(APPEND ${NX_SDK_FILE} "set(reproc++_DIR \"\${NX_SDK_ROOT}/${extProjectName}-\${reproc_VERSION}-\${BUILD_TYPE}/share/${extProjectName}++\" CACHE PATH \"\")\n")
endif()
file(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${reproc_DIR})\n")
