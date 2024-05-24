export NODE_OPTIONS=--max_old_space_size=524288

cd circuits
# check if ptau file exists
if [ ! -f "powersOfTau28_hez_final_22.ptau" ]; then
    echo "Downloading ptau file"
    wget https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_22.ptau
fi

circom circuit.circom --r1cs --wasm
cd circuit_js
node generate_witness.js circuit.wasm ../../test/input.json ../witness.wtns
cd ..
snarkjs groth16 setup circuit.r1cs powersOfTau28_hez_final_22.ptau circuit_0000.zkey
snarkjs zkey contribute circuit_0000.zkey circuit_final.zkey --name="1st Contributor Name" -v -e="random"
snarkjs zkey export verificationkey circuit_final.zkey verification_key.json
gtime -o ../bench_hash_prove.out -v snarkjs groth16 prove circuit_final.zkey witness.wtns proof.json public.json
gtime -o ../bench_hash_verify.out -v snarkjs groth16 verify verification_key.json public.json proof.json
