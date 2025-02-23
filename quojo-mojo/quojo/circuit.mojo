from .core import Iterator;
from .gates import Gate;
from collections import InlineList, List;

struct Targets:
    var qubits: VariadicList[Int];

    fn __init__(out self, *qubits: Int):
        self.qubits = qubits;
    
    fn __iter__(self) -> Iterator:
        return Iterator(self.qubits);

struct Controls:
    var qubits: VariadicList[Int];

    fn __init__(out self, *qubits: Int):
        self.qubits = qubits;

struct CircuitRepr[Width: Int]:
    var storage: List[List[Gate], Width];

    fn __init__(out self):
        self.storage = List[List[Gate], Width]();

    fn Apply(mut self, gate: Gate, targets: Targets):
        for target in targets:
            self.storage[target].append(gate);
    
    fn print(self):
        for i in range(Width):
            print("Qubit ", i, ": ", self.storage[i]);