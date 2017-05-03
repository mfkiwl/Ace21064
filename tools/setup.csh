#//////////////////////////////////////////////////////////////////////////////////////////
#//
#//  File Name   : setup.csh
#//  Author      : ejune@aureage.com
#//                
#//  Description : 
#//                
#//                
#//                
#//  Create Date : original_time
#//  Version     : v0.1 
#//
#//////////////////////////////////////////////////////////////////////////////////////////
source /eda_tools/synopsys_local.csh

setenv RISCV_PATH   /eda_tools/toolchain/riscv/riscv-linux-toolchain
setenv UVM_HOME     /eda_tools/uvm/uvm-1.2
setenv ACE_PATH     `pwd | perl -pe "s/ace.*/ace/"`

alias ace           'cd $ACE_PATH; pwd; ls -F'
alias dfilelist     'cd $ACE_PATH/rtl/filelist; pwd; ls -F'
alias dcore         'cd $ACE_PATH/rtl/Ace21064; pwd; ls -F'
alias duvm          'cd $ACE_PATH/sim/uvm;      pwd; ls -F'
alias dasic         'cd $ACE_PATH/asic;         pwd; ls -F'
alias dfpga         'cd $ACE_PATH/fpga;         pwd; ls -F'

