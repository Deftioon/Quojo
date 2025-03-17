use quojo_rust::zxcalc::graph::{EdgeType, SpiderType, ZXGraph};
use quojo_rust::zxcalc::tikz::{TikzConfig, save_tikz_to_file};

// fn main() {
//     let mut circuit = qcore::CircuitRepr::<4>();
//     circuit.Apply(Gate::H, qcore::Targets(&[0, 1, 2]));
//     circuit.Apply(Gate::X, qcore::Targets(&[0, 1, 2]));
//     circuit.Apply(Gate::Y, qcore::Targets(&[3]));
//     println!("{}", circuit);

//     let mut graph = graph::Graph::new();

//     let n1 = graph.add_node(graph::NodeType::Z, 0.0);
//     let n2 = graph.add_node(graph::NodeType::X, 1.0);
//     let n3 = graph.add_node(graph::NodeType::Z, 0.5);

//     graph.add_edge(n1, n2);
//     graph.add_edge(n2, n3);
//     graph.add_edge(n3, n1);

//     println!("{:?}", graph);
//     println!("{:?}", graph.to_adjacency_matrix())
// }

fn main() {
    let config = TikzConfig::default();

    let mut input_wires_test = ZXGraph::new();
    
    let i1 = input_wires_test.add_input_node(SpiderType::Z, 0.0);
    let i2 = input_wires_test.add_input_node(SpiderType::Z, 0.0);
    
    let middle1 = input_wires_test.add_node(SpiderType::X, 0.0);
    let middle2 = input_wires_test.add_node(SpiderType::Z, 0.5);
    
    let out = input_wires_test.add_node(SpiderType::Z, 0.0);
    
    input_wires_test.add_edge(i1, middle1, EdgeType::Regular);
    input_wires_test.add_edge(i2, middle1, EdgeType::Hadamard);
    input_wires_test.add_edge(middle1, middle2, EdgeType::Regular);
    input_wires_test.add_edge(middle2, out, EdgeType::Regular);
    
    match save_tikz_to_file(&input_wires_test, &config, "zx_diagram_with_inputs.tex") {
        Ok(_) => println!("Successfully saved ZX diagram with input wires to zx_diagram_with_inputs.tex"),
        Err(e) => eprintln!("Error saving diagram: {}", e),
    }

    let mut io_wires_test = ZXGraph::new();
    
    let i1 = io_wires_test.add_input_node(SpiderType::Z, 0.0);
    let i2 = io_wires_test.add_input_node(SpiderType::Z, 0.0);
    
    let middle1 = io_wires_test.add_node(SpiderType::X, 0.0);
    let middle2 = io_wires_test.add_node(SpiderType::Z, 0.5);
    
    let o1 = io_wires_test.add_output_node(SpiderType::Z, 0.0);
    let o2 = io_wires_test.add_output_node(SpiderType::X, 0.0);
    
    io_wires_test.add_edge(i1, middle1, EdgeType::Regular);
    io_wires_test.add_edge(i2, middle1, EdgeType::Hadamard);
    io_wires_test.add_edge(middle1, middle2, EdgeType::Regular);
    io_wires_test.add_edge(middle2, o1, EdgeType::Regular);
    io_wires_test.add_edge(middle1, o2, EdgeType::Hadamard);
    
    match save_tikz_to_file(&io_wires_test, &config, "zx_diagram_with_io_wires.tex") {
        Ok(_) => println!("Successfully saved ZX diagram with I/O wires to zx_diagram_with_io_wires.tex"),
        Err(e) => eprintln!("Error saving diagram: {}", e),
    }
}
