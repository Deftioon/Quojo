use super::graph::*;
use std::collections::{HashMap, VecDeque};
use std::fs::File;
use std::io::Write;
use std::path::Path;

pub struct TikzConfig {
    pub node_spacing: f64,
    pub layer_spacing: f64,
    pub z_style: String,
    pub x_style: String,
    pub regular_edge_style: String,
    pub hadamard_edge_style: String,
    pub hadamard_box_style: String,
}

impl Default for TikzConfig {
    fn default() -> Self {
        Self {
            node_spacing: 2.0,
            layer_spacing: 3.0,
            z_style: "circle,draw=green,fill=green!20,minimum size=6mm,text=black".into(),
            x_style: "circle,draw=red,fill=red!20,minimum size=6mm,text=black".into(),
            regular_edge_style: "black,thick".into(),
            hadamard_edge_style: "black,thick".into(),
            hadamard_box_style: "fill=yellow,draw=black,minimum size=3mm".into(),
        }
    }
}

pub fn generate_tikz(graph: &ZXGraph, config: &TikzConfig) -> String {
    let mut output = String::with_capacity(1024);
    
    output.push_str(&format!(
        "\\begin{{tikzpicture}}[\n    z_node/.style={{{}}},\n    x_node/.style={{{}}},\n    regular_edge/.style={{{}}},\n    hadamard_edge/.style={{{}}},\n    hadamard_box/.style={{{}}},\n    small_hadamard_box/.style={{fill=yellow,draw=black,minimum size=2mm}},\n    edge_count/.style={{text=black,font=\\scriptsize}},\n    input_wire/.style={{thick,black}},\n    output_wire/.style={{thick,black}}]\n",
        config.z_style, config.x_style, config.regular_edge_style, 
        config.hadamard_edge_style, config.hadamard_box_style
    ));

    let positions = calculate_professional_layout(graph, config);
    
    let fixed_output_endpoint = calculate_output_endpoint(&positions, graph, config);
    
    draw_input_wires(graph, &positions, config, &mut output);
    draw_output_wires(graph, &positions, fixed_output_endpoint, &mut output);
    
    draw_nodes(graph, &positions, &mut output);
    draw_edges(graph, &positions, config, &mut output);
    
    output.push_str("\\end{tikzpicture}");
    output
}

fn calculate_output_endpoint(
    positions: &HashMap<NodeIndex, (f64, f64)>, 
    graph: &ZXGraph,
    config: &TikzConfig
) -> f64 {
    let mut max_x = f64::MIN;
    
    for (&_node_idx, &(x, _)) in positions.iter() {
        max_x = max_x.max(x);
    }
    
    max_x + config.node_spacing * 1.5
}

fn draw_input_wires(
    graph: &ZXGraph,
    positions: &HashMap<NodeIndex, (f64, f64)>,
    config: &TikzConfig,
    output: &mut String
) {
    let input_wire_length = config.node_spacing * 1.5;
    
    for &node_idx in &graph.input_nodes {
        if let Some(&(x, y)) = positions.get(&node_idx) {
            output.push_str(&format!(
                "  \\draw[input_wire] ({:.2},{:.2}) -- ({:.2},{:.2});\n",
                x - input_wire_length, y, x, y
            ));
        } else {
            // Handle case where position isn't defined for an input node
            println!("Warning: No position for input node {:?}", node_idx);
        }
    }
}

fn draw_output_wires(
    graph: &ZXGraph,
    positions: &HashMap<NodeIndex, (f64, f64)>,
    end_x: f64,
    output: &mut String
) {
    for &node_idx in &graph.output_nodes {
        if let Some(&(x, y)) = positions.get(&node_idx) {
            output.push_str(&format!(
                "  \\draw[output_wire] ({:.2},{:.2}) -- ({:.2},{:.2});\n",
                x, y, end_x, y
            ));
        } else {
            // Handle case where position isn't defined for an output node
            println!("Warning: No position for output node {:?}", node_idx);
        }
    }
}

fn draw_nodes(graph: &ZXGraph, positions: &HashMap<NodeIndex, (f64, f64)>, output: &mut String) {
    let mut nodes: Vec<(NodeIndex, (f64, f64))> = positions.iter()
        .map(|(&idx, &pos)| (idx, pos))
        .collect();
    nodes.sort_by_key(|(idx, _)| idx.0);
    
    for (node_idx, (x, y)) in nodes {
        if let Some((spider_type, phase)) = graph.node_data(node_idx) {
            let style = match spider_type {
                SpiderType::Z => "z_node",
                SpiderType::X => "x_node",
            };
            
            let phase_text = if phase.abs() < 0.0001 {
                String::new()
            } else {
                format!("{:.2}", phase)
            };
            
            output.push_str(&format!(
                "\\node[{}] ({}) at ({:.2},{:.2}) {{{}}};\n",
                style, node_idx.0, x, y, phase_text
            ));
        }
    }
}

fn draw_edges(
    graph: &ZXGraph,
    positions: &HashMap<NodeIndex, (f64, f64)>,
    config: &TikzConfig,
    output: &mut String,
) {
    let edge_groups = group_edges_by_endpoints(graph);
    
    let mut sorted_edge_groups: Vec<((NodeIndex, NodeIndex), Vec<(EdgeIndex, &Edge)>)> = 
        edge_groups.into_iter().collect();
    sorted_edge_groups.sort_by_key(|((src, dst), _)| (src.0, dst.0));
    
    for ((src, dst), edges) in sorted_edge_groups {
        if let (Some(&src_pos), Some(&dst_pos)) = (positions.get(&src), positions.get(&dst)) {
            if (src_pos.0 - dst_pos.0).abs() < 0.001 && (src_pos.1 - dst_pos.1).abs() < 0.001 {
                continue;
            }
            
            let mut regular_edges: Vec<_> = Vec::new();
            let mut hadamard_edges: Vec<_> = Vec::new();
            
            for edge in &edges {
                match edge.1.edge_type {
                    EdgeType::Regular => regular_edges.push(*edge),
                    EdgeType::Hadamard => hadamard_edges.push(*edge),
                }
            }
            
            if !regular_edges.is_empty() {
                draw_edge_set(src, dst, src_pos, dst_pos, &regular_edges, 
                              config, "regular_edge", None, output);
            }
            
            if !hadamard_edges.is_empty() {
                draw_edge_set(src, dst, src_pos, dst_pos, &hadamard_edges, 
                              config, "hadamard_edge", Some("hadamard_box"), output);
            }
        }
    }
}

fn draw_edge_set(
    src: NodeIndex,
    dst: NodeIndex,
    src_pos: (f64, f64),
    dst_pos: (f64, f64),
    edges: &[(EdgeIndex, &Edge)],
    config: &TikzConfig,
    edge_style: &str,
    box_style: Option<&str>,
    output: &mut String,
) {
    if edges.is_empty() {
        return;
    }
    
    if edges.len() <= 4 {
        for (i, &(edge_idx, _)) in edges.iter().enumerate() {
            let (control_points, mid_point) = calculate_edge_curve(
                src_pos, dst_pos, i, edges.len(), config.node_spacing);
            
            output.push_str(&format!(
                "\\draw[{}] ({}) .. controls ({:.2},{:.2}) and ({:.2},{:.2}) .. ({});\n",
                edge_style, src.0, 
                control_points.0, control_points.1, 
                control_points.2, control_points.3, 
                dst.0
            ));
            
            if let Some(style) = box_style {
                output.push_str(&format!(
                    "\\node[{}] (h{}) at ({:.2},{:.2}) {{}};\n",
                    style, edge_idx.0, mid_point.0, mid_point.1
                ));
            }
        }
    } else {
        draw_edge_bundle(src, dst, src_pos, dst_pos, edges.len(), 
                         config, edge_style, box_style, output);
    }
}

fn draw_edge_bundle(
    src: NodeIndex,
    dst: NodeIndex,
    src_pos: (f64, f64),
    dst_pos: (f64, f64),
    edge_count: usize,
    config: &TikzConfig,
    edge_style: &str,
    box_style: Option<&str>,
    output: &mut String,
) {
    let (top_curve, top_mid) = calculate_edge_curve(
        src_pos, dst_pos, 0, 3, config.node_spacing * 0.6);
    
    let (bottom_curve, bottom_mid) = calculate_edge_curve(
        src_pos, dst_pos, 2, 3, config.node_spacing * 0.6);
    
    output.push_str(&format!(
        "\\draw[{}] ({}) .. controls ({:.2},{:.2}) and ({:.2},{:.2}) .. ({});\n",
        edge_style, src.0, 
        top_curve.0, top_curve.1, top_curve.2, top_curve.3, 
        dst.0
    ));
    
    output.push_str(&format!(
        "\\draw[{}] ({}) .. controls ({:.2},{:.2}) and ({:.2},{:.2}) .. ({});\n",
        edge_style, src.0, 
        bottom_curve.0, bottom_curve.1, bottom_curve.2, bottom_curve.3, 
        dst.0
    ));
    
    let center_x = (top_mid.0 + bottom_mid.0) / 2.0;
    let center_y = (top_mid.1 + bottom_mid.1) / 2.0;
    
    let dx = top_mid.0 - bottom_mid.0;
    let dy = top_mid.1 - bottom_mid.1;
    let distance = (dx * dx + dy * dy).sqrt();
    
    if let Some(_style) = box_style {
        let offset_factor = 1.2;
        
        let top_offset_x = (top_mid.0 - center_x) * offset_factor;
        let top_offset_y = (top_mid.1 - center_y) * offset_factor;
        let top_box_x = center_x + top_offset_x;
        let top_box_y = center_y + top_offset_y;
        
        let bottom_offset_x = (bottom_mid.0 - center_x) * offset_factor;
        let bottom_offset_y = (bottom_mid.1 - center_y) * offset_factor;
        let bottom_box_x = center_x + bottom_offset_x;
        let bottom_box_y = center_y + bottom_offset_y;
        
        output.push_str(&format!(
            "\\node[small_hadamard_box] (h_top) at ({:.2},{:.2}) {{}};\n",
            top_box_x, top_box_y
        ));
        
        output.push_str(&format!(
            "\\node[small_hadamard_box] (h_bottom) at ({:.2},{:.2}) {{}};\n",
            bottom_box_x, bottom_box_y
        ));
    }
    
    output.push_str(&format!(
        "\\node[fill=white,inner sep=2pt] at ({:.2},{:.2}) {{}};\n",
        center_x, center_y
    ));
    
    let gap_ratio = 0.5;
    
    if distance > 0.001 {
        let dir_x = dx / distance;
        let dir_y = dy / distance;
        
        let gap_top_x = center_x + dir_x * (distance * gap_ratio / 2.0);
        let gap_top_y = center_y + dir_y * (distance * gap_ratio / 2.0);
        let gap_bottom_x = center_x - dir_x * (distance * gap_ratio / 2.0);
        let gap_bottom_y = center_y - dir_y * (distance * gap_ratio / 2.0);
        
        output.push_str(&format!(
            "\\draw[{},dotted] ({:.2},{:.2}) -- ({:.2},{:.2});\n",
            edge_style, top_mid.0, top_mid.1, gap_top_x, gap_top_y
        ));
        
        output.push_str(&format!(
            "\\draw[{},dotted] ({:.2},{:.2}) -- ({:.2},{:.2});\n",
            edge_style, gap_bottom_x, gap_bottom_y, bottom_mid.0, bottom_mid.1
        ));
    }
    
    output.push_str(&format!(
        "\\node[edge_count] at ({:.2},{:.2}) {{{}}};\n",
        center_x, center_y, edge_count
    ));
}

fn calculate_edge_curve(
    src_pos: (f64, f64),
    dst_pos: (f64, f64),
    edge_index: usize,
    total_edges: usize,
    spacing_factor: f64
) -> ((f64, f64, f64, f64), (f64, f64)) {
    let (x1, y1) = src_pos;
    let (x2, y2) = dst_pos;
    
    let dx = x2 - x1;
    let dy = y2 - y1;
    let length = (dx * dx + dy * dy).sqrt();
    
    if length < 0.001 {
        let offset = spacing_factor * 0.25;
        return (
            (x1, y1 + offset, x2, y2 + offset),
            (x1, y1 + offset)
        );
    }
    
    let perp_x = -dy / length;
    let perp_y = dx / length;
    
    let bend_factor = if total_edges <= 1 {
        0.0 
    } else {
        let max_bend = if total_edges > 4 { 0.6 } else { 0.8 };
        let step = (max_bend * 2.0) / (total_edges as f64 - 1.0);
        -max_bend + step * edge_index as f64
    };
    
    let distance_factor = (length / 8.0).min(0.8).max(0.1);
    
    let edge_count_factor = 1.0 / (1.0 + (total_edges as f64 - 1.0) * 0.1);
    
    let bend_amount = spacing_factor * bend_factor * distance_factor * edge_count_factor;
    
    let bend_x = perp_x * bend_amount;
    let bend_y = perp_y * bend_amount;
    
    let cx1 = x1 + dx * 0.3 + bend_x;
    let cy1 = y1 + dy * 0.3 + bend_y;
    let cx2 = x1 + dx * 0.7 + bend_x;
    let cy2 = y1 + dy * 0.7 + bend_y;
    
    let mid_x = x1 + dx / 2.0 + bend_x * 0.75;
    let mid_y = y1 + dy / 2.0 + bend_y * 0.75;
    
    ((cx1, cy1, cx2, cy2), (mid_x, mid_y))
}

fn calculate_professional_layout(graph: &ZXGraph, config: &TikzConfig) -> HashMap<NodeIndex, (f64, f64)> {
    let nodes: Vec<NodeIndex> = graph.nodes.iter().enumerate()
        .filter_map(|(i, n)| if n.is_some() { Some(NodeIndex(i)) } else { None })
        .collect();
    
    if nodes.is_empty() {
        return HashMap::new();
    }
    
    let positions = calculate_circuit_layout(graph, &nodes, config);
    
    // Ensure all nodes have positions by assigning defaults to any missing ones
    let mut complete_positions = HashMap::new();
    
    // First add all calculated positions
    for &node in &nodes {
        if let Some(&pos) = positions.get(&node) {
            complete_positions.insert(node, pos);
        } else {
            // Assign a default position for nodes without one
            complete_positions.insert(node, (0.0, 0.0));
        }
    }
    
    // Make sure all input nodes have positions
    for &node in &graph.input_nodes {
        if !complete_positions.contains_key(&node) {
            complete_positions.insert(node, (0.0, 0.0));
            println!("Warning: Added default position for input node {:?}", node);
        }
    }
    
    // Make sure all output nodes have positions
    for &node in &graph.output_nodes {
        if !complete_positions.contains_key(&node) {
            complete_positions.insert(node, (0.0, 0.0));
            println!("Warning: Added default position for output node {:?}", node);
        }
    }
    
    let mut adjusted_positions = complete_positions.clone();
    for (&node, &(x, y)) in &complete_positions {
        if graph.is_input_node(node) {
            adjusted_positions.insert(node, (x + config.node_spacing * 0.5, y));
        }
    }
    
    center_and_normalize_positions(&mut adjusted_positions);
    
    adjusted_positions
}

fn calculate_circuit_layout(
    graph: &ZXGraph, 
    nodes: &[NodeIndex],
    config: &TikzConfig
) -> HashMap<NodeIndex, (f64, f64)> {
    let mut positions = HashMap::new();
    
    let (inputs, _outputs, _internal_nodes) = identify_io_nodes(graph, nodes);
    
    let ranks = assign_ranks(graph, &inputs);
    
    let row_assignments = assign_optimal_ordering(graph, &ranks);
    
    let _max_rank = ranks.values().copied().max().unwrap_or(0);
    
    let mut nodes_per_rank: HashMap<usize, Vec<NodeIndex>> = HashMap::new();
    for (&node, &rank) in &ranks {
        nodes_per_rank.entry(rank).or_insert_with(Vec::new).push(node);
    }
    
    let mut max_nodes_in_rank = 0;
    for nodes in nodes_per_rank.values() {
        max_nodes_in_rank = max_nodes_in_rank.max(nodes.len());
    }
    
    for (rank, nodes) in nodes_per_rank {
        let offset = (max_nodes_in_rank as f64 - nodes.len() as f64) / 2.0;
        
        for (_idx, &node) in nodes.iter().enumerate() {
            if let Some(&row_pos) = row_assignments.get(&node) {
                let x = rank as f64 * config.layer_spacing;
                let y = (offset + row_pos as f64) * config.node_spacing;
                
                positions.insert(node, (x, y));
            }
        }
    }

    handle_special_cases(graph, nodes, &mut positions, config);
    
    center_and_normalize_positions(&mut positions);
    
    positions
}

fn identify_io_nodes(
    graph: &ZXGraph, 
    nodes: &[NodeIndex]
) -> (Vec<NodeIndex>, Vec<NodeIndex>, Vec<NodeIndex>) {
    let mut inputs = Vec::new();
    let mut outputs = Vec::new();
    let mut internal = Vec::new();
    
    let mut degree1_nodes: Vec<(NodeIndex, usize)> = Vec::new();
    let mut min_idx = usize::MAX;
    let mut max_idx = 0;
    
    for &node in nodes {
        if let Some(node_ref) = &graph.nodes[node.0] {
            let degree = node_ref.edges.len();
            
            if degree == 1 {
                degree1_nodes.push((node, node.0));
                min_idx = min_idx.min(node.0);
                max_idx = max_idx.max(node.0);
            } else if degree > 0 {
                internal.push(node);
            } else {
                // Handle isolated nodes
            }
        }
    }
    
    degree1_nodes.sort_by_key(|(_, idx)| *idx);
    
    if degree1_nodes.len() <= 1 {
        inputs.extend(degree1_nodes.into_iter().map(|(node, _)| node));
    } else {
        let threshold = (min_idx + max_idx) / 2;
        
        for (node, idx) in degree1_nodes {
            if idx < threshold {
                inputs.push(node);
            } else {
                outputs.push(node);
            }
        }
    }
    
    if inputs.is_empty() && !internal.is_empty() {
        let mut best_node = internal[0];
        let mut lowest_avg = f64::MAX;
        
        for &node in &internal {
            let neighbors: Vec<_> = graph.neighbors(node);
            if !neighbors.is_empty() {
                let avg_idx = neighbors.iter().map(|n| n.0).sum::<usize>() as f64 / neighbors.len() as f64;
                if avg_idx < lowest_avg {
                    lowest_avg = avg_idx;
                    best_node = node;
                }
            }
        }
        
        inputs.push(best_node);
        internal.retain(|&n| n != best_node);
    }
    
    for &node in nodes {
        if let Some(node_ref) = &graph.nodes[node.0] {
            if node_ref.edges.is_empty() && !inputs.contains(&node) && !outputs.contains(&node) && !internal.contains(&node) {
                internal.push(node);
            }
        }
    }
    
    (inputs, outputs, internal)
}

fn assign_ranks(graph: &ZXGraph, inputs: &[NodeIndex]) -> HashMap<NodeIndex, usize> {
    let mut ranks = HashMap::new();
    let mut queue = VecDeque::new();
    
    for &input in inputs {
        ranks.insert(input, 0);
        queue.push_back(input);
    }
    
    if inputs.is_empty() {
        for (i, node_opt) in graph.nodes.iter().enumerate() {
            if node_opt.is_some() {
                let node = NodeIndex(i);
                ranks.insert(node, 0);
                queue.push_back(node);
                break;
            }
        }
    }
    
    while let Some(node) = queue.pop_front() {
        let current_rank = *ranks.get(&node).unwrap();
        let next_rank = current_rank + 1;
        
        for neighbor in graph.neighbors(node) {
            if !ranks.contains_key(&neighbor) {
                ranks.insert(neighbor, next_rank);
                queue.push_back(neighbor);
            }
        }
    }
    
    for (i, node_opt) in graph.nodes.iter().enumerate() {
        if node_opt.is_some() {
            let node = NodeIndex(i);
            if !ranks.contains_key(&node) {
                let max_rank = ranks.values().copied().max().unwrap_or(0) + 1;
                ranks.insert(node, max_rank);
            }
        }
    }
    
    ranks
}

fn assign_optimal_ordering(
    graph: &ZXGraph, 
    ranks: &HashMap<NodeIndex, usize>
) -> HashMap<NodeIndex, usize> {
    let mut nodes_by_rank: HashMap<usize, Vec<NodeIndex>> = HashMap::new();
    for (&node, &rank) in ranks {
        nodes_by_rank.entry(rank).or_insert_with(Vec::new).push(node);
    }
    
    let mut sorted_ranks: Vec<_> = nodes_by_rank.keys().collect();
    sorted_ranks.sort();
    
    let mut positions: HashMap<NodeIndex, usize> = HashMap::new();
    
    if let Some(&first_rank) = sorted_ranks.first() {
        if let Some(nodes) = nodes_by_rank.get(&first_rank) {
            let mut first_layer = nodes.clone();
            first_layer.sort_by_key(|n| n.0);
            
            for (i, &node) in first_layer.iter().enumerate() {
                positions.insert(node, i);
            }
        }
    }
    
    for &rank in &sorted_ranks[1..] {
        if let Some(nodes) = nodes_by_rank.get(&rank) {
            let mut node_positions: Vec<(NodeIndex, f64)> = Vec::new();
            
            for &node in nodes {
                let neighbors: Vec<_> = graph.neighbors(node)
                    .into_iter()
                    .filter(|n| ranks.get(n).copied().unwrap_or(*rank) < *rank)
                    .collect();
                
                if neighbors.is_empty() {
                    node_positions.push((node, node.0 as f64));
                } else {
                    let avg_pos = neighbors.iter()
                        .filter_map(|n| positions.get(n).map(|p| *p as f64))
                        .sum::<f64>() / neighbors.len() as f64;
                    
                    node_positions.push((node, avg_pos));
                }
            }
            
            node_positions.sort_by(|a, b| a.1.partial_cmp(&b.1).unwrap_or(std::cmp::Ordering::Equal));
            
            for (i, (node, _)) in node_positions.into_iter().enumerate() {
                positions.insert(node, i);
            }
        }
    }
    
    for &rank in sorted_ranks.iter().rev().skip(1) {
        if let Some(nodes) = nodes_by_rank.get(&rank) {
            let mut node_positions: Vec<(NodeIndex, f64)> = Vec::new();
            
            for &node in nodes {
                let neighbors: Vec<_> = graph.neighbors(node)
                    .into_iter()
                    .filter(|n| ranks.get(n).copied().unwrap_or(*rank) > *rank)
                    .collect();
                
                if !neighbors.is_empty() {
                    let avg_pos = neighbors.iter()
                        .filter_map(|n| positions.get(n).map(|p| *p as f64))
                        .sum::<f64>() / neighbors.len() as f64;
                    
                    let current_pos = positions.get(&node).copied().unwrap_or(0) as f64;
                    let new_pos = (current_pos + avg_pos) / 2.0;
                    node_positions.push((node, new_pos));
                } else {
                    let current_pos = positions.get(&node).copied().unwrap_or(0) as f64;
                    node_positions.push((node, current_pos));
                }
            }
            
            node_positions.sort_by(|a, b| a.1.partial_cmp(&b.1).unwrap_or(std::cmp::Ordering::Equal));
            
            for (i, (node, _)) in node_positions.into_iter().enumerate() {
                positions.insert(node, i);
            }
        }
    }
    
    positions
}

fn handle_special_cases(
    graph: &ZXGraph,
    nodes: &[NodeIndex],
    positions: &mut HashMap<NodeIndex, (f64, f64)>,
    config: &TikzConfig,
) {
    let mut max_y: f64 = 0.0;
    for &(_, y) in positions.values() {
        max_y = max_y.max(y);
    }
    
    let mut isolated_nodes: Vec<NodeIndex> = Vec::new();
    for &node in nodes {
        if let Some(node_ref) = &graph.nodes[node.0] {
            if node_ref.edges.is_empty() && !positions.contains_key(&node) {
                isolated_nodes.push(node);
            }
        }
    }
    
    if !isolated_nodes.is_empty() {
        let isolated_y = max_y + config.node_spacing * 2.0; 
        let grid_width = (isolated_nodes.len() as f64).sqrt().ceil() as usize;
        
        for (i, &node) in isolated_nodes.iter().enumerate() {
            let row = i / grid_width;
            let col = i % grid_width;
            
            let x = (col as f64 - (grid_width as f64 - 1.0) / 2.0) * config.node_spacing;
            let y = isolated_y + row as f64 * config.node_spacing;
            
            positions.insert(node, (x, y));
        }
    }
}

fn center_and_normalize_positions(positions: &mut HashMap<NodeIndex, (f64, f64)>) {
    if positions.is_empty() {
        return;
    }
    
    let mut min_x = f64::MAX;
    let mut min_y = f64::MAX;
    let mut max_x = f64::MIN;
    let mut max_y = f64::MIN;
    
    for &(x, y) in positions.values() {
        min_x = min_x.min(x);
        min_y = min_y.min(y);
        max_x = max_x.max(x);
        max_y = max_y.max(y);
    }
    
    let center_x = (min_x + max_x) / 2.0;
    let center_y = (min_y + max_y) / 2.0;
    
    for (_, pos) in positions.iter_mut() {
        pos.0 -= center_x;
        pos.1 -= center_y;
    }
}

fn group_edges_by_endpoints(graph: &ZXGraph) -> HashMap<(NodeIndex, NodeIndex), Vec<(EdgeIndex, &Edge)>> {
    let mut edge_groups = HashMap::new();
    
    for (i, edge) in graph.edges.iter().enumerate() {
        if let Some(edge) = edge {
            let key = if edge.endpoints.0.0 <= edge.endpoints.1.0 {
                (edge.endpoints.0, edge.endpoints.1)
            } else {
                (edge.endpoints.1, edge.endpoints.0)
            };
            
            edge_groups
                .entry(key)
                .or_insert_with(Vec::new)
                .push((EdgeIndex(i), edge));
        }
    }
    
    edge_groups
}

pub fn save_tikz_to_file(
    graph: &ZXGraph,
    config: &TikzConfig,
    filepath: &str,
) -> std::io::Result<()> {
    let tikz_content = generate_tikz(graph, config);
    
    let latex_document = format!(
        "\\documentclass{{standalone}}\n\\usepackage{{tikz}}\n\n\\begin{{document}}\n{}\n\\end{{document}}\n",
        tikz_content
    );
    
    let mut file = File::create(Path::new(filepath))?;
    file.write_all(latex_document.as_bytes())?;
    
    println!("TikZ diagram saved to: {}", filepath);
    Ok(())
}
