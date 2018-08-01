//
//  DiagonalMatrixTests.swift
//  MathEagle
//
//  Created by Rugen Heidbuchel on 01/06/15.
//  Copyright (c) 2015 Jorestha Solutions. All rights reserved.
//

import XCTest
import MathEagle


class DiagonalMatrixTests: XCTestCase {
    
    
    // MARK: Initialisers
    
    func testInitDiagonal() {
        
        let D = DiagonalMatrix(diagonal: [1, 2, 3, 4])
        XCTAssertEqual(4, D.size!)
        XCTAssertEqual([1, 2, 3, 4], D.diagonalElements)
    }
    
    
    func testInitDiagonalDimensions() {
        
        let D = DiagonalMatrix(diagonal: [1, 2, 3, 4], dimensions: Dimensions(4, 6))
        XCTAssertEqual(Dimensions(4, 6), D.dimensions)
        XCTAssertEqual([1, 2, 3, 4], D.diagonalElements)
    }
    
    
    func testInitDimensionsGenerator() {
        
        let D = DiagonalMatrix(dimensions: Dimensions(2, 3)){ $0.row }
        XCTAssertEqual(Dimensions(2, 3), D.dimensions)
        XCTAssertEqual([0, 1], D.diagonalElements)
        XCTAssertEqual([[0, 0, 0], [0, 1, 0]], D.elements)
    }
    
    
    func testInitFilledWithDimensions() {
        
        let D = DiagonalMatrix(filledWith: 3, dimensions: Dimensions(2, 3))
        XCTAssertEqual(Dimensions(2, 3), D.dimensions)
        XCTAssertEqual([[3, 0, 0], [0, 3, 0]], D.elements)
    }
    
    
    
    // MARK: Properties
    
    func testRank() {
        
        var D = DiagonalMatrix(filledWith: 3, dimensions: Dimensions(2, 4))
        XCTAssertEqual(2, D.rank)
        
        D = DiagonalMatrix(diagonal: [1, 2, 3, 0, 5])
        XCTAssertEqual(4, D.rank)
    }
    
    
    func testDeterminant() {
        
        var D = DiagonalMatrix(diagonal: [1, 2, 3])
        XCTAssertEqual(6, D.determinant)
        
        D = DiagonalMatrix(diagonal: [4, 2, 0, 5])
        XCTAssertEqual(0, D.determinant)
    }
    
    
    func testDiagonalElements() {
        
        var D = DiagonalMatrix(diagonal: [1, 2, 3])
        XCTAssertEqual([1, 2, 3], D.diagonalElements)
        
        D = DiagonalMatrix(filledWith: 5, dimensions: Dimensions(size: 2))
        XCTAssertEqual([5, 5], D.diagonalElements)
    }
    
    
    func testSetDiagonalElements() {
        
        var D = DiagonalMatrix(diagonal: [1, 2, 3, 4])
        D.diagonalElements = [2, 3, 5]
        XCTAssertEqual([2, 3, 5], D.diagonalElements)
        XCTAssertEqual(Dimensions(size: 3), D.dimensions)
        
        D = DiagonalMatrix(filledWith: 5, dimensions: Dimensions(3, 4))
        D.diagonalElements = [1, 2, 3, 4]
        XCTAssertEqual([1, 2, 3, 4], D.diagonalElements)
        XCTAssertEqual(Dimensions(size: 4), D.dimensions)
        
        D = DiagonalMatrix(filledWith: 5, dimensions: Dimensions(3, 4))
        D.diagonalElements = [1, 2, 3, 4, 5]
        XCTAssertEqual([1, 2, 3, 4, 5], D.diagonalElements)
        XCTAssertEqual(Dimensions(size: 5), D.dimensions)
        
        D = DiagonalMatrix(filledWith: 5, dimensions: Dimensions(2, 4))
        D.diagonalElements = [1, 2, 3]
        XCTAssertEqual([1, 2, 3], D.diagonalElements)
        XCTAssertEqual(Dimensions(3, 4), D.dimensions)
        
        D = DiagonalMatrix(filledWith: 5, dimensions: Dimensions(4, 2))
        D.diagonalElements = [1, 2, 3]
        XCTAssertEqual([1, 2, 3], D.diagonalElements)
        XCTAssertEqual(Dimensions(4, 3), D.dimensions)
        
        D = DiagonalMatrix(filledWith: 5, dimensions: Dimensions(3, 4))
        D.diagonalElements = [1, 2]
        XCTAssertEqual([1, 2], D.diagonalElements)
        XCTAssertEqual(Dimensions(2, 4), D.dimensions)
        
        D = DiagonalMatrix(filledWith: 5, dimensions: Dimensions(4, 3))
        D.diagonalElements = [1, 2]
        XCTAssertEqual([1, 2], D.diagonalElements)
        XCTAssertEqual(Dimensions(4, 2), D.dimensions)
        
        D = DiagonalMatrix(filledWith: 5, dimensions: Dimensions(4, 4))
        D.diagonalElements = [1, 2]
        XCTAssertEqual([1, 2], D.diagonalElements)
        XCTAssertEqual(Dimensions(size: 2), D.dimensions)
    }
}