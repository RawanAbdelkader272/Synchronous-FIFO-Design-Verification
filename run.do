vlib work
vlog *.sv  +cover -covercells +define+SIM
vsim -voptargs=+acc work.top -cover 
coverage save FIFO.ucdb -onexit -du FIFO
run -all