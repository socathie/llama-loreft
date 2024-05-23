pragma circom 2.1.9;

// ref: https://arxiv.org/pdf/2404.03592

// h + R.T @ (W @ h + b - R @h)
// r: rank (8)
// d: representation dimension (4096)
// R: rotation matrix (r, d) (8, 4096)
// W: weight (8, 4096)
// b: bias (8,)
// h: hidden state (4096,)

include "../node_modules/circomlib-matrix/circuits/matAdd.circom";
include "../node_modules/circomlib-matrix/circuits/matMul.circom";
include "../node_modules/circomlib-matrix/circuits/transpose.circom";

template loreft (r,d) {
    signal input h[d][1];
    signal input R[r][d];
    signal input W[r][d];
    signal input b[r][1];

    signal output out[d][1];
    
    component R_T = transpose(r,d);
    component W_h = matMul(r,d,1); // W @ h
    component R_h = matMul(r,d,1); // R @ h
    component add_b = matAdd(r,1); // W @ h + b
    component sub_R_h = matAdd(r,1); // W @ h + b - R @ h
    component R_T_mul = matMul(d,r,1); // R.T @ (W @ h + b - R @ h)
    component add_h = matAdd(d,1); // h + R.T @ (W @ h + b - R @h)

    R_T.a <== R;

    W_h.a <== W;
    W_h.b <== h;

    R_h.a <== R;
    R_h.b <== h;

    add_b.a <== W_h.out;
    add_b.b <== b;

    sub_R_h.a <== add_b.out;
    for (var i=0; i<r; i++) {
        sub_R_h.b[i][0] <== -R_h.out[i][0];
    }

    R_T_mul.a <== R_T.out;
    R_T_mul.b <== sub_R_h.out;

    add_h.a <== h;
    add_h.b <== R_T_mul.out;

    out <== add_h.out;
}