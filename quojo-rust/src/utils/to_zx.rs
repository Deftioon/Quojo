use crate::qcore::circuits::CircuitRepr;
use crate::qcore::gates::Gate;
use crate::zxcalc::graph::{EdgeType, NodeIndex, SpiderType, ZXGraph};
use std::collections::{HashMap, HashSet};

pub struct CircuitConverter {
    qubit_nodes: HashMap<usize, NodeIndex>,
}

impl CircuitConverter {
    pub fn new() -> Self {
        CircuitConverter {
            qubit_nodes: HashMap::new(),
        }
    }

    pub fn convert<const WIDTH: usize>(circuit: &CircuitRepr<WIDTH>) -> ZXGraph {
        let mut converter = Self::new();
        let mut graph = ZXGraph::new();

        for qubit in 0..WIDTH {
            let input_node = graph.add_input_node(SpiderType::Z, 0.0);
            converter.qubit_nodes.insert(qubit, input_node);
        }

        let time_slices = converter.extract_time_slices(circuit);

        for time_slice in time_slices {
            for (qubit, gate) in time_slice {
                converter.apply_gate(&mut graph, qubit, &gate);
            }
        }

        for qubit in 0..WIDTH {
            if let Some(&last_node) = converter.qubit_nodes.get(&qubit) {
                let output_node = graph.add_output_node(SpiderType::Z, 0.0);
                graph.add_edge(last_node, output_node, EdgeType::Regular);
            }
        }

        graph
    }

    fn apply_gate(&mut self, graph: &mut ZXGraph, qubit: usize, gate: &Gate) {
        match gate {
            Gate::X => self.apply_x_gate(graph, qubit),
            Gate::Z => self.apply_z_gate(graph, qubit),
            // Gate::Y => self.apply_y_gate(graph, qubit),
            // Gate::H => self.apply_h_gate(graph, qubit),
            // Gate::P(phase) => self.apply_phase_gate(graph, qubit, *phase),
            // Gate::CNOT { control, target } => self.apply_cnot_gate(graph, *control, *target),
            // Gate::CZ { control, target } => self.apply_cz_gate(graph, *control, *target),
            // Gate::SWAP { qubit1, qubit2 } => self.apply_swap_gate(graph, *qubit1, *qubit2),
            _ => {} // Other gates can be added as needed
        }
    }

    fn apply_x_gate(&mut self, graph: &mut ZXGraph, qubit: usize) {
        if let Some(&prev_node) = self.qubit_nodes.get(&qubit) {
            // X gate is represented by an X-spider with phase = 0
            let x_node = graph.add_node(SpiderType::X, 0.0);
            graph.add_edge(prev_node, x_node, EdgeType::Regular);
            self.qubit_nodes.insert(qubit, x_node);
        }
    }

    fn apply_z_gate(&mut self, graph: &mut ZXGraph, qubit: usize) {
        if let Some(&prev_node) = self.qubit_nodes.get(&qubit) {
            // Z gate is represented by a Z-spider with phase = π
            let z_node = graph.add_node(SpiderType::Z, std::f64::consts::PI);
            graph.add_edge(prev_node, z_node, EdgeType::Regular);
            self.qubit_nodes.insert(qubit, z_node);
        }
    }

    fn extract_time_slices<const WIDTH: usize>(
        &self,
        circuit: &CircuitRepr<WIDTH>,
    ) -> Vec<Vec<(usize, Gate)>> {
        let mut qubit_times = vec![0; WIDTH];

        let mut gate_timings: HashMap<(usize, usize), usize> = HashMap::new();

        for qubit in 0..WIDTH {
            for (gate_idx, gate) in circuit.storage[qubit].iter().enumerate() {
                let mut start_time = qubit_times[qubit];

                let involved_qubits = get_involved_qubits(qubit, gate);

                for &involved_qubit in &involved_qubits {
                    start_time = start_time.max(qubit_times[involved_qubit]);
                }

                gate_timings.insert((qubit, gate_idx), start_time);

                for &involved_qubit in &involved_qubits {
                    qubit_times[involved_qubit] = start_time + 1;
                }
            }
        }

        let max_time = *gate_timings.values().max().unwrap_or(&0);

        let mut time_slices = vec![Vec::new(); max_time + 1];

        for qubit in 0..WIDTH {
            for (gate_idx, gate) in circuit.storage[qubit].iter().enumerate() {
                if let Some(&time) = gate_timings.get(&(qubit, gate_idx)) {
                    let involved_qubits = get_involved_qubits(qubit, gate);
                    if involved_qubits.is_empty() || involved_qubits[0] == qubit {
                        time_slices[time].push((qubit, gate.clone()));
                    }
                }
            }
        }

        time_slices
            .into_iter()
            .filter(|slice| !slice.is_empty())
            .collect()
    }
}

fn get_involved_qubits(current_qubit: usize, gate: &Gate) -> Vec<usize> {
    match gate {
        Gate::X | Gate::Y | Gate::Z | Gate::H | Gate::P(_) => vec![current_qubit],
        Gate::CNOT { control, target } => vec![*control, *target],
        Gate::CZ { control, target } => vec![*control, *target],
        Gate::SWAP { qubit1, qubit2 } => vec![*qubit1, *qubit2],
        Gate::Toffoli {
            control1,
            control2,
            target,
        } => vec![*control1, *control2, *target],
        Gate::Fredkin {
            control,
            target1,
            target2,
        } => vec![*control, *target1, *target2],
    }
}
