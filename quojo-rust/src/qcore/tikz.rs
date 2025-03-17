use super::circuits::CircuitRepr;
use super::gates::Gate;
use std::collections::{HashMap, HashSet};
use std::fs::File;
use std::io::Write;
use std::path::Path;

pub struct TikzQConfig {
    pub gate_spacing: f64,
    pub wire_spacing: f64,
    pub show_labels: bool,
    pub font_size: String,
    pub qubit_style: String,
    pub wire_style: String,
    pub connection_style: String,
}

impl Default for TikzQConfig {
    fn default() -> Self {
        Self {
            gate_spacing: 1.2,
            wire_spacing: 0.6,
            show_labels: true,
            font_size: "\\footnotesize".to_string(),
            qubit_style: "draw=black".to_string(),
            wire_style: "thick".to_string(),
            connection_style: "thick".to_string(),
        }
    }
}

pub fn generate_tikz_circuit<const WIDTH: usize>(circuit: &CircuitRepr<WIDTH>, config: &TikzQConfig) -> String {
    let mut output = String::with_capacity(1024);
    
    output.push_str("\\begin{tikzpicture}[\n");
    output.push_str(&format!("  wire/.style={{{}}}]\n", config.wire_style));
    
    let (time_steps, max_time) = process_gates_and_determine_time_steps(circuit);
    
    let total_width = (max_time + 1) as f64 * config.gate_spacing + 0.5;
    
    for q in 0..WIDTH {
        let y_pos = q as f64 * config.wire_spacing;
        
        output.push_str(&format!("  \\draw[wire] (0,{y:.2}) -- ({max_x:.2},{y:.2});\n", 
            y = -y_pos, 
            max_x = total_width
        ));
        
        if config.show_labels {
            output.push_str(&format!(
                "  \\node[font={}, anchor=east] at (-0.2,{:.2}) {{$q_{{{}}}$}};\n", 
                config.font_size, -y_pos, q
            ));
        }
    }
    
    draw_gates(WIDTH, &time_steps, config, &mut output);
    
    output.push_str("\\end{tikzpicture}");
    output
}

fn process_gates_and_determine_time_steps<const WIDTH: usize>(
    circuit: &CircuitRepr<WIDTH>
) -> (HashMap<(usize, usize), GateRenderInfo>, usize) {
    let mut time_steps = HashMap::new();
    let mut max_time = 0;
    
    let mut processed_multi_qubit = HashSet::new();
    
    let mut last_used_time = vec![0; WIDTH];
    
    for qubit in 0..WIDTH {
        let mut time = 0;
        
        for gate in &circuit.storage[qubit] {
            match gate {
                Gate::CNOT { control, target } => {
                    if !processed_multi_qubit.contains(&(*control, *target, GateType::CNOT)) {
                        processed_multi_qubit.insert((*control, *target, GateType::CNOT));
                        
                        time = std::cmp::max(time, last_used_time[*control]);
                        time = std::cmp::max(time, last_used_time[*target]);
                        
                        time_steps.insert(
                            (*control, time), 
                            GateRenderInfo { 
                                gate_type: GateType::ControlPoint,
                                connected_to: vec![*target],
                                params: None
                            }
                        );
                        
                        time_steps.insert(
                            (*target, time), 
                            GateRenderInfo { 
                                gate_type: GateType::CNOT_Target, 
                                connected_to: vec![*control],
                                params: None
                            }
                        );
                        
                        last_used_time[*control] = time + 1;
                        last_used_time[*target] = time + 1;
                        
                        time = time + 1;
                        max_time = max_time.max(time);
                    }
                },
                Gate::CZ { control, target } => {
                    if !processed_multi_qubit.contains(&(*control, *target, GateType::CZ)) {
                        processed_multi_qubit.insert((*control, *target, GateType::CZ));
                        
                        time = std::cmp::max(time, last_used_time[*control]);
                        time = std::cmp::max(time, last_used_time[*target]);
                        
                        time_steps.insert(
                            (*control, time), 
                            GateRenderInfo { 
                                gate_type: GateType::ControlPoint,
                                connected_to: vec![*target],
                                params: None
                            }
                        );
                        
                        time_steps.insert(
                            (*target, time), 
                            GateRenderInfo { 
                                gate_type: GateType::CZ_Target,
                                connected_to: vec![*control],
                                params: None
                            }
                        );
                        
                        last_used_time[*control] = time + 1;
                        last_used_time[*target] = time + 1;
                        
                        time = time + 1;
                        max_time = max_time.max(time);
                    }
                },
                Gate::SWAP { qubit1, qubit2 } => {
                    if !processed_multi_qubit.contains(&(*qubit1, *qubit2, GateType::SWAP)) {
                        processed_multi_qubit.insert((*qubit1, *qubit2, GateType::SWAP));
                        
                        time = std::cmp::max(time, last_used_time[*qubit1]);
                        time = std::cmp::max(time, last_used_time[*qubit2]);
                        
                        time_steps.insert(
                            (*qubit1, time), 
                            GateRenderInfo { 
                                gate_type: GateType::SWAP_Point,
                                connected_to: vec![*qubit2],
                                params: None
                            }
                        );
                        
                        time_steps.insert(
                            (*qubit2, time), 
                            GateRenderInfo { 
                                gate_type: GateType::SWAP_Point,
                                connected_to: vec![*qubit1],
                                params: None
                            }
                        );
                        
                        last_used_time[*qubit1] = time + 1;
                        last_used_time[*qubit2] = time + 1;
                        
                        time = time + 1;
                        max_time = max_time.max(time);
                    }
                },
                Gate::X | Gate::Y | Gate::Z | Gate::H | Gate::P(_) => {
                    time = std::cmp::max(time, last_used_time[qubit]);
                    
                    let gate_type = match gate {
                        Gate::X => GateType::X,
                        Gate::Y => GateType::Y,
                        Gate::Z => GateType::Z,
                        Gate::H => GateType::H,
                        Gate::P(phase) => {
                            time_steps.insert(
                                (qubit, time), 
                                GateRenderInfo { 
                                    gate_type: GateType::P,
                                    connected_to: vec![],
                                    params: Some(*phase)
                                }
                            );
                            last_used_time[qubit] = time + 1;
                            time = time + 1;
                            max_time = max_time.max(time);
                            continue;
                        },
                        _ => continue,
                    };
                    
                    time_steps.insert(
                        (qubit, time), 
                        GateRenderInfo { 
                            gate_type,
                            connected_to: vec![],
                            params: None
                        }
                    );
                    
                    last_used_time[qubit] = time + 1;
                    time = time + 1;
                    max_time = max_time.max(time);
                },
                _ => {}, 
            }
        }
    }
    
    (time_steps, max_time)
}

fn draw_gates(
    width: usize,
    time_steps: &HashMap<(usize, usize), GateRenderInfo>,
    config: &TikzQConfig,
    output: &mut String,
) {
    let mut gates_by_time: HashMap<usize, Vec<(usize, &GateRenderInfo)>> = HashMap::new();
    
    for ((qubit, time), gate) in time_steps {
        gates_by_time.entry(*time).or_default().push((*qubit, gate));
    }
    
    let mut time_keys: Vec<usize> = gates_by_time.keys().cloned().collect();
    time_keys.sort();
    
    for time in time_keys {
        if let Some(gates) = gates_by_time.get(&time) {
            for &(qubit, gate_info) in gates {
                if !gate_info.connected_to.is_empty() {
                    let x_pos = (time as f64 + 1.0) * config.gate_spacing;
                    let y_pos = -(qubit as f64 * config.wire_spacing);
                    
                    for &connected_qubit in &gate_info.connected_to {
                        let connected_y = -(connected_qubit as f64 * config.wire_spacing);
                        
                        output.push_str(&format!(
                            "  \\draw[thick] ({:.2},{:.2}) -- ({:.2},{:.2});\n",
                            x_pos, y_pos, x_pos, connected_y
                        ));
                    }
                }
            }
            
            for &(qubit, gate_info) in gates {
                let x_pos = (time as f64 + 1.0) * config.gate_spacing;
                let y_pos = -(qubit as f64 * config.wire_spacing);
                
                match gate_info.gate_type {
                    GateType::X => {
                        output.push_str(&format!(
                            "  \\node[circle, fill=white, minimum size=3.0mm, inner sep=0pt] at ({:.2},{:.2}) {{}};\n",
                            x_pos, y_pos
                        ));
                        output.push_str(&format!(
                            "  \\node at ({:.2},{:.2}) {{$\\oplus$}};\n",
                            x_pos, y_pos
                        ));
                    },
                    GateType::Y => {
                        output.push_str(&format!(
                            "  \\node[draw, minimum size=0.5cm, fill=white, font={}] at ({:.2},{:.2}) {{$Y$}};\n",
                            config.font_size, x_pos, y_pos
                        ));
                    },
                    GateType::Z => {
                        output.push_str(&format!(
                            "  \\node[draw, minimum size=0.5cm, fill=white, font={}] at ({:.2},{:.2}) {{$Z$}};\n",
                            config.font_size, x_pos, y_pos
                        ));
                    },
                    GateType::H => {
                        output.push_str(&format!(
                            "  \\node[draw, minimum size=0.5cm, fill=white, font={}] at ({:.2},{:.2}) {{$H$}};\n",
                            config.font_size, x_pos, y_pos
                        ));
                    },
                    GateType::P => {
                        let phase_str = if let Some(phase) = gate_info.params {
                            if phase == std::f64::consts::PI {
                                "\\pi".to_string()
                            } else if phase == std::f64::consts::PI / 2.0 {
                                "\\pi/2".to_string()
                            } else {
                                format!("{:.2}", phase)
                            }
                        } else {
                            "\\phi".to_string()
                        };
                        
                        output.push_str(&format!(
                            "  \\node[draw, minimum size=0.5cm, fill=white, font={}] at ({:.2},{:.2}) {{$P({}$)}};\n",
                            config.font_size, x_pos, y_pos, phase_str
                        ));
                    },
                    GateType::ControlPoint => {
                        output.push_str(&format!(
                            "  \\node[circle, fill=black, minimum size=0.15cm, inner sep=0pt] at ({:.2},{:.2}) {{}};\n",
                            x_pos, y_pos
                        ));
                    },
                    GateType::CNOT_Target => {
                        output.push_str(&format!(
                            "  \\node[circle, fill=white, minimum size=3.0mm, inner sep=0pt] at ({:.2},{:.2}) {{}};\n",
                            x_pos, y_pos
                        ));
                        output.push_str(&format!(
                            "  \\node at ({:.2},{:.2}) {{$\\oplus$}};\n",
                            x_pos, y_pos
                        ));
                    },
                    GateType::CZ_Target => {
                        output.push_str(&format!(
                            "  \\node[circle, fill=black, minimum size=0.15cm, inner sep=0pt] at ({:.2},{:.2}) {{}};\n",
                            x_pos, y_pos
                        ));
                    },
                    GateType::SWAP_Point => {
                        output.push_str(&format!(
                            "  \\node[font=\\normalsize] at ({:.2},{:.2}) {{$\\times$}};\n", 
                            x_pos, y_pos
                        ));
                    },
                    _ => {}
                }
            }
        }
    }
}

#[derive(Debug, Copy, Clone, PartialEq, Eq, Hash)]
enum GateType {
    X,
    Y,
    Z,
    H,
    P,
    ControlPoint,
    CNOT_Target,
    CZ_Target,
    SWAP_Point,
    CNOT,
    CZ,
    SWAP,
}

struct GateRenderInfo {
    gate_type: GateType,
    connected_to: Vec<usize>, 
    params: Option<f64>, 
}

pub fn save_circuit_to_file<const WIDTH: usize>(
    circuit: &CircuitRepr<WIDTH>, 
    config: &TikzQConfig, 
    filepath: &str
) -> std::io::Result<()> {
    let tikz_content = generate_tikz_circuit(circuit, config);
    
    let latex_document = format!(
        "\\documentclass{{standalone}}\n\\usepackage{{tikz}}\n\\usepackage{{qcircuit}}\n\\usepackage{{braket}}\n\n\\begin{{document}}\n{}\n\\end{{document}}\n",
        tikz_content
    );
    
    let mut file = File::create(Path::new(filepath))?;
    file.write_all(latex_document.as_bytes())?;
    
    println!("Quantum circuit TikZ diagram saved to: {}", filepath);
    Ok(())
}

pub trait TikzCircuit<const WIDTH: usize> {
    fn to_tikz(&self, config: &TikzQConfig) -> String;
    
    fn save_tikz(&self, config: &TikzQConfig, filepath: &str) -> std::io::Result<()>;
}

impl<const WIDTH: usize> TikzCircuit<WIDTH> for CircuitRepr<WIDTH> {
    fn to_tikz(&self, config: &TikzQConfig) -> String {
        generate_tikz_circuit(self, config)
    }
    
    fn save_tikz(&self, config: &TikzQConfig, filepath: &str) -> std::io::Result<()> {
        save_circuit_to_file(self, config, filepath)
    }
}

pub fn default_circuit_config() -> TikzQConfig {
    TikzQConfig::default()
}
