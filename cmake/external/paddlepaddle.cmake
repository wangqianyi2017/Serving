# Copyright (c) 2019 PaddlePaddle Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

INCLUDE(ExternalProject)

SET(PADDLE_SOURCES_DIR ${THIRD_PARTY_PATH}/Paddle)
SET(PADDLE_INSTALL_DIR ${THIRD_PARTY_PATH}/install/Paddle)
SET(PADDLE_INCLUDE_DIR "${PADDLE_INSTALL_DIR}/include" CACHE PATH "PaddlePaddle include directory." FORCE)
SET(PADDLE_LIBRARIES "${PADDLE_INSTALL_DIR}/lib/libpaddle_fluid.a" CACHE FILEPATH "Paddle library." FORCE)

INCLUDE_DIRECTORIES(${PADDLE_INCLUDE_DIR})

# Reference https://stackoverflow.com/questions/45414507/pass-a-list-of-prefix-paths-to-externalproject-add-in-cmake-args
set(prefix_path "${THIRD_PARTY_PATH}/install/gflags|${THIRD_PARTY_PATH}/install/leveldb|${THIRD_PARTY_PATH}/install/snappy|${THIRD_PARTY_PATH}/install/gtest|${THIRD_PARTY_PATH}/install/protobuf|${THIRD_PARTY_PATH}/install/zlib|${THIRD_PARTY_PATH}/install/glog")

# If minimal .a is need, you can set  WITH_DEBUG_SYMBOLS=OFF
ExternalProject_Add(
    extern_paddle
    ${EXTERNAL_PROJECT_LOG_ARGS}
    # TODO(wangguibao): change to de newst repo when they changed.
    GIT_REPOSITORY  "https://github.com/PaddlePaddle/Paddle"
    GIT_TAG         "v1.2.0"
    PREFIX          ${PADDLE_SOURCES_DIR}
    UPDATE_COMMAND  ""
    CMAKE_ARGS      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
                    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                    -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
                    -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
                    -DCMAKE_INSTALL_PREFIX=${PADDLE_INSTALL_DIR}
                    -DCMAKE_INSTALL_LIBDIR=${PADDLE_INSTALL_DIR}/lib
                    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
                    -DCMAKE_BUILD_TYPE=${THIRD_PARTY_BUILD_TYPE}
                    -DCMAKE_PREFIX_PATH=${prefix_path}
                    -DWITH_SWIG_PY=OFF
                    -DWITH_PYTHON=OFF
                    -DWITH_MKL=${WITH_MKL}
                    -DWITH_AVX=${WITH_AVX}
                    -DWITH_MKLDNN=OFF
                    -DWITH_GPU=OFF
                    -DWITH_FLUID_ONLY=ON
                    -DWITH_TESTING=OFF
                    -DWITH_DISTRIBUTE=OFF
                    -DON_INFER=ON
                    ${EXTERNAL_OPTIONAL_ARGS}
    LIST_SEPARATOR |
    CMAKE_CACHE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${PADDLE_INSTALL_DIR}
                     -DCMAKE_INSTALL_LIBDIR:PATH=${PADDLE_INSTALL_DIR}/lib
                     -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
                     -DCMAKE_BUILD_TYPE:STRING=${THIRD_PARTY_BUILD_TYPE}
)
ADD_LIBRARY(paddle_fluid STATIC IMPORTED GLOBAL)
SET_PROPERTY(TARGET paddle_fluid PROPERTY IMPORTED_LOCATION ${PADDLE_LIBRARIES})
ADD_DEPENDENCIES(paddle_fluid extern_paddle)

LIST(APPEND external_project_dependencies paddle)
