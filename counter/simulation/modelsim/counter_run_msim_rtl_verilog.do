transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/danie/Desktop/Code/counter {C:/Users/danie/Desktop/Code/counter/counter.sv}
vlog -sv -work work +incdir+C:/Users/danie/Desktop/Code/counter {C:/Users/danie/Desktop/Code/counter/memory.sv}

