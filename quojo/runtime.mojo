from collections import List
from complex import ComplexSIMD
import .qubit as qubit
import .linalg as linalg
import .gates as gates

alias CS = ComplexSIMD[DType.float64, 1]
alias ROOT2 = 1.4142135623730951

alias HADAMARD = generate_hadamard_gate()
alias PAULI_X = generate_pauli_x_gate()
alias PAULI_Y = generate_pauli_y_gate()
alias PAULI_Z = generate_pauli_z_gate()
alias IDENTITY = generate_identity_gate()
alias CNOT = generate_cnot_gate()
alias SWAP = generate_swap_gate()

fn generate_hadamard_gate() -> gates.QuantumGate[2, 2]:
    var gate = gates.QuantumGate[2, 2]()
    gate.set_matrix(
        CS(1.0 / ROOT2, 0.0), CS(1.0 / ROOT2, 0.0),
        CS(1.0 / ROOT2, 0.0), CS(-1.0 / ROOT2, 0.0)
    )
    return gate

fn generate_pauli_x_gate() -> gates.QuantumGate[2, 2]:
    var gate = gates.QuantumGate[2, 2]()
    gate.set_matrix(
        CS(0.0, 0.0), CS(1.0, 0.0),
        CS(1.0, 0.0), CS(0.0, 0.0)
    )
    return gate

fn generate_pauli_y_gate() -> gates.QuantumGate[2, 2]:
    var gate = gates.QuantumGate[2, 2]()
    gate.set_matrix(
        CS(0.0, 0.0), CS(0.0, -1.0),
        CS(0.0, 1.0), CS(0.0, 0.0)
    )
    return gate

fn generate_pauli_z_gate() -> gates.QuantumGate[2, 2]:
    var gate = gates.QuantumGate[2, 2]()
    gate.set_matrix(
        CS(1.0, 0.0), CS(0.0, 0.0),
        CS(0.0, 0.0), CS(-1.0, 0.0)
    )
    return gate

fn generate_identity_gate() -> gates.QuantumGate[2, 2]:
    var gate = gates.QuantumGate[2, 2]()
    gate.set_matrix(
        CS(1.0, 0.0), CS(0.0, 0.0),
        CS(0.0, 0.0), CS(1.0, 0.0)
    )
    return gate

fn generate_cnot_gate() -> gates.QuantumGate[4, 4]:
    var gate = gates.QuantumGate[4, 4]()
    gate.set_matrix(
        CS(1.0, 0.0), CS(0.0, 0.0), CS(0.0, 0.0), CS(0.0, 0.0),
        CS(0.0, 0.0), CS(1.0, 0.0), CS(0.0, 0.0), CS(0.0, 0.0),
        CS(0.0, 0.0), CS(0.0, 0.0), CS(0.0, 0.0), CS(1.0, 0.0),
        CS(0.0, 0.0), CS(0.0, 0.0), CS(1.0, 0.0), CS(0.0, 0.0)
    )
    return gate

fn generate_swap_gate() -> gates.QuantumGate[4, 4]:
    var gate = gates.QuantumGate[4, 4]()
    gate.set_matrix(
        CS(1.0, 0.0), CS(0.0, 0.0), CS(0.0, 0.0), CS(0.0, 0.0),
        CS(0.0, 0.0), CS(0.0, 0.0), CS(1.0, 0.0), CS(0.0, 0.0),
        CS(0.0, 0.0), CS(1.0, 0.0), CS(0.0, 0.0), CS(0.0, 0.0),
        CS(0.0, 0.0), CS(0.0, 0.0), CS(0.0, 0.0), CS(1.0, 0.0)
    )
    return gate

struct Runtime(StringableRaising):
    var qubits: List[qubit.Qubit]

    fn __init__(out self):
        self.qubits = List[qubit.Qubit]()

    fn __str__(self) raises -> String:
        return "Quantum Runtime"

    fn __getitem__(self, index: Int) -> ref[self.qubits] qubit.Qubit:
        return self.qubits[index]

    fn AddQubit(mut self, state: Int):
        self.qubits.append(qubit.Qubit(state))
    
    fn hadamard(mut self, qubit_index: Int):
        self.qubits[qubit_index].apply_gate(HADAMARD)
    
    fn pauli_x(mut self, qubit_index: Int):
        self.qubits[qubit_index].apply_gate(PAULI_X)
    
    fn pauli_y(mut self, qubit_index: Int):
        self.qubits[qubit_index].apply_gate(PAULI_Y)
    
    fn pauli_z(mut self, qubit_index: Int):
        self.qubits[qubit_index].apply_gate(PAULI_Z)
    
    fn identity(mut self, qubit_index: Int):
        self.qubits[qubit_index].apply_gate(IDENTITY)