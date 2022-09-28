cmake_minimum_required(VERSION 3.16)

project(nod
  LANGUAGES CXX
  VERSION 0.5.2
)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

add_library(nod INTERFACE)

target_compile_features(nod INTERFACE cxx_std_11)

target_include_directories(nod
  INTERFACE
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

install(FILES ${CMAKE_CURRENT_LIST_DIR}/include/nod/nod.hpp
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/nod
)

set(CONFIG_NAME "${PROJECT_NAME}Config")

install(TARGETS nod EXPORT ${CONFIG_NAME})

set(CONFIG_INSTALL_DIR "${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}")

set(NAMESPACE nod::)

install(EXPORT ${CONFIG_NAME}
  NAMESPACE ${NAMESPACE}
  DESTINATION ${CONFIG_INSTALL_DIR}
)

set(CONFIG_VERSION_FILEPATH "${CMAKE_CURRENT_BINARY_DIR}/${CONFIG_NAME}Version.cmake")

write_basic_package_version_file("${CONFIG_VERSION_FILEPATH}"
  COMPATIBILITY ExactVersion
  ARCH_INDEPENDENT
)

install(FILES ${CONFIG_VERSION_FILEPATH}
  DESTINATION ${CONFIG_INSTALL_DIR}
)
