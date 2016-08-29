//
//  Matrix.swift
//  SwiftMath
//
//  Created by Rugen Heidbuchel on 22/12/14.
//  Copyright (c) 2014 Jorestha Solutions. All rights reserved.
//

import Foundation
import Accelerate

public protocol MatrixCompatible: Equatable, Comparable, Addable, Negatable, Subtractable, Multiplicable, Dividable, NaturalPowerable, IntegerPowerable, RealPowerable, Conjugatable, Randomizable, IntegerLiteralConvertible {}

/**
    A generic class representing a 2-dimensional matrix of the given type.
*/
public class Matrix <T: MatrixCompatible> : ArrayLiteralConvertible, Equatable, CustomStringConvertible, SequenceType {
    
    
    
    // MARK: Internal Elements
    
    /**
        The variable to store the inner structure of the matrix.
    */
    public var elementsStructure: [T] = []
    
    
    /**
        The variable to store the dimensions of the matrix.
    */
    internal var innerDimensions: Dimensions = Dimensions()
    
    
    /**
        Gets or sets the dimensions of the matrix.
    
        :Set: When the new dimensions are smaller, the stored elements will
                simply be removed. When the dimensions are bigger, the matrix will
                be padded with zeros.
    */
    public var dimensions: Dimensions {
        
        get {
            return self.innerDimensions
        }
        
        set(newDimensions) {
            
            if newDimensions.columns < self.dimensions.columns {
                
                for r in 0 ..< min(newDimensions.rows, self.dimensions.rows) {
                    self.elementsStructure.removeRange((r + 1) * newDimensions.columns ..< r * newDimensions.columns + self.dimensions.columns)
                }
                
            } else if newDimensions.columns > self.dimensions.columns {
                
                for r in 0 ..< min(newDimensions.rows, self.dimensions.rows) {
                    self.elementsStructure.insertContentsOf([T](count: newDimensions.columns - self.dimensions.columns, repeatedValue: 0), at: r * newDimensions.columns + self.dimensions.columns)
                }
            }
            
            if newDimensions.rows < self.dimensions.rows {
                
                self.elementsStructure.removeRange(newDimensions.product ..< self.elementsStructure.count)
                
            } else if newDimensions.rows > self.dimensions.rows {
                
                self.elementsStructure.appendContentsOf([T](count: (newDimensions.rows - self.dimensions.rows) * newDimensions.columns, repeatedValue: 0))
            }
            
            self.innerDimensions = newDimensions
        }
    }
    
    
    /**
        Returns a row major ordered list of all elements in the array.
        This should be used for high performance applications.
    */
    public var elementsList: [T] {
        
        get {
            return elementsStructure
        }
        
        set (newElementsList) {
            elementsStructure = newElementsList
        }
    }
    
    
    /**
        Returns or sets a 2 dimensional array containing the elements of the matrix.
        The array contains array's that represent rows.
    
        :performance: This method scales O(n*m) for an nxm matrix, so elementsList should be used for
                        high performance applications.
    */
    public var elements: [[T]] {
        
        get {
            var elements = [[T]]()
            
            for r in 0 ..< self.dimensions.rows {
                
                var rowElements = [T]()
                
                for c in 0 ..< self.dimensions.columns {
                    rowElements.append(elementsList[r * self.dimensions.columns + c])
                }
                
                elements.append(rowElements)
            }
            
            if elements.count == 0 {
                elements.append([])
            }
            
            return elements
        }
        
        set(newElements) {
            
            elementsList = []
            
            for row in newElements {
                elementsList.appendContentsOf(row)
            }
            
            if newElements.count == 0 || newElements[0].count == 0 {
                self.innerDimensions = Dimensions()
            } else {
                self.innerDimensions = Dimensions(newElements.count, newElements[0].count)
            }
        }
    }
    
    
    
    // MARK: Initialisation
    
    /**
        Creates an empty matrix with elements [[]]. The dimensions
        will be (0, 0).
    */
    public init() {}
    
    
    /**
        Creates a matrix with the given elements.
    
        - parameter elements: The elements of the matrix. Every element
                    in this array should be an array representing
                    a row in the matrix.
    */
    public init(_ elements: [[T]]) {
    
        self.elements = elements
    }
    
    
    /**
        Creates a matrix with the given array literal.
    
        - parameter elements: The elements of the matrix. Every element
                    in this array should be an array representing
                    a row in the matrix.
    */
    public required init(arrayLiteral elements: [T]...) {
        
        self.elements = elements
    }
    
    
    /**
        Creates a matrix with the given elementsList and the
        given number of rows.
    
        - parameter elementsList: A flat row majored list of all elements in
                    the matrix.
        - parameter rows: The number of rows the matrix should have.
    
        :exception: An exception will be thrown when the number
                        of elements in the elementsList is not
                        a multiple of rows.
    */
    public init(elementsList: [T], rows: Int) {
        
        if elementsList.count != 0 && elementsList.count % rows != 0 {
            NSException(name: "Wrong number of elements", reason: "The number of elements in the given list is not a multiple of rows.", userInfo: nil).raise()
        }
        
        self.innerDimensions = Dimensions(rows, rows == 0 ? 0 : elementsList.count / rows)
        self.elementsList = elementsList
    }
    
    
    /**
        Creates a matrix with the given elementsList and the
        given number of columns.
    
        - parameter elementsList: A flat row majored list of all elements in
                    the matrix.
        - parameter columns: The number of columns the matrix should have.
    
        :exception: An exception will be thrown when the number
                        of elements in the elementsList is not
                        a multiple of columns.
    */
    public init(elementsList: [T], columns: Int) {
        
        if elementsList.count != 0 && elementsList.count % columns != 0 {
            NSException(name: "Wrong number of elements", reason: "The number of elements in the given list is not a multiple of columns.", userInfo: nil).raise()
        }
        
        self.innerDimensions = Dimensions(columns == 0 ? 0 : elementsList.count / columns, columns)
        self.elementsList = elementsList
    }
    
    
    /**
        Creates a matrix with the given elementsList and the
        given dimensions.
    
        - parameter elementsList: A flat row majored list of all elements in
                    the matrix.
        - parameter dimensions: The dimensions the matrix should have.
    
        :exception: An exception will be thrown when the number
                        of elements in the elementsList is not
                        equal to the product of the dimensions.
    */
    public init(elementsList: [T], dimensions: Dimensions) {
        
        if elementsList.count != dimensions.product {
            NSException(name: "Wrong number of elements", reason: "The number of elements in the given list is not equal to the product of the dimensions.", userInfo: nil).raise()
        }
        
        self.innerDimensions = dimensions
        self.elementsList = elementsList
    }
    
    
    /**
        Creates a matrix with the given dimensions using
        the given generator.
    
        - parameter dimensions: The dimensions the matrix should have.
        - parameter generator: The generator used to generate the matrix.
                    This function is called for every element passing
                    the index of the element.
    */
    public init(dimensions: Dimensions, generator: (Index) -> T) {
        
        self.elementsList = []
        self.innerDimensions = dimensions
        
        for row in 0 ..< dimensions.rows {
            for col in 0 ..< dimensions.columns {
                self.elementsList.append(generator([row, col]))
            }
        }
    }
    
    
    /**
        Creates a square matrix with the given size using the given generator.
    
        - parameter size:        The size the matrix should have.
        - parameter generator:   The generator used to generate the matrix.
                                This function is called for every element
                                passing the index of the element.
    */
    public convenience init(size: Int, generator: (Index) -> T) {
        
        self.init(dimensions: Dimensions(size, size), generator: generator)
    }
    
    
    /**
        Creates a random matrix with the given dimensions. This uses
        the `random` function of the type of the matrix. Note that for
        this initialiser to work the type must be known to the compiler.
        So you can either state the type of the variable explicitly or
        call the initialiser with the specific type like Matrix<Type>(...).
    
        - parameter dimensions:  The dimensions the matrix should have.
    */
    public convenience init(randomWithDimensions dimensions: Dimensions) {
        
        self.init(elementsList: T.randomArrayOfLength(dimensions.product), dimensions: dimensions)
    }
    
    
    /**
        Creates a random square matrix with the given size. This uses
        the `random` function of the type of the matrix. Note that for
        this initialiser to work the type must be known to the compiler.
        So you can either state the type of the variable explicitly or
        call the initialiser with the specific type like Matrix<Type>(...).
    
        - parameter size:    The size the matrix should have.
    */
    public convenience init(randomWithSize size: Int) {
        
        self.init(randomWithDimensions: Dimensions(size, size))
    }
    
    
    /**
        Creates a random matrix with the given dimensions. The values lie in
        the given interval. This uses the `randomInInterval` function of the
        type of the matrix. Note that for this initialiser to work the type must
        be known to the compiler. So you can either state the type of the
        variable explicitly or call the initialiser with the specific type
        like Matrix<Type>(...).
    
        - parameter dimensions:  The dimensions the matrix should have.
        - parameter intervals:   The interval in which the values can lie. You should
                                only pass multiple intervals for Complex matrices.
                                Here the first interval represents the interval
                                for the real part and the second interval represents
                                the interval for the imaginary part.
    */
    public convenience init(randomWithDimensions dimensions: Dimensions, intervals: ClosedInterval<T.RandomIntervalType>...) {
        
        //TODO: Improve this implementation.
        self.init(dimensions: dimensions, generator: { i in T.randomInInterval(intervals) })
    }
    
    
    /**
        Creates a random square matrix with the given size. The values lie in
        the given interval. This uses the `randomInInterval` function of the
        type of the matrix. Note that for this initialiser to work the type must
        be known to the compiler. So you can either state the type of the
        variable explicitly or call the initialiser with the specific type
        like Matrix<Type>(...).
    
        - parameter size:  The dimensions the matrix should have.
        - parameter intervals:   The interval in which the values can lie. You should
                                only pass multiple intervals for Complex matrices.
                                Here the first interval represents the interval
                                for the real part and the second interval represents
                                the interval for the imaginary part.
    */
    public convenience init(randomWithSize size: Int, intervals: ClosedInterval<T.RandomIntervalType>...) {
        
        self.init(size: size, generator: { i in T.randomInInterval(intervals) })
    }
    
    
    public init(symmetrical elements: [T]) {
        
        //TODO: Remove this initialiser, move it to a SymmetricalMatrix class
        self.elementsList = [T]()
        
        let size = (elements.count + 1) / 2
        self.innerDimensions = Dimensions(size, size)
        
        for row in 0 ..< size {
            for column in 0 ..< size {
                elementsList.append(elements[row + column])
            }
        }
    }
    
    
    /**
        Creates a matrix of the given size filled with the given element.
    
        - parameter element: The element to fill the matrix with.
        - parameter size:    The size the matrix should have.
    */
    public convenience init(filledWith element: T, size: Int) {
        
        self.init(filledWith: element, dimensions: Dimensions(size: size))
    }
    
    
    /**
        Creates a matrix with the given dimensions filled with the given element.
    
        - parameter element:     The element to fill the matrix with.
        - parameter dimensions:  The dimensions the matrix should have.
    */
    public init(filledWith element: T, dimensions: Dimensions) {
        
        self.innerDimensions = dimensions
        self.elementsList = [T](count: dimensions.rows * dimensions.columns, repeatedValue: element)
    }
    
    
    /**
        Creates an identity matrix of the given size. This means all diagonal elements
        are equal to 1 and all other elements are equal to 0.
    
        - parameter size:    The size the matrix should have.
    */
    public convenience init(identityOfSize size: Int) {
        
        //TODO: Remove this initialiser, move it to a IdentityMatrix subclass of DiagonalMatrix.
        self.init(filledWith: 0, size: size)
        self.fillDiagonal(1)
    }
    
    
    
    // MARK: Subscript Methods
    
    /**
        Gets or sets the element at the given row and column.
    
        - parameter row:     The row of the desired element.
        - parameter column:  The column of the desired element.
    
        - returns: The element at the given row and column.
    
        :exception: An exception will be thrown when either of the indices
                        is out of bounds.
    */
    public subscript(row: Int, column: Int) -> T {
    
        get {
            
            return self.element(row, column)
        }
        
        set(newElement) {
            
            self.setElement(atRow: row, atColumn: column, toElement: newElement)
        }
    }
    
    /**
        Gets or sets the row at the given element.
    
        - parameter index:   The index of the desired row.
    
        - returns: A vector representing the row at the given index.
    
        :exception: An exception will be thrown when the given index is out
                        of bounds.
    */
    public subscript(index: Int) -> Vector<T>  {
        
        get {
            
            return self.row(index)
        }
        
        set(newRow) {
            
            self.setRow(atIndex: index, toRow: newRow)
        }
    }
    
    
    public subscript(indexRange: Range<Int>) -> Matrix<T> {
        
        get {
            
            var matrixElements = [[T]]()
            
            for i in indexRange {
                
                matrixElements.append(self[i].elements)
            }
            
            return Matrix(matrixElements)
        }
        
        set(newMatrix) {
            
            if !indexRange.isEmpty {
                
                if newMatrix.isEmpty {
                    
                    self.elements.removeRange(indexRange)
                    
                } else {
                    
                    self.elements.replaceRange(indexRange, with: newMatrix.elements)
                }
            }
        }
    }
    
    
    /**
        Gets or sets the submatrix at the given index ranges.
    
        - parameter rowRange:    The row index range of the desired submatrix.
        - parameter columnRange: The column index range of the desired submatrix.
    
        - returns: A matrix representing the submatrix at the given index ranges.
    
        :exception: Throws an exception when any of the index ranges is out of bounds.
    */
    public subscript(rowRange: Range<Int>, columnRange: Range<Int>) -> Matrix<T> {
        
        get {
            
            return self.submatrix(rowRange, columnRange)
        }
        
        set(newMatrix) {
            
            self.setSubmatrix(rowRange, columnRange, toMatrix: newMatrix)
        }
    }
    
    
    /**
        Gets or sets the subvector at the given row index range at the given column.
    
        - parameter rowRange:    The row index range of the desired subvector.
        - parameter column:      The column of the desired subvector.
    
        - returns: A vector representing the subvector at the given row index range at
                    the given column.
    
        :exception: Throws an exception when any of the indices is out of bounds.
    */
    public subscript(rowRange: Range<Int>, column: Int) -> Vector<T> {
        
        get {
            
            return self.subvector(rowRange, column)
        }
        
        set(newVector) {
            
            self.setSubvector(rowRange, column, toVector: newVector)
        }
    }
    
    
    /**
        Gets or sets the subvector at the given row at the given column index range.
    
        - parameter row:         The row of the desired subvector.
        - parameter columnRange: The column index range of the desired subvector.
    
        - returns: A vector representing the subvector at the given row at the given
                    columnn index range.
    
        :exception: Throws an exception when any of the indices is out of bounds.
    */
    public subscript(row: Int, columnRange: Range<Int>) -> Vector<T> {
        
        get {
            
            return self.subvector(row, columnRange)
        }
        
        set(newVector) {
            
            self.setSubvector(row, columnRange, toVector: newVector)
        }
    }
    
    
    // MARK: Sequence Type
    
    /**
        Returns a generator for this matrix.
    */
    public func generate() -> MatrixGenerator<T> {
        
        return MatrixGenerator(matrix: self)
    }
    
    
    // MARK: Class Behaviour
    
    /**
        Returns a copy of the matrix.
    */
    public var copy: Matrix<T> {
        
        return Matrix(elementsList: self.elementsList, dimensions: self.dimensions)
    }
    

    // MARK: Basic Properties
    
    /**
        Returns a textual representation of the matrix. This conforms to the array literal.
    
        :example: [[1, 2], [3, 4], [5, 6]]
    */
    public var description: String {
        
        return self.elements.description
    }
    
    
    /**
        Returns the size of the matrix if the matrix is square. If the matrix is not
        square it returns nil.
    
        - returns: The size of the matrix if the matrix is square or nil otherwise.
    */
    public var size: Int? {
        return self.dimensions.size
    }
    
    
    /**
        Gives the rank of the matrix. This is not the tensor rank.
    
        - returns: The rank of the matrix.
    */
    public var rank: Int {
        
        //FIXME: Implement this method!
        return 0
    }
    
    
    /**
        Returns the trace of the matrix. This is the sum of the diagonal elements. If the
        matrix is empty nil is returned.
    
        - returns: The trace of the matrix if the matrix is not empty, otherwise nil.
    */
    public var trace: T? {
        
        return self.isEmpty ? nil : sum(self.diagonalElements)
    }
    
    
    /**
        Returns the determinant of the matrix.
    */
    public var determinant: T {
        
        let (_, _, _, det) = self.LUDecomposition(pivoting: true, optimalPivoting: true)
        return det
    }
    
    
    /**
        Gets or sets the diagonal elements of the matrix.
    
        - returns: An array with the diagonal elements of the matrix.
    
        :exception: Throws an exception when the given array countains too many elements.
    */
    public var diagonalElements: [T] {
        
        get {
            
            var returnElements = [T]()
            
            for i in 0 ..< self.dimensions.minimum {
                
                returnElements.append(self.element(i, i))
            }
            
            return returnElements
        }
        
        set(elements) {
            
            let nrOfDiagonals = self.dimensions.minimum
            
            if elements.count != nrOfDiagonals {
                
                NSException(name: "Diagonal elements out of bounds", reason: "\(elements.count) are too many diagonal elements, only \(nrOfDiagonals) needed.", userInfo: nil).raise()
            }
            
            for i in 0 ..< nrOfDiagonals {
                
                self.setElement(atRow: i, atColumn: i, toElement: elements[i])
            }
        }
    }
    
    
    /**
        Returns the elements of the diagonal at the given index.
        0 represents the main diagonal.
        -1 means the first subdiagonal, this is the one below the main diagonal.
        Other negative numbers represent lower subdiagonals.
        1 means the first superdiagonal, this is the one above the main diagonal.
        Other positive numbers represent higher superdiagonals.
    
        - parameter n: The diagonal's index.
    
        - returns: An array representing the diagonal elements from top left to bottom right in the matrix.
    
        :exception: An exception will be raised if the diagonal at the given index does not exist.
                    This means -n >= the number of rows or n >= the number of columns.
    */
    public func diagonalElements(n: Int = 0) -> [T] {
        
        if -n >= self.dimensions.rows || n >= self.dimensions.columns {
            
            NSException(name: "Index out the bounds.", reason: "The given index is out of bounds.", userInfo: nil).raise()
        }
        
        var returnElements = [T]()
        
        var row = max(-n, 0)
        var col = max(n, 0)
        
        while row < self.dimensions.rows && col < self.dimensions.columns {
            
            returnElements.append(self.element(row, col))
            row += 1
            col += 1
        }
        
        return returnElements
    }
    
    
    /**
        Returns a copy of the matrix with all elements under the main diagonal set to zero.
        This also applies to non-square matrices.
    */
    public var upperTriangle: Matrix<T> {
        
        return try! upperTriangle()
    }
    
    
    /**
        Returns the upper triangle part of the matrix. This is the part of above the diagonal with the given index.
        The diagonal itself is also included. The part below the diagonal contains zero.
        0 represents the main diagonal.
        -1 means the first subdiagonal, this is the one below the main diagonal.
        Other negative numbers represent lower subdiagonals.
        1 means the first superdiagonal, this is the one above the main diagonal.
        Other positive numbers represent higher superdiagonals.
    
        :note: Note that this method also works for non-square matrices, but the returned matrix will thus be
                not upper triangular because only square matrices are upper triangular.
    
        - parameter n: The diagonal's index.
    
        - returns: A matrix where all elements under the diagonal with the given index are zero.
    
        :exception: An exception will be raised if the diagonal at the given index does not exist.
                    This means -n >= the number of rows or n >= the number of columns.
    */
    public func upperTriangle(n: Int = 0) throws -> Matrix<T> {
        
        if n != 0 && (-n >= self.dimensions.rows || n >= self.dimensions.columns) {
            
            throw MatrixError.IndexOutOfBounds(received: n, allowedRange: -(self.dimensions.rows + 1) ... self.dimensions.columns - 1, description: nil)
        }
        
        var row = max(-n, 0)
        var col = max(n, 0)
        
        if n > 0 {
            
            var elementsList = [T](count: self.dimensions.product, repeatedValue: 0)
            
            while row < self.dimensions.rows && col < self.dimensions.columns {
                
                for c in col ..< self.dimensions.columns {
                    
                    elementsList[row * self.dimensions.columns + c] = self.element(row, c)
                }
                
                row += 1
                col += 1
            }
            
            return Matrix(elementsList: elementsList, dimensions: self.dimensions)
            
        } else {
            
            var elementsList = Array(self.elementsList)
            
            while row + 1 < self.dimensions.rows && col < self.dimensions.columns {
                
                for r in row + 1 ..< self.dimensions.rows {
                    
                    elementsList[r * self.dimensions.columns + col] = 0
                }
                
                row += 1
                col += 1
            }
            
            return Matrix(elementsList: elementsList, dimensions: self.dimensions)
        }
    }
    
    
    /**
        Returns a copy of the matrix with all elements above the main diagonal set to zero.
        This also applies to non-square matrices.
    */
    public var lowerTriangle: Matrix<T> {
        
        get {
            return lowerTriangle()
        }
    }
    
    
    /**
        Returns the lower triangle part of the matrix. This is the part of below the diagonal with the given index.
        The diagonal itself is also included. The part below the diagonal contains zero.
        0 represents the main diagonal.
        -1 means the first subdiagonal, this is the one below the main diagonal.
        Other negative numbers represent lower subdiagonals.
        1 means the first superdiagonal, this is the one above the main diagonal.
        Other positive numbers represent higher superdiagonals.
    
        :note: Note that this method also works for non-square matrices, but the returned matrix will thus be
                not lower triangular because only square matrices are lower triangular.
    
        - parameter n:   The diagonal's index.
    
        - returns: A matrix where all elements above the diagonal with the given index are zero.
    
        :exception: An exception will be raised if the diagonal at the given index does not exist.
                    This means -n >= the number of rows or n >= the number of columns.
    */
    public func lowerTriangle(n: Int = 0) -> Matrix<T> {
        
        if n == 0 && self.dimensions.isEmpty {
            return Matrix()
        }
        
        if -n >= self.dimensions.rows || n >= self.dimensions.columns {
            
            NSException(name: "Index out the bounds.", reason: "The given index is out of bounds.", userInfo: nil).raise()
        }
        
        var row = max(-n, 0)
        var col = max(n, 0)
        
        if n >= 0 {
            
            var elementsList = Array(self.elementsList)
            
            while row < self.dimensions.rows && col + 1 < self.dimensions.columns {
                
                for c in col + 1 ..< self.dimensions.columns {
                    
                    elementsList[row * self.dimensions.columns + c] = 0
                }
                
                row += 1
                col += 1
            }
            
            return Matrix(elementsList: elementsList, dimensions: dimensions)
            
        } else {
            
            var elementsList = [T](count: self.dimensions.product, repeatedValue: 0)
            
            while row < self.dimensions.rows && col < self.dimensions.columns {
                
                for r in row ..< self.dimensions.rows {
                    
                    elementsList[r * self.dimensions.columns + col] = self.element(r, col)
                }
                
                row += 1
                col += 1
            }
            
            return Matrix(elementsList: elementsList, dimensions: self.dimensions)
        }
    }
    
    
    /**
        Returns the maximum element in the matrix if the matrix is not empty,
        otherwise it returns nil.
    */
    public var maxElement: T? {
        
        if self.isEmpty {
            
            return nil
            
        } else {
            
            return max(self.elementsList)
        }
    }
    
    
    /**
        Returns the minimum element in the matrix if the matrix is not empty,
        otherwise it returns nil.
    */
    public var minElement: T? {
        
        if self.isEmpty {
            
            return nil
            
        } else {
            
            return min(self.elementsList)
        }
    }
    
    
    /**
        Returns the transpose of the matrix.
    */
    public var transpose: Matrix<T> {
        
        var elementsList = [T]()
        
        for col in 0 ..< self.dimensions.columns {
            for row in 0 ..< self.dimensions.rows {
                
                elementsList.append(self.element(row, col))
            }
        }
        
        return Matrix(elementsList: elementsList, rows: self.dimensions.columns)
    }
    
    
    /**
        Returns the conjugate of the matrix.
    */
    public var conjugate: Matrix<T> {
        
        return mmap(self){ $0.conjugate }
    }
    
    
    /**
        Returns the conjugate transpose of the matrix. This is also called the Hermitian transpose.
    */
    public var conjugateTranspose: Matrix<T> {
        
        return self.transpose.conjugate
    }
    
    
    /**
        Returns whether the matrix is empty. This means the dimensions are (0, 0).
    
        - returns: true if the matrix is empty.
    */
    public var isEmpty: Bool {
        
        return self.dimensions.isEmpty
    }
    
    
    /**
        Returns whether all elements are zero.
    */
    public var isZero: Bool {
        
        for element in self.elementsList {
            
            if element != 0 { return false }
        }
        
        return true
    }
    
    
    /**
        Returns whether the matrix is square.
    
        - returns: true if the matrix is square.
    */
    public var isSquare: Bool {
        
        return self.dimensions.isSquare
    }
    
    
    /**
        Returns whether the matrix is diagonal. This means all elements that are not on the main diagonal are zero.
    */
    public var isDiagonal: Bool {
        
        for (index, element) in self.enumerate() {
            
            if index / self.dimensions.rows != index % self.dimensions.rows && element != 0 {
                
                return false
            }
        }
        
        return true
    }
    
    
    /**
        Returns whether the matrix is symmetrical. This method works O(2n) for symmetrical (square) matrixes of size n.
    
        - returns: true if the matrix is symmetrical.
    */
    public var isSymmetrical: Bool {
        
        // If it's not square, it's impossible to be symmetrical
        if !self.isSquare { return false }
        
        let size = self.dimensions[0]
        
        // If the size is not bigger than 1, it's always symmetrical
        if size <= 1 { return true }
        
        let nrOfSecondDiagonals = 2 * self.dimensions.rows - 1
        
        for i in 1 ..< nrOfSecondDiagonals - 1 {
            
            var k = i/2 + 1
            let d = min(i, size-1)
            while k <= d {
                
                let j = i - k
                if self.element(k, j) != self.element(j, k) { return false }
                k += 1
            }
        }
        
        return true
    }
    
    
    /**
        Returns whether the matrix is upper triangular.
        This means the matrix is square and all elements below the main diagonal are zero.
    */
    public var isUpperTriangular: Bool {
        
        return isUpperTriangular()
    }
    
    
    /**
        Returns whether the matrix is upper triangular according to the given diagonal index.
        This means all elements below the diagonal at the given index n must be zero.
        When mustBeSquare is set to true the matrix must be square.
    
        - parameter n:               The diagonal's index.
        - parameter mustBeSquare:    Whether the matrix must be square to be upper triangular.
    */
    public func isUpperTriangular(n: Int = 0, mustBeSquare: Bool = true) -> Bool {
        
        if -n >= self.dimensions.rows || n >= self.dimensions.columns {
            
            NSException(name: "Index out the bounds.", reason: "The given diagonal index is out of bounds.", userInfo: nil).raise()
        }
        
        // A non-square matrix can't be upper triangular
        if mustBeSquare && !self.isSquare { return false }
        
        if self.dimensions.rows <= 1 { return true }
        
        var row = max(-n, 0)
        var col = max(n, 0)
        
        for c in 0 ..< col {
            
            for r in 0 ..< self.dimensions.rows {
                
                if self.element(r, c) != 0 { return false }
            }
        }
        
        while row + 1 < self.dimensions.rows && col + 1 < self.dimensions.columns {
            
            for r in row + 1 ..< self.dimensions.rows {
                
                if self.element(r, col) != 0 { return false }
            }
            
            row += 1
            col += 1
        }
        
        return true
    }
    
    
    /**
        Returns whether the matrix is upper Hessenberg.
        This means all elements below the first subdiagonal are zero.
    */
    public var isUpperHessenberg: Bool {
        
        return isUpperTriangular(-1)
    }
    
    
    /**
        Returns whether the matrix is lower triangular.
        This means the matrix is square and all elements above the main diagonal are zero.
    */
    public var isLowerTriangular: Bool {
        
        return isLowerTriangular()
    }
    
    
    /**
        Returns whether the matrix is lower triangular according to the given diagonal index.
        This means all elements above the diagonal at the given index n must be zero.
        When mustBeSquare is set to true the matrix must be square.
    
        - parameter n: The diagonal's index.
        - parameter mustBeSquare: Whether the matrix must be square to be lower triangular.
    */
    public func isLowerTriangular(n: Int = 0, mustBeSquare: Bool = true) -> Bool {
        
        if -n >= self.dimensions.rows || n >= self.dimensions.columns {
            
            NSException(name: "Index out the bounds.", reason: "The given diagonal index is out of bounds.", userInfo: nil).raise()
        }
        
        // A non-square matrix can't be upper triangular
        if mustBeSquare && !self.isSquare { return false }
        
        if self.dimensions.rows <= 1 { return true }
        
        var row = max(-n, 0)
        var col = max(n, 0)
        
        for r in 0 ..< row {
            
            for c in 0 ..< self.dimensions.columns {
                
                if self.element(r, c) != 0 { return false }
            }
        }
        
        while row + 1 < self.dimensions.rows && col + 1 < self.dimensions.columns {
            
            for c in col + 1 ..< self.dimensions.columns {
                
                if self.element(row, c) != 0 { return false }
            }
            
            row += 1
            col += 1
        }
        
        return true
    }
    
    
    /**
        Returns whether the matrix is a lower Hessenberg matrix.
        This means all elements above the first superdiagonal are zero.
    */
    public var isLowerHessenberg: Bool {
        
        return isLowerTriangular(1)
    }
    
    
    /**
        Returns whether the matrix is Hermitian.
        This means the matrix is equal to it's own conjugate transpose.
    */
    public var isHermitian: Bool {
        
        if !self.isSquare { return false }
        
        var row = 0, col = 1
        
        while row < self.dimensions.rows && col < self.dimensions.columns {
            
            for c in col ..< self.dimensions.columns {
                
                if self.element(row, c).conjugate != self.element(c, row) {
                    return false
                }
            }
            
            row += 1
            col += 1
        }
        
        return true
    }
    
    
    
    // MARK: Element Methods
    
    /**
        Returns the element at the given index (row, column).
    
        - parameter row:     The row index of the requested element
        - parameter column:  The column index of the requested element
    
        - returns: The element at the given index (row, column).
    
        :exception: Throws an exception when either of the given indices is out of bounds.
    */
    public func element(row: Int, _ column: Int) -> T {
        
        if row < 0 || row >= self.dimensions.rows {
            
            NSException(name: "Row index out of bounds", reason: "The requested element's row index is out of bounds.", userInfo: nil).raise()
        }
        
        if column < 0 || column >= self.dimensions.columns {
            
            NSException(name: "Column index out of bounds", reason: "The requested element's column index is out of bounds.", userInfo: nil).raise()
        }
        
        return self.elementsList[row * self.dimensions.columns + column]
    }
    
    
    /**
        Sets the element at the given indexes.
    
        - parameter row:     The row index of the element
        - parameter column:  The column index of the element
        - parameter element: The element to set at the given indexes
    
        :exception: Throws an exception when either of the given indices is out of bounds.
    */
    public func setElement(atRow row: Int, atColumn column: Int, toElement element: T) {
        
        if row < 0 || row >= self.dimensions.rows {
            
            NSException(name: "Row index out of bounds", reason: "The row index at which the element should be set is out of bounds.", userInfo: nil).raise()
        }
        
        if column < 0 || column >= self.dimensions.columns {
            
            NSException(name: "Column index out of bounds", reason: "The column index at which the element should be set is out of bounds.", userInfo: nil).raise()
        }
        
        self.elementsList[row * self.dimensions.columns + column] = element
    }
    
    
    /**
        Sets the element at the given index.
    
        - parameter index:   A tuple containing the indexes of the element (row, column)
        - parameter element: The element to set at the given index
    
        :exception: Throws an exception when either of the given indices is out of bounds.
    */
    public func setElement(atIndex index: (Int, Int), toElement element: T) {
        
        let (row, column) = index
        
        self.setElement(atRow: row, atColumn: column, toElement: element)
    }
    
    
    /**
        Returns the row at the given index. The first row has index 0.
    
        - returns: The row at the given index.
    
        :exception: Throws an exception when the given index is out of bounds.
    */
    public func row(index: Int) -> Vector<T> {
        
        if index < 0 || index >= self.dimensions.rows {
            
            NSException(name: "Row index out of bounds", reason: "The requested row's index is out of bounds.", userInfo: nil).raise()
        }
        
        var elementsList = [T]()
        
        for i in index * self.dimensions.columns ..< (index + 1) * self.dimensions.columns {
            elementsList.append(self.elementsList[i])
        }
        
        return Vector(elementsList)
    }
    
    
    /**
        Sets the row at the given index to the given row.
    
        - parameter index: The index of the row to change.
        - parameter newRow: The row to set at the given index.
    
        :exception: Throws an exception when the given index is out of bounds.
        :exception: Throws an exception when the given vector is of the wrong length.
    */
    public func setRow(atIndex index: Int, toRow newRow: Vector<T>) {
        
        // If the index is out of bounds
        if index < 0 || index >= self.dimensions.rows {
            
            NSException(name: "Row index out of bounds", reason: "The index at which the row should be set is out of bounds.", userInfo: nil).raise()
        }
        
        // If the row's length is not correct
        if newRow.length != self.dimensions.columns {
            
            NSException(name: "New row wrong length", reason: "The new row's length is not equal to the matrix's number of columns.", userInfo: nil).raise()
        }
        
        self.elementsList.replaceRange(index * self.dimensions.columns ..< (index + 1) * self.dimensions.columns, with: newRow.elements)
    }
    
    
    /**
        Switches the rows at the given indexes.
    
        - parameter i: The index of the first row.
        - parameter j: The index of the second row.
    
        :exception: Throws an exception when the given index is out of bounds.
    */
    public func switchRows(i: Int, _ j: Int) {
        
        if i < 0 || i >= self.dimensions.rows || j < 0 || j >= self.dimensions.rows {
            
            NSException(name: "Row index out of bounds", reason: "The index of the row that should be switched is out of bounds.", userInfo: nil).raise()
        }
        
        let intermediate = self[i]
        
        self[i] = self[j]
        self[j] = intermediate
    }
    
    
    /**
        Returns the column at the given index. The first column has index 0.
    
        - returns: The column at the given index.
    
        :exception: Throws an exception when the given index is out of bounds.
    */
    public func column(index: Int) -> Vector<T> {
        
        if index < 0 || index >= self.dimensions.columns {
            
            NSException(name: "Column index out of bounds", reason: "The requested column's index is out of bounds.", userInfo: nil).raise()
        }
            
        var column = [T]()
        
        for i in 0 ..< self.dimensions.rows {
            
            column.append(self.elementsList[i * self.dimensions.columns + index])
        }
        
        return Vector(column)
    }
    
    
    /**
        Sets the column at the given index to the given column.
    
        - parameter index: The index of the column to change.
        - parameter column: The column to set at the given index.
    
        :exception: Throws an exception when the given index is out of bounds.
        :exception: Throws an exception when the given vector is of the wrong length.
    */
    public func setColumn(atIndex index: Int, toColumn newColumn: Vector<T>) {
        
        // If the index is out of bounds
        if index < 0 || index >= self.dimensions.columns {
            
            NSException(name: "Column index out of bounds", reason: "The index at which the column should be set is out of bounds.", userInfo: nil).raise()
        }
        
        // If the column's length is not correct
        if newColumn.length != self.dimensions.rows {
            
            NSException(name: "New column wrong length", reason: "The new column's length is not equal to the matrix's number of rows.", userInfo: nil).raise()
        }
        
        for i in 0 ..< self.dimensions.rows {
            
            self.elementsList[i * self.dimensions.columns + index] = newColumn[i]
        }
    }
    
    
    /**
        Removes the column at the given index.
    
        - parameter index:   The index of the column to remove.
    
        :exception: Throws an exception when the given index is out of bounds.
    */
    public func removeColumn(atIndex index: Int) {
        
        if index < 0 || index >= self.dimensions.columns {
            
            NSException(name: "Column index out of bounds", reason: "The index of the column that should be removed is out of bounds.", userInfo: nil).raise()
        }
        
        if self.dimensions.columns == 1 {
            
            self.elementsList = []
            self.innerDimensions = Dimensions()
            
        } else {
            
            for r in 0 ..< self.dimensions.rows {
                
                self.elementsList.removeAtIndex(r * (self.dimensions.columns - 1) + index)
            }
            
            self.innerDimensions = Dimensions(self.dimensions.rows, self.dimensions.columns - 1)
        }
    }
    
    
    /**
        Switches the columns at the given indexes.
    
        - parameter i: The index of the first column.
        - parameter j: The index of the second column.
    */
    public func switchColumns(i: Int, _ j: Int) {
        
        let intermediate = self.column(i)
        
        self.setColumn(atIndex: i, toColumn: self.column(j))
        self.setColumn(atIndex: j, toColumn: intermediate)
    }
    
    
    /**
        Returns the submatrix for the given row and column ranges.
    
        - parameter rowRange: The range with rows included in the submatrix.
        - parameter columnRange: The range with columns included in the submatrix.
    
        - returns: The submatrix for the given row and column ranges.
    */
    public func submatrix(rowRange: Range<Int>, _ columnRange: Range<Int>) -> Matrix<T> {
        
        if rowRange.startIndex < 0 || rowRange.endIndex > self.dimensions.rows {
            
            NSException(name: "Row index out of bound", reason: "The row index range is out of bounds. Range \(rowRange) given, but matrix row range is \(0..<self.dimensions.rows) .", userInfo: nil).raise()
        }
        
        if columnRange.startIndex < 0 || columnRange.endIndex > self.dimensions.columns {
            
            NSException(name: "Column index out of bound", reason: "The column index range is out of bounds. Range \(columnRange) given, but matrix column range is \(0..<self.dimensions.columns) .", userInfo: nil).raise()
        }
        
        var elementsList = [T]()
        
        for row in rowRange {
            for column in columnRange {
                
                elementsList.append(self.element(row, column))
            }
        }
        
        return Matrix(elementsList: elementsList, rows: rowRange.endIndex - rowRange.startIndex)
    }
    
    
    /**
        Replaces the current submatrix for the given row and column ranges with the given matrix.
    
        - parameter rowRange: The range with rows included in the submatrix.
        - parameter columnRange: The range with columns included in the submatrix.
        - parameter matrix: The matrix to replace the submatrix with.
    
        :exceptions: Expections will be thrown if the given ranges are out of bounds or if the given matrix's dimensions don't match the given ranges' lengths.
    */
    public func setSubmatrix(rowRange: Range<Int>, _ columnRange: Range<Int>, toMatrix matrix: Matrix<T>) {
        
        if rowRange.startIndex < 0 || rowRange.endIndex > self.dimensions.rows {
            
            NSException(name: "Row index out of bound", reason: "The row index range is out of bounds. Range \(rowRange) given, but matrix row range is \(0..<self.dimensions.rows) .", userInfo: nil).raise()
        }
        
        if columnRange.startIndex < 0 || columnRange.endIndex > self.dimensions.columns {
            
            NSException(name: "Column index out of bound", reason: "The column index range is out of bounds. Range \(columnRange) given, but matrix column range is \(0..<self.dimensions.columns) .", userInfo: nil).raise()
        }
        
        if matrix.dimensions.rows != rowRange.endIndex - rowRange.startIndex || matrix.dimensions.columns != columnRange.endIndex - columnRange.startIndex {
            
            NSException(name: "Matrix dimensions don't match", reason: "The dimensions of the given matrix don't match the dimensions of the row and/or column ranges.", userInfo: nil).raise()
        }
        
        for row in rowRange {
            for column in columnRange {
                
                self.setElement(atRow: row, atColumn: column, toElement: matrix.element(row - rowRange.startIndex, column - columnRange.startIndex))
            }
        }
    }
    
    
    /**
        Returns the subvector for the given row range at the given column.
    
        - parameter rowRange: The range with rows included in the subvector.
        - parameter column: The column of the subvector.
    
        :exceptions: Exceptions will be thrown if the given row range and/or column are out of bounds.
    */
    public func subvector(rowRange: Range<Int>, _ column: Int) -> Vector<T> {
        
        if rowRange.startIndex < 0 || rowRange.endIndex > self.dimensions.rows {
            
            NSException(name: "Row index out of bound", reason: "The row index range is out of bounds. Range \(rowRange) given, but matrix row range is \(0..<self.dimensions.rows) .", userInfo: nil).raise()
        }
        
        if column < 0 || column > self.dimensions.columns {
            
            NSException(name: "Column index out of bound", reason: "The column index is out of bounds. Index \(column) given, but matrix column range is \(0..<self.dimensions.columns) .", userInfo: nil).raise()
        }
        
        var vectorElements = [T]()
        
        for row in rowRange {
            
            vectorElements.append(self.element(row, column))
        }
        
        return Vector(vectorElements)
    }
    
    
    /**
        Replaces the current subvector for the given row range and column with the given vector.
    
        - parameter rowRange: The range with rows included in the subvector.
        - parameter column: The column of the subvector.
        - parameter vector: The vector to replace the subvector with.
    
        :exceptions: Exceptions will be thrown if the given row range and/or column are out of bounds or if the vector's length does not match the row range's length.
    */
    public func setSubvector(rowRange: Range<Int>, _ column: Int, toVector vector: Vector<T>) {
        
        if rowRange.startIndex < 0 || rowRange.endIndex > self.dimensions.rows {
            
            NSException(name: "Row index out of bound", reason: "The row index range is out of bounds. Range \(rowRange) given, but matrix row range is \(0..<self.dimensions.rows) .", userInfo: nil).raise()
        }
        
        if column < 0 || column > self.dimensions.columns {
            
            NSException(name: "Column index out of bound", reason: "The column index is out of bounds. Index \(column) given, but matrix column range is \(0..<self.dimensions.columns) .", userInfo: nil).raise()
        }
        
        if vector.length != rowRange.endIndex - rowRange.startIndex {
            
            NSException(name: "Unequal length", reason: "The length of the given vector is not equal to the length in the given row range. Vector length = \(vector.length), row range = \(rowRange).", userInfo: nil).raise()
        }
        
        for row in rowRange {
            
            self.setElement(atRow: row, atColumn: column, toElement: vector[row - rowRange.startIndex])
        }
    }
    
    
    /**
    Returns the subvector for the given column range at the given row.
    
    - parameter row: The row of the subvector.
    - parameter columnRange: The range with columns included in the subvector.
    
    :exceptions: Exceptions will be thrown if the given row and/or column range are out of bounds.
    */
    public func subvector(row: Int, _ columnRange: Range<Int>) -> Vector<T> {
        
        if row < 0 || row > self.dimensions.rows {
            
            NSException(name: "Row index out of bound", reason: "The row index is out of bounds. Index \(row) given, but matrix row range is \(0..<self.dimensions.rows) .", userInfo: nil).raise()
        }
        
        if columnRange.startIndex < 0 || columnRange.endIndex > self.dimensions.columns {
            
            NSException(name: "Column index out of bound", reason: "The column index range is out of bounds. Range \(columnRange) given, but matrix column range is \(0..<self.dimensions.columns) .", userInfo: nil).raise()
        }
        
        var vectorElements = [T]()
        
        for column in columnRange {
            
            vectorElements.append(self.element(row, column))
        }
        
        return Vector(vectorElements)
    }
    
    
    /**
    Replaces the current subvector for the given row and column range with the given vector.
    
    - parameter row: The row of the subvector.
    - parameter columnRange: The range with columns included in the subvector.
    - parameter vector: The vector to replace the subvector with.
    
    :exceptions: Exceptions will be thrown if the given row and/or column range are out of bounds or if the vector's length does not match the column range's length.
    */
    public func setSubvector(row: Int, _ columnRange: Range<Int>, toVector vector: Vector<T>) {
        
        if row < 0 || row > self.dimensions.rows {
            
            NSException(name: "Row index out of bound", reason: "The row index is out of bounds. Index \(row) given, but matrix row range is \(0..<self.dimensions.rows) .", userInfo: nil).raise()
        }
        
        if columnRange.startIndex < 0 || columnRange.endIndex > self.dimensions.columns {
            
            NSException(name: "Column index out of bound", reason: "The column index range is out of bounds. Range \(columnRange) given, but matrix column range is \(0..<self.dimensions.columns) .", userInfo: nil).raise()
        }
        
        if vector.length != columnRange.endIndex - columnRange.startIndex {
            
            NSException(name: "Unequal length", reason: "The length of the given vector is not equal to the length in the given column range. Vector length = \(vector.length), column range = \(columnRange).", userInfo: nil).raise()
        }
        
        for column in columnRange {
            
            self.setElement(atRow: row, atColumn: column, toElement: vector[column - columnRange.startIndex])
        }
    }
    
    
    /**
        Fills the diagonal with the given value.
    
        - parameter value: The value to fill the diagonal with.
    */
    public func fillDiagonal(value: T) {
        
        for i in 0 ..< self.dimensions.minimum {
            
            self.setElement(atRow: i, atColumn: i, toElement: value)
        }
    }
    
    
    
    // MARK: Factorisations
    
    /**
        Returns the LU decomposition of the matrix. This is only possible if the matrix is square.
    
        - returns: (L, U, P) with L being a lower triangular matrix with 1 on the diagonal, U an upper triangular matrix and P a permutation matrix. This way PA = LU.
    */
    public var LUDecomposition: (Matrix<T>, Matrix<T>, Matrix<T>) {
        
        let (L, U, P, _) = self.LUDecomposition()
        return (L, U, P)
    }
    
    
    /**
        Returns the LU decomposition of the matrix. This is only possible if the matrix is square.
    
        - parameter pivoting: Determines whether the algorithm should use row pivoting. Note that if note pivoting is disabled, the algorithm might not find the LU decomposition.
        - parameter optimalPivoting: Determines whether the algorithm should use optimal row pivoting when pivoting is enabled. This means the biggest element in the current column is chosen to get more numerical stability.
        
        - returns: (L, U, P, det) with L being a lower triangular matrix with 1 on the diagonal, U an upper triangular matrix and P a permutation matrix. This way PA = LU. det gives the determinant of the matrix
    */
    public func LUDecomposition(pivoting pivoting: Bool = true, optimalPivoting: Bool = true) -> (Matrix<T>, Matrix<T>, Matrix<T>, T) {
        
        if !self.isSquare {
            
            NSException(name: "Not square", reason: "A non-square matrix does not have a LU decomposition.", userInfo: nil).raise()
        }
        
        let n = self.size!
        
        let L = Matrix(identityOfSize: n)
        let U = self.copy
        let P = Matrix(identityOfSize: n)
        var detP: T = 1;
        
        for i in 0 ..< n {
            
            if pivoting {
                
                var p = i, max = U[i][i]
                
                for j in i ..< n {
                    
                    if U[i, j] > max { max = U[i, j]; p = j }
                }
                
                if p != i { detP = -detP }
                
                U.switchRows(p, i)
                P.switchRows(p, i)
            }
            
            L[i+1 ..< n, i] = U[i+1 ..< n, i]/U[i, i]
            U[i+1 ..< n, i+1 ..< n] = U[i+1 ..< n, i+1 ..< n] - L[i+1 ..< n, i].directProduct(U[i, i+1 ..< n])
            U[i+1 ..< n, i] = Vector(filledWith: 0, length: n-i-1)
        }
        
        let detU = product(U.diagonalElements)
        
        return (L, U, P, detP * detU)
    }
    
}


// MARK: Matrix Equality

/**
    Returns whether the two given matrices are equal. This means corresponding
    elements are equal.

    - parameter left:    The left matrix in the equation.
    - parameter right:   The right matrix in the equation.

    - returns: true if the two matrices are equal.
*/
public func == <T: MatrixCompatible> (left: Matrix<T>, right: Matrix<T>) -> Bool {
    
    if left.dimensions != right.dimensions {
        return false
    }
    
    for i in 0 ..< left.dimensions.product {
        
        if left.elementsList[i] != right.elementsList[i] {
            return false
        }
    }
    
    return true
}


// MARK: Matrix Addition

/**
    Returns the sum of the two matrices.

    - parameter left:    The left matrix in the sum.
    - parameter right:   The right matrix in the sum.

    - returns: A matrix of the same dimensions as the two
                given matrices.

    :exception: Throws an exception when the dimensions of the two matrices are not equal.
*/
public func + <T: MatrixCompatible> (left: Matrix<T>, right: Matrix<T>) -> Matrix<T> {
    
    if left.dimensions != right.dimensions {
        NSException(name: "Unequal dimensions", reason: "The dimensions of the two matrices are not equal.", userInfo: nil).raise()
    }
    
    return mcombine(left, right){ $0 + $1 }
}

/**
    Returns the sum of the two matrices.

    - parameter left:    The left matrix in the sum.
    - parameter right:   The right matrix in the sum.

    - returns: A matrix of the same dimensions as the two
                given matrices.

    :exception: Throws an exception when the dimensions of the two matrices are not equal.
*/
public func + (left: Matrix<Float>, right: Matrix<Float>) -> Matrix<Float> {
    
    if left.dimensions != right.dimensions {
        NSException(name: "Unequal dimensions", reason: "The dimensions of the two matrices are not equal.", userInfo: nil).raise()
    }
    
//    var elementsList = [Float](count: left.dimensions.product, repeatedValue: 0)
//    
//    vDSP_vadd(left.elementsList, 1, right.elementsList, 1, &elementsList, 1, vDSP_Length(left.dimensions.product))
//    
//    return Matrix(elementsList: elementsList, dimensions: left.dimensions)
    
    var elementsList = right.elementsList
    
    cblas_saxpy(Int32(left.dimensions.product), 1.0, left.elementsList, 1, &elementsList, 1)
    
    return Matrix(elementsList: elementsList, dimensions: left.dimensions)
    
//    var elementsList = right.elementsList
//    
//    catlas_saxpby(Int32(left.dimensions.product), 1.0, left.elementsList, 1, 1.0, &elementsList, 1)
//    
//    return Matrix(elementsList: elementsList, dimensions: left.dimensions)
}

/**
    Returns the sum of the two matrices.

    - parameter left:    The left matrix in the sum.
    - parameter right:   The right matrix in the sum.

    - returns: A matrix of the same dimensions as the two
    given matrices.

    :exception: Throws an exception when the dimensions of the two matrices are not equal.
*/
public func + (left: Matrix<Double>, right: Matrix<Double>) -> Matrix<Double> {
    
    if left.dimensions != right.dimensions {
        NSException(name: "Unequal dimensions", reason: "The dimensions of the two matrices are not equal.", userInfo: nil).raise()
    }
    
    //    var elementsList = [Float](count: left.dimensions.product, repeatedValue: 0)
    //
    //    vDSP_vaddD(left.elementsList, 1, right.elementsList, 1, &elementsList, 1, vDSP_Length(left.dimensions.product))
    //
    //    return Matrix(elementsList: elementsList, dimensions: left.dimensions)
    
    var elementsList = right.elementsList
    
    cblas_daxpy(Int32(left.dimensions.product), 1.0, left.elementsList, 1, &elementsList, 1)
    
    return Matrix(elementsList: elementsList, dimensions: left.dimensions)
    
    //    var elementsList = right.elementsList
    //
    //    catlas_daxpby(Int32(left.dimensions.product), 1.0, left.elementsList, 1, 1.0, &elementsList, 1)
    //
    //    return Matrix(elementsList: elementsList, dimensions: left.dimensions)
}


// MARK: Matrix Negation

/**
    Returns the negation of the given matrix.

    - parameter matrix:  The matrix to negate.

    - returns: A matrix with the given dimensions as the given matrix
                where every element is the negation of the corresponding
                element in the given matrix.
*/
public prefix func - <T: MatrixCompatible> (matrix: Matrix<T>) -> Matrix<T> {
    
    return mmap(matrix){ -$0 }
}


// MARK: Matrix Subtraction

/**
    Returns the subtraction of the two given matrices.

    - parameter left:    The left matrix in the subtraction.
    - parameter right:   The right matrix in the subtraction.

    - returns: A matrix with the same dimensions as the two given matrices
                where every element is the difference of the corresponding
                elements in the left and right matrices.

    :exception: Throws an exception when the dimensions of the two given
                    matrices are not equal.
*/
public func - <T: MatrixCompatible> (left: Matrix<T>, right: Matrix<T>) -> Matrix<T> {
    
    if left.dimensions != right.dimensions {
        NSException(name: "Unequal dimensions", reason: "The dimensions of the two given matrices are not equal. Left dimensions: \(left.dimensions), right dimensions: \(right.dimensions).", userInfo: nil).raise()
    }
    
    return mcombine(left, right){ $0 - $1 }
}


// MARK: Matrix Scalar Multiplication

/**
    Returns the product of the given scalar and the given matrix.

    - parameter scalar:  The scalar with which to multiply the given matrix.
    - parameter matrix:  The matrix to multiply with the given scalar.

    - returns: A matrix of the same dimensions as the given matrix where
                every element is calculated as the product of the corresponding
                element in the given matrix and the given scalar.
*/
public func * <T: MatrixCompatible> (scalar: T, matrix: Matrix<T>) -> Matrix<T> {
    
    return Matrix(matrix.elements.map{ $0.map{ scalar * $0 } })
}

/**
    Returns the product of the given scalar and the given matrix.

    - parameter scalar:  The scalar with which to multiply the given matrix.
    - parameter matrix:  The matrix to multiply with the given scalar.

    - returns: A matrix of the same dimensions as the given matrix where
                every element is calculated as the product of the corresponding
                element in the given matrix and the given scalar.
*/
public func * <T: MatrixCompatible> (matrix: Matrix<T>, scalar: T) -> Matrix<T> {
    
    return scalar * matrix
}


// MARK: Matrix Multiplication

/**
    Returns the product of the two given matrices.

    - parameter left:    The left matrix in the multiplication.
    - parameter right:   The right matrix in the multiplication.

    - returns: A matrix with the same number of rows as the left matrix
                and the same number of columns as the right matrix.

    :exception: Throws an exception when the number of columns of the left
                    matrix is not equal to the number of rows of the right matrix.
*/
public func * <T: MatrixCompatible> (left: Matrix<T>, right: Matrix<T>) -> Matrix<T> {
    
    if left.dimensions.columns != right.dimensions.rows {
        NSException(name: "Wrong dimensions", reason: "The left matrix's number of columns is not equal to the right matrix's rows.", userInfo: nil).raise()
    }
    
    var matrixElements = [[T]]()
    
    for row in 0 ..< left.dimensions.rows {
        
        var rowElements = [T]()
        
        for column in 0 ..< right.dimensions.columns {
            
            var element:T = left[row, 0] * right[0][column]
            
            for i in 1 ..< left.dimensions.columns {
                
                element = element + left[row, i] * right[i, column]
            }
            
            rowElements.append(element)
        }
        
        matrixElements.append(rowElements)
    }
    
    return Matrix(matrixElements)
}


// MARK: Matrix Functional Methods

/**
    Returns a new matrix of the same dimensions where the elements are generated by calling the transform with the elements in this matrix.

    - parameter matrix: The matrix to map with the original elements.
    - parameter transform: The transform to map on the elements of matrix.
*/
public func mmap <T: MatrixCompatible, U: MatrixCompatible> (matrix: Matrix<T>, transform: T -> U) -> Matrix<U> {
    
    let elementsList = matrix.elementsList.map(transform)
    
    return Matrix(elementsList: elementsList, dimensions: matrix.dimensions)
}

/**
    Returns a single value generated by systematically reducing the matrix using the combine closure. For the first element initial will be used. Then the last generated element will be used to combine with the next element in the matrix.
    The elements will be looped through row per row, column per column.

    - parameter matrix: The matrix to reduce.
    - parameter initial: The element to combine with the first element of the matrix.
    - parameter combine: The closure to combine two values to generate a new value.
*/
public func mreduce <T: MatrixCompatible, U> (matrix: Matrix<T>, initial: U, combine: (U, T) -> U) -> U {
    
    return matrix.elementsList.reduce(initial, combine: combine)
}

/**
    Returns a new matrix by combining the two given matrices using the combine closure. The two given matrices have to have the same dimensions, since the combination will happen element per element.

    - parameter left: The left matrix in the combination.
    - parameter right: The right matrix in the combination.
    - parameter combine: The closure to combine two elements from the two matrices.

    :exceptions: Throws an exception when the dimensions of the two given matrices are not equal.
*/
public func mcombine <T: MatrixCompatible, U: MatrixCompatible, V: MatrixCompatible> (left: Matrix<T>, _ right: Matrix<U>, combine: (T, U) -> V) -> Matrix<V> {

    if left.dimensions != right.dimensions {
        
        NSException(name: "Unequal dimensions", reason: "The dimensions of the two matrices are not equal.", userInfo: nil).raise()
    }
    
    var elementsList = [V]()
    
    for i in 0 ..< left.dimensions.product {
        elementsList.append(combine(left.elementsList[i], right.elementsList[i]))
    }
    
    return Matrix(elementsList: elementsList, dimensions: left.dimensions)
}



// MARK: High Perfomance Functions

/**
    Returns the transpose of the given matrix.

    - parameter matrix:  The matrix to transpose.

    - returns: The transpose of the given matrix.
*/
public func transpose(matrix: Matrix<Float>) -> Matrix<Float> {
    
    var elementsList = [Float](count: matrix.dimensions.product, repeatedValue: 0)
    
    vDSP_mtrans(matrix.elementsList, 1, &elementsList, 1, vDSP_Length(matrix.dimensions.columns), vDSP_Length(matrix.dimensions.rows))
    
    return Matrix(elementsList: elementsList, columns: matrix.dimensions.rows)
}


/**
    Returns the transpose of the given matrix.

    - parameter matrix:  The matrix to transpose.

    - returns: The transpose of the given matrix.
*/
public func transpose(matrix: Matrix<Double>) -> Matrix<Double> {
    
    var elementsList = [Double](count: matrix.dimensions.product, repeatedValue: 0)
    
    vDSP_mtransD(matrix.elementsList, 1, &elementsList, 1, vDSP_Length(matrix.dimensions.columns), vDSP_Length(matrix.dimensions.rows))
    
    return Matrix(elementsList: elementsList, columns: matrix.dimensions.rows)
}



// MARK: - Objective-C Bridged methods

// MARK: Decompositions / Factorisations

/**
    Returns the LU decomposition of the given matrix.

    - parameter matrix:  The matrix to compute the LU decomposition of.

    - returns: (L, U, P) A tuple containing three matrices. The first matrix
                is a lower triangular matrix with ones on the main diagonal.
                The second matrix is an upper triangular matrix and the third
                matrix is a permutations matrix. Here is A = PLU.
*/
public func LUDecomposition(matrix: Matrix<Float>) -> (Matrix<Float>, Matrix<Float>, Matrix<Float>)? {
    
    var elementsList = transpose(matrix).elementsList
    var pivotArray = [Int32](count: matrix.dimensions.minimum, repeatedValue: 0)
    var info: Int32 = 0
    
    Matrix_OBJC.LUDecompositionOfMatrix(&elementsList, nrOfRows: Int32(matrix.dimensions.rows), nrOfColumns: Int32(matrix.dimensions.columns), withPivotArray: &pivotArray, withInfo: &info)
    
    if info != 0 { return nil }
    
    let result = Matrix(elementsList: elementsList, columns: matrix.dimensions.rows).transpose
    
    //FIXME: L and U are always of the dimensions of result, which is not correct.
    
    let L = result.lowerTriangle
    L.fillDiagonal(1)
    
    let permutation = Permutation(identityOfLength: matrix.dimensions.columns)
    
    for (index, element) in pivotArray.enumerate() {
        permutation.switchElements(index, Int(element-1))
    }
    
    return (L, result.upperTriangle, PermutationMatrix(permutation: permutation))
}



// MARK: - Additional Structs

// MARK: - MatrixGenerator

/**
    A struct representing a generator for iterating over a matrix.
*/
public struct MatrixGenerator <T: MatrixCompatible> : GeneratorType {
    
    /**
        The generator of the elements list of the matrix.
    */
    private var generator: IndexingGenerator<Array<T>>
    
    /**
        Creates a new matrix generator to iterator over the given matrix.
    
        - parameter The: matrix to iterate over.
    */
    public init(matrix: Matrix<T>) {
        
        self.generator = matrix.elementsList.generate()
    }
    
    /**
        Returns the next element in the matrix or nil if there are no elements left.
    */
    public mutating func next() -> T? {
        return self.generator.next()
    }
}


// MARK: - Index

public struct Index: ArrayLiteralConvertible {
    
    public let row, column: Int
    
    public init(arrayLiteral elements: Int...) {
        
        if elements.count < 2 {
            
            NSException(name: "Not enough elements provided", reason: "Only \(elements.count) elements provided, but 2 elements needed for Index initialisation.", userInfo: nil).raise()
        }
        
        if elements.count > 2 {
            
            NSException(name: "Too many elements provided", reason: "\(elements.count) elements provided, but only 2 elements needed for Index initialisation.", userInfo: nil).raise()
        }
        
        self.row = elements[0]
        self.column = elements[1]
    }
}




// MARK: - Errors

/**
    A struct containing the different types of Matrix errors.
*/
public enum MatrixError: ErrorType {
    
    /**
    Caused by an index being out of bounds.
    
    - parameter received:       The index passed by the user.
    - parameter allowedRange:   The allowed range of indices. The error is thrown when the index
                                does not lie in this range.
    - parameter description:    A description describing what exactly went wrong.
    */
    case IndexOutOfBounds(received: Int, allowedRange: Range<Int>, description: String?)
    
    /**
    Caused by providing a wrong number of elements.
    
    - parameter received:       The number passed by the user.
    - parameter expected:       The expected number.
    - parameter description:    A description describing what exactly went wrong.
    */
    case WrongNumberOfElements(received: Int, expected: Int, description: String?)
}
