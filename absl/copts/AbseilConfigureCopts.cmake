# See absl/copts/copts.py and absl/copts/generate_copts.py
include(GENERATED_AbseilCopts)

set(ABSL_LSAN_LINKOPTS "")
set(ABSL_HAVE_LSAN OFF)
set(ABSL_DEFAULT_LINKOPTS "")

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
  set(ABSL_DEFAULT_COPTS "${ABSL_GCC_FLAGS}")
  set(ABSL_TEST_COPTS "${ABSL_GCC_FLAGS};${ABSL_GCC_TEST_FLAGS}")
  # Set HWAES flags for appropriate target system
  if (CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
    set(ABSL_RANDOM_RANDEN_COPTS "${ABSL_RANDOM_HWAES_X64_FLAGS}")
  elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64")
    set(ABSL_RANDOM_RANDEN_COPTS "${ABSL_RANDOM_HWAES_ARM64_FLAGS}")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "armeabi") # Not sure if it better to just match "armeabi-7a"
    set(ABSL_RANDOM_RANDEN_COPTS "${ABSL_RANDOM_HWAES_ARM32_FLAGS}")
  endif()
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
  # MATCHES so we get both Clang and AppleClang
  if(MSVC)
    # clang-cl is half MSVC, half LLVM
    set(ABSL_DEFAULT_COPTS "${ABSL_CLANG_CL_FLAGS}")
    set(ABSL_TEST_COPTS "${ABSL_CLANG_CL_FLAGS};${ABSL_CLANG_CL_TEST_FLAGS}")
    set(ABSL_DEFAULT_LINKOPTS "${ABSL_MSVC_LINKOPTS}")
    set(ABSL_RANDOM_RANDEN_COPTS "${ABSL_RANDOM_HWAES_MSVC_X64_FLAGS}")
  else()
    set(ABSL_DEFAULT_COPTS "${ABSL_LLVM_FLAGS}")
    set(ABSL_TEST_COPTS "${ABSL_LLVM_FLAGS};${ABSL_LLVM_TEST_FLAGS}")
    set(ABSL_RANDOM_RANDEN_COPTS "${ABSL_RANDOM_HWAES_X64_FLAGS}")
    if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
      # AppleClang doesn't have lsan
      # https://developer.apple.com/documentation/code_diagnostics
      if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.5)
        set(ABSL_LSAN_LINKOPTS "-fsanitize=leak")
        set(ABSL_HAVE_LSAN ON)
      endif()
    endif()
  endif()
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
  set(ABSL_DEFAULT_COPTS "${ABSL_MSVC_FLAGS}")
  set(ABSL_TEST_COPTS "${ABSL_MSVC_FLAGS};${ABSL_MSVC_TEST_FLAGS}")
  set(ABSL_DEFAULT_LINKOPTS "${ABSL_MSVC_LINKOPTS}")
  set(ABSL_RANDOM_RANDEN_COPTS "${ABSL_RANDOM_HWAES_MSVC_X64_FLAGS}")
else()
  message(WARNING "Unknown compiler: ${CMAKE_CXX_COMPILER}.  Building with no default flags")
  set(ABSL_DEFAULT_COPTS "")
  set(ABSL_TEST_COPTS "")
  set(ABSL_RANDOM_RANDEN_COPTS "")
endif()

if("${CMAKE_CXX_STANDARD}" EQUAL 98)
  message(FATAL_ERROR "Abseil requires at least C++11")
elseif(NOT "${CMAKE_CXX_STANDARD}")
  message(STATUS "No CMAKE_CXX_STANDARD set, assuming 11")
  set(ABSL_CXX_STANDARD 11)
else()
  set(ABSL_CXX_STANDARD "${CMAKE_CXX_STANDARD}")
endif()
