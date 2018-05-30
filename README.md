# Zhasher
Zhasher is a Zhash CPU&GPU Miner for BitcoinZ based on nheqminer made by NiceHash.

## About Zhash PoW
The Zhash PoW is based on the Equihash 144,5 algorithm, a memory hard algorithm
solving the Generalized Birthday Problem with custom parameters unique to BitcoinZ.

Zhash uses a larger amount of memory (700 MB) in comparison to Equihash 200,9
(150 MB) to make it not financial feasible to create an ASIC device and put them
on an equal playing field when compared to GPUs.

# Build instructions:

### Dependencies:
  - Boost 1.62+
  - cuda tools 9.2+

## Windows:

Windows builds made by us are available here: https://github.com/btcz/zhasher/releases

Download and install:
- [CUDA SDK](https://developer.nvidia.com/cuda-downloads) (if not needed remove **USE_CUDA_TROMP** and **USE_CUDA_DJEZO** from **zhasher** Preprocessor definitions under Properties > C/C++ > Preprocessor)
- Visual Studio 2013 Community: https://www.visualstudio.com/en-us/news/releasenotes/vs2013-community-vs
- [Visual Studio Update 5](https://www.microsoft.com/en-us/download/details.aspx?id=48129) installed
- 64 bit version only

Open **zhasher.sln** under **zhasher/zhasher.sln** and build. You will have to build ReleaseSSE2 cpu_tromp project first, then Release7.5 cuda_tromp project, then select Release and build all.

### Enabled solvers:
  - USE_CPU_TROMP
  - USE_CUDA_TROMP

### Currently Broken solvers:
  - USE_CPU_XENONCAT
  - USE_CUDA_DJEZO

If you don't wan't to build with all solvers you can go to **zhasher Properties > C/C++ > Preprocessor > Preprocessor Definitions** and remove the solver you don't need.

## Linux
  - As root, you may need to update symlinks to older version of GCC. eg using cuda tools 9.2 on Ubuntu 18.04
    - update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 100
    - update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 100
    - update-alternatives --install /usr/bin/cpp cpp-bin /usr/bin/cpp-6 100

Work in progress.
Working solvers CPU_TROMP, CUDA_TROMP

### General instructions:
  - Install CUDA SDK v9 (make sure you have cuda libraries in **LD_LIBRARY_PATH** and cuda toolkit bins in **PATH**)
    - example on Ubuntu:
    - LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda-9.2/lib64:/usr/local/cuda-9.2/lib64/stubs"
    - PATH="$PATH:/usr/local/cuda-9.2/"
    - PATH="$PATH:/usr/local/cuda-9.2/bin"

  - Use Boost 1.62+ (if it is not available from the repos you will have to download and build it yourself)
  - CMake v3.5 (if it is not available from the repos you will have to download and build it yourself)
  - Currently support only static building (CUDA_TROMP is enabled by default, check **CMakeLists.txt** in **zhasher** root folder)
  - If not on Ubuntu make sure you have **fasm** installed and accessible in **PATH**
  - After that open the terminal and run the following commands:
    - `git clone https://github.com/btcz/zhasher.git`
    - `mkdir build && cd build`
    - `export CUDA_CUDART_LIBRARY="/usr/local/cuda/lib64/libcudart.so"`
    - `cmake -DCUDA_CUDART_LIBRARY=CUDA_CUDART_LIBRARY ../`
    - `make -j $(nproc)`

# Run instructions:

Parameters:
	-h		Print this help and quit
	-l [location]	Stratum server:port
	-u [username]	Username (bitcoinzaddress)
	-a [port]	Local API port (default: 0 = do not bind)
	-d [level]	Debug print level (0 = print all, 5 = fatal only, default: 2)
	-b [hashes]	Run in benchmark mode (default: 200 iterations)

CPU settings
	-t [num_thrds]	Number of CPU threads
	-e [ext]	Force CPU ext (0 = SSE2, 1 = AVX, 2 = AVX2)

NVIDIA CUDA settings
	-ci		CUDA info
	-cd [devices]	Enable CUDA mining on spec. devices
	-cb [blocks]	Number of blocks
	-ct [tpb]	Number of threads per block
Example: -cv 1 -cd 0 2 -cb 12 16 -ct 64 128

If run without parameters, miner will start mining with 75% of available logical CPU cores. Use parameter -h to learn about available parameters:

Example to run benchmark on your CPU:

        zhasher -b

Example to mine on your CPU with your own BTCZ address and worker1 on Equipool USA server:

        zhasher -l mine.equipool.1ds.us:50063 -u YOUR_BTCZ_ADDRESS_HERE.worker1

Example to mine on your CPU with your own BTCZ address and worker1 on EU server, using 6 threads:

        zhasher -l mine.equipool.1ds.us:50063 -u YOUR_BTCZ_ADDRESS_HERE.worker1 -t 6

<i>Note: if you have a 4-core CPU with hyper threading enabled (total 8 threads) it is best to run with only 6 threads (experimental benchmarks shows that best results are achieved with 75% threads utilized)</i>

Example to mine on your CPU as well on your CUDA GPUs with your own BTCZ address and worker1 on EU server, using 6 CPU threads and 2 CUDA GPUs:

        zhasher -l mine.equipool.1ds.us:50063 -u YOUR_BTCZ_ADDRESS_HERE.worker1 -t 6 -cv 1 -cd 0 1
