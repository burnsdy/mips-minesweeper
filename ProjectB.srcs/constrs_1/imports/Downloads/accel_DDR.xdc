## Clock signal
#  Use an XDC file for the clock signal

## Sound
#  Use an XDC file for the sound generator

##7 segment display
#  Use an XDC file for the segmented display


##Accelerometer
set_property -dict { PACKAGE_PIN E15   IOSTANDARD LVCMOS33 } [get_ports { aclMISO }]; #IO_L11P_T1_SRCC_15 Sch=acl_miso
set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS33 } [get_ports { aclMOSI }]; #IO_L5N_T0_AD9N_15 Sch=acl_mosi
set_property -dict { PACKAGE_PIN F15   IOSTANDARD LVCMOS33 } [get_ports { aclSCK }]; #IO_L14P_T2_SRCC_15 Sch=acl_sclk
set_property -dict { PACKAGE_PIN D15   IOSTANDARD LVCMOS33 } [get_ports { aclSS }]; #IO_L12P_T1_MRCC_15 Sch=acl_csn
