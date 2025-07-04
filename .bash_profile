# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH

# .aliases

TCINTE=/home/ltian/testcenter-ltian

###
### lib/bin shortcuts
###
alias cdi='cd $TCINTE/'
alias cdbin_64='cd $TCINTE/build/il/bld_ccpu_yocto_x86_64-vm-64-3.0/bin/'
alias cdlib_64='cd $TCINTE/build/il/bld_ccpu_yocto_x86_64-vm-64-3.0/lib/'
alias cdbin_32='cd $TCINTE/build/il/bld_ccpu_yocto_i686-vm-64-32-1.5/bin/'
alias cdlib_32='cd $TCINTE/build/il/bld_ccpu_yocto_i686-vm-64-32-1.5/lib/'

###
### x86_64 64bit yocto 64 compilation 
###

alias bddpdk_64=' scons -j32 -u target=dpdk_yocto arch=yocto_ccpu_x86_64 yocto_ver=3.0 wawr_support=vif'
alias bdccpu_64=' scons -j32 -u target=ccpu_yocto arch=yocto_ccpu_x86_64 yocto_ver=3.0'
alias bdccpu_prebuild_64=' scons -j32 -u target=ccpu_prebuild arch=yocto_ccpu_x86_64 yocto_ver=3.0'
alias bdstc_64='  scons -j32 -u target=stc_yocto  arch=yocto_ccpu_x86_64 yocto_ver=3.0'
alias bdl2l3_64=' APP_ARCH=x86_64 scons -j32 -u target=l2l3_yocto arch=yocto_ccpu_x86_64 yocto_ver=3.0'
alias bdut_64='   scons -j32 -u target=ccpu_utest arch=yocto_ccpu_x86_64'
alias bdhwmgrd_64=' APP_ARCH=x86_64 scons -j32 -u target=ccpu_yocto arch=yocto_ccpu_x86_64 yocto_ver=3.0'
alias bdall_64='bdccpu_prebuild_64 && bddpdk_64 && bdccpu_64 && bdstc_64 && bdl2l3_64'

###
### x86_64 32bit yocto 32 compilation 
###
alias bddpdk_32=' scons -j32 -u target=dpdk_yocto arch=yocto_x86_64 yocto_ver=1.5 wawr_support=vif'
alias bdccpu_32=' scons -j32 -u target=ccpu_yocto arch=yocto_x86_64 yocto_ver=1.5'
alias bdccpu_prebuild_32=' scons -j32 -u target=ccpu_prebuild arch=yocto_x86_64 yocto_ver=1.5'
alias bdstc_32='  scons -j32 -u target=stc_yocto  arch=yocto_x86_64 yocto_ver=1.5'
alias bdl2l3_32=' scons -j32 -u target=l2l3_yocto arch=yocto_x86_64 yocto_ver=1.5'
alias bdut_32='scons -j32 -u target=ccpu_utest'
alias bdall_32='bdccpu_prebuild_32 && bddpdk_32 && bdccpu_32 && bdstc_32 && bdl2l3_32'



