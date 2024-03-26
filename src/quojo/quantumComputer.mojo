import quantum as Q
from quantum import QuantumGates as Gates
import complexNum as comp
from collections.vector import DynamicVector


struct QMC: #Quantum Memory Cells
    var top: Int
    var addresses: DynamicVector[Int]
    var data: comp.ComplexArray

    fn __init__(inout self, capacity: Int) raises:
        self.top = 1
        self.addresses = DynamicVector[Int]()
        self.addresses.push_back(1)
        self.data = comp.ComplexArray(capacity + 1)
    
    fn dump(inout self) raises:
        for i in range(1, self.data.len):
            self.data[i].print()
        
    fn delete(inout self, address: Int) raises:
        if address >= len(self.addresses) - 1:
            raise("Address does not exist")

        var size = self.addresses[address + 1] - self.addresses[address]
        var start = self.addresses[address]

        # clear data from start to start + size
        for i in range(start, start+size):
            self.data[i] = comp.ComplexNum(0,0)
    
    fn write(inout self, contents: Q.Qubit, mode: String, address: Int = 0) raises:
        if mode == "a":
            var size = 2

            for i in range(size):
                self.data[self.top + i] = contents.qubit[0, i]
            
            self.top += size
            self.addresses.push_back(self.top)
        
        if mode == "o":
            var size = 2
            var start = self.addresses[address]
            self.delete(address)

            for i in range(start, start + size):
                self.data[i] = contents.qubit[0, i - start]

    
    fn write(inout self, contents: Q.Qudit, mode: String, address: Int = 0) raises:
        if mode == "a":
            var size = contents.qudit.cols

            for i in range(size):
                self.data[self.top + i] = contents.qudit[0, i]
            
            self.top += size
            self.addresses.push_back(self.top)
        
        if mode == "o":
            var addrSize = self.addresses[address + 1] - self.addresses[address]
            var size = contents.qudit.cols
            if size > addrSize:
                raise("Given contents too big, cannot overwrite")
            var start = self.addresses[address]
            self.delete(address)

            for i in range(start, start + size):
                self.data[i] = contents.qudit[0, i - start]