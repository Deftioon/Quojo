import quojo as qj

fn main() raises:
    var circuit = qj.CircuitRepr[4]();
    var targets = qj.Targets(0, 1, 2, 3);
    var h = qj.H();
    var x = qj.X();
    var p = qj.P(3.14);
    circuit.Apply(h, targets);
    circuit.print();
