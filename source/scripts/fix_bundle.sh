
build/deps/macdylibbundler-build/dylibbundler -od -b \
	-x externals/csound6~.mxo/Contents/MacOS/csound6~ \
	-d externals/csound6~.mxo/Contents/Frameworks \
	-p @loader_path/../Frameworks

build/deps/macdylibbundler-build/dylibbundler -od -b \
	-x externals/csound~.mxo/Contents/MacOS/csound~ \
	-d externals/csound~.mxo/Contents/Frameworks \
	-p @loader_path/../Frameworks
