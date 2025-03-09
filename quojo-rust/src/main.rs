use quojo_rust::qcore;
use quojo_rust::qcore::gates::Gate;
use quojo_rust::zxcalc::graph;

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

//TODO:  Does not work for this case! Missing edge from n5 to n1
fn main() {
    let mut graph = graph::Graph::new();
    let n1 = graph.add_node(graph::NodeType::Z, 1.0);
    let n2 = graph.add_node(graph::NodeType::Z, 1.0);
    graph.add_edge(n1, n2);

    println!("{:?}", graph);

    graph.fuse_nodes(n1, n2);
    println!("{:?}", graph);
}
