const chai = require("chai");
const path = require("path");

const wasm_tester = require("circom_tester").wasm;

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const assert = chai.assert;

const INPUT = require("./input.json");
const OUTPUT = require("./output.json");

describe("loreft test", function () {
    this.timeout(100000000);

    it("should return correct output", async () => {
        const circuit = await wasm_tester(path.join(__dirname, "test.circom"));

        const witness = await circuit.calculateWitness(INPUT, true);


        assert(Fr.eq(Fr.e(witness[0]),Fr.e(1)));
        for (let i = 0; i < 4096; i++) {
            assert(Fr.eq(Fr.e(witness[1 + i]),Fr.e(OUTPUT[i])));
        }
    });
});