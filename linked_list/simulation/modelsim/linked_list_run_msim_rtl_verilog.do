transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/danie/Desktop/Code/linked_list {C:/Users/danie/Desktop/Code/linked_list/memory.sv}
vlog -sv -work work +incdir+C:/Users/danie/Desktop/Code/linked_list {C:/Users/danie/Desktop/Code/linked_list/linked_list.sv}

