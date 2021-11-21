module eight_bit_CLA (Sum, Cout, A, B, Cin);
    input [7:0] A, B; // Make A and B 8-bit inputs
    input Cin;

    output [7:0] Sum; // Make Sum an 8-bit output
    output Cout;

    wire [7:0] G, P; // Create wires for the 8-bit generate and propagate values
    wire C1, C2, C3, C4, C5, C6, C7; // Create wires for the intermediate carry values
    wire w01, w11, w12, w21, w22, w23, w31, w32, w33, w34, w41, w42, w43, w44, w45, w51, w52, w53, w54, w55, w56, w61, w62, w63, w64, w65, w66, w67, w71, w72, w73, w74, w75, w76, w77, w78;

    wire dummy;
    // Caluclate the generation and propagation outputs for all 8-bits
    gp gp0(G[0], P[0], A[0], B[0]);
    gp gp1(G[1], P[1], A[1], B[1]);
    gp gp2(G[2], P[2], A[2], B[2]);
    gp gp3(G[3], P[3], A[3], B[3]);
    gp gp4(G[4], P[4], A[4], B[4]);
    gp gp5(G[5], P[5], A[5], B[5]);
    gp gp6(G[6], P[6], A[6], B[6]);
    gp gp7(G[7], P[7], A[7], B[7]);

    // Now for the magic! Recursively solve to take advantage of our parallelism.
    and and01(w01, Cin, P[0]); // Do we have a carry-in AND have we met the propagation condition?
    or or0(C1, G[0], w01); // Did we generate a carry-out OR are we propagating a previous carry-in?

    and and11(w11, Cin, P[0], P[1]); // Do we have an initial carry-in AND have we met both of the propagation conditions?
    and and12(w12, G[0], P[1]); // Have we met the propagation condition for this bit AND did we meet the generation condition last bit?
    or or1(C2, G[1], w11, w12); // So on and so forth...

    and and21(w21, Cin, P[0], P[1], P[2]);
    and and22(w22, G[0], P[1], P[2]);
    and and23(w23, G[1], P[2]);
    or or2(C3, G[2], w21, w22, w23);

    and and31(w31, Cin, P[0], P[1], P[2], P[3]);
    and and32(w32, G[0], P[1], P[2], P[3]);
    and and33(w33, G[1], P[2], P[3]);
    and and34(w34, G[2], P[3]);
    or or3(C4, G[3], w31, w32, w33, w34);

    and and41(w41, Cin, P[0], P[1], P[2], P[3], P[4]);
    and and42(w42, G[0], P[1], P[2], P[3], P[4]);
    and and43(w43, G[1], P[2], P[3], P[4]);
    and and44(w44, G[2], P[3], P[4]);
    and and45(w45, G[3], P[4]);
    or or4(C5, G[4], w41, w42, w43, w44, w45);

    and and51(w51, Cin, P[0], P[1], P[2], P[3], P[4], P[5]);
    and and52(w52, G[0], P[1], P[2], P[3], P[4], P[5]);
    and and53(w53, G[1], P[2], P[3], P[4], P[5]);
    and and54(w54, G[2], P[3], P[4], P[5]);
    and and55(w55, G[3], P[4], P[5]);
    and and56(w56, G[4], P[5]);
    or or5(C6, G[5], w51, w52, w53, w54, w55, w56);

    and and61(w61, Cin, P[0], P[1], P[2], P[3], P[4], P[5], P[6]);
    and and62(w62, G[0], P[1], P[2], P[3], P[4], P[5], P[6]);
    and and63(w63, G[1], P[2], P[3], P[4], P[5], P[6]);
    and and64(w64, G[2], P[3], P[4], P[5], P[6]);
    and and65(w65, G[3], P[4], P[5], P[6]);
    and and66(w66, G[4], P[5], P[6]);
    and and67(w67, G[5], P[6]);
    or or6(C7, G[6], w61, w62, w63, w64, w65, w66, w67);

    and and71(w71, Cin, P[0], P[1], P[2], P[3], P[4], P[5], P[6], P[7]);
    and and72(w72, G[0], P[1], P[2], P[3], P[4], P[5], P[6], P[7]);
    and and73(w73, G[1], P[2], P[3], P[4], P[5], P[6], P[7]);
    and and74(w74, G[2], P[3], P[4], P[5], P[6], P[7]);
    and and75(w75, G[3], P[4], P[5], P[6], P[7]);
    and and76(w76, G[4], P[5], P[6], P[7]);
    and and77(w77, G[5], P[6], P[7]);
    and and78(w78, G[6], P[7]);
    or or7(Cout, G[7], w71, w72, w73, w74, w75, w76, w77, w78);

    // Finally, generate the xor-ed Sum values for all 8-bits
    xor Sum0(Sum[0], Cin, A[0], B[0]);
    xor Sum1(Sum[1], C1, A[1], B[1]);
    xor Sum2(Sum[2], C2, A[2], B[2]);
    xor Sum3(Sum[3], C3, A[3], B[3]);
    xor Sum4(Sum[4], C4, A[4], B[4]);
    xor Sum5(Sum[5], C5, A[5], B[5]);
    xor Sum6(Sum[6], C6, A[6], B[6]);
    xor Sum7(Sum[7], C7, A[7], B[7]);


endmodule