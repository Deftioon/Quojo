
trait Gate(CollectionElement):
    pass;

struct Z(Gate):
    fn __init__(out self):
        pass
    
    fn __copyinit__(mut self, other: Z):
        pass
    
    fn __moveinit__(out self, owned other: Z):
        pass

struct X(Gate):
    fn __init__(out self):
        pass
    
    fn __copyinit__(mut self, other: X):
        pass
    
    fn __moveinit__(out self, owned other: X):
        pass
    
struct Y(Gate):
    fn __init__(out self):
        pass
    
    fn __copyinit__(mut self, other: Y):
        pass
    
    fn __moveinit__(out self, owned other: Y):
        pass

struct H(Gate):
    fn __init__(out self):
        pass
    
    fn __copyinit__(mut self, other: H):
        pass
    
    fn __moveinit__(out self, owned other: H):
        pass

struct P(Gate):
    var theta: Float32;
    
    fn __init__(out self, theta: Float32):
        self.theta = theta;
    
    fn __copyinit__(mut self, other: P):
        self.theta = other.theta;
    
    fn __moveinit__(out self, owned other: P):
        self.theta = other.theta;

# TODO: Implement ControlledGate when its supported
# struct ControlledGate(Gate, Controlled):
#     var controls: Controls;
#     var target: Targets;
#     var gate: Gate;

#     fn __init__(out self, controls: Controls, target: Targets, gate: Gate):
#         self.controls = controls;
#         self.target = target;
#         self.gate = gate;

#     fn __copyinit__(mut self, other: ControlledGate):
#         self.controls = other.controls;
#         self.target = other.target;
#         self.gate = other.gate;
    
#     fn __moveinit__(out self, owned other: ControlledGate):
#         self.controls = other.controls;
#         self.target = other.target;
#         self.gate = other.gate;