include(${CMAKE_CURRENT_SOURCE_DIR}/../../max-sdk-base/script/max-pretarget.cmake)
set(CMAKE_VERBOSE_MAKEFILE ON)

#############################################################
# MAX EXTERNAL
#############################################################
set(CMAKE_OSX_DEPLOYMENT_TARGET 10.13 CACHE STRING "force it" FORCE)

option(BUILD_RELOCATABLE OFF "builds relocatable macOS bundle")


if(NOT BUILD_RELOCATABLE)

    include_directories( 
      "${MAX_SDK_INCLUDES}"
      "${MAX_SDK_MSP_INCLUDES}"
      "${MAX_SDK_JIT_INCLUDES}"
    )


    file(GLOB PROJECT_SRC
       "*.h"
       "*.c"
       "*.cpp"
    )

    add_library( 
        ${PROJECT_NAME} 
        MODULE
        ${PROJECT_SRC}
    )

    # the below is not working on Mac for me so finding and specifying 
    # header and library explicitly
    # find_package(Csound)

    if(APPLE)
        find_path(CSOUND_HEADER_PATH csound.h)
        find_library(CSOUND_LIBRARY CsoundLib64)
    else()
        find_path(CSOUND_HEADER_PATH csound/csound.h)
        find_library(CSOUND_LIBRARY csound64.lib)
    endif()

    if(CSOUND_HEADER_PATH)
        MESSAGE("found csound header path: ${CSOUND_HEADER_PATH}")
    else()
        MESSAGE(FATAL_ERROR "could not find csound header path")
    endif()
        
    if(CSOUND_LIBRARY)
      MESSAGE("found csound library path: ${CSOUND_LIBRARY}")
    else()
      MESSAGE(FATAL_ERROR "could not find csound library path")
    endif()

    target_include_directories(${PROJECT_NAME}
        PUBLIC
        ${CSOUND_HEADER_PATH}
    )

    target_link_libraries(${PROJECT_NAME}
        PUBLIC
        ${CSOUND_LIBRARY}
    )

    else()

    set(DEPS ${CMAKE_BINARY_DIR}/deps)
    set(CSOUND_LIBRARY ${DEPS}/csound-build/libCsoundLib64.a)
    set(CSOUND_HEADER_PATH ${DEPS}/csound-build/CsoundLib64.framework/Headers)
    set(EXTERNAL_PATH {CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${PROJECT_NAME}.mxo)

    MESSAGE("CSOUND_HEADER_PATH: ${CSOUND_HEADER_PATH}")

    include_directories( 
      "${MAX_SDK_INCLUDES}"
      "${MAX_SDK_MSP_INCLUDES}"
      "${MAX_SDK_JIT_INCLUDES}"
      "${CSOUND_HEADER_PATH}"
    )

    file(GLOB PROJECT_SRC
       "*.h"
       "*.c"
       "*.cpp"
    )

    add_library( 
        ${PROJECT_NAME} 
        MODULE
        ${PROJECT_SRC}
    )

    target_include_directories(${PROJECT_NAME}
        PUBLIC
        ${CSOUND_HEADER_PATH}
        $<${HAS_HOMEBREW}:${HOMEBREW_PREFIX}>/include
    )

    target_link_directories(${PROJECT_NAME}
        PUBLIC
        $<${HAS_HOMEBREW}:${HOMEBREW_PREFIX}>/lib
        # /usr/local/lib
    )

    target_link_libraries(${PROJECT_NAME}
        PUBLIC
        ${CSOUND_LIBRARY}
        ${DEPS/libcsnd6.a}
        -lsndfile
        -lcurl
        "-framework Accelerate"
    )

endif()


include(${CMAKE_CURRENT_SOURCE_DIR}/../../max-sdk-base/script/max-posttarget.cmake)
