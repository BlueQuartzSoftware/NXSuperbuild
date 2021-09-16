# NX Superbuild #

This project will download, configure and build a complete NX SDK and optionally also build NX itself. NX can be cloned from [https://www.github.com/bluequartzsoftware/complex](https://www.github.com/bluequartzsoftware/complex). 

## Dependent Libraries ##

+ CMake 3.19.0
+ Eigen 3.3.9
+ HDF5 1.12.1
+ Qt 5.15.2
+ ghcFilesystem 1.3.2 (Linux/macOS)
+ pybind11 2.6.2
+ Python 3.7 (Anaconda Preferred) if you want to include the Python bindings. The script will NOT download or install Python. That is left as an exercise for the developer.
+ fmt
+ catch2
+ nlohmann_json

_Please note in the below instructions that the version of CMake on www.cmake.org may be newer than what is shown in the scree captures. That is perfectly normal.
