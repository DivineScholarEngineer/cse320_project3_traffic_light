# Problem 1 – Package Sorter
- Design: `src/package_sorter.v`
- Testbench: `tb/tb_package_sorter.v`
- Constraints (template): `constraints/package_sorter.xdc` (fill in board pins from your master XDC)
Run sim with Icarus:
```
iverilog -g2012 -o p1.vvp tb/tb_package_sorter.v src/package_sorter.v && vvp p1.vvp
gtkwave tb_package_sorter.vcd
```
