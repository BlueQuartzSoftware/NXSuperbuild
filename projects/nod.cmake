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

if(DREAM3D_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${nod_VERSION}.zip
    URL ${DREAM3D_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${nod_VERSION}.zip
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
  SOURCE_DIR "${nod_INSTALL}"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${nod_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${nod_INSTALL}"

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
file(APPEND ${NX_SDK_FILE} "\n")
file(APPEND ${NX_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
file(APPEND ${NX_SDK_FILE} "# nod dir\n")
file(APPEND ${NX_SDK_FILE} "set(nod_DIR \"\${NX_SDK_ROOT}/${extProjectName}-${nod_VERSION}/share/${extProjectName}\" CACHE PATH \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(nod_INCLUDE_DIRS \"\${NX_SDK_ROOT}/${extProjectName}-${nod_VERSION}/include\" CACHE PATH \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${nod_DIR})\n")
file(APPEND ${NX_SDK_FILE} "set(nod_VERSION \"${nod_VERSION}\" CACHE STRING \"\")\n")
