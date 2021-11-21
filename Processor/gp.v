module gp(G, P, A, B);
    input A, B;
    output G, P;
    
    and generate_carry(G, A, B);
    or propagate_carry(P, A, B);
endmodule