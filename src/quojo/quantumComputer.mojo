import quantum as Q
from quantum import QuantumGates as Gates
import complexNum as comp

# https://arxiv.org/pdf/2309.14432.pdf
struct QuantumRAM:
    var Bus: quantum.Qudit
    var top: Int
    var capacity: Int
    var addresses: DynamicVector[Int]
    var data: comp.ComplexArray

    fn __init__(inout self, size: Int) raises:
        var state: String = ""
        for i in range(size):
            state += "0"
        
        self.Bus = Q.Qudit(state)
        self.top = 0
        self.capacity = size
        self.addresses = DynamicVector[Int]()
        self.data = comp.ComplexArray(2 ** size)
    
    fn store(inout self, qubit: Q.Qubit) raises:
        var size = 2
        if self.top + size > 2 ** self.capacity:
            raise "Quantum RAM Does Not have Enough Space"

        for i in range(size):
            self.data[self.top + i] = qubit.qubit[0, i]
        
        self.addresses.push_back(self.top)
        self.top += size
    
    fn store(inout self, qudit: Q.Qudit) raises:
        var size = 2 ** qudit.width
        if self.top + size > 2 ** self.capacity:
            raise "Quantum RAM Does Not have Enough Space"

        for i in range(size):
            self.data[self.top + i] = qudit.qudit[0, i]
        
        self.addresses.push_back(self.top)
        self.top += size
    
    fn dump(inout self) raises:
        self.data.print()