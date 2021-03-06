#--------------------------------------------------------------------------------------------------
# Are we building Discount (ON by default)
#--------------------------------------------------------------------------------------------------
OPTION(BUILD_DISCOUNT "Build Discount" ON)
if("${BUILD_DISCOUNT}" STREQUAL "OFF")
  return()
endif()

set(extProjectName "discount")
set(discount_VERSION "2.2.3")
message(STATUS "Building: ${extProjectName} ${discount_VERSION}: -DBUILD_DISCOUNT=${BUILD_DISCOUNT}" )

if(WIN32)
  set(discount_INSTALL "${NX_SDK}/${extProjectName}-${discount_VERSION}")
else()
  set(discount_INSTALL "${NX_SDK}/${extProjectName}-${discount_VERSION}-${CMAKE_BUILD_TYPE}")
endif()

if(NX_USE_CUSTOM_DOWNLOAD_SITE)
  set(EP_SOURCE_ARGS  
    DOWNLOAD_NAME ${extProjectName}-${discount_VERSION}.tar.gz
    URL ${NX_CUSTOM_DOWNLOAD_URL_PREFIX}${extProjectName}-${discount_VERSION}.tar.gz
  )
else()
  set(EP_SOURCE_ARGS  
    GIT_REPOSITORY "https://github.com/BlueQuartzSoftware/discount.git"
    GIT_PROGRESS 1
  )
endif()


ExternalProject_Add(${extProjectName}
  ${EP_SOURCE_ARGS}
  TMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${discount_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${NX_SDK}/superbuild/${extProjectName}-${discount_VERSION}/Stamp"
  DOWNLOAD_DIR ${NX_SDK}/superbuild/${extProjectName}-${discount_VERSION}/Download
  SOURCE_DIR "${NX_SDK}/superbuild/${extProjectName}-${discount_VERSION}/Source"
  BINARY_DIR "${NX_SDK}/superbuild/${extProjectName}-${discount_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${discount_INSTALL}"

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
    -DBUILD_SHARED_LIBS=OFF 
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
FILE(APPEND ${NX_SDK_FILE} "\n")
FILE(APPEND ${NX_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
FILE(APPEND ${NX_SDK_FILE} "# Discount\n")
if(APPLE)
  FILE(APPEND ${NX_SDK_FILE} "set(discount_DIR \"\${NX_SDK_ROOT}/${extProjectName}-${discount_VERSION}-\${BUILD_TYPE}/lib/cmake/${extProjectName}\" CACHE PATH \"\")\n")
elseif(WIN32)
  FILE(APPEND ${NX_SDK_FILE} "set(discount_DIR \"\${NX_SDK_ROOT}/${extProjectName}-${discount_VERSION}/lib/cmake/${extProjectName}\" CACHE PATH \"\")\n")
else()
  FILE(APPEND ${NX_SDK_FILE} "set(discount_DIR \"\${NX_SDK_ROOT}/${extProjectName}-${discount_VERSION}-\${BUILD_TYPE}/lib/cmake/${extProjectName}\" CACHE PATH \"\")\n")
endif()
FILE(APPEND ${NX_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${discount_DIR})\n")
FILE(APPEND ${NX_SDK_FILE} "set(discount_VERSION \"${discount_VERSION}\" CACHE STRING \"\")\n")
