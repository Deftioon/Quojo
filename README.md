# Quojo
A Quantum Computing Simulation written in Mojo. This really only serves as one of my passion projects, but I would like it to expand into a larger platform for Quantum Development. Moved to a Python adaptation, (PyQ)[https://github.com/Deftioon/PyQ]

## Goals
This project aims to:
- Provide an easy to use, comprehensible, and simple interface to simulate operations on a Quantum System
  - This will be done with a simple `QuantumWire("H X Y H")` Quantum Wiring Syntax, `Circuit.Connect(Wire, Wire)` Quantum Circuitry Syntax to give full freedom on the customizability of Quantum Circuits.
- Fast, Parallelized Compute on Quantum Operations.
  - This will make use of Mojo's fast parallelization, tiling, and autotune to optimize Matrix operations. Eventually when enabled to run on GPU, we will utilize GPU to perform matrix operations for more speed.

## TODO:
- Implement Uncomputing
- Implement Quantum RAM
- Implement Quantum Circuits
- Add Sample Programs (Quantum Search, Quantum Teleportation)
- Optimize code and make it more readable
  - Parallelize Quantum Gates

## Usage
See [USAGE.md](USAGE.md)

## Complex Number Module
See [COMPLEX.md](COMPLEX.md)

## Sample Programs
### Quantum Search
With a classical computer, a linear search has time complexity $O(n)$. With a Quantum Computer, a Quantum Search has time complexity $O(\sqrt{n})$.
