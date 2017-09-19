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
source /cad/cshrc/synopsys_local.csh

setenv RISCV_PATH   /cad/toolchain/riscv/riscv-linux-toolchain
setenv UVM_HOME     /cad/uvm/uvm-1.2
setenv ACE_PATH     `pwd | perl -pe "s/ace.*/ace/"`

alias dace          'cd $ACE_PATH; pwd; ls -F'
alias dfilelist     'cd $ACE_PATH/rtl/filelist; pwd; ls -F'
alias dcore         'cd $ACE_PATH/rtl/core;     pwd; ls -F'
alias dlint         'cd $ACE_PATH/asic/lint;    pwd; ls -F'
alias duvm          'cd $ACE_PATH/sim/uvm;      pwd; ls -F'
alias dasic         'cd $ACE_PATH/asic;         pwd; ls -F'
alias dfpga         'cd $ACE_PATH/fpga;         pwd; ls -F'

