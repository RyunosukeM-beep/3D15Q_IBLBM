module information
    use kinds
    use LBMparams
    implicit none
    contains

    subroutine make_output_dir(outdir)
        implicit none
        character(len=*), intent(out) :: outdir
        character(8)  :: date
        character(10) :: time
        character(64) :: subdir
        integer :: stat

        ! 日付・時刻取得
        call date_and_time(date=date, time=time)

        ! サブディレクトリ名を作成
        write(subdir, '("flowdata_",A8, "_", A6)') date, time(1:6)

        ! outdirの既存パスに日付を追加
        ! 例: ./output/ + 20240101_153045 → ./output/20240101_153045
        outdir = trim(OUTPUT_DIR)//'/'//trim(subdir)

        ! ディレクトリ作成
        call execute_command_line('mkdir -p '//trim(outdir), exitstat=stat)
        if (stat /= 0) then
            write(*,*) 'ERROR: failed to create directory: ', trim(outdir)
            stop
        end if

        write(*,*) 'Output directory: ', trim(outdir)

    end subroutine make_output_dir
    

    subroutine write_config(outdir,comment)
        implicit none
        character(len=*), intent(in) :: outdir
        character(len=256),intent(in):: comment
    
        character(256) :: filename
        character(8)   :: date
        character(10)  :: time
        integer        :: unit = 20

        call date_and_time(date=date, time=time)

        ! ファイルパス
        write(filename, '(A, "/Flowinformation.txt")') trim(outdir)

        open(unit, file=trim(filename), status='replace', action='write')

        write(unit, '(A)')       '===== LBM Simulation Config ====='
        write(unit, '(A)')       ''
        write(unit, '(A, A8, A, A6)') 'Date     : ', date, '  Time: ', time(1:6)
        write(unit, '(A)')       ''
        write(unit, '(A, A)')    'Comment  : ', trim(comment)
        write(unit, '(A)')       ''
        write(unit, '(A)')       '--- Method ---'
        write(unit, '(A)')       'Lattice Boltzmann Method 3D15Q for CUDA'
        write(unit, '(A)')       ''
        write(unit, '(A)')       '--- Grid ---'
        write(unit, '(A, I0, A, I0, A, I0)') 'Grid size  : ', nx, ' x ', ny, ' x ', nz
        write(unit, '(A, I0)')   'Total cells: ', nx*ny*nz
        write(unit, '(A)')       ''
        write(unit, '(A)')       '--- Parameters ---'
        write(unit, '(A, I0)')    'Total steps     : ', n_end - n_start
        write(unit, '(A, I0)')    'Output interval : ', outputstep
        write(unit, '(A, I0)')    'Total outputs   : ', (n_end-n_start)/outputstep + 1
        write(unit, '(A)')        ''
        write(unit, '(A)')        '--- Memory (estimate) ---'
        write(unit, '(A, F8.2, A)') 'f array  : ', &
            nx*ny*nz*15*8.0d0/1024/1024/1024, ' GB'
        write(unit, '(A, F8.2, A)') 'ux,uy,uz,rho array  : ', &
            nx*ny*nz*8.0d0/1024/1024/1024, ' GB'

        close(unit)

        write(*,*) 'Config written: ', trim(filename)

    end subroutine write_config

    subroutine load_args(comment_val)
        implicit none
        character(len=256), intent(out) :: comment_val
        character(len=256) :: arg, next_arg
        integer :: i, argc

        comment_val = ""
        argc = command_argument_count()

        i = 1
        do while (i <= argc)
            call get_command_argument(i, arg)

            select case (trim(arg))
            case ("--m")
            if (i < argc) then
                call get_command_argument(i+1, next_arg)
                comment_val = next_arg
                i = i + 2
            end if
            case ("--o")
            if (i < argc) then
                call get_command_argument(i+1, next_arg)
                if(next_arg == "f") then
                    ActiveOutput = "False"
                else if(next_arg == "t") then
                    ActiveOutput = "True"
                else
                    ActiveOutput = "True"
                end if
                i = i + 2
            end if
            case ("--s")
            if (i < argc) then
                call get_command_argument(i+1, next_arg)
                read(next_arg, *) n_end 
                i = i + 2
            end if
            case ("--w")
            if (i < argc) then
                call get_command_argument(i+1, next_arg)
                read(next_arg, *) outputstep   ! 文字列→integerに変換
                i = i + 2
            end if
            case default
                print *, "Unknown option: ", trim(arg)
            i = i + 1
            end select
        end do

end subroutine load_args

end module information