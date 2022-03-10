# common-ec-cairo

A Cairo implementation of common Elliptic Curve, can be used with different parameters for different curves.

For now, it only support 256-bit curve. 


#### Outsourcing computing

We use Python to compute the complex field computing, and verify the correctness in Cairo. 

#### How to use it?

See [src/example.cairo](src/example.cairo) to start.

Developers should change domain parameters in [src/param_def.cairo](src/param_def.cairo) for different curves, and use different test data in example.cairo.

Parameters is in 3-limbs format, each limb is in range of [0, 2^86), you can use `split.py` to split a big number into 3 limbs.