import complexNum as comp
import random
from math import sin, cos
from collections.vector import DynamicVector

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
    
    fn S(borrowed self, other: Qubit, phi: Float64) raises -> Qubit:
        return self.PhaseShift(other, phi)
    
    fn I(borrowed self, other: Qubit) raises -> Qubit:
        return self.Identity(other)
    
    # Two Qubit Gates
    
    fn CNOT(borrowed self, other: Qudit) raises -> Qudit:
        if other.width != 2:
            raise "Invalid Qudit Size"
        return Qudit(other.qudit @ self.mCNOT)
    
    fn CX(borrowed self, other: Qudit) raises -> Qudit:
        return self.CNOT(other)

    fn CU(borrowed self, other: Qudit, gate: comp.ComplexMatrix) raises -> Qudit:
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

    fn SWAP(borrowed self, other: Qudit) raises -> Qudit:
        return Qudit(other.qudit @ self.mSWAP)
    
    # Three Qubit Gates

    fn CCNOT(borrowed self, other: Qudit) raises -> Qudit:
        var state_vector = (other[0].qubit * other[1].qubit) * other[2].qubit
        #return Qudit(state_vector @ self.mCCNOT)
        var result = Qubit()
        result[1] = state_vector[0,6]
        result[0] = state_vector[0,7]
        var output = Qudit(3)
        output[0] = other[0]
        output[1] = other[1]
        output[2] = result
        return output
    
    fn CCX(borrowed self, other: Qudit) raises -> Qudit:
        return self.CCNOT(other)

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
    var width: Int
    var qudit: comp.ComplexMatrix

    fn __init__(inout self, size: Int) raises:
        self.width = size
        self.qudit = comp.ComplexMatrix(1, 2 * size)
    
    fn __init__(inout self, state: comp.ComplexMatrix) raises:
        self.width = 2 * state.rows 
        self.qudit = state
    
    fn __copyinit__(inout self, existing: Self):
        self.width = existing.width
        self.qudit = existing.qudit

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
        self.qudit.print()

struct QuantumWire:
    var g: QuantumGates
    var wire: DynamicVector[String]
    var valid_states: String

    fn __init__(inout self) raises:
        self.g = QuantumGates()
        self.wire = DynamicVector[String]()
        self.valid_states = "H X Y Z M I"

    fn __init__(inout self, states: String) raises:
        self.g = QuantumGates()
        var split_state = states.rstrip().lstrip().split(" ")
        self.valid_states = "H X Y Z M I"
        self.wire = DynamicVector[String]()
        for i in range(len(split_state)):
            if self.valid_states.find(split_state[i]) == -1:
                raise "Invalid State in String"
            self.wire.push_back(split_state[i])
        
    fn __copyinit__(inout self, existing: Self):
        self.g = existing.g
        self.wire = existing.wire
        self.valid_states = existing.valid_states
    
    fn help(borrowed self) raises:
        print("-------QUANTUM WIRE HELP--------")
        print('Valid States: "I H X Y Z M"')
        print("I: Identity Gate")
        print("H: Hadamard Gate")
        print("X: Pauli-X Gate")
        print("Y: Pauli-Y Gate")
        print("Z: Pauli-Z Gate")
        print("M: Measure Qubit")
        print("--------------------------------")
    
    fn add(inout self, state: String) raises:
        if self.valid_states.find(state) == -1:
                raise "Invalid State in String"
        self.wire.push_back(state)
    
    fn pop(inout self) raises -> String:
        return self.wire.pop_back()
    
    fn print(borrowed self) raises:
        print_no_newline("▯ -")
        for i in range(len(self.wire)):
            print_no_newline(self.wire[i])
            print_no_newline("-")
        print_no_newline(">")
        print()

    fn parse(inout self, applied: Qubit) raises -> Qubit:
        var temp = applied
        var result = Qubit()
        for i in range(len(self.wire)):
            if self.wire[i] == "I":
                result = self.g.I(temp)
            elif self.wire[i] == "H":
                result = self.g.H(temp)
            elif self.wire[i] == "X":
                result = self.g.X(temp)
            elif self.wire[i] == "Y":
                result = self.g.Y(temp)
            elif self.wire[i] == "Z":
                result = self.g.Z(temp)
            elif self.wire[i] == "M":
                result = temp.measure()
            else:
                raise "Invalid State in Wire"
            temp = result
        return result


fn main() raises:
    var wire = QuantumWire("I M")
    wire.help()
    var qubit = Qubit("0")
    var res = wire.parse(qubit)