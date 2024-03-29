#--------------------------------------------------------------------------------------------------
# Are we building Qwt (ON by default)
#--------------------------------------------------------------------------------------------------
option(BUILD_QWT "Build Qwt" ON)
if(NOT BUILD_QWT)
  return()
endif()

set(extProjectName "qwt")
set(qwt_VERSION "6.1.5")
message(STATUS "Building: ${extProjectName} ${qwt_VERSION}: -DBUILD_QWT=${BUILD_QWT}")

#set(qwt_url "https://github.com/BlueQuartzSoftware/DREAM3DSuperbuild/releases/download/v6.6/${extProjectName}-${qwt_VERSION}.tar.gz")

set(qwt_INSTALL "${NX_SDK}/${extProjectName}-${qwt_VERSION}-${qt5_version_full}")

set(qwtConfig_FILE "${NX_SDK}/superbuild/${extProjectName}-${qwt_VERSION}-${qt5_version_full}/Build/qwtconfig.pri")
set(qwtSrcPro_FILE "${NX_SDK}/superbuild/${extProjectName}-${qwt_VERSION}-${qt5_version_full}/Build/src.pro")
set(COMMENT "")
if(NOT APPLE)
  set(COMMENT "#")
endif()

get_filename_component(_self_dir ${CMAKE_CURRENT_LIST_FILE} PATH)

configure_file(
  "${_self_dir}/patches/qwt/qwtconfig.pri.in"
  "${qwtConfig_FILE}"
  @ONLY
)

configure_file(
  "${_self_dir}/patches/qwt/src/src.pro.in"
  "${qwtSrcPro_FILE}"
  @ONLY
)

set(qwt_ParallelBuild "")
if(WIN32)
  set(qwt_BUILD_COMMAND "nmake")
else()
  set(qwt_BUILD_COMMAND "/usr/bin/make")
  set(qwt_ParallelBuild "-j${CoreCount}")
endif()


if(NX_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${qwt_VERSION}.tar.gz
    URL ${NX_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${qwt_VERSION}.tar.gz
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY "https://github.com/BlueQuartzSoftware/Qwt.git"
    GIT_PROGRESS 1
    GIT_TAG "origin/v${qwt_VERSION}"
  )
endif()

ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}

  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${qwt_VERSION}-${qt5_version_full}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${qwt_VERSION}-${qt5_version_full}/Stamp"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${qwt_VERSION}-${qt5_version_full}
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${qwt_VERSION}-${qt5_version_full}/Source/${extProjectName}-${qwt_VERSION}"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${qwt_VERSION}-${qt5_version_full}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${qwt_INSTALL}"

  CONFIGURE_COMMAND ${Qt5_QMAKE_EXECUTABLE} <SOURCE_DIR>/qwt.pro
  PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${qwtConfig_FILE} <SOURCE_DIR>/qwtconfig.pri
                COMMAND ${CMAKE_COMMAND} -E copy ${qwtSrcPro_FILE} <SOURCE_DIR>/src/src.pro
  BUILD_COMMAND ${qwt_BUILD_COMMAND} ${qwt_ParallelBuild}
  INSTALL_COMMAND ${qwt_BUILD_COMMAND} install

  # BUILD_IN_SOURCE 1
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
file(APPEND ${NX_SDK_FILE} "# Qwt ${qwt_VERSION} Library\n")
file(APPEND ${NX_SDK_FILE} "set(QWT_VERSION \"${qwt_VERSION}\" CACHE STRING \"\")\n")
file(APPEND ${NX_SDK_FILE} "set(QWT_INSTALL \"\${NX_SDK_ROOT}/${extProjectName}-\${QWT_VERSION}-${qt5_version_full}\" CACHE PATH \"\")\n")
