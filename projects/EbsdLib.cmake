#--------------------------------------------------------------------------------------------------
# Are we building Haru (ON by default)
#--------------------------------------------------------------------------------------------------
OPTION(BUILD_EBSDLIB "Build EbsdLib" ON)
if("${BUILD_EBSDLIB}" STREQUAL "OFF")
  return()
endif()

set(extProjectName "EbsdLib")
set(EbsdLib_VERSION "1.0.11")
set(EbsdLib_GIT_TAG "v1.0.11")
message(STATUS "Building: ${extProjectName} ${EbsdLib_VERSION}: -DBUILD_EBSDLIB=${BUILD_EBSDLIB}" )

if (CMAKE_GENERATOR MATCHES "Visual Studio")
  set(EbsdLib_INSTALL "${NX_SDK}/${extProjectName}-${EbsdLib_VERSION}")
else()
  set(EbsdLib_INSTALL "${NX_SDK}/${extProjectName}-${EbsdLib_VERSION}-${CMAKE_BUILD_TYPE}")
endif()

if(NOT APPLE AND NOT WIN32)
  set(LINUX_COMPILE_OPTIONS "-fPIC")
endif()


if(NX_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${EbsdLib_VERSION}.zip
    URL ${NX_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${EbsdLib_VERSION}.zip
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY "https://github.com/BlueQuartzSoftware/EbsdLib.git"
    GIT_PROGRESS 1
    GIT_TAG ${EbsdLib_GIT_TAG}
  )
endif()


ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}

  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${EbsdLib_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${EbsdLib_VERSION}/Stamp"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${EbsdLib_VERSION}/Download
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${EbsdLib_VERSION}/Source"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${EbsdLib_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${EbsdLib_INSTALL}"

  CMAKE_ARGS
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

    -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${OSX_SDK}
    -DCMAKE_CXX_STANDARD=11 
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -Wno-dev
    -DBUILD_SHARED_LIBS=ON 
    -DEbsdLib_BUILD_TOOLS=OFF
    -DEbsdLib_ENABLE_TESTING=OFF
    -DEbsdLib_BUILD_H5SUPPORT=OFF
    -DDREAM3D_ANACONDA=ON
    -DH5Support_DIR:PATH=${NX_SDK}/H5Support-${H5Support_VERSION}/share/H5Support
    -DTBB_DIR:PATH=${NX_SDK}/oneTBB-${oneTBB_VERSION}-${CMAKE_BUILD_TYPE}/lib/cmake/TBB
    -DEigen3_DIR:PATH=${NX_SDK}/Eigen-${Eigen3_VERSION}/share/eigen3/cmake
    -DHDF5_DIR:PATH=${NX_SDK}/hdf5-${HDF5_VERSION}-${CMAKE_BUILD_TYPE}/share/hdf5

  DEPENDS 
     #hdf5
    H5Support
    Eigen
    oneTBB

  LOG_DOWNLOAD 1
  LOG_UPDATE 1
  LOG_CONFIGURE 1
  LOG_BUILD 1
  LOG_TEST 1
  LOG_INSTALL 1
)

#-- Append this information to the NX_SDK CMake file that helps other developers
#-- configure DREAM3D for building
FILE(APPEND ${NX_SDK_FILE} "\n")
FILE(APPEND ${NX_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
FILE(APPEND ${NX_SDK_FILE} "# EbsdLib\n")
if (CMAKE_GENERATOR MATCHES "Visual Studio")
  FILE(APPEND ${NX_SDK_FILE} "set(EbsdLib_DIR \"\${NX_SDK_ROOT}/${extProjectName}-${EbsdLib_VERSION}/share/${extProjectName}\" CACHE PATH \"\")\n")
else()
  FILE(APPEND ${NX_SDK_FILE} "set(EbsdLib_DIR \"\${NX_SDK_ROOT}/${extProjectName}-${EbsdLib_VERSION}-\${BUILD_TYPE}/share/${extProjectName}\" CACHE PATH \"\")\n")
endif()
FILE(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${EbsdLib_DIR})\n")
FILE(APPEND ${NX_SDK_FILE} "set(EbsdLib_VERSION \"${EbsdLib_VERSION}\" CACHE STRING \"\")\n")
