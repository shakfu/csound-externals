SCRIPTS := source/scripts
CONFIG := "Release" # or Debug
 

.PHONY: build release build-relocatable relocatable deps fixup clean reset setup 


all: build


build:
	@mkdir -p build && cd build && cmake -GXcode .. && \
		cmake --build . --config '$(CONFIG)'


release: relocatable


relocatable: fixup


deps:
	@bash $(SCRIPTS)/build_dependencies.sh


fixup: build-relocatable
	@bash $(SCRIPTS)/fix_bundle.sh


fixup-tool:
	@bash $(SCRIPTS)/fix_bundle.sh


build-relocatable: deps
# 	@mkdir -p build && cd build && cmake -DBUILD_RELOCATABLE=ON .. && make
	@mkdir -p build && cd build && cmake -GXcode -DBUILD_RELOCATABLE=ON .. && \
		cmake --build . --config '$(CONFIG)'


clean:
	@rm -rf build


reset: clean
	@rm -rf externals


setup:
	git submodule init
	git submodule update
	ln -s $(shell pwd) "$(HOME)/Documents/Max 8/Packages/$(shell basename `pwd`)"
