module triBuff #(parameter SIZE = 32) (in, oe, out);
    input[SIZE-1:0] in;
    input oe;
    output[SIZE-1:0] out;
    
    assign out = oe ? in : {SIZE{1'bz}}; 

endmodule