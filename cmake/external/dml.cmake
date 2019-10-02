# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

if (NOT onnxruntime_USE_CUSTOM_DIRECTML)
  if (NOT(MSVC) OR NOT(WIN32))
    message(FATAL_ERROR "NuGet packages are only supported for MSVC on Windows.")
  endif()

  # Retrieve the latest version of nuget
  include(ExternalProject)
  ExternalProject_Add(nuget
    PREFIX nuget
    URL "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
    DOWNLOAD_NO_EXTRACT 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    UPDATE_COMMAND ""
    INSTALL_COMMAND "")

  set(PACKAGES_CONFIG ${PROJECT_SOURCE_DIR}/../packages.config)
  set(PACKAGES_DIR ${CMAKE_CURRENT_BINARY_DIR}/packages)

  # Restore nuget packages, which will pull down the DirectML redist package
  add_custom_command(
    OUTPUT restore_packages.stamp
    DEPENDS ${PROJECT_SOURCE_DIR}/../packages.config
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/nuget/src/nuget restore ${PACKAGES_CONFIG} -PackagesDirectory ${PACKAGES_DIR}
    COMMAND ${CMAKE_COMMAND} -E touch restore_packages.stamp
    VERBATIM)

  add_custom_target(RESTORE_PACKAGES ALL DEPENDS restore_packages.stamp)
  add_dependencies(RESTORE_PACKAGES nuget)

  link_libraries(${CMAKE_CURRENT_BINARY_DIR}/packages/DirectML.0.0.1/build/DirectML.targets)
else()
  include_directories(${dml_INCLUDE_DIR})
  link_directories(${dml_LIB_DIR})
endif()