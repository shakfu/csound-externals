include(${CMAKE_CURRENT_SOURCE_DIR}/../../max-sdk-base/script/max-pretarget.cmake)

#############################################################
# csound~
#############################################################


# list(APPEND CMAKE_PREFIX_PATH
#     "/usr/local"
#     "/usr/opt"
#     "$ENV{HOME}/Library/Frameworks"
#     $<${HAS_HOMEBREW}:${HOMEBREW_PREFIX}>
# )

message(STATUS "CMAKE_PREFIX_PATH:  ${CMAKE_PREFIX_PATH}")

include_directories( 
    "${MAX_SDK_INCLUDES}"
    "${MAX_SDK_MSP_INCLUDES}"
    "${MAX_SDK_JIT_INCLUDES}"
)

set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(SCRIPTS_DIR ${CMAKE_SOURCE_DIR}/source/scripts)

set(PROJECT_SRC
    csound6~.c
)

set(PROJECT_HEADERS)

if(APPLE)
    message(STATUS "building on macOS")

    set(CMAKE_OSX_DEPLOYMENT_TARGET 10.13 CACHE STRING 
        "override default MACOS_DEPLOYMENT_TARGET" FORCE)

    if(BUILD_RELEASE)
        include(${SCRIPTS_DIR}/macos_release.cmake)

    else()
        include(${SCRIPTS_DIR}/macos_common.cmake)        

        if(BUILD_HYBRID)
            include(${SCRIPTS_DIR}/macos_hybrid.cmake)
        
        else()
            include(${SCRIPTS_DIR}/macos_local.cmake)
        
        endif()

    endif()

elseif(WIN32)
    message(STATUS "building on Windows")

    # added windows-specific source
    list(APPEND PROJECT_SRC ${SRC_DIR}/dllmain_win.c)

    include(${SCRIPTS_DIR}/windows_release.cmake)

else()
    message(FATAL_ERROR "can only build on macOS or windows")

endif()


include(${CMAKE_CURRENT_SOURCE_DIR}/../../max-sdk-base/script/max-posttarget.cmake)
