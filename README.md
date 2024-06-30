# common-ec-cairo

A Cairo implementation of common elliptic curve, can be used with different parameters for different curves.

For now, it only support 256-bit curve. 

🎉🎉 __The code we implemented in this library was officially adopted by Cairo and added to the core code base, see [Cairo v0.8.2](https://github.com/starkware-libs/cairo-lang/commit/082af75faa8e3a099bae8183e017398e211121f5#diff-858e1866160c8c69a06e8cbde98843126fa185dc17e03dd5f69ffe7a6ff9d47a) release log.__

## Outsourcing computing

We use Python to compute the complex field computing, and verify the correctness in Cairo. Especially, we use [ff-cairo](https://github.com/EulerSmile/ff-cairo) do finite field operations.

## How to use it?

All common elliptic curve Cairo implementations are in `ec` directory.

See [examples/example.cairo](examples/example.cairo) for some examples of usage of this repo, i.e. Secp256k1 or NIST P-256.

Developers should change domain parameters in [ec/param_def.cairo](ec/param_def.cairo) for different curves, and use different test data in example.


*Parameters is in 3-limbs format, each limb is in range of [0, 2^86), you can use `split.py` to split a big number into 3 limbs.*

## License
[MIT License](https://opensource.org/licenses/MIT) © EulerSmile
