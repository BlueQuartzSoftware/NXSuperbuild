#--------------------------------------------------------------------------------------------------
# Are we building Catch2 (ON by default)
#--------------------------------------------------------------------------------------------------
option(BUILD_CATCH2 "Build Catch2" ON)
if(NOT BUILD_CATCH2)
  return()
endif()

set(extProjectName "Catch2")
set(Catch2_GIT_TAG "v2.13.6")
set(Catch2_VERSION "2.13.6")
message(STATUS "Building: ${extProjectName} ${Catch2_VERSION}: -DBUILD_CATCH2=${BUILD_CATCH2}")

set(Catch2_INSTALL "${NX_SDK}/${extProjectName}-${Catch2_VERSION}")

if(DREAM3D_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${Catch2_VERSION}.zip
    URL ${DREAM3D_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${Catch2_VERSION}.zip
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY "https://github.com/catchorg/Catch2"
    GIT_PROGRESS 1
    GIT_TAG ${Catch2_GIT_TAG}
  )
endif()


ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}

  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${Catch2_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${Catch2_VERSION}/Stamp"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${Catch2_VERSION}/Download
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${Catch2_VERSION}/Source"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${Catch2_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${Catch2_INSTALL}"

  CMAKE_ARGS
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

    -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${OSX_SDK}
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -Wno-dev
    -DBUILD_TESTING=OFF
    -DCATCH_BUILD_EXAMPLES=OFF

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
file(APPEND ${NX_SDK_FILE} "# Catch2\n")
file(APPEND ${NX_SDK_FILE} "set(Catch2_DIR \"\${NX_SDK_ROOT}/${extProjectName}-${Catch2_VERSION}/lib/cmake/${extProjectName}\" CACHE PATH \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${Catch2_DIR})\n")
file(APPEND ${NX_SDK_FILE} "set(Catch2_VERSION \"${Catch2_VERSION}\" CACHE STRING \"\")\n")
