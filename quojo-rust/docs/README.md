# Quojo-Rust Documentation

Quojo-Rust is a quantum computing toolkit written in Rust that provides tools for:

- Creating and manipulating quantum circuits
- Working with ZX-calculus for quantum circuit optimization
- Visualizing quantum circuits and ZX-graphs

## Table of Contents

1. [Getting Started](getting-started.md)
2. [Quantum Circuits](circuits.md)
3. [Quantum Gates](gates.md)
4. [ZX-Calculus](zx-calculus.md)
5. [Visualization](visualization.md)

## Project Overview

Quojo-Rust implements tools for quantum computing simulation, optimization, and visualization. The main components are:

- Circuit representation (`CircuitRepr`)
- Quantum gates and operations
- ZX-calculus graph representation (ZXGraph)
- TikZ visualization for both quantum circuits and ZX-graphs

## Basic Example

Here's a simple example of creating a circuit and visualizing it:

```rust
use quojo_rust::qcore::{CircuitRepr, Targets, TikzConfig};
use quojo_rust::qcore::gates::Gate;
use quojo_rust::qcore::tikz::TikzCircuit;

fn main() {
    // Create a 2-qubit circuit
    let mut circuit = CircuitRepr::<2>();
    
    // Apply a Hadamard gate to the first qubit
    circuit.Apply(Gate::H, Targets(&[0]));
    
    // Apply a CNOT gate with control on qubit 0 and target on qubit 1
    circuit.ApplyControlled(Gate::X, 0, 1);
    
    // Create a TikZ visualization of the circuit
    let config = TikzConfig();
    circuit.save_tikz(&config, "bell_state.tex").unwrap();
}
```

This creates a Bell state preparation circuit and visualizes it using TikZ.

## Contributing

Contributions to Quojo-Rust are welcome!

## License

This project is licensed under [LICENSE](../../LICENSE) - see the file for details.
