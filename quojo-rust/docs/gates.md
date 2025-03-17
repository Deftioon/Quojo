# Quantum Gates in Quojo-Rust

Quojo-Rust provides a set of quantum gates for building quantum circuits.

## Gate Enum

Gates are represented by the `Gate` enum in the `quojo_rust::qcore::gates` module:

```rust
pub enum Gate {
    X,                       // Pauli-X (NOT) gate
    Y,                       // Pauli-Y gate
    Z,                       // Pauli-Z gate
    H,                       // Hadamard gate
    P(f64),                  // Phase rotation gate
    CNOT { control: usize, target: usize }, // Controlled-NOT
    CZ { control: usize, target: usize },   // Controlled-Z
    SWAP { qubit1: usize, qubit2: usize },  // SWAP
    Toffoli { control1: usize, control2: usize, target: usize }, // Toffoli (CCX)
    Fredkin { control: usize, target1: usize, target2: usize },  // Fredkin (CSWAP)
}
```

## Single-Qubit Gates

### Pauli X Gate (NOT)

The Pauli X gate flips the state of a qubit, similar to a classical NOT gate.

```rust
circuit.Apply(Gate::X, Targets(&[0])); // Apply X to qubit 0
```

Matrix representation:
```
X = [0 1]
    [1 0]
```

### Pauli Y Gate

The Pauli Y gate.

```rust
circuit.Apply(Gate::Y, Targets(&[0])); // Apply Y to qubit 0
```

Matrix representation:
```
Y = [0 -i]
    [i  0]
```

### Pauli Z Gate

The Pauli Z gate changes the phase of the |1⟩ state.

```rust
circuit.Apply(Gate::Z, Targets(&[0])); // Apply Z to qubit 0
```

Matrix representation:
```
Z = [1  0]
    [0 -1]
```

### Hadamard Gate (H)

The Hadamard gate creates a superposition of states.

```rust
circuit.Apply(Gate::H, Targets(&[0])); // Apply H to qubit 0
```

Matrix representation:
```
H = 1/√2 * [1  1]
           [1 -1]
```

### Phase Gate (P)

The phase gate applies a rotation around the Z-axis.

```rust
// Apply π/4 phase rotation to qubit 0 (T gate)
circuit.Apply(Gate::P(std::f64::consts::PI/4.0), Targets(&[0]));
```

Matrix representation for phase φ:
```
P(φ) = [1      0]
       [0  e^(iφ)]
```

## Two-Qubit Gates

### CNOT Gate

The Controlled-NOT gate flips the target qubit if the control qubit is |1⟩.

```rust
// CNOT with control on qubit 0 and target on qubit 1
circuit.ApplyControlled(Gate::X, 0, 1);
```

### CZ Gate

The Controlled-Z gate applies a Z gate to the target if the control is |1⟩.

```rust
// CZ with control on qubit 1 and target on qubit 2
circuit.ApplyControlled(Gate::Z, 1, 2);
```

### SWAP Gate

The SWAP gate exchanges the states of two qubits.

```rust
// Swap qubits 2 and 3
circuit.ApplySwap(2, 3);
```

## Multi-Qubit Gates

### Toffoli Gate (CCNOT)

The Toffoli gate applies an X to the target if both controls are |1⟩.

```rust
// Toffoli with control1=0, control2=1, target=2
let toffoli = Gate::Toffoli { control1: 0, control2: 1, target: 2 };
circuit.Apply(toffoli, Targets(&[0, 1, 2]));
```

### Fredkin Gate (CSWAP)

The Fredkin gate swaps two target qubits if the control is |1⟩.

```rust
// Fredkin with control=0, target1=1, target2=2
let fredkin = Gate::Fredkin { control: 0, target1: 1, target2: 2 };
circuit.Apply(fredkin, Targets(&[0, 1, 2]));
```

## Gate Decomposition

All gates can be decomposed into primitive gates, which is useful for simulation and ZX-calculus.

```rust
use quojo_rust::qcore::gates::GateDecomposition;

let gate = Gate::CNOT { control: 0, target: 1 };
let primitives = gate.decompose();

for primitive in primitives {
    println!("{:?} on qubits {:?}", primitive.gate, primitive.qubits);
}
```

### Primitive Gates

The primitive gates used in decompositions are:

- `PrimitiveGate::X`: Pauli X gate
- `PrimitiveGate::Z`: Pauli Z gate
- `PrimitiveGate::H`: Hadamard gate
- `PrimitiveGate::P(f64)`: Phase gate
- `PrimitiveGate::Connect`: Multi-qubit connection indicator

## Common Gate Combinations

### Creating a Bell State

```rust
// Create a Bell state |Φ⁺⟩ = (|00⟩ + |11⟩)/√2
circuit.Apply(Gate::H, Targets(&[0]));
circuit.ApplyControlled(Gate::X, 0, 1);
```

### Quantum Fourier Transform (2-qubit)

```rust
// 2-qubit QFT
circuit.Apply(Gate::H, Targets(&[0]));
circuit.ApplyControlled(Gate::P(std::f64::consts::PI/2.0), 1, 0);
circuit.Apply(Gate::H, Targets(&[1]));
circuit.ApplySwap(0, 1);
```
