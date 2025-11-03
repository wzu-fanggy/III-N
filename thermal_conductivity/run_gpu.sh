#!/bin/bash -x
#PBS -N BNr4
#PBS -l select=1:ncpus=4:ngpus=1:host=cn61 
#PBS -j oe
#PBS -q gpuq


cd $PBS_O_WORKDIR

# 使用 select 语法，指定节点和资源

# 设置 CUDA 环境变量
export PATH="/share/apps/cuda-11.8/bin:$PATH"
export LD_LIBRARY_PATH="/share/apps/cuda-11.8/lib64:$LD_LIBRARY_PATH"

if [ -f "/home/cjin/anaconda3/etc/profile.d/conda.sh" ]; then
    . "/home/cjin/anaconda3/etc/profile.d/conda.sh"
else
    export PATH="/home/cjin/anaconda3/bin:$PATH"
fi

conda activate dp_lmp



# 运行 LAMMPS 热传导模拟
echo "开始运行 LAMMPS 热传导模拟..."
lmp -i in.thermal_conductivity
echo "LAMMPS 模拟完成"



export TempDir="/home/cjin/temp/$PBS_JOBID"  # 使用用户有权限的目录
mkdir -p $TempDir
if [ $? -ne 0 ];then
    echo "TempDir Create Failed!";exit
fi
cd $TempDir
#copy files to temp dir
cp $PBS_O_WORKDIR/* .

#command line
pmemd.cuda -O -i pH_12.mdin -p com.mod0.parm7 -c 12_com.md1.rst7 -cpin com.cpin -o 12_com.md1.mdout -cpout 12_com.md1.cpout -r 12_com.md1.rst7 -x 12_com.md1.nc -cprestrt 12_com.md1.cpin

#copy files back to PBS_O_WORKDIR
cp -rf $TempDir/* $PBS_O_WORKDIR
#remove temp dir
rm -rf $TempDir

