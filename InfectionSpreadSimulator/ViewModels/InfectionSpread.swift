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
	
	var people: [Person]
	var infectedPeople: [Person] = []
		
	let infectionFactor: Int // >= infect count
	let infectionFrequency: Int // timer
	
	
	
	var spreadTimeInterval: TimeInterval {
		TimeInterval(infectionFrequency)
	}
	
	var timer: Timer?
	
	init(peopleNumber: Int, infectionFactor: Int, infectionFrequency: Int) {
		self.people = Self.createPeople(for: peopleNumber)
		self.infectionFactor = infectionFactor
		self.infectionFrequency = infectionFrequency

	}
	
	func setUpTimer() {
		self.timer = Timer.scheduledTimer(withTimeInterval: spreadTimeInterval, repeats: true) { _ in
			if self.people.filter({ !$0.isSick }).isEmpty {
				self.timer?.invalidate()
				print("stop timer")
			} else {
				self.spreadInfectionWithIntervalAsync()
			}
		}
		
	}
	
	func infect(_ person: Person) {
		if let index = people.firstIndex(of: person) {
				self.people[index].isSick = true
			
			print("\ninfected \(people[index])")
		}
	}
	
	func findUninfectedNeighbors(for infectedPerson: Person) {
		print("\nfindUninfectedNeighbors for \(infectedPerson)")
		
		let uninfectedNeighbors = people.filter { person in
			!person.isSick &&
			person.position.row >= infectedPerson.position.row - 1 &&
			person.position.row <= infectedPerson.position.row + 1 &&
			person.position.col >= infectedPerson.position.col - 1 &&
			person.position.col <= infectedPerson.position.col + 1
		}
		print("find \(uninfectedNeighbors.count) neighbors: ")

		if let index = people.firstIndex(of: infectedPerson) {
			people[index].uninfectedNeighbors = uninfectedNeighbors
			people[index].uninfectedNeighbors.forEach {
				print("\($0)")
			}
		}
	}
	
	func infectRandomNeighbors(for infectedPerson: Person) {
		print("\ninfectRandomNeighbors for \(infectedPerson)")

		guard let infectedPersonIndex = people.firstIndex(of: infectedPerson) else {
			print("wrong infectedPersonIndex")
			return
		}
		print("find infectedPersonIndex: \(infectedPersonIndex)")
		
		guard people[infectedPersonIndex].infectedCounter < infectionFactor else {
			print("infectedPerson.infectedCounter >= infectionFactor")
			return
		}
		
		print("infectionFactor: \(infectionFactor) or uninfectedNeighbors.count: \(people[infectedPersonIndex].uninfectedNeighbors.count) - infectedCounter: \(people[infectedPersonIndex].infectedCounter)")
		
		let maxInfectionsPerWave = min(infectionFactor, people[infectedPersonIndex].uninfectedNeighbors.count) - people[infectedPersonIndex].infectedCounter
		
		print("maxInfectionsPerWave: \(maxInfectionsPerWave)")
		guard maxInfectionsPerWave > 0 else { return }
		let infectionsPerWave = Int.random(in: 0...maxInfectionsPerWave)
		print("infectionsPerWave: \(infectionsPerWave)")
		
		for _ in 0..<infectionsPerWave {
			if let randomNeighbor = people[infectedPersonIndex].uninfectedNeighbors.filter({!$0.isSick}).randomElement() { 	//TODO: check double random element
				infect(randomNeighbor)
				people[infectedPersonIndex].infectedCounter += 1
			}
		}
	}
	
	func checkInfectedCounter(for infectedPerson: Person) -> Bool {
		if let infectedPersonIndex = people.firstIndex(of: infectedPerson) {
			return people[infectedPersonIndex].infectedCounter < infectionFactor
		}
		return false
	}
	
	func spreadInfectionWithIntervalAsync() {
		DispatchQueue.global().async {
			
			self.people.filter({ $0.isSick }).forEach({ infectedPerson in
				
				print("\nspreadInfectionWithIntervalAsync start for \(infectedPerson)")
				if self.checkInfectedCounter(for: infectedPerson) {
					print("\nspreadInfectionWithIntervalAsync performs for \(infectedPerson)")
					
					self.findUninfectedNeighbors(for: infectedPerson)
					self.infectRandomNeighbors(for: infectedPerson)
					
				}
				
			})
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
	
	static func createPeople(for peopleCount: Int) -> [Person] {
		var people = [Person]()
		let (_, cols) = getGridLimits(for: peopleCount)
		for index in 0..<peopleCount {
			people.append(Person(index: index,position: (
				index / cols,
				index % cols
			)))
		}
		return people
	}
}
