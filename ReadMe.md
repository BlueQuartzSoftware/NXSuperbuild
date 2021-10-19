# NX Superbuild #

This project will download, configure and build a complete NX SDK and optionally also build NX itself. NX can be cloned from [https://www.github.com/bluequartzsoftware/complex](https://www.github.com/bluequartzsoftware/complex). 

## Dependent Libraries ##

+ ninja
+ CMake 3.19.0
+ Eigen 3.3.9
+ HDF5 1.12.1
+ Qt 5.15.2
+ ghcFilesystem 1.3.2 (Linux/macOS)
+ fmt
+ catch2
+ nlohmann_json
+ VTK 9.1
+ expected-lite
+ Bool MP11
+ nod
+ span-lite

## Future Dependencies ##

+ pybind11 2.6.2
+ Python 3.7 (Anaconda Preferred) if you want to include the Python bindings. The script will NOT download or install Python. That is left as an exercise for the developer.
+ TBB


## MacOS Notes ##

You will need Qt 5.15.2 (or Higher), but **NOT** Qt6 (Yet).

```(lang-console)
  export PATH=/Users/Shared/DREAM3D_SDK/Qt5.15.2/5.15.2/clang_x86_64/bin:$PATH
  cd NXSuperbuild
  mkdir debug
  cd debug
  cmake -G Ninja -DNX_SDK=/opt/local/NX_SDK -DCMAKE_BUILD_TYPE=Debug -DINSTALL_QT5=OFF -DQt5_QMAKE_EXECUTABLE=/Users/Shared/DREAM3D_SDK/Qt5.15.2/5.15.2/clang_x86_64/bin/qmake  ../
  ninja
```

Note that if you try to rebuild the same directory, HDF5 will fail, most likely so you need to remove the entire SDK/superbuild/HDF5-*** directory and rebuild HDF5 from scratch.

