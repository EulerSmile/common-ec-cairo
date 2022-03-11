# common-ec-cairo

A Cairo implementation of common elliptic curve, can be used with different parameters for different curves.

For now, it only support 256-bit curve. 

#### Outsourcing computing

We use Python to compute the complex field computing, and verify the correctness in Cairo. 

#### How to use it?

All common elliptic curve Cairo implementations are in ec directory.

See [examples/example.cairo](examples/example.cairo) to see Secp256k1 or NIST P-256 demo.

Developers should change domain parameters in [ec/param_def.cairo](ec/param_def.cairo) for different curves, and use different test data in example.cairo.

Parameters is in 3-limbs format, each limb is in range of [0, 2^86), you can use `split.py` to split a big number into 3 limbs.