cmake_minimum_required (VERSION 3.25)

project ("cpp-devcontainer-test")

# set global c++ standard to c++20
set(CMAKE_CXX_STANDARD 20)

# log base compiler info
message(STATUS "CMAKE_CXX_COMPILER='${CMAKE_CXX_COMPILER}'")
message(STATUS "CMAKE_CXX_COMPILER_ID='${CMAKE_CXX_COMPILER_ID}'")
message(STATUS "CMAKE_CXX_COMPILER_VERSION='${CMAKE_CXX_COMPILER_VERSION}'")
message(STATUS "CMAKE_COMPILER_IS_GNUCXX='${CMAKE_COMPILER_IS_GNUCXX}'")

add_executable(test main.cpp)

