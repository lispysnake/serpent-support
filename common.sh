#!/bin/true

export CXX="ccache g++"
export CC="ccache gcc"

export CFLAGS="-O3 -flto=thin"
export CXXFLAGS="-O3 -flto=thin"
