#--------------------------------------------------------------------------------------------------
# Are we building Eigen (ON by default)
#--------------------------------------------------------------------------------------------------
option(BUILD_EIGEN "Build Eigen" ON)
if(NOT BUILD_EIGEN)
  return()
endif()

set(extProjectName "Eigen")
set(Eigen3_VERSION "3.3.9" CACHE STRING "")
message(STATUS "Building: ${extProjectName} ${Eigen3_VERSION}: -DBUILD_EIGEN=${BUILD_EIGEN}")
set(Eigen_GIT_TAG ${Eigen3_VERSION})

set(SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${Eigen3_VERSION}/Source/${extProjectName}")

set(Eigen_INSTALL "${NX_SDK}/${extProjectName}-${Eigen3_VERSION}")

get_filename_component(_self_dir ${CMAKE_CURRENT_LIST_FILE} PATH)

configure_file(
  "${_self_dir}/patches/Eigen_DartConfiguration.tcl.in"
  "${NX_SDK}/superbuild/${extProjectName}-${Eigen3_VERSION}/Build/${CMAKE_BUILD_TYPE}/DartConfiguration.tcl"
  @ONLY
)


if(NX_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${Eigen3_VERSION}.tar.gz
    URL ${NX_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${Eigen3_VERSION}.tar.gz
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
    GIT_PROGRESS 1
    GIT_TAG ${Eigen_GIT_TAG}
  )
endif()

set_property(DIRECTORY PROPERTY EP_BASE ${NX_SDK}/superbuild)

ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}
  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${Eigen3_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${Eigen3_VERSION}/Stamp/${CMAKE_BUILD_TYPE}"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${Eigen3_VERSION}
  SOURCE_DIR "${SOURCE_DIR}"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${Eigen3_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${Eigen_INSTALL}"

  CMAKE_ARGS
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

    -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${OSX_SDK}
    -DCMAKE_CXX_STANDARD=11
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -Wno-dev
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
set(Eigen3_DIR "${NX_SDK}/Eigen-${Eigen3_VERSION}/share/eigen3/cmake" CACHE PATH "" FORCE)

file(APPEND ${NX_SDK_FILE} "\n")
file(APPEND ${NX_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
file(APPEND ${NX_SDK_FILE} "# Eigen3 Library Location\n")
file(APPEND ${NX_SDK_FILE} "set(Eigen3_VERSION \"${Eigen3_VERSION}\" CACHE STRING \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(Eigen3_DIR \"\${NX_SDK_ROOT}/Eigen-\${Eigen3_VERSION}/share/eigen3/cmake\" CACHE PATH \"\")\n")
