import complexNum as comp
import random
from math import sin, cos
from collections.vector import DynamicVector
from collections.dict import Dict, KeyElement

@value
struct StringKey(KeyElement):
    var s: String

    fn __init__(inout self, owned s: String):
        self.s = s ^

    fn __init__(inout self, s: StringLiteral):
        self.s = String(s)

    fn __hash__(self) -> Int:
        let ptr = self.s._buffer.data.value
        return hash(DTypePointer[DType.int8](ptr), len(self.s))

    fn __eq__(self, other: Self) -> Bool:
        return self.s == other.s

struct QuantumGates:

    var HadamardMatrix: comp.ComplexMatrix
    var mX: comp.ComplexMatrix
    var mY: comp.ComplexMatrix
    var mZ: comp.ComplexMatrix
    var mCNOT: comp.ComplexMatrix
    var mSWAP: comp.ComplexMatrix
    var mCCNOT: comp.ComplexMatrix
    var IdentityMatrix: comp.ComplexMatrix

    fn __init__(inout self) raises:

        # Initialise Identity Gate
        self.IdentityMatrix = comp.ComplexMatrix(2, 2)
        self.IdentityMatrix[0, 0] = comp.ComplexNum(1, 0)
        self.IdentityMatrix[1, 1] = comp.ComplexNum(1, 0)

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

        # Initialise SWAP Gate
        self.mSWAP = comp.ComplexMatrix(4, 4)
        self.mSWAP[0, 0] = comp.ComplexNum(1, 0)
        self.mSWAP[1, 2] = comp.ComplexNum(1, 0)
        self.mSWAP[2, 1] = comp.ComplexNum(1, 0)
        self.mSWAP[3, 3] = comp.ComplexNum(1, 0)

        # CCNOT Gate
        self.mCCNOT = comp.ComplexMatrix(8, 8)
        self.mCCNOT[0, 0] = comp.ComplexNum(1, 0)
        self.mCCNOT[1, 1] = comp.ComplexNum(1, 0)
        self.mCCNOT[2, 2] = comp.ComplexNum(1, 0)
        self.mCCNOT[3, 3] = comp.ComplexNum(1, 0)
        self.mCCNOT[4, 4] = comp.ComplexNum(1, 0)
        self.mCCNOT[5, 5] = comp.ComplexNum(1, 0)
        self.mCCNOT[6, 7] = comp.ComplexNum(1, 0)
        self.mCCNOT[7, 6] = comp.ComplexNum(1, 0)

    fn __copyinit__(inout self, existing: Self):
        self.HadamardMatrix = existing.HadamardMatrix
        self.mX = existing.mX
        self.mY = existing.mY
        self.mZ = existing.mZ
        self.mCNOT = existing.mCNOT
        self.mSWAP = existing.mSWAP
        self.mCCNOT = existing.mCCNOT
        self.IdentityMatrix = existing.IdentityMatrix

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
    
    fn Identity(borrowed self, other: Qubit) raises -> Qubit:
        return Qubit(other.qubit @ self.IdentityMatrix)

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
    
    fn S(borrowed self, other: Qubit) raises -> Qubit:
        return self.PhaseShift(other, 0.5 * 3.14159265358979323846)
    
    fn I(borrowed self, other: Qubit) raises -> Qubit:
        return self.Identity(other)
    
    # One Qudit Gates
    fn Hadamard(borrowed self, state: Qudit) raises -> Qudit:
        if state.width != 1:
            raise "Invalid Qudit Width"
        return Qudit(state.qudit @ self.HadamardMatrix)
    
    fn PauliX(borrowed self, state: Qudit) raises -> Qudit:
        if state.width != 1:
            raise "Invalid Qudit Width"
        return Qudit(state.qudit @ self.mX)
    
    fn PauliY(borrowed self, state: Qudit) raises -> Qudit:
        if state.width != 1:
            raise "Invalid Qudit Width"
        return Qudit(state.qudit @ self.mY)
    
    fn PauliZ(borrowed self, state: Qudit) raises -> Qudit:
        if state.width != 1:
            raise "Invalid Qudit Width"
        return Qudit(state.qudit @ self.mZ)
    
    fn PhaseShift(borrowed self, state: Qudit) raises -> Qudit:
        if state.width != 1:
            raise "Invalid Qudit Width"
        var mP = comp.ComplexMatrix(2, 2)
        mP[0, 0] = comp.ComplexNum(1, 0)
        mP[1, 1] = comp.ComplexNum(0, 1)
        return Qudit(state.qudit @ mP)
    
    fn Identity(borrowed self, state: Qudit) raises -> Qudit:
        if state.width != 1:
            raise "Invalid Qudit Width"
        return Qudit(state.qudit @ self.IdentityMatrix)
    
    fn H(borrowed self, state: Qudit) raises -> Qudit:
        return self.Hadamard(state)
    
    fn X(borrowed self, state: Qudit) raises -> Qudit:
        return self.PauliX(state)
    
    fn Y(borrowed self, state: Qudit) raises -> Qudit:
        return self.PauliY(state)
    
    fn Z(borrowed self, state: Qudit) raises -> Qudit:
        return self.PauliZ(state)
    
    fn P(borrowed self, state: Qudit, phi: Float64) raises -> Qudit:
        return self.PhaseShift(state)
    
    fn S(borrowed self, state: Qudit) raises -> Qudit:
        return self.PhaseShift(state)
    
    fn T(borrowed self, state: Qudit) raises -> Qudit:
        if state.width != 1:
            raise "Invalid Qudit Width"
        var mP = comp.ComplexMatrix(2, 2)
        mP[0, 0] = comp.ComplexNum(1, 0)
        mP[1, 1] = comp.ComplexNum(cos[DType.float64, 1](0.25 *3.141592653589793), sin[DType.float64, 1](0.25 *3.141592653589793))
        return Qudit(state.qudit @ mP)
    
    fn I(borrowed self, state: Qudit) raises -> Qudit:
        return self.Identity(state)
    
    # Two Qubit Gates
    fn CNOT(borrowed self, state: Qudit) raises -> Qudit:
        return Qudit(state.qudit @ self.mCNOT)
    
    fn SWAP(borrowed self, state: Qudit) raises -> Qudit:
        return Qudit(state.qudit @ self.mSWAP)
    
    # Three Qubit Gates
    fn CCNOT(borrowed self, state: Qudit) raises -> Qudit:
        return Qudit(state.qudit @ self.mCCNOT)
    
    # Parallel Gates
    fn ParallelHadamard(borrowed self, states: Qudit) raises -> Qudit:
        var pH = self.HadamardMatrix
        for i in range(states.width - 1):
            pH = pH * self.HadamardMatrix
        return Qudit(states.qudit @ pH)


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
        
    fn measure(inout self) raises -> Qubit:
        random.seed()
        var randNum = random.random_float64()
        var alpha = (self.qubit[0, 0] * self.qubit[0,0]).magnitude()
        if randNum < alpha:
            self.qubit = comp.ComplexMatrix(1, 2)
            self.qubit[0, 0] = comp.ComplexNum(1, 0)
        else:
            self.qubit = comp.ComplexMatrix(1, 2)
            self.qubit[0, 1] = comp.ComplexNum(1, 0)

        print("Measured Qubit: ")
        self.qubit.print()
        return self
        
struct Qudit:
    var qudit: comp.ComplexMatrix
    var width: Int

    fn __init__(inout self, state: String) raises:
        self.width = len(state)
        self.qudit = comp.ComplexMatrix(1, 2 ** self.width)
        var binary_num = atol(state)
        var decimal_num = 0
        var power = 0

        while binary_num > 0:
            decimal_num += 2 ** power * (binary_num % 10)
            binary_num = binary_num // 10
            power += 1
        
        self.qudit[0, decimal_num] = comp.ComplexNum(1, 0)
    
    fn __init__(inout self, state: comp.ComplexMatrix) raises:
        self.width = state.cols
        self.qudit = state
    
    fn __copyinit__(inout self, existing: Self):
        self.width = existing.width
        self.qudit = existing.qudit
    
    fn __getitem__(borrowed self, index: Int) raises -> comp.ComplexNum:
        return self.qudit[0, index]
    
    fn __setitem__(inout self, index: Int, value: comp.ComplexNum) raises:
        self.qudit[0, index] = value
    
    fn print(borrowed self) raises:
        self.qudit.print()
    
    fn measure(inout self) raises -> None:
        random.seed()
        var randNum = random.random_float64()
        var sum: Float64 = 0.0
        var index = 0
        
        for i in range(self.width):
            sum += (self.qudit[0, i] * self.qudit[0, i]).magnitude()
            if randNum < sum:
                index = i
                break
        
        self.qudit = comp.ComplexMatrix(1, self.width)
        self.qudit[0, index] = comp.ComplexNum(1, 0)
        self.print()

fn main() raises:
    var g = QuantumGates()
    var q = Qudit("111")
    var h = g.ParallelHadamard(q)
    h.measure()