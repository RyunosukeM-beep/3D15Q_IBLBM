# ====== コンパイラ ======
FC       = mpif90
FFLAGS = -O3 -cuda -gpu=cc80,ptxinfo -Minfo=accel 
#FFLAGS   = -O0 -cuda -gpu=cc80,debug -g -Ktrap=fp
TARGET   = Run_lbm3d

# ====== HDF5 ======
HDF5INC = -I$(HDF5DIR)/include
HDF5LIB = -L$(HDF5DIR)/lib -lhdf5_fortran -lhdf5 \
          -Wl,-rpath,$(HDF5DIR)/lib

# ====== ソース ======
SRC = params.cuf IBparams.cuf write_hdf5.f90 mpidiv.f90 outputinfo.f90 IBMroutines.cuf routines.cuf main.cuf
OBJ = params.o IBparams.o write_hdf5.o mpidiv.o outputinfo.o IBMroutines.o routines.o main.o

# ====== ルール ======
all: $(TARGET)

$(TARGET): $(OBJ)
		$(FC) $(FFLAGS) -o $@ $(OBJ) $(HDF5LIB)

%.o: %.f90
		$(FC) $(FFLAGS) $(HDF5INC) -c $<

%.o: %.cuf
		$(FC) $(FFLAGS) $(HDF5INC) -c $<

clean:
		rm -f $(OBJ) $(TARGET) *.mod
