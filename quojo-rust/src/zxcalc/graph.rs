//TODO: Don't use outgoing and incoming edges, just one  vec of edges.

use std::collections::HashMap;
use std::fmt;
use uuid::Uuid;

fn fuse_vec<T>(v1: Vec<T>, v2: Vec<T>) -> Vec<T> {
    let mut v = Vec::new();
    v.extend(v1);
    v.extend(v2);
    v
}

#[derive(Debug, Copy, Clone)]
pub enum NodeType {
    Z,
    X,
    H,
}

impl PartialEq for NodeType {
    fn eq(&self, other: &Self) -> bool {
        match (self, other) {
            (NodeType::Z, NodeType::Z) => true,
            (NodeType::X, NodeType::X) => true,
            (NodeType::H, NodeType::H) => true,
            _ => false,
        }
    }
}

#[derive(Debug)]
pub struct Node {
    pub node_type: NodeType,
    pub phase: f64,
    pub outgoing_edges: Vec<Uuid>,
    pub incoming_edges: Vec<Uuid>,
}

impl Node {
    fn new(node_type: NodeType, phase: f64) -> Self {
        Self {
            node_type,
            phase,
            outgoing_edges: Vec::new(),
            incoming_edges: Vec::new(),
        }
    }
}

#[derive(Debug)]
pub struct Graph {
    nodes: HashMap<Uuid, Node>,
}

impl Graph {
    pub fn new() -> Self {
        Self {
            nodes: HashMap::new(),
        }
    }

    pub fn add_node(&mut self, node_type: NodeType, phase: f64) -> Uuid {
        let node = Node::new(node_type, phase);
        let id = Uuid::new_v4();
        self.nodes.insert(id, node);
        id
    }

    pub fn add_edge(&mut self, from: Uuid, to: Uuid) {
        self.nodes.get_mut(&from).unwrap().outgoing_edges.push(to);
        self.nodes.get_mut(&to).unwrap().incoming_edges.push(from);
    }

    pub fn fuse_nodes(&mut self, n1: Uuid, n2: Uuid) {
        let origin = self.nodes.get(&n1).unwrap();
        let target = self.nodes.get(&n2).unwrap();
        let origin_type = origin.node_type;
        if origin_type != target.node_type {
            panic!("Cannot fuse nodes of different types");
        }

        let fused_phase = origin.phase + target.phase;

        let fused_id = self.add_node(NodeType::Z, fused_phase);

        let fused_outgoing_edges = fuse_vec(
            self.nodes.get(&n1).unwrap().outgoing_edges.clone(),
            self.nodes.get(&n2).unwrap().outgoing_edges.clone(),
        );

        let fused_incoming_edges = fuse_vec(
            self.nodes.get(&n1).unwrap().incoming_edges.clone(),
            self.nodes.get(&n2).unwrap().incoming_edges.clone(),
        );

        self.nodes.get_mut(&fused_id).unwrap().outgoing_edges = fused_outgoing_edges;
        self.nodes.get_mut(&fused_id).unwrap().incoming_edges = fused_incoming_edges;

        self.nodes.remove(&n1).expect("Could not remove node 1");
        self.nodes.remove(&n2).expect("Could not remove node 2");
    }
}
