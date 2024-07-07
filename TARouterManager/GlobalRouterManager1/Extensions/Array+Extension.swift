//
//  Array+Extension.swift
//  NavigationRouterDemo
//
//  Created by Taslim Ansari on 22/03/24.
//

import Foundation

extension Array where Element : Equatable {
    /// Get the first index of the subarray in the main array if it is present other wise return nil
    /// - Parameter subArray: sub array to be searched
    /// - Returns: First index of the sub array
    func firstIndexOfContiguous(_ subArray: [Element]) -> Int? {
        /// Check if the subarray is smaller
        if subArray.count > self.count {
            return nil
        }

        /// The index of the match could not exceed data.count-part.count
        let range = 0...self.count - subArray.count
        var firstIndex: Int?
        range.forEach { index in
            if [Element](self[index..<index+subArray.count]) == subArray {
                firstIndex = Int(index)
            }
        }
        return firstIndex
    }
    
    /// Get the last index of the subarray in the main array if it is present other wise return nil
    /// - Parameter subArray: sub array to be searched
    /// - Returns: Last index of the sub array
    func lastIndexOfContiguous(_ subArray: [Element]) -> Int? {
        // Check if the subarray is smaller
        if subArray.count > self.count {
            return nil
        }

        /// The index of the match could not exceed data.count-part.count
        let range = 0...self.count - subArray.count
        var lastIndex: Int?
        range.forEach { index in
            if [Element](self[index..<index+subArray.count]) == subArray {
                lastIndex = Int(index) + (subArray.count - 1)
            }
        }
        return lastIndex
    }
}
