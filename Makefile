VERSION = 0.0.1

ROOT_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ifeq ($(OS),Windows_NT)
	GOROOT ?= C:/Go
	GOCC ?= $(GOROOT)bin\go
	SEP = \\
	RM = del /Q /F /S
	RRM = rmdir /S /Q
	MV = rename
	CMDSEP = &
	ROOT_DIR_CLEAN = $(subst /,\,$(ROOT_DIR))
	LIB_PREFIX =
else
	GOROOT ?= /usr/local/go
	GOCC ?= $(GOROOT)/bin/go
	SEP = /
	RM = rm -f
	RRM = rm -f -r
	MV = mv -f
	CMDSEP = ;
	ROOT_DIR_CLEAN = $(ROOT_DIR)
	LIB_PREFIX = lib
endif

PATHSEP = $(strip $(SEP))
JAVA_HOME ?= /usr/local
ROOTOUTDIR = $(ROOT_DIR)/build
SWIG = swig

CXXFLAGS = -g -fPIC -std=c++11 -I.$(PATHSEP)sdk-cpp$(PATHSEP)include -I.$(PATHSEP)sdk-cpp$(PATHSEP)src -I.$(PATHSEP)sdk-cpp$(PATHSEP)sdk-c$(PATHSEP)include$(PATHSEP) -I.$(PATHSEP)sdk-cpp$(PATHSEP)sdk-c$(PATHSEP)build$(PATHSEP) -L.$(PATHSEP)sdk-cpp$(PATHSEP)sdk-c$(PATHSEP)build
LDFLAGS = -lkuzzlesdk

RUBY_INCLUDE_DIR ?= `pkg-config --cflags ruby`
RUBYINCLUDE = $(RUBY_INCLUDE_DIR)

SRCS = kcore_wrap.cxx
OBJS = $(SRCS:.cxx=.o)

all: ruby

kcore_wrap.o: kcore_wrap.cxx
	$(CXX) -c $< -o $@ $(CXXFLAGS) $(LDFLAGS) $(RUBYINCLUDE)

makedir:
ifeq ($(OS),Windows_NT)
	@if not exist $(subst /,\,$(ROOTOUTDIR)) mkdir $(subst /,\,$(ROOTOUTDIR))
else
	mkdir -p $(ROOTOUTDIR)
endif

make_c_sdk:
	cd sdk-cpp/sdk-c && $(MAKE)

swig:
	$(SWIG) -Wall -c++ -ruby -globalmodule -outdir $(OUTDIR) -o $(SRCS) -I.$(PATHSEP)sdk-cpp$(PATHSEP)include -I.$(PATHSEP)sdk-cpp$(PATHSEP)sdk-c$(PATHSEP)include$(PATHSEP) -I.$(PATHSEP)sdk-cpp$(PATHSEP)src -I.$(PATHSEP)sdk-cpp$(PATHSEP)sdk-c$(PATHSEP)build$(PATHSEP) $(RUBYINCLUDE) swig/core.i

make_lib:
	$(CXX) -shared kcore_wrap.o -o $(OUTDIR)$(SEP)libkuzzlesdk.so $(CXXFLAGS) $(LDFLAGS) $(RUBYINCLUDE)

remove_so:
	rm -rf .$(PATHSEP)sdk-cpp$(PATHSEP)sdk-c$(PATHSEP)build$(PATHSEP)*.so*

ruby: LANGINCLUDE = $(RUBYINCLUDE)
ruby: OUTDIR = $(ROOTOUTDIR)
ruby: CC = $(CPP)
ruby: CFLAGS = -fPIC
ruby: makedir make_c_sdk remove_so swig $(OBJS) make_lib

clean:
	cd sdk-cpp && $(MAKE) clean
	rm -rf build

.PHONY: all clean swig ruby remove_so make_lib make_c_sdk makedir
