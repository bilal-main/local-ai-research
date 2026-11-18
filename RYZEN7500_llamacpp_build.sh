cmake -S ./llama.cpp -B ./llama.cpp/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DGGML_STATIC=ON \
  -DGGML_NATIVE=ON \
  -DGGML_LTO=ON \
  -DGGML_OPENMP=ON \
  -DGGML_LLAMAFILE=ON \
  -DLLAMA_BUILD_TESTS=OFF \
  -DLLAMA_BUILD_EXAMPLES=OFF \
  -DLLAMA_BUILD_SERVER=OFF \
  -DCMAKE_C_FLAGS="-O3 -DNDEBUG -march=native -ffunction-sections -fdata-sections" \
  -DCMAKE_CXX_FLAGS="-O3 -DNDEBUG -march=native -ffunction-sections -fdata-sections"

cmake --build ./llama.cpp/build --config Release -j 4
g++ -std=c++17 -O3 -DNDEBUG -march=native -mavx2 -mfma -mf16c \
  -flto=auto -fuse-linker-plugin -fomit-frame-pointer \
  -ffunction-sections -fdata-sections -Wl,--gc-sections -s \
  -static main.cpp -o fia_local_ai \
  -Iai_libs -I./llama.cpp/include -I./llama.cpp/ggml/include \
  -Wl,--start-group \
    ./llama.cpp/build/src/libllama.a \
    ./llama.cpp/build/ggml/src/libggml.a \
    ./llama.cpp/build/ggml/src/libggml-cpu.a \
    ./llama.cpp/build/ggml/src/libggml-base.a \
  -Wl,--end-group \
  -lX11 -lxcb -lXau -lXdmcp -lm -ldl -lpthread -lgomp
OMP_NUM_THREADS=4 OMP_PROC_BIND=close OMP_PLACES=cores ./fia_local_ai
