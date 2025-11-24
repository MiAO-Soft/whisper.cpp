set(TARGET whisper-websocket-stream)
add_executable(${TARGET} main.cpp whisper-server.cpp message-buffer.cpp)

find_package(CURL REQUIRED)
include(DefaultTargetOptions)

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(IXWEBSOCKET_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/libs/linux")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")  # macOS
    set(IXWEBSOCKET_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/libs/macos")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(IXWEBSOCKET_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/libs/windows")
else()
    message(FATAL_ERROR "Unsupported system: ${CMAKE_SYSTEM_NAME}")
endif()

if(MSVC)
    set(IXWEBSOCKET_STATIC_LIB "${IXWEBSOCKET_LIB_DIR}/ixwebsocket.lib")
else()
    set(IXWEBSOCKET_STATIC_LIB "${IXWEBSOCKET_LIB_DIR}/libixwebsocket.a")
endif()

if(NOT EXISTS ${IXWEBSOCKET_STATIC_LIB})
    message(FATAL_ERROR "ixwebsocket static library not found at: ${IXWEBSOCKET_STATIC_LIB}")
endif()

target_include_directories(${TARGET} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

set(COMMON_LIBS
    common
    whisper
    ${IXWEBSOCKET_STATIC_LIB}
    z
    CURL::libcurl
    ${CMAKE_THREAD_LIBS_INIT}
    ssl
    crypto
)

if(NOT WIN32)
    list(APPEND COMMON_LIBS dl)
else()
    list(APPEND COMMON_LIBS ws2_32)
endif()

target_link_libraries(${TARGET} PRIVATE ${COMMON_LIBS})