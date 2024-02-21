import complexNum as comp

struct QuantumGates:

    var HadamardMatrix: comp.ComplexMatrix
    var X: comp.ComplexMatrix
    var Y: comp.ComplexMatrix
    var Z: comp.ComplexMatrix

    fn __init__(inout self) raises:

        # Initialise Hadamard Gate
        self.HadamardMatrix = comp.ComplexMatrix(2, 2)
        self.HadamardMatrix[0, 0] = comp.ComplexNum(1, 0)
        self.HadamardMatrix[0, 1] = comp.ComplexNum(1, 0)
        self.HadamardMatrix[1, 0] = comp.ComplexNum(1, 0)
        self.HadamardMatrix[1, 1] = comp.ComplexNum(-1, 0)

        self.HadamardMatrix = self.HadamardMatrix * (1 / (2 ** 0.5))

        # Initialise Pauli- X,Y,Z Gates
        self.X = comp.ComplexMatrix(2, 2)
        self.X[0, 1] = comp.ComplexNum(1, 0)
        self.X[1, 0] = comp.ComplexNum(1, 0)

        self.Y = comp.ComplexMatrix(2, 2)
        self.Y[0, 1] = comp.ComplexNum(0, -1)
        self.Y[1, 0] = comp.ComplexNum(0, 1)

        self.Z = comp.ComplexMatrix(2, 2)
        self.Z[0, 0] = comp.ComplexNum(1, 0)
        self.Z[1, 1] = comp.ComplexNum(-1, 0)

    fn Hadamard(borrowed self, other: Qubit) raises -> comp.ComplexMatrix:
        return self.HadamardMatrix @ other.qubit
    
    fn PauliX(borrowed self, other: Qubit) raises -> comp.ComplexMatrix:
        return self.X @ other.qubit
    
    fn PauliY(borrowed self, other: Qubit) raises -> comp.ComplexMatrix:
        return self.Y @ other.qubit
    
    fn PauliZ(borrowed self, other: Qubit) raises -> comp.ComplexMatrix:
        return self.Z @ other.qubit

struct Qubit:
    var qubit: comp.ComplexMatrix

    fn __init__(inout self, state: StringLiteral) raises:
        # Initialise Qubit
        if state != "0" and state != "1":
            raise "Invalid Qubit State"

        self.qubit = comp.ComplexMatrix(1, 2)
        self.qubit[0, atol(state)] = comp.ComplexNum(1, 0)

    fn print(borrowed self) raises:
        for i in range(2):
            print(self.qubit[0, i].re, self.qubit[0, i].im)
        
struct Qudit:
    var width: Int
    var qubit: comp.ComplexMatrix

    fn __init__(inout self, state: StringLiteral) raises:
        var Stringed = String(state)
        self.width = len(Stringed)
        var binint = atol(Stringed)
        var statePhase = 0
        var power = 0
        while binint > 0:
            statePhase += 2 ** power * (binint % 10)
            binint = binint // 10
            power += 1
        
        self.qubit = comp.ComplexMatrix(1, self.width*2)
        self.qubit[0, statePhase] = comp.ComplexNum(1, 0)

fn main() raises:
    var State = Qubit("11")
    State.print()