import random
from complex import ComplexSIMD
import .linalg as linalg
import .gates as gates

@value
struct Qubit(StringableRaising):
    var state: linalg.Matrix[2, 1]

    fn __init__(out self, state: Int):
        self.state = linalg.Matrix[2, 1](0.0, 0.0)
        self.state[state, 0] = ComplexSIMD[DType.float64, 1](1.0, 0.0)
    
    fn __str__(self) raises -> String:      
        return "({},{})|0> + ({},{})|1>".format(
            self.state[0, 0].re[0], self.state[0, 0].im[0],
            self.state[1, 0].re[0], self.state[1, 0].im[0]
        )

    fn apply_gate(mut self, gate: gates.QuantumGate[2, 2]) -> None:
        self.state = linalg.dot(gate.matrix, self.state)
    
    fn measure(mut self) -> Int:
        var probability = self.state.data.__abs__()
        var random_number = random.random_float64(0.0, 1.1)
        if random_number < probability[0]:
            self.state = linalg.Matrix[2, 1](1.0, 0.0)
            return 0
        else:
            self.state = linalg.Matrix[2, 1](0.0, 1.0)
            return 1