cmake_minimum_required(VERSION 3.11)
include(ExternalProject)

project(emacs-libvterm C)

if(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD" OR CMAKE_SYSTEM_NAME STREQUAL "OpenBSD" OR CMAKE_SYSTEM_NAME STREQUAL "NetBSD")
   set(LIBVTERM_BUILD_COMMAND "gmake")
else()
   set(LIBVTERM_BUILD_COMMAND "make")
endif()

add_library(vterm-module MODULE vterm-module.c utf8.c elisp.c)
set_target_properties(vterm-module PROPERTIES
  C_STANDARD 99
  C_VISIBILITY_PRESET "hidden"
  POSITION_INDEPENDENT_CODE ON
  PREFIX ""
  LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}
  )

# Set RelWithDebInfo as default build type
if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "No build type selected, defaulting to RelWithDebInfo")
  set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Build type (default RelWithDebInfo)" FORCE)
endif()

# Look for the header file.
option(USE_SYSTEM_LIBVTERM "Use system libvterm instead of the vendored version." ON)

# Try to find the libvterm in system.
if (USE_SYSTEM_LIBVTERM)
  # try to find the vterm.h header file.
  find_path(LIBVTERM_INCLUDE_DIR
    NAMES vterm.h
    )

  # vterm.h is found.
  if (LIBVTERM_INCLUDE_DIR)
    message(STATUS "System libvterm detected")
    execute_process(COMMAND  grep -c "VTermStringFragment" "${LIBVTERM_INCLUDE_DIR}/vterm.h" OUTPUT_VARIABLE VTermStringFragmentExists)
    if (${VTermStringFragmentExists} EQUAL "0")
#    add_compile_definitions(VTermStringFragmentNotExists)
    add_definitions(-DVTermStringFragmentNotExists)
    endif()
    execute_process(COMMAND  grep -c "VTermSelectionMask" "${LIBVTERM_INCLUDE_DIR}/vterm.h" OUTPUT_VARIABLE VTermSelectionMaskExists)
    if (${VTermSelectionMaskExists} EQUAL "0")
#    add_compile_definitions(VTermStringFragmentNotExists)
    add_definitions(-DVTermSelectionMaskNotExists)
    endif()
    execute_process(COMMAND  grep -c "sb_clear" "${LIBVTERM_INCLUDE_DIR}/vterm.h" OUTPUT_VARIABLE VTermSBClearExists)
    if (${VTermSBClearExists} EQUAL "0")
      add_definitions(-DVTermSBClearNotExists)
    endif()
    execute_process(COMMAND  grep -c "vterm_screen_enable_reflow" "${LIBVTERM_INCLUDE_DIR}/vterm.h" OUTPUT_VARIABLE VTermEnableReflowExists)
    if (${VTermEnableReflowExists} EQUAL "0")
      message(WARNING "System libvterm too old, reflow not supported")
      add_definitions(-DVTermEnableReflowNotExists)
    endif()
    execute_process(COMMAND  grep -c "sb_pushline4" "${LIBVTERM_INCLUDE_DIR}/vterm.h" OUTPUT_VARIABLE VTermPushline4Exists)
    if (${VTermPushline4Exists} EQUAL "0")
      message(WARNING "System libvterm too old, sb_pushline4 not supported")
      add_definitions(-DVTermPushline4NotExists)
    endif()
    execute_process(COMMAND  grep -c "sb_popline4" "${LIBVTERM_INCLUDE_DIR}/vterm.h" OUTPUT_VARIABLE VTermPopline4Exists)
    if (${VTermPopline4Exists} EQUAL "0")
      message(WARNING "System libvterm too old, sb_popline4 not supported")
      add_definitions(-DVTermPopline4NotExists)
    endif()
  else()
    message(STATUS "System libvterm not found: libvterm will be downloaded and compiled as part of the build process")
  endif()
endif()

if (LIBVTERM_INCLUDE_DIR)
  find_library(LIBVTERM_LIBRARY NAMES
    vterm
    libvterm
    )

  if(NOT LIBVTERM_LIBRARY)
    message(FATAL_ERROR "libvterm not found")
  endif()
else()
  find_program(LIBTOOL NAMES libtool glibtool)
  if(NOT LIBTOOL)
    message(FATAL_ERROR "libtool not found. Please install libtool")
  endif()

  # ExternalProject_add(libvterm
  #   # GIT_REPOSITORY https://github.com/jixiuf/libvterm.git
  #   GIT_REPOSITORY file:///home/jixiuf/repos/libvterm/.git
  #   GIT_TAG fork
  #   CONFIGURE_COMMAND ""
  #   BUILD_COMMAND ${LIBVTERM_BUILD_COMMAND} "CFLAGS='-fPIC'" "LDFLAGS='-static'"
  #   BUILD_IN_SOURCE ON
  #   INSTALL_COMMAND "")

ExternalProject_Add(libvterm
    SOURCE_DIR          /home/jixiuf/repos/libvterm
    DOWNLOAD_COMMAND    ""
    UPDATE_COMMAND      ""
    
    # 强制每次构建
    BUILD_ALWAYS        ON
    BUILD_IN_SOURCE     ON
    
    CONFIGURE_COMMAND   ""
    # 将 CFLAGS 作为环境变量传递，并确保传递给 make
    BUILD_COMMAND       ${CMAKE_COMMAND} -E env CFLAGS=-fPIC LDFLAGS=-static ${LIBVTERM_BUILD_COMMAND}
    
    INSTALL_COMMAND     ""
)
  ExternalProject_Get_property(libvterm SOURCE_DIR)

  set(LIBVTERM_INCLUDE_DIR ${SOURCE_DIR}/include)
  set(LIBVTERM_LIBRARY ${SOURCE_DIR}/.libs/libvterm.a)

  add_dependencies(vterm-module libvterm)

  # Workaround for https://gitlab.kitware.com/cmake/cmake/issues/15052
  file(MAKE_DIRECTORY ${LIBVTERM_INCLUDE_DIR})
endif()

add_library(vterm STATIC IMPORTED)
set_target_properties(vterm PROPERTIES IMPORTED_LOCATION ${LIBVTERM_LIBRARY})
target_include_directories(vterm INTERFACE ${LIBVTERM_INCLUDE_DIR})

# Link with libvterm
target_link_libraries(vterm-module PUBLIC vterm)

# Custom run command for testing
add_custom_target(run
  COMMAND emacs -Q -L ${CMAKE_SOURCE_DIR} -L ${CMAKE_BINARY_DIR} --eval "\\(require \\'vterm\\)" --eval "\\(vterm\\)"
  DEPENDS vterm-module
  )
