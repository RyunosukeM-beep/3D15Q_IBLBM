module IBMparams
    use kinds
    use cudafor
    use LBMparams
    implicit none
    
    !粒子のパラメーター
    integer:: numpoints  !ラグランジュ点の数
    integer,device :: dnumpoints
    real(dp),parameter :: hradius = 20.0_dp
    real(dp),device :: radius
    real(dp),parameter :: hcenter(3) = [64_dp,64_dp,128_dp] !中心座標
    real(dp),device :: center(3)

    real(dp), dimension(:,:), allocatable, device :: p_pos !粒子の位置
    real(dp), dimension(:,:), allocatable, device :: p_vel !粒子の速度
    real(dp),parameter :: pvel0(3) = [0.0_dp,0.0_dp,0.0_dp]
    real(dp),device :: dV
    real(dp),device :: dds
    real(dp),device :: ds_lat
    real(dp) :: hdv

    !体積力計算に関わる部分
    integer,parameter :: MDFNnp = 10 !MDFNの繰り返しの最大数　基本5程度で収束する
    real(dp),parameter :: eps_condition = 1.0e-5_dp !収束条件
    real(dp),dimension(:),allocatable,device :: eps !体積力の収束判定条件
    real(dp),dimension(:),allocatable :: heps
    
    real(dp), dimension(:,:), allocatable, device :: Gforce
    real(dp), dimension(:,:), allocatable, device :: vel_pstd
    real(dp), dimension(:,:,:), allocatable, device :: collect_tmp
    real(dp), dimension(:,:,:), allocatable, device :: collect_tmp_G

    !real(dp), dimension(:,:,:,:), allocatable, device :: latticeF

    integer,dimension(:,:),allocatable,device :: test
    integer,dimension(:,:),allocatable :: htest


    type(dim3) :: blockIB = dim3(32, 4, 4)          ! x:128スレッド, y:4スレッド(=全域), z:4スレッド(=全域)
    type(dim3) :: gridIB 

    type(dim3) :: blockIB2 = dim3(128, 1, 1)          ! x:128スレッド, y:4スレッド(=全域), z:4スレッド(=全域)
    type(dim3) :: gridIB2 
 
  end module IBMparams
