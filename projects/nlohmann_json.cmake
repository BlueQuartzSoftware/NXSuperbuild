#--------------------------------------------------------------------------------------------------
# Are we building NLohmann JSON (ON by default)
#--------------------------------------------------------------------------------------------------
option(BUILD_NLOHMANN_JSON "Build NLohmann JSON" ON)
if(NOT BUILD_NLOHMANN_JSON)
  return()
endif()

set(extProjectName "nlohmann_json")
set(nlohmann_json_GIT_TAG "v3.11.2")
set(nlohmann_json_VERSION "3.11.2")
message(STATUS "Building: ${extProjectName} ${nlohmann_json_VERSION}: -DBUILD_NLOHMANN_JSON=${BUILD_NLOHMANN_JSON}")

set(nlohmann_json_INSTALL "${NX_SDK}/${extProjectName}-${nlohmann_json_VERSION}")

if(NX_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${nlohmann_json_VERSION}.zip
    URL ${NX_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${nlohmann_json_VERSION}.zip
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY "https://github.com/nlohmann/json/"
    GIT_PROGRESS 1
    GIT_TAG ${nlohmann_json_GIT_TAG}
  )
endif()


ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}

  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${nlohmann_json_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${nlohmann_json_VERSION}/Stamp"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${nlohmann_json_VERSION}/Download
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${nlohmann_json_VERSION}/Source"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${nlohmann_json_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${nlohmann_json_INSTALL}"

  CMAKE_ARGS
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

    -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${OSX_SDK}
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -Wno-dev
    -DJSON_BuildTests=OFF
    -DJSON_MultipleHeaders=ON

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
file(APPEND ${NX_SDK_FILE} "# nlohmann_json\n")
file(APPEND ${NX_SDK_FILE} "set(nlohmann_json_VERSION \"${nlohmann_json_VERSION}\" CACHE STRING \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(nlohmann_json_DIR \"\${NX_SDK_ROOT}/${extProjectName}-\${nlohmann_json_VERSION}/share/cmake/${extProjectName}\" CACHE PATH \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${nlohmann_json_DIR})\n")

