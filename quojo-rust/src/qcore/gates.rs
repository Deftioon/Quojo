// TODO: custom unitary gates

use std::fmt::Display;

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Gate {
    X,
    Y,
    Z,
    H,
    P(f64),
    CNOT { control: usize, target: usize },
    CZ { control: usize, target: usize },
    SWAP { qubit1: usize, qubit2: usize },
    Toffoli { control1: usize, control2: usize, target: usize }, // CCX
    Fredkin { control: usize, target1: usize, target2: usize },  // CSWAP
}

impl Display for Gate {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Gate::X => write!(f, "X"),
            Gate::Y => write!(f, "Y"),
            Gate::Z => write!(f, "Z"),
            Gate::H => write!(f, "H"),
            Gate::P(phase) => write!(f, "P({})", phase),
            Gate::CNOT { control, target } => write!(f, "CNOT({},{})", control, target),
            Gate::CZ { control, target } => write!(f, "CZ({},{})", control, target),
            Gate::SWAP { qubit1, qubit2 } => write!(f, "SWAP({},{})", qubit1, qubit2),
            Gate::Toffoli { control1, control2, target } => 
                write!(f, "Toffoli({},{},{})", control1, control2, target),
            Gate::Fredkin { control, target1, target2 } => 
                write!(f, "Fredkin({},{},{})", control, target1, target2),
        }
    }
}

pub trait GateDecomposition {
    fn decompose(&self) -> Vec<DecomposedGate>;
}

#[derive(Debug, Clone)]
pub struct DecomposedGate {
    pub gate: PrimitiveGate,
    pub qubits: Vec<usize>,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum PrimitiveGate {
    X,
    Z,
    H,
    P(f64),
    Connect,
}

impl GateDecomposition for Gate {
    fn decompose(&self) -> Vec<DecomposedGate> {
        match self {
            Gate::X => vec![DecomposedGate { 
                gate: PrimitiveGate::X, 
                qubits: vec![0] 
            }],
            Gate::Z => vec![DecomposedGate { 
                gate: PrimitiveGate::Z, 
                qubits: vec![0] 
            }],
            Gate::H => vec![DecomposedGate { 
                gate: PrimitiveGate::H, 
                qubits: vec![0] 
            }],
            Gate::P(phase) => vec![DecomposedGate { 
                gate: PrimitiveGate::P(*phase), 
                qubits: vec![0] 
            }],
            Gate::CNOT { control, target } => vec![
                DecomposedGate { gate: PrimitiveGate::H, qubits: vec![*target] },
                DecomposedGate { gate: PrimitiveGate::Z, qubits: vec![*control, *target] },
                DecomposedGate { gate: PrimitiveGate::H, qubits: vec![*target] },
                DecomposedGate { gate: PrimitiveGate::Connect, qubits: vec![*control, *target] },
            ],
            Gate::CZ { control, target } => vec![
                DecomposedGate { gate: PrimitiveGate::Z, qubits: vec![*control, *target] },
                DecomposedGate { gate: PrimitiveGate::Connect, qubits: vec![*control, *target] },
            ],
            Gate::SWAP { qubit1, qubit2 } => vec![
                // SWAP = 3 consecutive CNOTs
                // First CNOT
                DecomposedGate { gate: PrimitiveGate::H, qubits: vec![*qubit2] },
                DecomposedGate { gate: PrimitiveGate::Z, qubits: vec![*qubit1, *qubit2] },
                DecomposedGate { gate: PrimitiveGate::H, qubits: vec![*qubit2] },
                // Second CNOT
                DecomposedGate { gate: PrimitiveGate::H, qubits: vec![*qubit1] },
                DecomposedGate { gate: PrimitiveGate::Z, qubits: vec![*qubit2, *qubit1] },
                DecomposedGate { gate: PrimitiveGate::H, qubits: vec![*qubit1] },
                // Third CNOT
                DecomposedGate { gate: PrimitiveGate::H, qubits: vec![*qubit2] },
                DecomposedGate { gate: PrimitiveGate::Z, qubits: vec![*qubit1, *qubit2] },
                DecomposedGate { gate: PrimitiveGate::H, qubits: vec![*qubit2] },
                DecomposedGate { gate: PrimitiveGate::Connect, qubits: vec![*qubit1, *qubit2] },
            ],
            // TODO: Additional decompositions for Toffoli and Fredkin WILL GO HERE
            _ => vec![],
        }
    }
}
