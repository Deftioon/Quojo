import complexNum as comp
import random
from math import sin, cos

struct QuantumGates:

    var HadamardMatrix: comp.ComplexMatrix
    var mX: comp.ComplexMatrix
    var mY: comp.ComplexMatrix
    var mZ: comp.ComplexMatrix
    var mCNOT: comp.ComplexMatrix

    fn __init__(inout self) raises:

        # Initialise Hadamard Gate
        self.HadamardMatrix = comp.ComplexMatrix(2, 2)
        self.HadamardMatrix[0, 0] = comp.ComplexNum(1, 0)
        self.HadamardMatrix[0, 1] = comp.ComplexNum(1, 0)
        self.HadamardMatrix[1, 0] = comp.ComplexNum(1, 0)
        self.HadamardMatrix[1, 1] = comp.ComplexNum(-1, 0)

        self.HadamardMatrix = self.HadamardMatrix * (1 / (2 ** 0.5))

        # Initialise Pauli- X,Y,Z Gates
        self.mX = comp.ComplexMatrix(2, 2)
        self.mX[0, 1] = comp.ComplexNum(1, 0)
        self.mX[1, 0] = comp.ComplexNum(1, 0)

        self.mY = comp.ComplexMatrix(2, 2)
        self.mY[0, 1] = comp.ComplexNum(0, -1)
        self.mY[1, 0] = comp.ComplexNum(0, 1)

        self.mZ = comp.ComplexMatrix(2, 2)
        self.mZ[0, 0] = comp.ComplexNum(1, 0)
        self.mZ[1, 1] = comp.ComplexNum(-1, 0)

        # Initialise CNOT Gate
        self.mCNOT = comp.ComplexMatrix(4, 4)
        self.mCNOT[0, 0] = comp.ComplexNum(1, 0)
        self.mCNOT[1, 1] = comp.ComplexNum(1, 0)
        self.mCNOT[2, 3] = comp.ComplexNum(1, 0)
        self.mCNOT[3, 2] = comp.ComplexNum(1, 0)

    # One Qubit Gates

    fn Hadamard(borrowed self, other: Qubit) raises -> Qubit:
        return Qubit(other.qubit @ self.HadamardMatrix)
    
    fn PauliX(borrowed self, other: Qubit) raises -> Qubit:
        return Qubit(other.qubit @ self.mX)
    
    fn PauliY(borrowed self, other: Qubit) raises -> Qubit:
        return Qubit(other.qubit @ self.mY)
    
    fn PauliZ(borrowed self, other: Qubit) raises -> Qubit:
        return Qubit(other.qubit @ self.mZ)
    
    fn PhaseShift(borrowed self, other: Qubit, phi: Float64) raises -> Qubit:
        var mP = comp.ComplexMatrix(2, 2)
        mP[0, 0] = comp.ComplexNum(1, 0)
        mP[1, 1] = comp.ComplexNum(cos[DType.float64, 1](phi), sin[DType.float64, 1](phi))
        return Qubit(other.qubit @ mP)
    
    fn PhaseMatrix(borrowed self, phi: Float64) raises -> comp.ComplexMatrix:
        var mP = comp.ComplexMatrix(2, 2)
        mP[0, 0] = comp.ComplexNum(1, 0)
        mP[1, 1] = comp.ComplexNum(cos[DType.float64, 1](phi), sin[DType.float64, 1](phi))
        return mP

    fn H(borrowed self, other: Qubit) raises -> Qubit:
        return self.Hadamard(other)
    
    fn X(borrowed self, other: Qubit) raises -> Qubit:
        return self.PauliX(other)
    
    fn Y(borrowed self, other: Qubit) raises -> Qubit:
        return self.PauliY(other)
    
    fn Z(borrowed self, other: Qubit) raises -> Qubit:
        return self.PauliZ(other)

    fn P(borrowed self, other: Qubit, phi: Float64) raises -> Qubit:
        return self.PhaseShift(other, phi)
    
    fn S(borrowed self, other: Qubit, phi: Float64) raises -> Qubit:
        return self.PhaseShift(other, phi)
    
    # Two Qubit Gates
    
    fn CNOT(borrowed self, other: Qudit) raises -> Qudit:
        return Qudit(other.qudit @ self.mCNOT)

    fn CU(borrowed self, other: Qudit, gate: comp.ComplexMatrix):
        var mCU = comp.ComplexMatrix(4, 4)
        mCU[0, 0] = comp.ComplexNum(1, 0)
        mCU[1, 1] = comp.ComplexNum(1, 0)
        mCU[2, 2] = gate[0, 0]
        mCU[2, 3] = gate[0, 1]
        mCU[3, 2] = gate[1, 0]
        mCU[3, 3] = gate[1, 1]
        return Qudit(other.qudit @ mCU)

    fn mCU(borrowed self, gate: comp.ComplexMatrix) raises -> comp.ComplexMatrix:
        var mCU = comp.ComplexMatrix(4, 4)
        mCU[0, 0] = comp.ComplexNum(1, 0)
        mCU[1, 1] = comp.ComplexNum(1, 0)
        mCU[2, 2] = gate[0, 0]
        mCU[2, 3] = gate[0, 1]
        mCU[3, 2] = gate[1, 0]
        mCU[3, 3] = gate[1, 1]
        return mCU

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
    
    fn __init__(inout self) raises:
        self.qubit = comp.ComplexMatrix(1, 2)
    
    fn __copyinit__(inout self, existing: Self):
        self.qubit = existing.qubit

    fn __getitem__(borrowed self, index: Int) raises -> comp.ComplexNum:
        return self.qubit[0, index]
    
    fn __setitem__(inout self, index: Int, value: comp.ComplexNum) raises:
        self.qubit[0, index] = value

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

    fn __init__(inout self, size: Int) raises:
        self.width = size
        self.qudit = comp.ComplexMatrix(1, size * 2)
    
    fn __init__(inout self, state: comp.ComplexMatrix) raises:
        self.width = state.rows * 2
        self.qudit = state
    
    fn __getitem__(borrowed self, index: Int) raises -> Qubit:
        if index < 0 or index >= self.width:
            raise "Index out of range"
        var result = Qubit()
        result[0] = self.qudit[0, index * 2]
        result[1] = self.qudit[0, index * 2 + 1]
        return result

    fn __setitem__(inout self, index: Int, value: Qubit) raises:
        if index < 0 or index >= self.width:
            raise "Index out of range"
        self.qudit[0, index * 2] = value[0]
        self.qudit[0, index * 2 + 1] = value[1]
    
    fn print(borrowed self) raises:
        for i in range(self.width):
            print(self.qudit[0, i * 2].re, self.qudit[0, i * 2].im)
            print(self.qudit[0, i * 2 + 1].re, self.qudit[0, i * 2 + 1].im)
    
fn main() raises:
    var q = Qubit("0")
    var p = Qubit("1")
    var reg = Qudit(2)
    reg[0] = q
    reg[1] = p
    var g = QuantumGates()
    var r = g.CNOT(reg)
    r.print()https://github.com/Deftioon/Quojo