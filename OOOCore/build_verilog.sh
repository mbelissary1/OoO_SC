#!/usr/bin/env bash

ls *?.v > module.txt

for test_file in tests/*.mem; do
    file_name=`echo $test_file | sed 's/.mem//'`
    iverilog -o ${file_name} -c FileList.txt -s main_tb -Wimplicit -P main_tb.FILE=\"${file_name}\" > icarus_output.txt 2>&1
done

exit $?