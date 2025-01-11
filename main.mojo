import quojo as qj

fn main() raises:
    var Runtime = qj.Runtime()
    Runtime.AddQubit(0)
    Runtime.AddQubit(1)

    Runtime.hadamard(0)
    Runtime.pauli_z(1)
    print(str(Runtime.qubits[0]))
    print(str(Runtime.qubits[1]))