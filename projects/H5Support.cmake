#--------------------------------------------------------------------------------------------------
# Are we building H5Support (ON by default)
#--------------------------------------------------------------------------------------------------
option(BUILD_H5Support "Build H5Support" ON)
if(NOT BUILD_H5Support)
  return()
endif()

set(extProjectName "H5Support")
set(H5Support_GIT_TAG "v1.0.8")
set(H5Support_VERSION "1.0.8")
message(STATUS "Building: ${extProjectName} ${H5Support_VERSION}: -DBUILD_H5Support=${BUILD_H5Support}")

set(H5Support_INSTALL "${NX_SDK}/${extProjectName}-${H5Support_VERSION}")

if(NX_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${H5Support_VERSION}.zip
    URL ${NX_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${H5Support_VERSION}.zip
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY "https://github.com/BlueQuartzSoftware/H5Support.git"
    GIT_PROGRESS 1
    GIT_TAG ${H5Support_GIT_TAG}
  )
endif()

set(HDF5_CMAKE_MODULE_DIR "${HDF5_INSTALL}/share/hdf5")

ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}

  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${H5Support_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${H5Support_VERSION}/Stamp"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${H5Support_VERSION}/Download
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${H5Support_VERSION}/Source"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${H5Support_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${H5Support_INSTALL}"

  CMAKE_ARGS
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

    -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${OSX_SDK}
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -DBUILD_TESTING=OFF
    -DH5Support_INCLUDE_QT_API=OFF
    -DHDF5_DIR=${HDF5_CMAKE_MODULE_DIR}
    -DCMP_HDF5_ENABLE_INSTALL=OFF
    -DCMP_HDF5_ENABLE_COPY=OFF

  DEPENDS hdf5
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
file(APPEND ${NX_SDK_FILE} "# H5Support\n")
file(APPEND ${NX_SDK_FILE} "set(H5Support_VERSION \"${H5Support_VERSION}\" CACHE STRING \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(H5Support_DIR \"\${NX_SDK_ROOT}/${extProjectName}-\${H5Support_VERSION}/share/${extProjectName}\" CACHE PATH \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${H5Support_DIR})\n")
