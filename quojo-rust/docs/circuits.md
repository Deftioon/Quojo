# Quantum Circuits in Quojo-Rust

Quojo-Rust provides a representation for quantum circuits through the `CircuitRepr` struct.

## Circuit Representation

The `CircuitRepr` struct represents a quantum circuit with a fixed width (number of qubits). It stores quantum gates for each qubit in order.

```rust
pub struct CircuitRepr<const WIDTH: usize> {
    pub storage: [Vec<Gate>; WIDTH],
}
```

The constant generic parameter `WIDTH` determines the number of qubits in the circuit.

## Creating Circuits

To create a new circuit, use:

```rust
use quojo_rust::qcore::CircuitRepr;

// Create a 4-qubit circuit
let mut circuit = CircuitRepr::<4>();
```

## Adding Gates to Circuits

### Single-Qubit Gates

To apply single-qubit gates to one or more qubits:

```rust
use quojo_rust::qcore::{Targets};
use quojo_rust::qcore::gates::Gate;

// Apply Hadamard to qubits 0 and 1
circuit.Apply(Gate::H, Targets(&[0, 1]));

// Apply X (NOT) gate to qubit 2
circuit.Apply(Gate::X, Targets(&[2]));

// Apply phase rotation gate to qubit 0
let phase = std::f64::consts::PI / 4.0; // π/4 rotation
circuit.Apply(Gate::P(phase), Targets(&[0]));
```

### Two-Qubit Gates

For two-qubit gates like CNOT and CZ:

```rust
// CNOT with control on qubit 0 and target on qubit 1
circuit.ApplyControlled(Gate::X, 0, 1);

// CZ with control on qubit 1 and target on qubit 2
circuit.ApplyControlled(Gate::Z, 1, 2);

// SWAP qubits 2 and 3
circuit.ApplySwap(2, 3);
```

## Available Gates

Quojo-Rust provides several standard quantum gates:

- `Gate::X`: Pauli-X (NOT) gate
- `Gate::Y`: Pauli-Y gate
- `Gate::Z`: Pauli-Z gate
- `Gate::H`: Hadamard gate
- `Gate::P(float)`: Phase rotation gate
- `Gate::CNOT`: Controlled-NOT gate
- `Gate::CZ`: Controlled-Z gate
- `Gate::SWAP`: SWAP gate
- `Gate::Toffoli`: Toffoli (CCX) gate
- `Gate::Fredkin`: Fredkin (CSWAP) gate

For more details, see [gates.md](gates.md).

## Displaying Circuits

You can use the `Display` trait to print a textual representation of the circuit:

```rust
println!("{}", circuit);
```

## Visualizing Circuits

Quojo-Rust provides TikZ visualization for quantum circuits:

```rust
use quojo_rust::qcore::TikzConfig;
use quojo_rust::qcore::tikz::TikzCircuit;

// Create TikZ visualization config
let config = TikzConfig();

// Generate and save the visualization
circuit.save_tikz(&config, "circuit.tex").unwrap();
```

For more visualization options, see [visualization.md](visualization.md).

## Example: Bell State Preparation

Here's a complete example of creating a Bell state preparation circuit:

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
    
    // Visualize the circuit
    let config = TikzConfig();
    circuit.save_tikz(&config, "bell_state.tex").unwrap();
}
```
