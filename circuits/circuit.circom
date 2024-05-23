pragma circom 2.1.9;

include "loreft.circom";
include "../node_modules/circomlib/circuits/mimc.circom";

template loreft_hashed (r,d) {
    signal input h[d][1];
    signal input R[r][d];
    signal input W[r][d];
    signal input b[r][1];

    signal output h_hash;
    signal output out_hash;

    component reft = loreft(r,d);

    reft.h <== h;
    reft.R <== R;
    reft.W <== W;
    reft.b <== b;

    component hash_h = MultiMiMC7(d, 91);
    component hash_out = MultiMiMC7(d, 91);

    hash_h.k <== 0;
    hash_out.k <== 0;

    for (var i=0; i<d; i++) {
        hash_h.in[i] <== h[i][0];
        hash_out.in[i] <== reft.out[i][0];
    }

    h_hash <== hash_h.out;
    out_hash <== hash_out.out;

}

component main = loreft_hashed(8, 4096);