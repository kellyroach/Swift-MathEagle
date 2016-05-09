//
//  GraphTests.swift
//  MathEagle
//
//  Created by Rugen Heidbuchel on 05/05/16.
//  Copyright © 2016 Jorestha Solutions. All rights reserved.
//

import Cocoa
import XCTest
import MathEagle

class GraphTests: XCTestCase {
    
    // TODO: Add more test graphs (negative weights, directed, ...)
    
    var undirectedGraph = Graph<String, Double, Double>()

    override func setUp() {
        
        undirectedGraph.addBidirectionalEdge(173.4, capacity: 20.0, fromVertex: "Amsterdam", toVertex: "Brussels")
        undirectedGraph.addBidirectionalEdge(46.8, capacity: 13.5, fromVertex: "Brussels", toVertex: "Charleroi")
        undirectedGraph.addBidirectionalEdge(757.1, capacity: 38.4, fromVertex: "Amsterdam", toVertex: "Dublin")
        undirectedGraph.addBidirectionalEdge(800.8, capacity: 7.2, fromVertex: "Dublin", toVertex: "Charleroi")
        undirectedGraph.addBidirectionalEdge(135.8, capacity: 26.8, fromVertex: "Eindhoven", toVertex: "Charleroi")
    }
    
    
    // MARK: Basic Properties Tests
    
    func testVertexManagement() {
        
        XCTAssertContentEqual(undirectedGraph.vertices, ["Amsterdam", "Brussels", "Charleroi", "Dublin", "Eindhoven"])
        XCTAssertEqual(undirectedGraph.numberOfVertices, 5)
        
        XCTAssertTrue(undirectedGraph.containsVertex("Amsterdam"))
        XCTAssertFalse(undirectedGraph.containsVertex("Waterloo"))
        
        undirectedGraph.addVertex("TestVertex")
        XCTAssertTrue(undirectedGraph.containsVertex("TestVertex"))
        undirectedGraph.removeVertex("TestVertex")
        XCTAssertFalse(undirectedGraph.containsVertex("TestVertex"))
        
        XCTAssertEqual(undirectedGraph.degreeOfVertex("Amsterdam"), 2)
        XCTAssertEqual(undirectedGraph.degreeOfVertex("TestVertex"), 0)
        
        XCTAssertEqual(undirectedGraph.numberOfVerticesWithOddDegree, 2)
        
        undirectedGraph.removeVertex("Eindhoven")
        XCTAssertEqual(undirectedGraph.numberOfVertices, 4)
        XCTAssertFalse(undirectedGraph.containsVertex("Eindhoven"))
    }
    
    func testEdgeManagement() {
        
        XCTAssertEqual(undirectedGraph.numberOfEdges, 5)
        XCTAssertEqual(undirectedGraph.numberOfEdges(countBidirectionalEdgesTwice: true), 10)
        
        XCTAssertEqual(undirectedGraph.getEdgeWeight(fromVertex: "Amsterdam", toVertex: "Brussels"), 173.4)
        XCTAssertEqual(undirectedGraph.getEdgeWeight(fromVertex: "Amsterdam", toVertex: "Charleroi"), 0.0)
        
        XCTAssertEqual(undirectedGraph.getEdgeCapacity(fromVertex: "Amsterdam", toVertex: "Brussels"), 20.0)
        XCTAssertEqual(undirectedGraph.getEdgeCapacity(fromVertex: "Amsterdam", toVertex: "Charleroi"), 0.0)
        
        XCTAssertTrue(undirectedGraph.containsEdge(fromVertex: "Amsterdam", toVertex: "Brussels"))
        XCTAssertTrue(undirectedGraph.containsEdge(fromVertex: "Brussels", toVertex: "Amsterdam"))
        XCTAssertFalse(undirectedGraph.containsEdge(fromVertex: "Amsterdam", toVertex: "Charleroi"))
        
        var edge = undirectedGraph.removeEdge(fromVertex: "Amsterdam", toVertex: "Brussels")!
        XCTAssertEqual(edge.weight, 173.4)
        XCTAssertEqual(edge.capacity, 20.0)
        
        XCTAssertFalse(undirectedGraph.containsEdge(fromVertex: "Amsterdam", toVertex: "Brussels"))
        XCTAssertTrue(undirectedGraph.containsEdge(fromVertex: "Brussels", toVertex: "Amsterdam"))
        
        edge = undirectedGraph.removeBidirectionalEdge(fromVertex: "Amsterdam", toVertex: "Brussels")!
        XCTAssertEqual(edge.weight, 173.4)
        XCTAssertEqual(edge.capacity, 20.0)
        
        XCTAssertFalse(undirectedGraph.containsEdge(fromVertex: "Amsterdam", toVertex: "Brussels"))
        XCTAssertFalse(undirectedGraph.containsEdge(fromVertex: "Brussels", toVertex: "Amsterdam"))
    }
    
    
    // MARK: Shortest Path Tests
    
    func testDijkstraUndirectedGraph() {
        
        var shortestPathResult = undirectedGraph.dijkstra(fromVertex: "Amsterdam", toVertex: "Eindhoven")
        XCTAssertNotNil(shortestPathResult)
        XCTAssertEqual(shortestPathResult!.path, ["Amsterdam", "Brussels", "Charleroi", "Eindhoven"])
        XCTAssertEqual(shortestPathResult!.totalDistance, 356)
        
        shortestPathResult = undirectedGraph.dijkstra(fromVertex: "Amsterdam", toVertex: "Waterloo")
        XCTAssertNil(shortestPathResult)
    }
    
    func testBellmanFordUndirectedGraph() {
        
        var minimumDistances = try! undirectedGraph.bellmanFord(fromVertex: "Amsterdam")
        XCTAssertEqual(minimumDistances["Amsterdam"]!.distance, 0.0)
        XCTAssertEqual(minimumDistances["Amsterdam"]!.vertex!, "Amsterdam")
        XCTAssertEqual(minimumDistances["Brussels"]!.distance, 173.4)
        XCTAssertEqual(minimumDistances["Brussels"]!.vertex!, "Amsterdam")
        XCTAssertEqual(minimumDistances["Charleroi"]!.distance, 220.2)
        XCTAssertEqual(minimumDistances["Charleroi"]!.vertex!, "Brussels")
        XCTAssertEqual(minimumDistances["Dublin"]!.distance, 757.1)
        XCTAssertEqual(minimumDistances["Dublin"]!.vertex!, "Amsterdam")
        XCTAssertEqual(minimumDistances["Eindhoven"]!.distance, 356)
        XCTAssertEqual(minimumDistances["Eindhoven"]!.vertex!, "Charleroi")
    }
}