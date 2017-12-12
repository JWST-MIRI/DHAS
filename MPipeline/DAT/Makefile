# Makefile for the MIRI DAT
# JEM - v1.0 - copied MIPS make file for mips_sloper and libaries. 

MAKE = make

#for linux
LDFLAGS = -L../lib/cfitsio -lcfitsio
CCFLAGS = -O2 -funroll-loops -Iinclude -I../src_gen/include -I../lib/cfitsio -Wno-deprecated -D_FILE_OFFSET_BITS=64 -DHAVE_LONGLONG=1 -D_LARGEFILE_SOURCE=1
#for solaris
#LDFLAGS = -L../lib/cfitsio -lcfitsio -lsocket -lnsl -L /usr/local/lib -R /usr/local/lib
#CCFLAGS = -O2 -Iinclude -I../src_gen/include -I../lib/cfitsio -I /usr/local/include -Wno-deprecated -D_FILE_OFFSET_BITS=64 -DHAVE_LONGLONG=1 -D_LARGEFILE_SOURCE=1 -DSOLARIS

all: miri_sloper miri_caler miri_cube

miri_fitsio:
	cd lib/cfitsio; $(MAKE)


miri_sloper: 
	cd src_ms; $(MAKE) "CCFLAGS=${CCFLAGS}" "LDFLAGS=${LDFLAGS}"
	cp src_ms/miri_sloper .

miri_caler: 
	cd src_mc; $(MAKE) "CCFLAGS=${CCFLAGS}" "LDFLAGS=${LDFLAGS}"
	cp src_mc/miri_caler .

miri_cube: 
	cd src_mrs; $(MAKE) "CCFLAGS=${CCFLAGS}" "LDFLAGS=${LDFLAGS}"
	cp src_mrs/miri_cube .

depend: 
	cd src_ms; $(MAKE) depend

new_dist:
	cd lib/cfitsio; ./configure

# ----------
# cleaning targets
# ----------

clean_all: clean clean_lfitsio

clean: 
	rm -f miri_sloper
	rm -f miri_caler
	rm -f miri_cube
	rm -f src_gen/*.o
	cd src_ms; $(MAKE) clean
	cd src_mc; $(MAKE) clean
	cd src_mrs; $(MAKE) clean

clean_lfitsio:
	cd lib/cfitsio; $(MAKE) clean

