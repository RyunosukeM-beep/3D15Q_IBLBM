module hdf5output
  use hdf5
  implicit none
contains

  subroutine write_hdf5(step, uxout, uyout, uzout, rhoout, outdir)

    use kinds
    use LBMparams
    use latticeval
    implicit none

    integer,          intent(in) :: step
    real(dp), dimension(:,:,:), intent(in) :: uxout, uyout, uzout, rhoout

    character(len=100) :: h5filename, xdmffilename, h5relname
    character(len=*), intent(in) :: outdir
    integer(HID_T) :: file_id, dspace_id, dset_id
    integer(HSIZE_T), dimension(3) :: dims
    integer :: hdferr, i, j, k

    !--- ファイル名
    write(h5filename,   '(A,"/velocity_",I6.6,".h5")')   trim(outdir), step
    write(xdmffilename, '(A,"/velocity_",I6.6,".xdmf")') trim(outdir), step
    write(h5relname, '("velocity_",I6.6,".h5")') step
    print *, h5filename,xdmffilename

    dims = [NZ, NY, NX]

    !====================
    ! HDF5ファイル書き出し
    !====================
    call h5open_f(hdferr)
    call h5fcreate_f(trim(h5filename), H5F_ACC_TRUNC_F, file_id, hdferr)
    call h5screate_simple_f(3, dims, dspace_id, hdferr)

    if(varimode == "Double") then
    ! ux
      call h5dcreate_f(file_id, "ux", H5T_NATIVE_DOUBLE, dspace_id, dset_id, hdferr)
      call h5dwrite_f(dset_id, H5T_NATIVE_DOUBLE, uxout, dims, hdferr)
      call h5dclose_f(dset_id, hdferr)

      ! uy
      call h5dcreate_f(file_id, "uy", H5T_NATIVE_DOUBLE, dspace_id, dset_id, hdferr)
      call h5dwrite_f(dset_id, H5T_NATIVE_DOUBLE, uyout, dims, hdferr)
      call h5dclose_f(dset_id, hdferr)

      ! uz
      call h5dcreate_f(file_id, "uz", H5T_NATIVE_DOUBLE, dspace_id, dset_id, hdferr)
      call h5dwrite_f(dset_id, H5T_NATIVE_DOUBLE, uzout, dims, hdferr)
      call h5dclose_f(dset_id, hdferr)

      ! rho
      call h5dcreate_f(file_id, "rho", H5T_NATIVE_DOUBLE, dspace_id, dset_id, hdferr)
      call h5dwrite_f(dset_id, H5T_NATIVE_DOUBLE, rhoout, dims, hdferr)
      call h5dclose_f(dset_id, hdferr)
    else if(varimode == "Single") then
      ! ux
      call h5dcreate_f(file_id, "ux", H5T_NATIVE_REAL, dspace_id, dset_id, hdferr)
      call h5dwrite_f(dset_id, H5T_NATIVE_REAL, uxout, dims, hdferr)
      call h5dclose_f(dset_id, hdferr)
  
      ! uy
      call h5dcreate_f(file_id, "uy", H5T_NATIVE_REAL, dspace_id, dset_id, hdferr)
      call h5dwrite_f(dset_id, H5T_NATIVE_REAL, uyout, dims, hdferr)
      call h5dclose_f(dset_id, hdferr)
  
      ! uz
      call h5dcreate_f(file_id, "uz", H5T_NATIVE_REAL, dspace_id, dset_id, hdferr)
      call h5dwrite_f(dset_id, H5T_NATIVE_REAL, uzout, dims, hdferr)
      call h5dclose_f(dset_id, hdferr)
  
      ! rho
      call h5dcreate_f(file_id, "rho", H5T_NATIVE_REAL, dspace_id, dset_id, hdferr)
      call h5dwrite_f(dset_id, H5T_NATIVE_REAL, rhoout, dims, hdferr)
      call h5dclose_f(dset_id, hdferr)

    endif


    call h5sclose_f(dspace_id, hdferr)
    call h5fclose_f(file_id, hdferr)
    call h5close_f(hdferr)

    !====================
    ! XDMFファイル書き出し
    !====================
    open(unit=20, file=trim(xdmffilename), status='replace', action='write')

    write(20,'(A)') '<?xml version="1.0" ?>'
    write(20,'(A)') '<!DOCTYPE Xdmf SYSTEM "Xdmf.dtd" []>'
    write(20,'(A)') '<Xdmf xmlns:xi="http://www.w3.org/2001/XInclude" Version="2.0">'
    write(20,'(A)') '  <Domain>'
    write(20,'(A)') '    <Grid Name="LBM" GridType="Uniform">'
    write(20,'(A,3I6,A)') '      <Topology TopologyType="3DCoRectMesh" Dimensions="', NZ, NY, NX, '"/>'
    write(20,'(A)') '      <Geometry GeometryType="ORIGIN_DXDYDZ">'
    write(20,'(A)') '        <DataItem Format="XML" Dimensions="3">0.0 0.0 0.0</DataItem>'
    write(20,'(A,3F12.6,A)') '        <DataItem Format="XML" Dimensions="3">', dz, dy, dx, '</DataItem>'
    write(20,'(A)') '      </Geometry>'

    ! ux
    write(20,'(A)') '      <Attribute Name="ux" AttributeType="Scalar" Center="Node">'
    write(20,'(A,3I6,A)') '        <DataItem Dimensions="', NZ, NY, NX, '" NumberType="Float" Precision="8" Format="HDF">'
    write(20,'(A,A,A)') '          ', trim(h5relname), ':/ux'
    write(20,'(A)') '        </DataItem>'
    write(20,'(A)') '      </Attribute>'

    ! uy
    write(20,'(A)') '      <Attribute Name="uy" AttributeType="Scalar" Center="Node">'
    write(20,'(A,3I6,A)') '        <DataItem Dimensions="', NZ, NY, NX, '" NumberType="Float" Precision="8" Format="HDF">'
    write(20,'(A,A,A)') '          ', trim(h5relname), ':/uy'
    write(20,'(A)') '        </DataItem>'
    write(20,'(A)') '      </Attribute>'

    ! uz
    write(20,'(A)') '      <Attribute Name="uz" AttributeType="Scalar" Center="Node">'
    write(20,'(A,3I6,A)') '        <DataItem Dimensions="', NZ, NY, NX, '" NumberType="Float" Precision="8" Format="HDF">'
    write(20,'(A,A,A)') '          ', trim(h5relname), ':/uz'
    write(20,'(A)') '        </DataItem>'
    write(20,'(A)') '      </Attribute>'

    ! velocity vector（ParaView用）
    write(20,'(A)') '      <Attribute Name="velocity" AttributeType="Vector" Center="Node">'
    write(20,'(A,3I6,A)') '        <DataItem ItemType="Function" Dimensions="', NZ, NY, NX, ' 3"'
    write(20,'(A)') '                  Function="JOIN($0, $1, $2)">'
    write(20,'(A,3I6,A)') '          <DataItem Dimensions="', NZ, NY, NX, '" NumberType="Float" Precision="8" Format="HDF">'
    write(20,'(A,A,A)') '            ', trim(h5relname), ':/ux'
    write(20,'(A)') '          </DataItem>'
    write(20,'(A,3I6,A)') '          <DataItem Dimensions="', NZ, NY, NX, '" NumberType="Float" Precision="8" Format="HDF">'
    write(20,'(A,A,A)') '            ', trim(h5relname), ':/uy'
    write(20,'(A)') '          </DataItem>'
    write(20,'(A,3I6,A)') '          <DataItem Dimensions="', NZ, NY, NX, '" NumberType="Float" Precision="8" Format="HDF">'
    write(20,'(A,A,A)') '            ', trim(h5relname), ':/uz'
    write(20,'(A)') '          </DataItem>'
    write(20,'(A)') '        </DataItem>'
    write(20,'(A)') '      </Attribute>'

    ! rho
    write(20,'(A)') '      <Attribute Name="rho" AttributeType="Scalar" Center="Node">'
    write(20,'(A,3I6,A)') '        <DataItem Dimensions="', NZ, NY, NX, '" NumberType="Float" Precision="8" Format="HDF">'
    write(20,'(A,A,A)') '          ', trim(h5relname), ':/rho'
    write(20,'(A)') '        </DataItem>'
    write(20,'(A)') '      </Attribute>'

    write(20,'(A)') '    </Grid>'
    write(20,'(A)') '  </Domain>'
    write(20,'(A)') '</Xdmf>'

    close(20)
    print *, 'HDF5/XDMF written:', trim(h5filename)

  end subroutine write_hdf5

  
  subroutine write_particles_hdf5(step, outdir)
    use hdf5
    use kinds
    use IBMparams
    implicit none

    integer, intent(in) :: step
    character(len=*), intent(in) :: outdir

    real(dp), allocatable :: p_pos_h(:,:)
    real(dp), allocatable :: xcoords(:), ycoords(:), zcoords(:)

    character(len=128) :: h5filename, xdmffilename, h5relname
    integer(HID_T) :: file_id, dspace_id, dset_id
    integer(HSIZE_T) :: dims(1)
    integer :: hdferr, k

    write(h5filename,   '(A,"/particles_",I6.6,".h5")')   trim(outdir), step
    write(xdmffilename, '(A,"/particles_",I6.6,".xdmf")') trim(outdir), step
    write(h5relname,    '("particles_",I6.6,".h5")')       step

    allocate(p_pos_h(3, numpoints))
    allocate(xcoords(numpoints))
    allocate(ycoords(numpoints))
    allocate(zcoords(numpoints))
    p_pos_h = p_pos

    do k = 1, numpoints
        xcoords(k) = p_pos_h(1, k)
        ycoords(k) = p_pos_h(2, k)
        zcoords(k) = p_pos_h(3, k)
    end do

    !====================
    ! HDF5書き出し
    !====================
    call h5open_f(hdferr)
    call h5fcreate_f(trim(h5filename), H5F_ACC_TRUNC_F, file_id, hdferr)

    dims = [numpoints]
    call h5screate_simple_f(1, dims, dspace_id, hdferr)

    call h5dcreate_f(file_id, "x", H5T_NATIVE_REAL, dspace_id, dset_id, hdferr)
    call h5dwrite_f(dset_id, H5T_NATIVE_REAL, xcoords, dims, hdferr)
    call h5dclose_f(dset_id, hdferr)

    call h5dcreate_f(file_id, "y", H5T_NATIVE_REAL, dspace_id, dset_id, hdferr)
    call h5dwrite_f(dset_id, H5T_NATIVE_REAL, ycoords, dims, hdferr)
    call h5dclose_f(dset_id, hdferr)

    call h5dcreate_f(file_id, "z", H5T_NATIVE_REAL, dspace_id, dset_id, hdferr)
    call h5dwrite_f(dset_id, H5T_NATIVE_REAL, zcoords, dims, hdferr)
    call h5dclose_f(dset_id, hdferr)

    call h5sclose_f(dspace_id, hdferr)
    call h5fclose_f(file_id, hdferr)
    call h5close_f(hdferr)

    !====================
    ! XDMF書き出し
    !====================
    open(unit=21, file=trim(xdmffilename), status='replace', action='write')

    write(21,'(A)') '<?xml version="1.0" ?>'
    write(21,'(A)') '<!DOCTYPE Xdmf SYSTEM "Xdmf.dtd" []>'
    write(21,'(A)') '<Xdmf xmlns:xi="http://www.w3.org/2001/XInclude" Version="2.0">'
    write(21,'(A)') '  <Domain>'
    write(21,'(A)') '    <Grid Name="Particles" GridType="Uniform">'
    write(21,'(A,I0,A)') '      <Topology TopologyType="Polyvertex" NodesPerElement="1" NumberOfElements="', numpoints, '"/>'
    write(21,'(A)') '      <Geometry GeometryType="XYZ">'
    write(21,'(A,I0,A)') '        <DataItem ItemType="Function" Dimensions="', numpoints, ' 3"'
    write(21,'(A)') '                  Function="JOIN($0, $1, $2)">'
    write(21,'(A,I0,A)') '          <DataItem Dimensions="', numpoints, '" NumberType="Float" Precision="4" Format="HDF">'
    write(21,'(A,A,A)') '            ', trim(h5relname), ':/x'
    write(21,'(A)') '          </DataItem>'
    write(21,'(A,I0,A)') '          <DataItem Dimensions="', numpoints, '" NumberType="Float" Precision="4" Format="HDF">'
    write(21,'(A,A,A)') '            ', trim(h5relname), ':/y'
    write(21,'(A)') '          </DataItem>'
    write(21,'(A,I0,A)') '          <DataItem Dimensions="', numpoints, '" NumberType="Float" Precision="4" Format="HDF">'
    write(21,'(A,A,A)') '            ', trim(h5relname), ':/z'
    write(21,'(A)') '          </DataItem>'
    write(21,'(A)') '        </DataItem>'
    write(21,'(A)') '      </Geometry>'
    write(21,'(A)') '    </Grid>'
    write(21,'(A)') '  </Domain>'
    write(21,'(A)') '</Xdmf>'

    close(21)

    deallocate(p_pos_h, xcoords, ycoords, zcoords)
    print *, 'Particles HDF5/XDMF written:', trim(h5filename)

end subroutine write_particles_hdf5



end module hdf5output