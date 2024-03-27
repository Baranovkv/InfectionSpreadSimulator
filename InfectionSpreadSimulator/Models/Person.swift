//
//  Person.swift
//  InfectionSpreadSimulator
//
//  Created by Kirill Baranov on 27/03/24.
//

import Foundation

struct Person: Identifiable, CustomDebugStringConvertible, Equatable {
	
	
	
	var id = UUID()
	var index: Int
	var isSick = false
	var uninfectedNeighbors: [Person] = []
	var infectedCounter = 0
	var position: (row: Int, col: Int)
	
	var debugDescription: String {
		"PERSON index: \(index), position: \(position)"
	}
	
	static func == (lhs: Person, rhs: Person) -> Bool {
		lhs.id == rhs.id
	}

}
