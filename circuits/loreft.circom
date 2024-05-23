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

template loreft (r,d) {
    signal input h[d];
    signal input R[r][d];
    signal input W[r][d];
    signal input b[r];

    // signal output h_hash;
    signal output out_hash[d]; // TODO: not hashed yet
    
    component W_h = matMul(r,d,1); // W @ h
    component R_h = matMul(r,d,1); // R @ h
    component add_b = matAdd(r,1); // W @ h + b
    component sub_R_h = matAdd(r,1); // W @ h + b - R @ h
    component R_T_mul = matMul(d,r,1); // R.T @ (W @ h + b - R @ h)
    component out = matAdd(d,1); // h + R.T @ (W @ h + b - R @h)

    for (var i=0; i<r; i++) {
        for (var j=0; j<d; j++) {
            W_h.a[i][j] <== W[i][j];
            R_h.a[i][j] <== R[i][j];
            R_T_mul.a[j][i] <== R[i][j];
        }
    }

    for (var i=0; i<d; i++) {
        W_h.b[i][0] <== h[i];
        R_h.b[i][0] <== h[i];

        out.a[i][0] <== h[i];
    }

    for (var i=0; i<r; i++) {
        add_b.a[i][0] <== W_h.out[i][0];
        add_b.b[i][0] <== b[i];
    }

    for (var i=0; i<r; i++) {
        sub_R_h.a[i][0] <== add_b.out[i][0];
        sub_R_h.b[i][0] <== -R_h.out[i][0];
    }

    for (var i=0; i<r; i++) {
        R_T_mul.b[i][0] <== sub_R_h.out[i][0];
    }

    for (var i=0; i<d; i++) {
        out.b[i][0] <== R_T_mul.out[i][0];
    }

    for (var i=0; i<d; i++) {
        out_hash[i] <== out.out[i][0];
    }
}

component main = loreft(8, 4096);