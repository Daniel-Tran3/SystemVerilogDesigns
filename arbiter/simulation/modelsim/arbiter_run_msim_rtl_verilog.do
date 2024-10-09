transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/danie/Desktop/Code/arbiter {C:/Users/danie/Desktop/Code/arbiter/arbiter.sv}

