#--------------------------------------------------------------------------------------------------
# Are we building HDF5 (ON by default)
#--------------------------------------------------------------------------------------------------
OPTION(BUILD_HDF5 "Build HDF5" ON)
if("${BUILD_HDF5}" STREQUAL "OFF")
  return()
endif()

set(extProjectName "hdf5")
set(HDF5_VERSION "1.12.1")
message(STATUS "Building: ${extProjectName} ${HDF5_VERSION}: -DBUILD_HDF5=${BUILD_HDF5}" )
set(HDF5_GIT_TAG "hdf5-1_12_1")

#set(HDF5_URL "http://www.hdfgroup.org/ftp/HDF5/prev-releases/hdf5-${HDF5_VERSION}/src/hdf5-${HDF5_VERSION}.tar.gz")
#set(HDF5_URL "https://github.com/BlueQuartzSoftware/DREAM3DSuperbuild/releases/download/v6.6/hdf5-${HDF5_VERSION}.tar.gz")

if(CMAKE_GENERATOR MATCHES "Visual Studio")
  set(HDF5_INSTALL "${NX_SDK}/${extProjectName}-${HDF5_VERSION}")
else()
  set(HDF5_INSTALL "${NX_SDK}/${extProjectName}-${HDF5_VERSION}-${CMAKE_BUILD_TYPE}")
endif()

if( CMAKE_BUILD_TYPE MATCHES Debug )
  set(HDF5_SUFFIX "_debug")
ENDif( CMAKE_BUILD_TYPE MATCHES Debug )

set_property(DIRECTORY PROPERTY EP_BASE ${NX_SDK}/superbuild)


if(WIN32)
  set(CXX_FLAGS "/DWIN32 /D_WINDOWS /W3 /GR /EHsc /MP")
  set(C_FLAGS "/DWIN32 /D_WINDOWS /W3 /MP")
  set(C_CXX_FLAGS -DCMAKE_CXX_FLAGS=${CXX_FLAGS} -DCMAKE_C_FLAGS=${C_FLAGS})
endif()


if(NX_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${HDF5_VERSION}.tar.gz
    URL ${NX_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${HDF5_VERSION}.tar.gz
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY "https://github.com/HDFGroup/hdf5/"
    GIT_PROGRESS 1
    GIT_TAG ${HDF5_GIT_TAG}
  )
endif()

ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}

  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${HDF5_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${HDF5_VERSION}/Stamp/${CMAKE_BUILD_TYPE}"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${HDF5_VERSION}
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${HDF5_VERSION}/Source/${extProjectName}"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${HDF5_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${HDF5_INSTALL}"

  CMAKE_ARGS
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    ${C_CXX_FLAGS}
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${OSX_SDK}
    -DCMAKE_CXX_STANDARD=11 
    -DCMAKE_CXX_STANDARD_REQUIRED=ON 
    -DHDF5_BUILD_WITH_INSTALL_NAME=ON 
    -DHDF5_BUILD_CPP_LIB=ON
    -DHDF5_BUILD_HL_LIB=OFF
    -DBUILD_TESTING=OFF
    -DHDF_PACKAGE_NAMESPACE=hdf5::
    -DHDF5_BUILD_EXAMPLES=OFF
    -DHDF5_INSTALL_DATA_DIR=share/hdf5/data
    -DHDF5_INSTALL_CMAKE_DIR=share

  LOG_DOWNLOAD 1
  LOG_UPDATE 1
  LOG_CONFIGURE 1
  LOG_BUILD 1
  LOG_TEST 1
  LOG_INSTALL 1
)

set(HDF5_CMAKE_MODULE_DIR "${HDF5_INSTALL}/share/hdf5" CACHE PATH "" FORCE)

#-- Append this information to the NX_SDK CMake file that helps other developers
#-- configure DREAM3D for building
FILE(APPEND ${NX_SDK_FILE} "\n")
FILE(APPEND ${NX_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
FILE(APPEND ${NX_SDK_FILE} "# HDF5 Library Location\n")
FILE(APPEND ${NX_SDK_FILE} "set(HDF5_VERSION \"${HDF5_VERSION}\" CACHE STRING \"\")\n")
if(CMAKE_GENERATOR MATCHES "Visual Studio")
  FILE(APPEND ${NX_SDK_FILE} "set(HDF5_INSTALL \"\${NX_SDK_ROOT}/${extProjectName}-\${HDF5_VERSION}\" CACHE PATH \"\")\n")
  FILE(APPEND ${NX_SDK_FILE} "set(HDF5_DIR \"\${NX_SDK_ROOT}/${extProjectName}-\${HDF5_VERSION}/share/hdf5\" CACHE PATH \"\")\n")
else()
  FILE(APPEND ${NX_SDK_FILE} "set(HDF5_INSTALL \"\${NX_SDK_ROOT}/${extProjectName}-\${HDF5_VERSION}-\${BUILD_TYPE}\" CACHE PATH \"\")\n")
  FILE(APPEND ${NX_SDK_FILE} "set(HDF5_DIR \"\${NX_SDK_ROOT}/${extProjectName}-\${HDF5_VERSION}-\${BUILD_TYPE}/share/hdf5\" CACHE PATH \"\")\n")
endif()
FILE(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${HDF5_DIR})\n")
