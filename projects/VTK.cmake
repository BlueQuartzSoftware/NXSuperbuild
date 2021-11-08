#cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DQt5_DIR=/Users/Shared/NX_SDK/Qt5.10.1/5.10.1/clang_64/lib/cmake/Qt5 -DVTK_Group_Qt=ON -DVTK_QT_VERSION=5 -DModule_vtkGUISupportQtOpenGL=ON -DVTK_BUILD_QT_DESIGNER_PLUGIN=ON -DVTK_USE_SYSTEM_HDF5=ON -DHDF5_C_INCLUDE_DIR=/Users/Shared/NX_SDK/hdf5-1.8.20-Release/include -DHDF5_hdf5_LIBRARY_RELEASE=/Users/Shared/NX_SDK/hdf5-1.8.20-Release/lib/libhdf5.dylib -DHDF5_hdf5_hl_LIBRARY_RELEASE=/Users/Shared/NX_SDK/hdf5-1.8.20-Release/lib/libhdf5_hl.dylib  ../VTK-8.1.1



#cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug -DQt5_DIR=/Users/Shared/NX_SDK/Qt5.10.1/5.10.1/clang_64/lib/cmake/Qt5 -DVTK_Group_Qt=ON -DVTK_QT_VERSION=5 -DModule_vtkGUISupportQtOpenGL=ON -DVTK_BUILD_QT_DESIGNER_PLUGIN=ON -DVTK_USE_SYSTEM_HDF5=ON -DHDF5_C_INCLUDE_DIR=/Users/Shared/NX_SDK/hdf5-1.8.20-Debug/include -DHDF5_hdf5_LIBRARY_DEBUG=/Users/Shared/NX_SDK/hdf5-1.8.20-Debug/lib/libhdf5_debug.dylib -DHDF5_hdf5_hl_LIBRARY_DEBUG=/Users/Shared/NX_SDK/hdf5-1.8.20-Debug/lib/libhdf5_hl_debug.dylib  ../VTK-8.1.1



#--------------------------------------------------------------------------------------------------
# Are we building VTK (ON by default)
#--------------------------------------------------------------------------------------------------
OPTION(BUILD_VTK "Build VTK" ON)
if("${BUILD_VTK}" STREQUAL "OFF")
  return()
endif()

set(extProjectName "VTK")
set(VTK_GIT_TAG "v9.1.0")
set(VTK_VERSION "9.1.0")
set(VTK_VERSION_SHORT "9.1")

message(STATUS "Building: ${extProjectName} ${VTK_VERSION}: -DBUILD_VTK=${BUILD_VTK}" )

set(SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${VTK_VERSION}/Source/${extProjectName}")
set(BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}/Build-${CMAKE_BUILD_TYPE}")

if(WIN32)
  set(VTK_INSTALL "${NX_SDK}/${extProjectName}-${VTK_VERSION}")
else()
  set(VTK_INSTALL "${NX_SDK}/${extProjectName}-${VTK_VERSION}-${CMAKE_BUILD_TYPE}")
endif()

if( CMAKE_BUILD_TYPE MATCHES Debug )
  set(HDF5_SUFFIX "_debug")
  set(upper "DEBUG")
else()
  set(HDF5_SUFFIX "")
  set(upper "RELEASE")
endif( CMAKE_BUILD_TYPE MATCHES Debug )

set_property(DIRECTORY PROPERTY EP_BASE ${NX_SDK}/superbuild)
set(D3DSP_BASE_DIR "${NX_SDK}/superbuild/${extProjectName}-${VTK_VERSION}")


if(DREAM3D_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${VTK_VERSION}.zip
    URL ${DREAM3D_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${VTK_VERSION}.zip
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY "https://github.com/Kitware/VTK.git"
    GIT_PROGRESS 1
    GIT_TAG ${VTK_GIT_TAG}
  )
endif()

#------------------------------------------------------------------------------
# We are building Qt support into VTK so we need to know where our Qt installation is at
if("${Qt5_QMAKE_EXECUTABLE}" STREQUAL "")
  message(FATAL_ERROR "You have indicated that Qt5 is already installed. Please use -DQt5_QMAKE_EXECUTABLE=/path/to/qmake cmake variable to point to the location of the qmake(.exe) executable.")
  return()
endif()

if(NOT EXISTS "${Qt5_QMAKE_EXECUTABLE}")
  message(FATAL_ERROR "QMake does not exist at path '${Qt5_QMAKE_EXECUTABLE}'.\nPlease double check the path to qmake.\nUse the -DQt5_QMAKE_EXECUTABLE=/path/to/qmake to set the 'qmake(.exe)' executable")
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
message(STATUS "  VTK ${VTK_VERSION} USING: Qt ${qt5_version_full}: -DQt5_QMAKE_EXECUTABLE=${Qt5_QMAKE_EXECUTABLE}" )
set(Qt5_DIR "${QT_INSTALL_LIBS}/cmake/Qt5" CACHE PATH "")

#------------------------------------------------------------------------------
# In the below we are using 
ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}

  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${VTK_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${VTK_VERSION}/Stamp/${CMAKE_BUILD_TYPE}"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${VTK_VERSION}
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${VTK_VERSION}/Source/${extProjectName}"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${VTK_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${VTK_INSTALL}"
  
  CMAKE_ARGS
    -DBUILD_SHARED_LIBS:STRING=${BUILD_SHARED_LIBS}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DCMAKE_CXX_FLAGS=${CXX_FLAGS}

    -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT:PATH=${OSX_SDK}
    -DCMAKE_SKIP_INSTALL_RPATH:BOOL=${CMAKE_SKIP_INSTALL_RPATH}
    -DCMAKE_SKIP_RPATH:BOOL=${CMAKE_SKIP_RPATH}

    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_CXX_STANDARD:STRING=14
    -DCMAKE_CXX_STANDARD_REQUIRED:BOOL=ON
    -DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
    
    -DQt5_DIR=${Qt5_DIR}
    -DVTK_GROUP_ENABLE_Qt=YES
    -DVTK_MODULE_ENABLE_VTK_GUISupportQt=YES
    -DVTK_MODULE_ENABLE_VTK_GUISupportQtSQL=NO
    -DVTK_MODULE_ENABLE_VTK_RenderingQt=YES
    -DVTK_MODULE_ENABLE_VTK_ViewsQt=YES

    -DVTK_MODULE_ENABLE_VTK_hdf5=NO
    # -DVTK_USE_SYSTEM_HDF5=ON
    # -DHDF5_CMAKE_MODULE_DIR=${HDF5_INSTALL}/share/hdf5
    # -DHDF5_C_INCLUDE_DIR=${HDF5_INSTALL}/include
    # -DHDF5_hdf5_LIBRARY_DEBUG=${HDF5_INSTALL}/lib/libhdf5_debug.dylib
    # -DHDF5_hdf5_hl_LIBRARY_DEBUG=${HDF5_INSTALL}/lib/libhdf5_hl_debug.dylib
  
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
FILE(APPEND ${NX_SDK_FILE} "# VTK Library Location\n")
if(WIN32)
  FILE(APPEND ${NX_SDK_FILE} "set(VTK_DIR \"\${NX_SDK_ROOT}/VTK-${VTK_VERSION}\" CACHE PATH \"\")\n")
else()
  FILE(APPEND ${NX_SDK_FILE} "set(VTK_DIR \"\${NX_SDK_ROOT}/VTK-${VTK_VERSION}-\${BUILD_TYPE}/lib/cmake/vtk-${VTK_VERSION_SHORT}\" CACHE PATH \"\")\n")
endif()
FILE(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${VTK_DIR})\n")
FILE(APPEND ${NX_SDK_FILE} "set(VTK_VERSION \"${VTK_VERSION}\" CACHE STRING \"\")\n")

