#!/usr/bin/env bash
set -e

# for win
mkdir -p /tmp

UNAME="$(uname)"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS//-std=c++17/-std=c++11}"

if [ "${UNAME}" == "Linux" ]; then
    export FLIBS="-lgcc_s -lgcc -lstdc++ -lm"
fi

# Use only 1 thread with OpenBLAS to avoid timeouts on CIs.
# This should have no other affect on the build. A user
# should still be able to set this (or not) to a different
# value at run-time to get the expected amount of parallelism.
export OPENBLAS_NUM_THREADS=1



if [ ! -z ${LIBRARY_PREFIX+x} ]; then
    USE_PREFIX=$LIBRARY_PREFIX
    WITH_BLAS_LIB="-L${LIBRARY_PREFIX}/lib -lblas"
    WITH_LAPACK_LIB="-L${LIBRARY_PREFIX}/lib -llapack"
else
    USE_PREFIX=$PREFIX
    WITH_BLAS_LIB="-L${PREFIX}/lib -lblas"
    WITH_LAPACK_LIB="-L${PREFIX}/lib -llapack"
fi


if [[ $UNAME == *"MSYS"* ]]; then
    WIN_FLAGS="--build=x86_64-w64-mingw32 --enable-msvc"
fi

./configure \
    --prefix="${USE_PREFIX}" \
    --exec-prefix="${USE_PREFIX}" \
    --with-blas="${WITH_BLAS_LIB}" \
    --with-lapack="${WITH_LAPACK_LIB}" \
    ${WIN_FLAGS}

make -j "${CPU_COUNT}"
make install
