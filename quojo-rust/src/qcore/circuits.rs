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
        for target in targets.targets {
            self.storage[target].push(gate.clone());
        }
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
