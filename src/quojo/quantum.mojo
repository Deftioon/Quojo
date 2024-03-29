import complexNum as comp
import random
from math import sin, cos
from collections.list import List
from collections.dict import Dict, KeyElement

struct QuantumGates:
    var HadamardMatrix: comp.ComplexMatrix
    var mX: comp.ComplexMatrix
    var mY: comp.ComplexMatrix
    var mZ: comp.ComplexMatrix
    var mP: comp.ComplexMatrix
    var mT: comp.ComplexMatrix
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

        self.HadamardMatrix = self.HadamardMatrix * (1 / (2.0 ** 0.5))

        # Initialise Phase Shift Gate
        self.mP = comp.ComplexMatrix(2, 2)
        self.mP[0, 0] = comp.ComplexNum(1, 0)
        self.mP[1, 1] = comp.ComplexNum(0, 1)

        self.mT = comp.ComplexMatrix(2, 2)
        self.mT[0, 0] = comp.ComplexNum(1, 0)
        self.mT[1, 1] = comp.ComplexNum(cos[DType.float64, 1](0.25 * 3.14159265358979323846), sin[DType.float64, 1](0.25 * 3.14159265358979323846))

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
        self.mP = existing.mP
        self.mT = existing.mT
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
    
    fn PhaseShift(borrowed self, other: Qubit) raises -> Qubit:
        return Qubit(other.qubit @ self.mP)
    
    fn PhaseShift(borrowed self, other: Qubit, phi: Float64) raises -> Qubit:
        var mP = comp.ComplexMatrix(2, 2)
        mP[0, 0] = comp.ComplexNum(1, 0)
        mP[1, 1] = comp.ComplexNum(cos[DType.float64, 1](phi), sin[DType.float64, 1](phi))
        return Qubit(other.qubit @ mP)
    
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

    fn P(borrowed self, other: Qubit) raises -> Qubit:
        return self.PhaseShift(other)
    
    fn S(borrowed self, other: Qubit) raises -> Qubit:
        return self.PhaseShift(other)
    
    fn T(borrowed self, other: Qubit) raises -> Qubit:
        return Qubit(other.qubit @ self.mT)
    
    fn I(borrowed self, other: Qubit) raises -> Qubit:
        return self.Identity(other)

    # Qudit Gates
    
    fn ParallelHadamard(borrowed self, states: Qudit) raises -> Qudit:
        var pH = self.HadamardMatrix
        for i in range(states.width - 1):
            pH = pH * self.HadamardMatrix
        return Qudit(states.qudit @ pH)
    
    fn ParallelPauliX(borrowed self, states: Qudit) raises -> Qudit:
        var pX = self.mX
        for i in range(states.width - 1):
            pX = pX * self.mX
        return Qudit(states.qudit @ pX)
    
    fn ParallelPauliY(borrowed self, states: Qudit) raises -> Qudit:
        var pY = self.mY
        for i in range(states.width - 1):
            pY = pY * self.mY
        return Qudit(states.qudit @ pY)
    
    fn ParallelPauliZ(borrowed self, states: Qudit) raises -> Qudit:
        var pZ = self.mZ
        for i in range(states.width - 1):
            pZ = pZ * self.mZ
        return Qudit(states.qudit @ pZ)
    
    fn ParallelPhaseShift(borrowed self, states: Qudit) raises -> Qudit:
        var mP = self.mP
        for i in range(states.width - 1):
            mP = mP * self.mP
        return Qudit(states.qudit @ mP)
    
    fn ParallelTGate(borrowed self, states: Qudit) raises -> Qudit:
        var mP = self.mT
        for i in range(states.width - 1):
            mP = mP * self.mT
        return Qudit(states.qudit @ mP)
    
    fn ParallelIdentity(borrowed self, states: Qudit) raises -> Qudit:
        var mI = self.IdentityMatrix
        for i in range(states.width - 1):
            mI = mI * self.IdentityMatrix
        return Qudit(states.qudit @ mI)
    
    fn ParallelCNOT(borrowed self, states: Qudit) raises -> Qudit:
        var pCNOT = self.mCNOT
        for i in range((states.width - 2)/2):
            pCNOT = pCNOT * self.mCNOT
        return Qudit(states.qudit @ pCNOT)
    
    fn ParallelSWAP(borrowed self, states: Qudit) raises -> Qudit:
        var pSWAP = self.mSWAP
        for i in range((states.width - 2)/2):
            pSWAP = pSWAP * pSWAP
        return Qudit(states.qudit @ pSWAP)
        
    fn ParallelCCNOT(borrowed self, states: Qudit) raises -> Qudit:
        var pCCNOT = self.mCCNOT
        for i in range((states.width - 3)/3):
            pCCNOT = pCCNOT * self.mCCNOT
        return Qudit(states.qudit @ pCCNOT)
    
    
    fn H(borrowed self, states: Qudit) raises -> Qudit:
        return self.ParallelHadamard(states)
    
    fn X(borrowed self, states: Qudit) raises -> Qudit:
        return self.ParallelPauliX(states)

    fn Y(borrowed self, states: Qudit) raises -> Qudit:
        return self.ParallelPauliY(states)

    fn Z(borrowed self, states: Qudit) raises -> Qudit:
        return self.ParallelPauliZ(states)
    
    fn P(borrowed self, states: Qudit) raises -> Qudit:
        return self.ParallelPhaseShift(states)
    
    fn S(borrowed self, states: Qudit) raises -> Qudit:
        return self.ParallelPhaseShift(states)
    
    fn T(borrowed self, states: Qudit) raises -> Qudit:
        return self.ParallelTGate(states)
    
    fn I(borrowed self, states: Qudit) raises -> Qudit:
        return self.ParallelIdentity(states)

    fn CNOT(borrowed self, states: Qudit) raises -> Qudit:
        return self.ParallelCNOT(states)

    fn SWAP(borrowed self, states: Qudit) raises -> Qudit:
        return self.ParallelSWAP(states)

    fn CCNOT(borrowed self, states: Qudit) raises -> Qudit:
        return self.ParallelCCNOT(states)

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
    
    fn __init__(inout self, size: Int) raises:
        self.width = size
        self.qudit = comp.ComplexMatrix(1, 2 ** size)
    
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