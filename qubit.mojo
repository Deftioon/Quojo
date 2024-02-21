import complexNum as comp

struct Qubit:
    var bit: comp.ComplexMatrix

    fn __init__(inout self, state: Int) raises:
        self.bit = comp.ComplexMatrix(1, 0)
        self.bit[0, state] = self.bit[0, state] * 0.0
    
    fn print(inout self) raises:
        self.bit.print()

fn main() raises:
    var myBit = Qubit(0)
    myBit.print()