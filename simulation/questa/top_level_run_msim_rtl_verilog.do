transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+D:/Desktop/9-bit-processor {D:/Desktop/9-bit-processor/reg_file.sv}
vlog -sv -work work +incdir+D:/Desktop/9-bit-processor {D:/Desktop/9-bit-processor/PC.sv}
vlog -sv -work work +incdir+D:/Desktop/9-bit-processor {D:/Desktop/9-bit-processor/immed_LUT.sv}
vlog -sv -work work +incdir+D:/Desktop/9-bit-processor {D:/Desktop/9-bit-processor/dat_mem.sv}
vlog -sv -work work +incdir+D:/Desktop/9-bit-processor {D:/Desktop/9-bit-processor/Control.sv}
vlog -sv -work work +incdir+D:/Desktop/9-bit-processor {D:/Desktop/9-bit-processor/alu.sv}
vlog -sv -work work +incdir+D:/Desktop/9-bit-processor {D:/Desktop/9-bit-processor/instr_ROM.sv}
vlog -sv -work work +incdir+D:/Desktop/9-bit-processor {D:/Desktop/9-bit-processor/top_level.sv}

