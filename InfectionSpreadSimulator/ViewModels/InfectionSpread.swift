//
//  Simulation.swift
//  InfectionSpreadSimulator
//
//  Created by Kirill Baranov on 26/03/24.
//

import Foundation
import Observation

@Observable
class InfectionSpread {
	
	//MARK: - properties
	
	var people: [Person]
	var infectedPeopleActive = Set<Person>()
	var infectedPeople = [Person]()
	
	let infectionFactor: Int // >= infect count
	let infectionFrequency: Int // timer
	
	
	
	var spreadTimeInterval: TimeInterval {
		TimeInterval(infectionFrequency)
	}
	
	var timer: Timer?
	
	//MARK: - Init
	
	init(peopleNumber: Int, infectionFactor: Int, infectionFrequency: Int) {
		self.people = Self.createPeople(for: peopleNumber, infectionFactor: infectionFactor)
		self.infectionFactor = infectionFactor
		self.infectionFrequency = infectionFrequency
		
		self.people.forEach({
			findNeighbors(for: $0)
		})
	}
	
	func setUpTimer() {
		self.timer = Timer.scheduledTimer(withTimeInterval: spreadTimeInterval, repeats: true) { _ in
			if self.infectedPeopleActive.isEmpty {
				self.timer?.invalidate()
				print("stop timer")
			} else {
				self.spreadInfectionWithIntervalAsync()
			}
		}
	}
	
	//MARK: - main logic
	
	func infect(_ person: Person) {
		
		self.people[person.index].isSick = true
		self.infectedPeopleActive.insert(people[person.index])
		self.infectedPeople.append(people[person.index])
		print("infected \(self.people[person.index])\n")
		
	}
	
	func findNeighbors(for person: Person) {
		let neighborIndices = people.filter { neighbor in
			neighbor != person &&
			neighbor.position.row >= person.position.row - 1 &&
			neighbor.position.row <= person.position.row + 1 &&
			neighbor.position.col >= person.position.col - 1 &&
			neighbor.position.col <= person.position.col + 1
		}
			.map( { $0.index } )
		people[person.index].neighborIndices = neighborIndices
	}
	
	
	func infectRandomNeighbors(for infectedPerson: Person) {
		
		let maxInfectionsPerWave = min(people[infectedPerson.index].neighborIndices.count, people[infectedPerson.index].infectedReminder)
		
		guard maxInfectionsPerWave > 0 else { return }
		let infectionsPerWave = Int.random(in: 1...maxInfectionsPerWave)
		
		for _ in 1...infectionsPerWave {
			if let randomNeighborIndex = people[infectedPerson.index].neighborIndices.randomElement() {
				print("\(people[infectedPerson.index]) infects:")
				infect(people[randomNeighborIndex])
				people[infectedPerson.index].neighborIndices.removeAll(where: { $0 == randomNeighborIndex })
				people[infectedPerson.index].infectedReminder -= 1
			}
		}
	}
	
	func spreadInfectionWithIntervalAsync() {
		DispatchQueue.global().sync {
			self.infectedPeopleActive.forEach { infectedPerson in
				
				if self.people[infectedPerson.index].infectedReminder > 0 {
					self.infectRandomNeighbors(for: infectedPerson)
					
				} else {
					self.infectedPeopleActive.remove(infectedPerson)
					print("\(infectedPerson) dont have infection potencial \(infectedPerson.infectedReminder)\n")

				}
				
			}
		}
	}
}

//MARK: - static methods

extension InfectionSpread {
	
	static func getGridLimits(for peopleCount: Int) -> (rows: Int, cols: Int) {
		let peopleCountDouble = Double(peopleCount)
		let root = (sqrt(Double(peopleCount)))
		var rows: Int
		var cols: Int
		
		if abs(peopleCountDouble.remainder(dividingBy: root)) > 0 {
			rows = Int(peopleCountDouble / root + 1)
		} else {
			rows = Int(peopleCountDouble / root)
		}
		
		if peopleCount % rows > 0 {
			cols = peopleCount / rows + 1
		} else {
			cols = peopleCount / rows
		}
		return (rows, cols)
	}
	
	static func createPeople(for peopleCount: Int, infectionFactor: Int) -> [Person] {
		var people = [Person]()
		let (_, cols) = getGridLimits(for: peopleCount)
		for index in 0..<peopleCount {
			people.append(Person(index: index,
								 infectedReminder: infectionFactor, 
								 position: PersonPosition(
									row: index / cols, 
									col: index % cols)))
		}
		return people
	}
	
	
}
