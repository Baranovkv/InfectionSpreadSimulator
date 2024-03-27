//
//  Person.swift
//  InfectionSpreadSimulator
//
//  Created by Kirill Baranov on 27/03/24.
//

import Foundation

struct Person: Identifiable, CustomDebugStringConvertible, Equatable, Hashable {
	
	var id = UUID()
	var index: Int
	var isSick = false
	var neighbors: [Person] = []
	var neighborIndices: [Int] = []
	var infectedReminder: Int
	var position: PersonPosition
	
	var debugDescription: String {
		"PERSON index: \(index), position: \(position)"
	}
	
	static func == (lhs: Person, rhs: Person) -> Bool {
		lhs.id == rhs.id
	}
}

struct PersonPosition: Hashable {
	var row: Int
	var col: Int
}
