#!/usr/bin/make -f
# Makefile for 2FS #
# ---------------- #
# Created by falkTX
#

# ---------------------------------------------------------------------------------------------------------------------
# Check for fluidsynth

HAVE_FLUIDSYNTH = $(shell pkg-config --exists fluidsynth && echo true)

ifneq ($(HAVE_FLUIDSYNTH),true)
$(error fluidsynth missing, cannot continue)
endif

# ---------------------------------------------------------------------------------------------------------------------
# Fallback to Linux if no other OS defined

ifneq ($(HAIKU),true)
ifneq ($(MACOS),true)
ifneq ($(WIN32),true)
LINUX=true
endif
endif
endif

# ---------------------------------------------------------------------------------------------------------------------
# Set compiler

CC  ?= gcc
CXX ?= g++

# ---------------------------------------------------------------------------------------------------------------------
# Set build and link flags

BASE_FLAGS = -Wall -Wextra -Wshadow -pipe
BASE_OPTS  = -O2 -ffast-math -mtune=generic -msse -msse2 -mfpmath=sse -fdata-sections -ffunction-sections

ifeq ($(MACOS),true)
# MacOS linker flags
LINK_OPTS  = -fdata-sections -ffunction-sections -Wl,-dead_strip -Wl,-dead_strip_dylibs
else
# Common linker flags
LINK_OPTS  = -fdata-sections -ffunction-sections -Wl,--gc-sections -Wl,-O1 -Wl,--as-needed -Wl,--strip-all
endif

ifeq ($(NOOPT),true)
# No optimization flags
BASE_OPTS  = -O2 -ffast-math -fdata-sections -ffunction-sections
endif

ifneq ($(WIN32),true)
# Not needed for Windows
BASE_FLAGS += -fPIC -DPIC
endif

ifeq ($(DEBUG),true)
BASE_FLAGS += -DDEBUG -O0 -g
ifeq ($(WIN32),true)
BASE_FLAGS += -msse -msse2
endif
LINK_OPTS   =
else
BASE_FLAGS += -DNDEBUG $(BASE_OPTS) -fvisibility=hidden
CXXFLAGS   += -fvisibility-inlines-hidden
endif

BUILD_C_FLAGS   = $(BASE_FLAGS) -std=gnu99 $(CFLAGS)
BUILD_CXX_FLAGS = $(BASE_FLAGS) -std=gnu++0x $(CXXFLAGS)
LINK_FLAGS      = $(LINK_OPTS) $(LDFLAGS)

ifneq ($(MACOS),true)
# Not available on MacOS
LINK_FLAGS     += -Wl,--no-undefined
endif

# ---------------------------------------------------------------------------------------------------------------------
# Set fluidsynth flags

FLUIDSYNTH_FLAGS = $(shell pkg-config --cflags fluidsynth)
FLUIDSYNTH_LIBS  = $(shell pkg-config --libs fluidsynth)

# ---------------------------------------------------------------------------------------------------------------------
# Set app extension

ifeq ($(WIN32),true)
APP_EXT = .exe
endif

# ---------------------------------------------------------------------------------------------------------------------
# Set shared lib extension

LIB_EXT = .so

ifeq ($(MACOS),true)
LIB_EXT = .dylib
endif

ifeq ($(WIN32),true)
LIB_EXT = .dll
endif

# ---------------------------------------------------------------------------------------------------------------------
# Set shared library CLI arg

ifeq ($(MACOS),true)
SHARED = -dynamiclib
else
SHARED = -shared
endif

# ---------------------------------------------------------------------------------------------------------------------
