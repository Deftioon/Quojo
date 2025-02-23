pub mod circuits;
pub mod gates;

pub fn Targets(targets: &[usize]) -> circuits::Targets {
    circuits::Targets {
        targets: targets.to_vec(),
    }
}

pub fn Controls(controls: &[usize]) -> circuits::Controls {
    circuits::Controls {
        controls: controls.to_vec(),
    }
}

pub fn CircuitRepr<const WIDTH: usize>() -> circuits::CircuitRepr<WIDTH> {
    circuits::CircuitRepr {
        storage: std::array::from_fn(|_| Vec::new()),
    }
}
