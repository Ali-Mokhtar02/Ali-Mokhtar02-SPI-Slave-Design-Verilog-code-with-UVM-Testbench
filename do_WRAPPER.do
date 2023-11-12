vlib work
vlog -f compile.txt +cover -covercells
vsim -voptargs=+acc work.Top_WRAPPER -cover -classdebug -uvmcontrol=all 
add wave /Top_WRAPPER/WRAPPER_if/*
add wave /Top_WRAPPER/WRAPPER_insta/wrap_sva_insta/Asynchronous_reset /Top_WRAPPER/WRAPPER_insta/wrap_sva_insta/MOSI_read_ap /Top_WRAPPER/WRAPPER_insta/wrap_sva_insta/MOSI_Write_ap /Top_WRAPPER/WRAPPER_insta/wrap_sva_insta/SS_correct_sequence_Readadd_ap /Top_WRAPPER/WRAPPER_insta/wrap_sva_insta/SS_correct_sequence_ReadData_ap /Top_WRAPPER/WRAPPER_insta/wrap_sva_insta/SS_correct_sequence_write_ap
coverage save ucdb_WRAPPER.ucdb -du SPI_Wrapper -onexit
run 0
add wave -position insertpoint  \
sim:/uvm_root/uvm_test_top/WRAPPER_test_env/WRAPPER_env_agent/WRAPPER_agent_driver/stim_seq_item
run -all
coverage report -detail -cvg -directive -comments -output fcover_WRAPPER.txt {}