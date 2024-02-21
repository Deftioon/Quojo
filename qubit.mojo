import complexNum as comp

struct TSQubit:
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
    
    fn print(borrowed self) raises:
        for i in range(self.width*2):
            print(self.qubit[0, i].re, self.qubit[0, i].im)
        

fn main() raises:
    var State = TSQubit("11")
    State.print()