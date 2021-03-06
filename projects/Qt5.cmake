#--------------------------------------------------------------------------------------------------
# Are we installing Qt (ON by default)
#--------------------------------------------------------------------------------------------------
OPTION(INSTALL_QT5 "Install Qt5" ON)

set(QtVersion "5.15")
set(Qt515 "1")

# ------------------------------------------------------------------------------
# Qt 5.15.x
set(qt5_version_major "5.15")
set(qt5_version_full "5.15.2")
set(qt5_version_short "5.15.2")
# This variable is used inside the javascript file that performs the Qt installation
set(qt5_installer_version "qt5.5152")


set(extProjectName "Qt${qt5_version_full}")

if("${INSTALL_QT5}" STREQUAL "OFF" AND "${Qt5_QMAKE_EXECUTABLE}" STREQUAL "")
  message(FATAL_ERROR "INSTALL_QT5=${INSTALL_QT5}\nYou have indicated that Qt5 is already installed. Please use -DQt5_QMAKE_EXECUTABLE=/path/to/qmake cmake variable to point to the location of the qmake(.exe) executable.")
  return()
endif()

if(NOT INSTALL_QT5 AND NOT "${Qt5_QMAKE_EXECUTABLE}" STREQUAL "")
  
  if(NOT EXISTS "${Qt5_QMAKE_EXECUTABLE}")
    message(FATAL_ERROR "QMake does not exist at path '${Qt5_QMAKE_EXECUTABLE}'. Please double check the path to qmake.")
  endif()

  execute_process(
    COMMAND "${Qt5_QMAKE_EXECUTABLE}" -query QT_VERSION
    OUTPUT_VARIABLE qt5_version_full
    RESULT_VARIABLE qmake_result
    OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_STRIP_TRAILING_WHITESPACE
  )

  execute_process(
    COMMAND "${Qt5_QMAKE_EXECUTABLE}" -query QT_INSTALL_LIBS
    OUTPUT_VARIABLE QT_INSTALL_LIBS
    OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_STRIP_TRAILING_WHITESPACE
  )

  set(extProjectName "Qt${qt5_version_full}")
  message(STATUS "Installed: Qt ${qt5_version_full}: -DQt5_QMAKE_EXECUTABLE=${Qt5_QMAKE_EXECUTABLE}" )

  FILE(APPEND ${NX_SDK_FILE} "\n")
  FILE(APPEND ${NX_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
  FILE(APPEND ${NX_SDK_FILE} "# Qt5 ${qt5_version_full} Library\n")
  FILE(APPEND ${NX_SDK_FILE} "set(Qt5_DIR \"${QT_INSTALL_LIBS}/cmake/Qt5\" CACHE PATH \"\")\n")
  FILE(APPEND ${NX_SDK_FILE} "set(Qt5QuickCompiler_DIR \"${QT_INSTALL_LIBS}/cmake/Qt5QuickCompiler\" CACHE PATH \"\")\n")
  FILE(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${Qt5_DIR})\n")
  return()
endif()

if("${INSTALL_QT5}")
  message(STATUS "Building: ${extProjectName} ${qt5_version_full}: -DINSTALL_QT5=${INSTALL_QT5}" )
endif()

set(qt5_INSTALL "${NX_SDK}/${extProjectName}${qt5_version_full}")
set(qt5_BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}/Build")

get_filename_component(_self_dir ${CMAKE_CURRENT_LIST_FILE} PATH)

set(QT_INSTALL_LOCATION "${NX_SDK}/${extProjectName}")

if(APPLE)
  set(qt5_Headless_FILE "apple/Qt_HeadlessInstall_OSX.js")
elseif(WIN32)
  set(qt5_Headless_FILE "win32/Qt_HeadlessInstall_Win64.js")
else()
  set(qt5_Headless_FILE "unix/Qt_HeadlessInstall.js")
endif()

set(QT_MSVC_VERSION_NAME "")
if(MSVC13)
   set(QT_MSVC_VERSION_NAME "msvc2013_64")
endif()
if(MSVC14)
  set(QT_MSVC_VERSION_NAME "msvc2015_64")
endif()
if(MSVC_VERSION GREATER 1900)
  set(QT_MSVC_VERSION_NAME "msvc2017_64")
endif()

set(JSFILE "${NX_SDK}/superbuild/${extProjectName}/Download/Qt_HeadlessInstall.js")
configure_file(
  "${_self_dir}/${qt5_Headless_FILE}"
  "${JSFILE}"
  @ONLY
)

if(NX_USE_CUSTOM_DOWNLOAD_SITE)
  set(qt5_url ${NX_CUSTOM_DOWNLOAD_URL_PREFIX}/qt)
else()
  set(qt5_url http://qt.mirror.constant.com/archive/qt)
endif()

if(APPLE)
  set(qt5_url "${qt5_url}/${qt5_version_major}/${qt5_version_short}/qt-opensource-mac-x64-${qt5_version_full}.dmg")

  set(Qt5_OSX_BASE_NAME qt-opensource-mac-x64-${qt5_version_full})

  set(Qt5_OSX_DMG_ABS_PATH "${NX_SDK}/superbuild/${extProjectName}/${Qt5_OSX_BASE_NAME}.dmg")
  set(Qt5_DMG ${Qt5_OSX_DMG_ABS_PATH})

  configure_file(
    "${_self_dir}/apple/Qt5_osx_install.sh.in"
    "${CMAKE_BINARY_DIR}/Qt5_osx_install.sh"
    @ONLY
  )


  if(NOT EXISTS "${Qt5_DMG}")
    message(STATUS "===============================================================")
    message(STATUS "    Downloading ${extProjectName} Offline Installer")
    message(STATUS "    ${qt5_url}")
    message(STATUS "    Large Download!! This can take a bit... Please be patient")
    file(DOWNLOAD ${qt5_url} "${Qt5_DMG}" SHOW_PROGRESS)
  endif()


  if(NOT EXISTS "${QT_INSTALL_LOCATION}/${qt5_version_short}/clang_64/bin/qmake")
    message(STATUS "    Running Qt5 Installer. A GUI Application will pop up on your machine.")
    message(STATUS "    This may take some time for the installer to start.")
    message(STATUS "    Please wait for the installer to finish.")
    execute_process(COMMAND "${CMAKE_BINARY_DIR}/Qt5_osx_install.sh"
                    OUTPUT_FILE "${NX_SDK}/superbuild/${extProjectName}/Download/Qt5-offline-out.log"
                    ERROR_FILE "${NX_SDK}/superbuild/${extProjectName}/Download/Qt5-offline-err.log"
                    ERROR_VARIABLE mount_error
                    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )

  endif()
  set(Qt5_QMAKE_EXECUTABLE ${QT_INSTALL_LOCATION}/${qt5_version_short}/clang_64/bin/qmake)

elseif(WIN32)
  set(qt5_online_installer "qt-opensource-windows-x86-${qt5_version_full}.exe")
  set(qt5_url "${qt5_url}/${qt5_version_major}/${qt5_version_short}/qt-opensource-windows-x86-${qt5_version_full}.exe")

  if(NOT EXISTS "${NX_SDK}/superbuild/${extProjectName}/Download/${qt5_online_installer}")
    message(STATUS "===============================================================")
    message(STATUS "   Downloading ${extProjectName}")
    message(STATUS "   Large Download!! This can take a bit... Please be patient")
    file(DOWNLOAD ${qt5_url} "${NX_SDK}/superbuild/${extProjectName}/Download/${qt5_online_installer}" SHOW_PROGRESS)
  endif()

  set(QT5_ONLINE_INSTALLER "${NX_SDK}/superbuild/${extProjectName}/Download/${qt5_online_installer}")
  configure_file(
    "${_self_dir}/win32/Qt_HeadlessInstall.bat"
    "${NX_SDK}/superbuild/${extProjectName}/Download/Qt_HeadlessInstall.bat"
    @ONLY
  )

  if(NOT EXISTS "${NX_SDK}/${extProjectName}")
    message(STATUS "Executing the Qt5 Installer... ")
    execute_process(COMMAND "${NX_SDK}/superbuild/${extProjectName}/Download/Qt_HeadlessInstall.bat"
                    OUTPUT_FILE "${NX_SDK}/superbuild/${extProjectName}/Download/qt-unified-out.log"
                    ERROR_FILE "${NX_SDK}/superbuild/${extProjectName}/Download/qt-unified-err.log"
                    ERROR_VARIABLE installer_error
                    WORKING_DIRECTORY ${qt5_BINARY_DIR} )
  endif()
  set(Qt5_QMAKE_EXECUTABLE ${QT_INSTALL_LOCATION}/${qt5_version_short}/${QT_MSVC_VERSION_NAME}/bin/qmake.exe)
else()
  set(qt5_online_installer "qt-opensource-linux-x64-${qt5_version_full}.run")
  set(qt5_url "${qt5_url}/${qt5_version_major}${qt5_version_short}/${qt5_online_installer}")

  if(NOT EXISTS "${NX_SDK}/superbuild/${extProjectName}/Download/${qt5_online_installer}")
    message(STATUS "===============================================================")
    message(STATUS "   Downloading ${extProjectName}")
    message(STATUS "   Large Download!! This can take a bit... Please be patient")
    file(DOWNLOAD ${qt5_url} "${NX_SDK}/superbuild/${extProjectName}/Download/${qt5_online_installer}" SHOW_PROGRESS)
  endif()

  set(QT5_ONLINE_INSTALLER "${NX_SDK}/superbuild/${extProjectName}/Download/${qt5_online_installer}")
  configure_file(
    "${_self_dir}/unix/Qt5_linux_install.sh.in"
    "${NX_SDK}/superbuild/${extProjectName}/Download/Qt_HeadlessInstall.sh"
  )

  if(NOT EXISTS "${NX_SDK}/${extProjectName}")
    message(STATUS "Executing the Qt5 Installer... ")
    execute_process(COMMAND "${NX_SDK}/superbuild/${extProjectName}/Download/Qt_HeadlessInstall.sh"
                    OUTPUT_FILE "${NX_SDK}/superbuild/${extProjectName}/Download/qt-unified-out.log"
                    ERROR_FILE "${NX_SDK}/superbuild/${extProjectName}/Download/qt-unified-err.log"
                    ERROR_VARIABLE installer_error
                    WORKING_DIRECTORY ${qt5_BINARY_DIR} )
  endif()

  set(Qt5_QMAKE_EXECUTABLE ${QT_INSTALL_LOCATION}/${qt5_version_short}/gcc_64/bin/qmake)
endif()


ExternalProject_Add(Qt5

  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}/Stamp/${CMAKE_BUILD_TYPE}"
  DOWNLOAD_DIR "${NX_SDK}/superbuild/${extProjectName}/Download"
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}/Source"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}/Build"
  INSTALL_DIR "${NX_SDK}/superbuild/${extProjectName}/Install"

  DOWNLOAD_COMMAND ""
  UPDATE_COMMAND ""
  PATCH_COMMAND ""
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  TEST_COMMAND ""
  )

#-- Append this information to the NX_SDK CMake file that helps other developers
#-- configure DREAM3D for building
FILE(APPEND ${NX_SDK_FILE} "\n")
FILE(APPEND ${NX_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
FILE(APPEND ${NX_SDK_FILE} "# Qt ${qt5_version_full} Library\n")
if(APPLE)
  FILE(APPEND ${NX_SDK_FILE} "set(Qt5_DIR \"\${NX_SDK_ROOT}/${extProjectName}/${qt5_version_short}/clang_64/lib/cmake/Qt5\" CACHE PATH \"\")\n")
  FILE(APPEND ${NX_SDK_FILE} "set(Qt5QuickCompiler_DIR \"\${NX_SDK_ROOT}/${extProjectName}/${qt5_version_short}/clang_64/lib/cmake/Qt5QuickCompiler\" CACHE PATH \"\")\n")
elseif(WIN32)
  FILE(APPEND ${NX_SDK_FILE} "set(Qt5_DIR \"\${NX_SDK_ROOT}/${extProjectName}/${qt5_version_short}/${QT_MSVC_VERSION_NAME}/lib/cmake/Qt5\" CACHE PATH \"\")\n")
else()
  FILE(APPEND ${NX_SDK_FILE} "set(Qt5_DIR \"\${NX_SDK_ROOT}/${extProjectName}/${qt5_version_short}/gcc_64/lib/cmake/Qt5\" CACHE PATH \"\")\n")
  FILE(APPEND ${NX_SDK_FILE} "set(Qt5QuickCompiler_DIR \"\${NX_SDK_ROOT}/${extProjectName}/${qt5_version_short}/gcc_64/lib/cmake/Qt5QuickCompiler\" CACHE PATH \"\")\n")
endif()
FILE(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${Qt5_DIR})\n")


