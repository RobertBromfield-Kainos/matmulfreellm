cmake_minimum_required(VERSION 3.12)
project(triton_C)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

include_directories(include)

add_library(_C SHARED
    # List all your source files here
    triton/Analysis/Alias.h
    triton/Analysis/Allocation.h
    # Add all other necessary source files
)

target_include_directories(_C PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
