project(zhasher)
cmake_minimum_required(VERSION 3.5)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11") #  -Wall

## Enable solvers here
#### older slower
option(USE_CPU_TROMP "USE CPU_TROMP" OFF)
option(USE_CUDA_TROMP "USE CUDA_TROMP" ON)
#### faster
option(USE_CPU_XENONCAT "USE CPU_XENONCAT" OFF)
option(USE_CUDA_DJEZO "USE CUDA_DJEZO" OFF)

## Add solvers here
if (USE_CPU_TROMP)
    add_definitions(-DUSE_CPU_TROMP)
    message("-- USE_CPU_TROMP DEFINED")
endif()
if (USE_CPU_XENONCAT)
    add_definitions(-DUSE_CPU_XENONCAT)
    message("-- USE_CPU_XENONCAT DEFINED")
endif()
if (USE_CUDA_TROMP)
    add_definitions(-DUSE_CUDA_TROMP)
    message("-- USE_CUDA_TROMP DEFINED")
endif()
if (USE_CUDA_DJEZO)
    add_definitions(-DUSE_CUDA_DJEZO)
    message("-- USE_CUDA_DJEZO DEFINED")
endif()


########
# LINUX
if(CMAKE_COMPILER_IS_GNUCXX)
#    # use native cpu features
#    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=native -fPIC")
#    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native -fPIC")

#    # optimizations
#    add_definitions(-O3)

    # use
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m64 -msse2")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -m64 -msse2")
    # optimizations
    add_definitions(-O2)
endif()

# Common
include_directories(${zhasher_SOURCE_DIR}/zhasher)

# BOOST
#find_package(Threads REQUIRED COMPONENTS)
# compile boost staticaly
set(Boost_USE_STATIC_LIBS ON)
set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
#set(BUILD_SHARED_LIBRARIES OFF)
#set(CMAKE_EXE_LINKER_FLAGS "-static-libgcc -static-libstdc++ -static")
find_package(Boost REQUIRED COMPONENTS system log_setup log date_time filesystem thread)

if (Boost_FOUND)
  # From the offical documentation:
  # Add include directories to the build. [...] If the SYSTEM option is given,
  # the compiler will be told the directories are meant as system include
  # directories on some platforms (signalling this setting might achieve effects
  # such as the compiler skipping warnings [...])."
  include_directories (SYSTEM ${Boost_INCLUDE_DIR})

  # From the offical documentation:
  # "Specify directories in which the linker will look for libraries. [...] Note
  # that this command is rarely necessary. Library locations returned by
  # find_package() and find_library() are absolute paths. Pass these absolute
  # library file paths directly to the target_link_libraries() command. CMake
  # will ensure the linker finds them."
  link_directories (${Boost_LIBRARY_DIRS})
else()
    message("Boost_FOUND NOT FOUND")
endif ()

include_directories(${CMAKE_CURRENT_BINARY_DIR}/../)

set(SOURCE_FILES
    # sources
    zhasher/amount.cpp
    zhasher/api.cpp
    zhasher/arith_uint256.cpp
    zhasher/crypto/sha256.cpp
    zhasher/json/json_spirit_reader.cpp
    zhasher/json/json_spirit_value.cpp
    zhasher/json/json_spirit_writer.cpp
    zhasher/libstratum/ZcashStratum.cpp
    zhasher/main.cpp
    zhasher/primitives/block.cpp
    zhasher/speed.cpp
    zhasher/uint256.cpp
    zhasher/utilstrencodings.cpp
    # headers
    zhasher/amount.h
    zhasher/api.hpp
    zhasher/arith_uint256.h
    zhasher/crypto/sha256.h
    zhasher/hash.h
    zhasher/json/json_spirit.h
    zhasher/json/json_spirit_error_position.h
    zhasher/json/json_spirit_reader.h
    zhasher/json/json_spirit_reader_template.h
    zhasher/json/json_spirit_stream_reader.h
    zhasher/json/json_spirit_utils.h
    zhasher/json/json_spirit_value.h
    zhasher/json/json_spirit_writer.h
    zhasher/json/json_spirit_writer_template.h
    zhasher/libstratum/StratumClient.cpp
    zhasher/libstratum/StratumClient.h
    zhasher/libstratum/ZcashStratum.cpp
    zhasher/libstratum/ZcashStratum.h
    zhasher/primitives/block.h
    zhasher/primitives/transaction.h
    zhasher/script/script.h
    zhasher/serialize.h
    zhasher/speed.hpp
    zhasher/streams.h
    zhasher/support/allocators/zeroafterfree.h
    zhasher/tinyformat.h
    zhasher/uint252.h
    zhasher/uint256.h
    zhasher/utilstrencodings.h
    zhasher/version.h
    zhasher/zcash/JoinSplit.hpp
    zhasher/zcash/NoteEncryption.hpp
    zhasher/zcash/Proof.hpp
    zhasher/zcash/Zcash.h
    zhasher/SolverStub.h # just a stub

    zhasher/AvailableSolvers.h
    zhasher/ISolver.h
    zhasher/Solver.h
    zhasher/MinerFactory.h
    zhasher/MinerFactory.cpp

    # make same path on windows
    #blake shared
    # src
    blake2/blake2bx.cpp
    # headers
    blake2/blake2.h
    blake2/blake2b-load-sse2.h
    blake2/blake2b-load-sse41.h
    blake2/blake2b-round.h
    blake2/blake2-config.h
    blake2/blake2-impl.h
    blake2/blake2-round.h
    )

#set(LIBS ${LIBS} ${Threads_LIBRARIES} ${Boost_LIBRARIES})
set(LIBS ${LIBS} ${Boost_LIBRARIES})

message("-- CXXFLAGS: ${CMAKE_CXX_FLAGS}")
message("-- LIBS: ${LIBS}")

if (USE_CPU_TROMP)
    add_subdirectory(cpu_tromp)
endif()
if (USE_CPU_XENONCAT)
    add_subdirectory(cpu_xenoncat)
endif()
if (USE_CUDA_TROMP)
    add_subdirectory(cuda_tromp)
endif()
if (USE_CUDA_DJEZO)
    add_subdirectory(cuda_djezo)
endif()

#add_subdirectory(cpu_xenoncat)

ADD_EXECUTABLE(${PROJECT_NAME} ${SOURCE_FILES})

#target_link_libraries(${PROJECT_NAME} ${LIBS} ${CUDA_LIBRARIES} )
target_link_libraries(${PROJECT_NAME} ${CMAKE_THREAD_LIBS_INIT} ${LIBS} )

# link libs
if (USE_CPU_TROMP)
    target_link_libraries(${PROJECT_NAME} cpu_tromp)
endif()
if (USE_CPU_XENONCAT)
    add_library ( xenoncat_avx1 SHARED IMPORTED GLOBAL )
    set_target_properties ( xenoncat_avx1 PROPERTIES IMPORTED_LOCATION "../zhasher/cpu_xenoncat/asm_linux/equihash_avx1.o" )
    add_library ( xenoncat_avx2 SHARED IMPORTED GLOBAL )
    set_target_properties ( xenoncat_avx2 PROPERTIES IMPORTED_LOCATION "../zhasher/cpu_xenoncat/asm_linux/equihash_avx2.o" )
    target_link_libraries(${PROJECT_NAME} cpu_xenoncat xenoncat_avx1 xenoncat_avx2)
endif()
if (USE_CUDA_TROMP)
    target_link_libraries(${PROJECT_NAME} cuda_tromp)
endif()
if (USE_CUDA_DJEZO)
    target_link_libraries(${PROJECT_NAME} cuda_djezo)
endif()
