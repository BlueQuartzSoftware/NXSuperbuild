#--------------------------------------------------------------------------------------------------
# Are we building boost_mp11 (ON by default)
#--------------------------------------------------------------------------------------------------
option(BUILD_MP11_LITE "Build boost_mp11" ON)
if(NOT BUILD_MP11_LITE)
  return()
endif()

set(extProjectName "boost_mp11")
set(boost_mp11_GIT_TAG "boost-1.77.0")
set(boost_mp11_VERSION "1.77.0")
message(STATUS "Building: ${extProjectName} ${boost_mp11_VERSION}: -DBUILD_MP11_LITE=${BUILD_MP11_LITE}")

set(boost_mp11_INSTALL "${NX_SDK}/${extProjectName}-${boost_mp11_VERSION}")

if(NX_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${boost_mp11_VERSION}.zip
    URL ${NX_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${boost_mp11_VERSION}.zip
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY "https://github.com/boostorg/mp11"
    GIT_PROGRESS 1
    GIT_TAG ${boost_mp11_GIT_TAG}
  )
endif()


ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}

  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${boost_mp11_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${boost_mp11_VERSION}/Stamp"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${boost_mp11_VERSION}/Download
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${boost_mp11_VERSION}/Source"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${boost_mp11_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${boost_mp11_INSTALL}"

  CMAKE_ARGS
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

    -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${OSX_SDK}
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -DBUILD_TESTING=OFF

    
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
file(APPEND ${NX_SDK_FILE} "# boost_mp11\n")
file(APPEND ${NX_SDK_FILE} "set(boost_mp11_VERSION \"${boost_mp11_VERSION}\" CACHE STRING \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(boost_mp11_DIR \"\${NX_SDK_ROOT}/${extProjectName}-\${boost_mp11_VERSION}/lib/cmake/${extProjectName}-\${boost_mp11_VERSION}\" CACHE PATH \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${boost_mp11_DIR})\n")
