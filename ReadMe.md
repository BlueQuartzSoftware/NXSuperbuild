# NX Superbuild #

This project will download, configure and build a complete NX SDK and optionally also build NX itself. NX can be cloned from [https://www.github.com/bluequartzsoftware/complex](https://www.github.com/bluequartzsoftware/complex). 

## Dependent Libraries ##

| Library Name | GitHub Source | Version |
|--------------|---------------|---------|
| boost-mp11  | https://github.com/boostorg/mp11  | 1.77.0 |
| catch2  | https://github.com/catchorg/Catch2  | 2.13.6 |
| eigen3  |  https://gitlab.com/libeigen/eigen.git | 3.3.9 |
| expected-lite  | https://github.com/martinmoene/expected-lite  | 0.5.0 |
| fmt  | https://github.com/fmtlib/fmt  | 7.1.3 |
| hdf5  | https://github.com/HDFGroup/hdf5/  | 1.12.1 |
| itk  | https://github.com/InsightSoftwareConsortium/ITK.git  | 5.2.1 |
| nlohmann-json  | https://github.com/nlohmann/json/  | 3.9.1 |
| pybind11  | https://github.com/pybind/pybind11.git  | 2.6.2 |
| span-lite  | https://github.com/martinmoene/span-lite  | 0.10.3 |
| oneTBB  | https://github.com/oneapi-src/onetbb  | 2021.5.0 |
| ebsdlib  | https://www.github.com/bluequartzsoftware/EBSDLib   | 1.0.16 |
| h5support  | https://www.github.com/bluequartzsoftware/H5Support  | 1.0.8 |
| nod  | https://github.com/fr00b0/nod.git  | 0.5.2 |
| Qt5  | https://github.com/qt/qt5.git  | 5.15.2 |
| VTK  | https://github.com/Kitware/VTK.git  | 9.1.0 |

## Future Dependencies ##

+ pybind11 2.6.2
+ Python 3.7 (Anaconda Preferred) if you want to include the Python bindings. The script will NOT download or install Python. That is left as an exercise for the developer.

## MacOS M1 | Apple Silicon | ARM64 Support ##

You will need to build Qt5 for ARM64 before running the super build. You can do this by running the built in shell scripts in the Qt5-Build-Tools folder

```(lang-console)
  export NX_SDK_DIR=/Users/Shared/NX_SDK
  ./Qt5-Build-Tools/qt-5.15.2-build.zsh ${NX_SDK_DIR}/superbuild/Qt5.15.2/build ${NX_SDK_DIR}
  export PATH=${NX_SDK_DIR}/Qt5.15.2-arm64/5.15.2/clang_arm64/bin:$PATH
  mkdir Debug
  cd Debug
  cmake -G Ninja -DNX_SDK=${NX_SDK_DIR} -DCMAKE_BUILD_TYPE=Debug ../
  ninja
  cd ../
  mkdir Release
  cd Release
  cmake -G Ninja -DNX_SDK=${NX_SDK_DIR} -DCMAKE_BUILD_TYPE=Release ../
  ninja 
```


## MacOS Notes ##

You will need Qt 5.15.2 (or Higher), but **NOT** Qt6 (Yet).

```(lang-console)
  export PATH=/Users/Shared/NX_SDK/Qt5.15.2/5.15.2/clang_x86_64/bin:$PATH
  cd NXSuperbuild
  mkdir debug
  cd debug
  cmake -G Ninja -DNX_SDK=/opt/local/NX_SDK -DCMAKE_BUILD_TYPE=Debug -DINSTALL_QT5=OFF -DQt5_QMAKE_EXECUTABLE=/Users/Shared/DREAM3D_SDK/Qt5.15.2/5.15.2/clang_x86_64/bin/qmake  ../
  ninja
```

Note that if you try to rebuild the same directory, HDF5 will fail, most likely so you need to remove the entire SDK/superbuild/HDF5-*** directory and rebuild HDF5 from scratch.

