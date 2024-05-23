pragma circom 2.1.9;

include "../circuits/loreft.circom";

component main { public [h] } = loreft(8, 4096);