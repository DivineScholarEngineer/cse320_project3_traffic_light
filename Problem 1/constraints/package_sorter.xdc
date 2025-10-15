## Problem 1 (Simulation-focused). If you map to a board, wire these ports appropriately.
## Use your board's master XDC to fill in PACKAGE_PIN and IOSTANDARD.
## Example shows logical nets only; replace PIN names for your FPGA board (e.g., Nexys A7, Basys3).

# Clock (replace with your board clock pin, e.g., W5 and 100 MHz create_clock in master XDC)
#set_property PACKAGE_PIN W5 [get_ports clk]
#set_property IOSTANDARD LVCMOS33 [get_ports clk]
#create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# Reset (e.g., CPU_RESETN on some boards or BTN0)
#set_property PACKAGE_PIN U18 [get_ports reset]
#set_property IOSTANDARD LVCMOS33 [get_ports reset]

# Weight from switches SW[11:0] (example pins; replace with your board's SW pins)
#foreach i 0 1 2 3 4 5 6 7 8 9 10 11 {
#  set_property PACKAGE_PIN <PIN> [get_ports {weight[$i]}]
#  set_property IOSTANDARD LVCMOS33 [get_ports {weight[$i]}]
#}

# currentGrp to LEDs [2:0]
# set_property PACKAGE_PIN <LED2_PIN> [get_ports {currentGrp[2]}]
# set_property PACKAGE_PIN <LED1_PIN> [get_ports {currentGrp[1]}]
# set_property PACKAGE_PIN <LED0_PIN> [get_ports {currentGrp[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {currentGrp[*]}]

## For counters (Grp1..Grp6), you may route selected bits to LEDs or seven-seg as desired.
