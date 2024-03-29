#--------------------------------------------------------------------------------------------------
# Are we building FileSystem? Only needed on macOS systems or Linux Systems
#--------------------------------------------------------------------------------------------------
if(WIN32)
  return()
endif()

if(CMAKE_COMPILER_IS_GNUCC AND "${CMAKE_SYSTEM_NAME}" STREQUAL "Linux" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 8.99)
  return()
endif()

if(CMAKE_OSX_DEPLOYMENT_TARGET VERSION_GREATER 10.14)
  return()
endif()

set(extProjectName "ghcFilesystem")
set(ghcFilesystem_GIT_TAG "v1.3.2")
set(ghcFilesystem_VERSION "1.3.2")
message(STATUS "Building: ${extProjectName} ${ghcFilesystem_VERSION}:  ghcFilesystem required")

set(ghcFilesystem_INSTALL "${NX_SDK}/${extProjectName}-${ghcFilesystem_VERSION}")

if(NX_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${ghcFilesystem_VERSION}.zip
    URL ${NX_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${ghcFilesystem_VERSION}.zip
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY "https://github.com/gulrak/filesystem.git"
    GIT_PROGRESS 1
    GIT_TAG ${ghcFilesystem_GIT_TAG}
  )
endif()

ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}

  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${ghcFilesystem_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${ghcFilesystem_VERSION}/Stamp"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${ghcFilesystem_VERSION}/Download
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${ghcFilesystem_VERSION}/Source"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${ghcFilesystem_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${ghcFilesystem_INSTALL}"

  CMAKE_ARGS
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

    -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${OSX_SDK}
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -Wno-dev
    -DGHC_FILESYSTEM_BUILD_EXAMPLES:BOOL=OFF
    -DGHC_FILESYSTEM_BUILD_TESTING:BOOL=OFF

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
file(APPEND ${NX_SDK_FILE} "# GulRok FileSystem\n")
file(APPEND ${NX_SDK_FILE} "set(ghcFilesystem_VERSION \"${ghcFilesystem_VERSION}\" CACHE STRING \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(ghcFilesystem_DIR \"\${NX_SDK_ROOT}/${extProjectName}-\${ghcFilesystem_VERSION}/lib/cmake/${extProjectName}\" CACHE PATH \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${ghcFilesystem_DIR})\n")
