#--------------------------------------------------------------------------------------------------
# Are we building expected-lite (ON by default)
#--------------------------------------------------------------------------------------------------
option(BUILD_EXPECTED_LITE "Build expected-lite" ON)
if(NOT BUILD_EXPECTED_LITE)
  return()
endif()

set(extProjectName "expected-lite")
set(expected-lite_GIT_TAG "v0.5.0")
set(expected-lite_VERSION "v0.5.0")
message(STATUS "Building: ${extProjectName} ${expected-lite_VERSION}: -DBUILD_EXPECTED_LITE=${BUILD_EXPECTED_LITE}")

set(expected-lite_INSTALL "${NX_SDK}/${extProjectName}-${expected-lite_VERSION}")

if(DREAM3D_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${expected-lite_VERSION}.zip
    URL ${DREAM3D_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${expected-lite_VERSION}.zip
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY "https://github.com/martinmoene/expected-lite"
    GIT_PROGRESS 1
    GIT_TAG ${expected-lite_GIT_TAG}
  )
endif()


ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}

  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${expected-lite_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${expected-lite_VERSION}/Stamp"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${expected-lite_VERSION}/Download
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${expected-lite_VERSION}/Source"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${expected-lite_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${expected-lite_INSTALL}"

  CMAKE_ARGS
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

    -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${OSX_SDK}
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -Wno-dev
    -DEXPECTED_LITE_OPT_BUILD_TESTS=OFF
    -DEXPECTED_LITE_OPT_BUILD_EXAMPLES=OFF

  LOG_DOWNLOAD 1
  LOG_UPDATE 1
  LOG_CONFIGURE 1
  LOG_BUILD 1
  LOG_TEST 1
  LOG_INSTALL 1
)

#-- Append this information to the NX_SDK CMake file that helps other developers
#-- configure DREAM3D for building
file(APPEND ${NX_SDK_FILE} "\n")
file(APPEND ${NX_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
file(APPEND ${NX_SDK_FILE} "# expected-lite\n")
file(APPEND ${NX_SDK_FILE} "set(expected-lite_DIR \"\${NX_SDK_ROOT}/${extProjectName}-${expected-lite_VERSION}/lib/cmake/${extProjectName}\" CACHE PATH \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${expected-lite_DIR})\n")
file(APPEND ${NX_SDK_FILE} "set(expected-lite_VERSION \"${expected-lite_VERSION}\" CACHE STRING \"\")\n")
