include(${CMAKE_CURRENT_SOURCE_DIR}/../../max-sdk-base/script/max-pretarget.cmake)

#############################################################
# MAX EXTERNAL
#############################################################

option(BUILD_RELOCATABLE OFF "builds relocatable macOS bundle")

include_directories( 
    "${MAX_SDK_INCLUDES}"
    "${MAX_SDK_MSP_INCLUDES}"
    "${MAX_SDK_JIT_INCLUDES}"
)

set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)

set(PROJECT_SRC
    ${SRC_DIR}/Args.cpp
    ${SRC_DIR}/atom_buffer.cpp
    ${SRC_DIR}/channel.cpp
    ${SRC_DIR}/CsoundObject.cpp
    ${SRC_DIR}/CsoundTable.cpp
    ${SRC_DIR}/csound~.cpp
    ${SRC_DIR}/Lock.cpp
    ${SRC_DIR}/memory.cpp
    ${SRC_DIR}/message_buffer.cpp
    ${SRC_DIR}/midi.cpp
    ${SRC_DIR}/PatchScripter.cpp
    ${SRC_DIR}/sequencer.cpp
    ${SRC_DIR}/util.cpp
)

set(PROJECT_HEADERS
    ${SRC_DIR}/Args.h
    ${SRC_DIR}/CsoundObject.h
    ${SRC_DIR}/CsoundTable.h
    ${SRC_DIR}/Lock.h
    ${SRC_DIR}/Parser.h
    ${SRC_DIR}/PatchScripter.h
    ${SRC_DIR}/atom_buffer.h
    ${SRC_DIR}/channel.h
    ${SRC_DIR}/csound~.h
    ${SRC_DIR}/definitions.h
    ${SRC_DIR}/eksepshun.h
    ${SRC_DIR}/includes.h
    ${SRC_DIR}/max_headers.h
    ${SRC_DIR}/memory.h
    ${SRC_DIR}/message_buffer.h
    ${SRC_DIR}/midi.h
    ${SRC_DIR}/sequencer.h
    ${SRC_DIR}/util.h
)

# set(CMAKE_CXX_STANDARD 11)


if(NOT BUILD_RELOCATABLE)
# --------------------------------------------------------------------
# Local or Non-Relocatable build

    find_library(CORE_SERVICES_FRAMEWORK CoreServices)
    find_library(LAUNCH_SERVICES_FRAMEWORK LaunchServices PATHS ${CORE_SERVICES_FRAMEWORK}/Frameworks)
    find_library(LIBSNDFILE libsndfile.dylib 
        PATHS 
        ${MAX_INCLUDES_DIR}
        $<${HAS_HOMEBREW}:${HOMEBREW_PREFIX}>
    )

    if (LIBSNDFILE)
        MESSAGE("found libsndfile library: ${LIBSNDFILE}")
    else()
        MESSAGE(FATAL_ERROR "could not find libsndfile library")
    endif()

    add_library( 
        ${PROJECT_NAME} 
        MODULE
        ${PROJECT_SRC}
        ${PROJECT_HEADERS}
    )

    # the below is not working on Mac for me so finding and specifying 
    # header and library explicitly
    find_package(Csound)

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
        ${SRC_DIR}
        ${CSOUND_HEADER_PATH}
        ${CORE_SERVICES_FRAMEWORK}/Frameworks/CarbonCore.framework/Headers
        ${LAUNCH_SERVICES_FRAMEWORK}/Headers
        $<${HAS_HOMEBREW}:${HOMEBREW_PREFIX}/include>
    )

    target_compile_definitions(${PROJECT_NAME}
        PUBLIC
        MACOSX
    )

    target_link_directories(${PROJECT_NAME}
        PUBLIC
        ${CORE_SERVICES_FRAMEWORK}
        $<${HAS_HOMEBREW}:${HOMEBREW_PREFIX}/lib>
    )

    # set_target_properties(${PROJECT_NAME} PROPERTIES FRAMEWORK YES)

    target_link_libraries(${PROJECT_NAME}
        PUBLIC
        ${CSOUND_LIBRARY}
        ${LIBSNDFILE}
        # -lsndfile
        "-framework CoreFoundation"
        "-framework CoreServices"
    )

else()
# --------------------------------------------------------------------
# Relocatable

    set(DEPS ${CMAKE_BINARY_DIR}/deps)
    set(CSOUND_LIBRARY ${DEPS}/csound-build/libCsoundLib64.a)
    set(CSOUND_HEADER_PATH ${DEPS}/csound-build/CsoundLib64.framework/Headers)
    set(EXTERNAL_PATH {CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${PROJECT_NAME}.mxo)

    MESSAGE("CSOUND_HEADER_PATH: ${CSOUND_HEADER_PATH}")

    add_library( 
        ${PROJECT_NAME} 
        MODULE
        ${PROJECT_SRC}
        ${PROJECT_HEADERS}
    )

    target_include_directories(${PROJECT_NAME}
        PUBLIC
        ${SRC_DIR}
        ${CSOUND_HEADER_PATH}
        ${CORE_SERVICES_FRAMEWORK}/Frameworks/CarbonCore.framework/Headers
        ${LAUNCH_SERVICES_FRAMEWORK}/Headers
        $<${HAS_HOMEBREW}:${HOMEBREW_PREFIX}/include>
    )


    target_compile_definitions(${PROJECT_NAME}
        PUBLIC
        MACOSX
    )

    target_link_directories(${PROJECT_NAME}
        PUBLIC
        ${CORE_SERVICES_FRAMEWORK}
        $<${HAS_HOMEBREW}:${HOMEBREW_PREFIX}/lib>
    )

    # set_target_properties(${PROJECT_NAME} PROPERTIES FRAMEWORK YES)

    target_link_libraries(${PROJECT_NAME}
        PUBLIC
        ${CSOUND_LIBRARY}
        ${DEPS/libcsnd6.a}
        # ${LIBSNDFILE}
        -lsndfile
        -lcurl
        "-framework CoreFoundation"
        "-framework CoreServices"
        "-framework Accelerate"
    )

endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/../../max-sdk-base/script/max-posttarget.cmake)
