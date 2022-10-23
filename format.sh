#!/bin/bash

find ./main | grep ".*\\.[c|h]\$" | xargs astyle --style=kr
find ./main | grep ".*\\.[c|h]pp\$" | xargs astyle --style=kr
cmake-format ./CMakeLists.txt > ./CMakeLists.txt.orig && cp ./CMakeLists.txt.orig ./CMakeLists.txt
cmake-format ./main/CMakeLists.txt > ./CMakeLists.txt.orig && cp ./CMakeLists.txt.orig ./main/CMakeLists.txt

