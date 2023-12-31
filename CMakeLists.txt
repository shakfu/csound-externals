cmake_minimum_required(VERSION 3.19)

string(REGEX REPLACE "(.*)/" "" THIS_FOLDER_NAME "${CMAKE_CURRENT_SOURCE_DIR}")
project(${THIS_FOLDER_NAME})

option(BUILD_UNIVERSAL "Build Universal Externals for macOS")
option(BUILD_HYBRID "Build relocatable hybrid macOS bundle")
option(BUILD_RELEASE "Build relocatable static macos bundle using vcpkg")

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_CXX_FLAGS "-Wall -Wextra")
set(CMAKE_CXX_FLAGS_DEBUG "-g")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

# use ccache if available
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    message(STATUS "Found ccache in ${CCACHE_PROGRAM}")
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CCACHE_PROGRAM}")
endif()

if (APPLE)
    if (${CMAKE_GENERATOR} MATCHES "Xcode")
            if (${XCODE_VERSION} VERSION_LESS 10)
                message(STATUS "Xcode 10 or higher is required. Please install from the Mac App Store.")
                return ()
            endif ()
    endif ()

    if (NOT CMAKE_OSX_ARCHITECTURES)
        if(BUILD_UNIVERSAL)
            set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "macOS architecture" FORCE)
        else()
            set(CMAKE_OSX_ARCHITECTURES ${CMAKE_SYSTEM_PROCESSOR} CACHE STRING "macOS architecture" FORCE)
        endif()
        message("CMAKE_OSX_ARCHITECTURES set to ${CMAKE_OSX_ARCHITECTURES}")
    endif()

    # if homebrew is available get prefix
    execute_process(
        COMMAND brew --prefix
        OUTPUT_VARIABLE HOMEBREW_PREFIX
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(DEFINED HOMEBREW_PREFIX)
        set(HAS_HOMEBREW 1)
    endif()
endif()

MACRO(SUBDIRLIST result curdir)
  FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
  SET(dirlist "")
  FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child})
        LIST(APPEND dirlist ${child})
    ENDIF()
  ENDFOREACH()
  SET(${result} ${dirlist})
ENDMACRO()

# Generate a project for every folder in the "source/category" folder
SUBDIRLIST(CATEGORY_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/source)
foreach (cat_dir ${CATEGORY_DIRS})
  SUBDIRLIST(PROJECT_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/source/${cat_dir})
  foreach (project_dir ${PROJECT_DIRS})
    set(project_path ${CMAKE_CURRENT_SOURCE_DIR}/source/${cat_dir}/${project_dir})
    message("checking in: ${project_path}")
    if (EXISTS "${project_path}/CMakeLists.txt")
      message("Generating: ${project_dir}")
      add_subdirectory(${project_path})
    endif ()
  endforeach ()
endforeach ()


