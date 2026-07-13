# IB-LBM (CUDA Fortran)

[English](README.md) | [日本語 (Japanese)](README.ja.md)

This is a program that performs numerical simulations of the Kármán vortex generated behind a **three-dimensional sphere** using the Immersed Boundary Lattice Boltzmann Method (IB-LBM) [[2]](#reference).
It is a numerical simulation program based on the Lattice Boltzmann Model with the three-dimensional 15-velocity model (D3Q15), implemented in CUDA Fortran and running on NVIDIA GPUs.

## Numerical Methods

### Fluid Computation

The fluid is computed using the Lattice Boltzmann Method (LBM). The velocity model is the three-dimensional 15-velocity model (D3Q15).

### Immersed Boundary Method

The solid boundary is treated using the Immersed Boundary Method (IBM).
The body force required to satisfy the no-slip condition on the boundary is computed using the Multi Direct Forcing Method (MDFN) [[2]](#reference).

## Default Computational Domain

By default, the simulation is performed under the following conditions.

| Item | Setting |
|---|---|
| Boundary condition in Z direction | Pressure-difference boundary condition (Zou-He pressure boundary condition [[1]](#reference)) |
| Boundary condition in X, Y directions | Periodic boundary condition |
| Domain size (X, Y, Z) | 1.0, 1.0, 4.0 |
| Number of mesh points (X, Y, Z) | 128, 128, 128×4 |
| Grid spacing | dx = 1/128.0 |
| Sphere radius | 20.0 dx |
| Sphere center coordinates | [64.0 dx, 64.0 dx, 128.0 dx] |

## Requirements

- NVIDIA GPU (CUDA-capable)
- NVIDIA HPC SDK (`nvfortran` compiler)
- Parallel HDF5 library

### Required Modules

On an HPC cluster environment, the following modules must be loaded before compilation and execution.

```bash
module load hpc_sdk
module load hdf5_pararell
```

## Directory Structure

```
3D15Q_IBLBM/
├── README.md
└── src_IB/         # Program source directory
    ├── Makefile    # Makefile for building
    └── (source files)
```

## Build

Move to the `src_IB` directory and run `make`.
The executable is generated in the same directory as the Makefile (`src_IB/`).

```bash
cd src_IB
make
```

## Preparation Before Execution (Important)

An `output` directory must be created in advance in the location where the executable is generated (the `src_IB/` directory, same as the Makefile).

```bash
cd src_IB
mkdir output
```

If the `output` directory does not exist, writing the simulation results will fail.

## How to Run

The program is executed via MPI.

```bash
cd src_IB
mpirun -np 1 ./Run_lbm3d
```

### Command-Line Options

| Option | Description | Example |
|---|---|---|
| `--m "message"` | Adds a message at run time. The message is recorded in `output/flowdata_(run start time)/Flowinformation.txt` | `./Run_lbm3d --m "Message"` |
| `--o f` / `--o t` | Switches output on/off (`f`: output off, `t`: output on). If this option is not specified, the default is `t` (output on) | `./Run_lbm3d --o f` |
| `--s (integer)` | Specifies the maximum number of steps (integer type, default: 5000) | `./Run_lbm3d --s 10000` |
| `--w (integer)` | Specifies the write-step interval (integer type, default: 1000) | `./Run_lbm3d --w 500` |

Usage examples:

```bash
# Run with a message
mpirun -np 1 ./Run_lbm3d --m "test run"

# Run with output disabled
mpirun -np 1 ./Run_lbm3d --o f

# Run with both options
mpirun -np 1 ./Run_lbm3d --m "no output run" --o f

# Run with the maximum number of steps and the write-step interval specified
mpirun -np 1 ./Run_lbm3d --s 10000 --w 500
```

### Pre-Run Check: MPI Path

Before running, verify that the MPI in use is the one located under the `hpcz` module.

```bash
which mpirun
```

If the displayed path points to a directory under the `hpcz` module installation, the setup is correct.
If a different MPI (e.g., the system default MPI) is shown, review the module load order and environment settings.

## Output

For each run, a directory named `flowdata_(run start time)/` is created under `output/`, and the results are written into it.

```
output/
└── flowdata_(run start time)/
    ├── Flowinformation.txt    # Run information log file
    └── (velocity field data)
```

| Output data | Description |
|---|---|
| Velocity field data | Three-dimensional velocity field (u, v, w) |
| `Flowinformation.txt` | Run information log file. The message specified with the `--m` option is also recorded here |

## Reference

[1] Q. Zou and X. He, "On pressure and velocity boundary conditions for the lattice Boltzmann BGK model," *Physics of Fluids*, Vol. 9, No. 6, pp. 1591–1598 (1997).

[2] K. Suzuki and T. Inamuro, "Effect of internal mass in the simulation of a moving body by the immersed boundary method," *Computers & Fluids*, Vol. 49, No. 1, pp. 173–187 (2011). 
## Change Log

| Date | Version | Description |
|---|---|---|
| 2026/07/13 | ver1.0 | Initial public release |
