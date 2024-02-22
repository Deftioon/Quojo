import complexNum as comp
import random
from math import sin, cos

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

    fn Hadamard(borrowed self, other: Qubit) raises -> Qubit:
        return Qubit(other.qubit @ self.HadamardMatrix)
    
    fn PauliX(borrowed self, other: Qubit) raises -> Qubit:
        return Qubit(other.qubit @ self.X)
    
    fn PauliY(borrowed self, other: Qubit) raises -> Qubit:
        return Qubit(other.qubit @ self.Y)
    
    fn PauliZ(borrowed self, other: Qubit) raises -> Qubit:
        return Qubit(other.qubit @ self.Z)
    
    fn PhaseShift(borrowed self, other: Qubit, phi: Float64) raises -> Qubit:
        var P = comp.ComplexMatrix(2, 2)
        P[0, 0] = comp.ComplexNum(1, 0)
        P[1, 1] = comp.ComplexNum(cos[DType.float64, 1](phi), sin[DType.float64, 1](phi))
        return Qubit(P @ other.qubit)

    fn Ha(borrowed self, other: Qubit) raises -> Qubit:
        return self.Hadamard(other)
    
    fn pX(borrowed self, other: Qubit) raises -> Qubit:
        return self.PauliX(other)
    
    fn pY(borrowed self, other: Qubit) raises -> Qubit:
        return self.PauliY(other)
    
    fn pZ(borrowed self, other: Qubit) raises -> Qubit:
        return self.PauliZ(other)

    fn Ps(borrowed self, other: Qubit, phi: Float64) raises -> Qubit:
        return self.PhaseShift(other, phi)
    
    fn St(borrowed self, other: Qubit, phi: Float64) raises -> Qubit:
        return self.PhaseShift(other, phi)
    

struct Qubit:
    var qubit: comp.ComplexMatrix

    fn __init__(inout self, state: StringLiteral) raises:
        # Initialise Qubit
        if state != "0" and state != "1":
            raise "Invalid Qubit State"

        self.qubit = comp.ComplexMatrix(1, 2)
        self.qubit[0, atol(state)] = comp.ComplexNum(1, 0)
    
    fn __init__(inout self, state: comp.ComplexMatrix) raises:
        self.qubit = state
    
    fn __copyinit__(inout self, existing: Self):
        self.qubit = existing.qubit

    fn print(borrowed self) raises:
        for i in range(2):
            print(self.qubit[0, i].re, self.qubit[0, i].im)
        
    fn measure(inout self) raises:
        var randNum = random.random_float64(0.0, 1.0)
        var alpha = (self.qubit[0, 0] * self.qubit[0,0]).magnitude()
        if randNum < alpha:
            self.qubit = comp.ComplexMatrix(1, 2)
            self.qubit[0, 0] = comp.ComplexNum(1, 0)
        else:
            self.qubit = comp.ComplexMatrix(1, 2)
            self.qubit[0, 1] = comp.ComplexNum(1, 0)

        self.qubit.print()
        
struct Qudit:
    var width: Int
    var qudit: comp.ComplexMatrix

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
        
        self.qudit = comp.ComplexMatrix(1, self.width*2)
        self.qudit[0, statePhase] = comp.ComplexNum(1, 0)
    
fn main() raises:
    var State = Qubit("1")
    var Gates = QuantumGates()
    var Circ = Gates.Hadamard(Gates.PauliZ(Gates.PauliY(Gates.Hadamard(State))))
    Circ.print()
    Circ.measure()
