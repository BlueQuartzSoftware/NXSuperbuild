#--------------------------------------------------------------------------------------------------
# Are we building nod (ON by default)
#--------------------------------------------------------------------------------------------------
option(BUILD_NOD "Build nod" ON)
if(NOT BUILD_NOD)
  return()
endif()

set(extProjectName "nod")
set(nod_GIT_TAG "v0.5.3")
set(nod_VERSION "0.5.3")
message(STATUS "Building: ${extProjectName} ${nod_VERSION}: -DBUILD_NOD=${BUILD_NOD}")

set(nod_INSTALL "${NX_SDK}/${extProjectName}-${nod_VERSION}")

if(NX_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${nod_VERSION}.zip
    URL ${NX_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${nod_VERSION}.zip
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY "https://github.com/fr00b0/nod"
    GIT_PROGRESS 1
    GIT_TAG ${nod_GIT_TAG}
  )
endif()


ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}

  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${nod_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${nod_VERSION}/Stamp"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${nod_VERSION}/Download
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${nod_VERSION}/Source"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${nod_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${nod_INSTALL}"

  PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different "${_self_dir}/patches/nod/CMakeLists.txt" "<SOURCE_DIR>/CMakeLists.txt"

  CMAKE_ARGS
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

    -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${OSX_SDK}
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -Wno-dev


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
file(APPEND ${NX_SDK_FILE} "# nod dir\n")
file(APPEND ${NX_SDK_FILE} "set(nod_DIR \"\${NX_SDK_ROOT}/${extProjectName}-${nod_VERSION}/share/${extProjectName}\" CACHE PATH \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(nod_INCLUDE_DIRS \"\${NX_SDK_ROOT}/${extProjectName}-${nod_VERSION}/include\" CACHE PATH \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${nod_DIR})\n")
file(APPEND ${NX_SDK_FILE} "set(nod_VERSION \"${nod_VERSION}\" CACHE STRING \"\")\n")
