# IB-LBM (CUDA Fortran)

[English](README.md) | [日本語 (Japanese)](README.ja.md)

Immersed Boundary Lattice Boltzmann Method (IB-LBM) [[2]](#reference) を用いて、**3次元球の後方に生じるカルマン渦**の数値シミュレーションを行うプログラムである。
3次元15速度モデル(D3Q15)の Lattice Boltzmann Model を用いた数値シミュレーションプログラムであり、CUDA Fortran で実装され、NVIDIA GPU 上で動作する。

## 計算手法

### 流体の計算

流体の計算には Lattice Boltzmann Method(LBM)を用いる。速度モデルは3次元15速度モデル(D3Q15)である。

### Immersed Boundary Method

物体境界の取り扱いには Immersed Boundary Method(IBM)を用いる。
境界上で no-slip 条件を満たすための体積力の計算には、Multi Direct Forcing Method(MDFN)[[2]](#reference) を用いる。

## 初期設定の計算領域

初期設定では、以下の条件で計算を行う。

| 項目 | 設定 |
|---|---|
| Z 方向境界条件 | 圧力差の境界条件(Zou-He の圧力境界条件 [[1]](#reference)) |
| X, Y 方向境界条件 | 周期境界条件 |
| 領域サイズ (X, Y, Z) | 1.0, 1.0, 4.0 |
| メッシュ数 (X, Y, Z) | 128, 128, 128×4 |
| 格子幅 | dx = 1/128.0 |
| 球の半径 | 20.0 dx |
| 球の中心座標 | [64.0 dx, 64.0 dx, 128.0 dx] |

## 動作環境

- NVIDIA GPU(CUDA 対応)
- NVIDIA HPC SDK(`nvfortran` コンパイラ)
- 並列 HDF5 ライブラリ

### 必要モジュール

HPC クラスタ環境では、コンパイル・実行前に以下のモジュールをロードする必要がある。

```bash
module load hpc_sdk
module load hdf5_pararell
```

## ディレクトリ構成

```
3D15Q_IBLBM/
├── README.md
└── src_IB/            # プログラムファイル・ディレクトリ
    ├── Makefile    # ビルド用 Makefile
    └── (ソースファイル一式)
```

## ビルド方法

`src_IB` ディレクトリに移動し、`make` を実行する。
実行ファイルは Makefile と同じディレクトリ(`src_IB/`)に生成される。

```bash
cd src_IB
make
```

## 実行前の準備(重要)

実行ファイルが生成される場所(Makefile と同じ `src_IB/` ディレクトリ)に、
出力用の `output` ディレクトリをあらかじめ作成しておく必要がある。

```bash
cd src_IB
mkdir output
```

`output` ディレクトリが存在しない場合、計算結果の出力に失敗する。

## 実行方法

実行は MPI 経由で行う。

```bash
cd src_IB
mpirun -np 1 ./Run_lbm3d
```

### コマンドラインオプション

| オプション | 内容 | 例 |
|---|---|---|
| `--m "メッセージの内容"` | 実行時にメッセージを追加する。追加したメッセージは `output/flowdata_(実行時の時刻)/Flowinformation.txt` 内に記録される | `./Run_lbm3d --m "Message"` |
| `--o f` / `--o t` | 出力の有無を切り替える(`f`: 出力オフ、`t`: 出力あり)。このオプションを指定しない場合、デフォルトは `t`(出力あり)である | `./Run_lbm3d --o f` |
| `--s (整数)` | 最大ステップ数を指定する(整数型、初期値: 5000) | `./Run_lbm3d --s 10000` |
| `--w (整数)` | 書き込みステップ数を指定する(整数型、初期値: 1000) | `./Run_lbm3d --w 500` |

使用例:

```bash
# メッセージを付けて実行
mpirun -np 1 ./Run_lbm3d --m "test run"

# 出力をオフにして実行
mpirun -np 1 ./Run_lbm3d --o f

# 両方を指定して実行
mpirun -np 1 ./Run_lbm3d --m "no output run" --o f

# 最大ステップ数と書き込みステップ数を指定して実行
mpirun -np 1 ./Run_lbm3d --s 10000 --w 500
```

### 実行前の確認: MPI のパス

実行前に、使用される MPI が `hpcz` モジュール直下のものになっていることを確認する必要がある。

```bash
which mpirun
```

出力されたパスが `hpcz` モジュールのインストールディレクトリ配下を指していれば正常である。
別の MPI(システム標準の MPI など)のパスが表示される場合は、モジュールのロード順や環境設定を見直すこと。

## 出力内容

計算結果は、実行のたびに `output/` 以下に実行時の時刻を名前に含むディレクトリ `flowdata_(実行時の時刻)/` が作成され、その中に出力される。

```
output/
└── flowdata_(実行時の時刻)/
    ├── Flowinformation.txt    # 実行情報の記録ファイル
    └── (速度場データ)
```

| 出力データ | 内容 |
|---|---|
| 速度場データ | 3 次元の速度場 (u, v, w) |
| `Flowinformation.txt` | 実行情報の記録ファイル。`--m` オプションで指定したメッセージもここに記録される |

## Reference

[1] Q. Zou and X. He, "On pressure and velocity boundary conditions for the lattice Boltzmann BGK model," *Physics of Fluids*, Vol. 9, No. 6, pp. 1591–1598 (1997).

[2] K. Suzuki and T. Inamuro, "Effect of internal mass in the simulation of a moving body by the immersed boundary method," *Computers & Fluids*, Vol. 49, No. 1, pp. 173–187 (2011).

## 更新履歴

| 日付 | バージョン | 内容 |
|---|---|---|
| 2026/07/13 | ver1.0 | プログラムの公開 |

