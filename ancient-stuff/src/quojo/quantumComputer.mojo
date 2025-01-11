import quantum as Q
from quantum import QuantumGates as Gates
import complexNum as comp
from collections.list import List

#TODO: Apply Memory Paging of 4 Qubit
struct QuantumPages: #Quantum Memory Cells
    var top: Int
    var addresses: List[Int]
    var data: comp.ComplexArray

    fn __init__(inout self, capacity: Int) raises:
        self.top = 1
        self.addresses = List[Int]()
        self.addresses.append(1)
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
            self.addresses.append(self.top)
        
        if mode == "o":
            var size = 2
            var start = self.addresses[address]
            self.delete(address)

            for i in range(start, start + size):
                self.data[i] = contents.qubit[0, i - start]