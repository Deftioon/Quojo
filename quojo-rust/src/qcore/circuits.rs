use crate::qcore::gates::Gate;
use std::fmt::Display;

pub struct Controls {
    pub controls: Vec<usize>,
}

pub struct Targets {
    pub targets: Vec<usize>,
}

pub struct CircuitRepr<const WIDTH: usize> {
    pub storage: [Vec<Gate>; WIDTH],
}

impl<const WIDTH: usize> CircuitRepr<WIDTH> {
    pub fn Apply(&mut self, gate: Gate, targets: Targets) {
        for &target in &targets.targets {
            if target >= WIDTH {
                panic!("Target qubit index {} exceeds circuit width {}", target, WIDTH);
            }
            self.storage[target].push(gate.clone());
        }
    }

    pub fn ApplyControlled(&mut self, gate: Gate, control: usize, target: usize) {
        if control >= WIDTH || target >= WIDTH {
            panic!("Qubit index exceeds circuit width {}", WIDTH);
        }
        
        let controlled_gate = match gate {
            Gate::X => Gate::CNOT { control, target },
            Gate::Z => Gate::CZ { control, target },
            _ => panic!("Unsupported controlled operation for gate {:?}", gate),
        };
        
        self.storage[control].push(controlled_gate.clone());
        self.storage[target].push(controlled_gate);
    }
    
    pub fn ApplySwap(&mut self, qubit1: usize, qubit2: usize) {
        if qubit1 >= WIDTH || qubit2 >= WIDTH {
            panic!("Qubit index exceeds circuit width {}", WIDTH);
        }
        
        let swap_gate = Gate::SWAP { qubit1, qubit2 };
        self.storage[qubit1].push(swap_gate.clone());
        self.storage[qubit2].push(swap_gate);
    }
}

impl<const WIDTH: usize> Display for CircuitRepr<WIDTH> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        for wire in self.storage.iter() {
            for gate in wire.iter() {
                write!(f, "{} ", gate)?;
            }
            writeln!(f)?;
        }
        Ok(())
    }
}
