## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project
## - CASE SENSITIVE: make sure the port names here exactly match those in your top level!

## Clock signal
set_property PACKAGE_PIN W5 [get_ports mclk]							
	set_property IOSTANDARD LVCMOS33 [get_ports mclk]
	create_clock -add -name mclk -period 10.00 -waveform {0 5} [get_ports mclk]

set_property PACKAGE_PIN L1 [get_ports led]
    set_property IOSTANDARD LVCMOS33 [get_ports led]
    
##Pmod Header JB
##Sch name = JB1
set_property PACKAGE_PIN A14 [get_ports {sound}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sound}]


## These additional constraints are recommended by Digilent, do not remove!
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]