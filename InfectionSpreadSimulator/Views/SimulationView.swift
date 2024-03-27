//
//  SimulationView.swift
//  InfectionSpreadSimulator
//
//  Created by Kirill Baranov on 26/03/24.
//

import SwiftUI

struct SimulationView: View {
	
	@State private var currentZoom = 0.0
	@State private var totalZoom = 1.0
	
	@State var infectionSpread: InfectionSpread
	let columns: [GridItem]
	
	var body: some View {
		ZStack {
			
			ScrollView([.horizontal, .vertical]) {
				LazyVGrid(columns: columns) {
					ForEach (infectionSpread.people) { person in
						Button {
							infectionSpread.infect(person)
							if infectionSpread.timer == nil {
								infectionSpread.setUpTimer()
							}
						} label: {
							Circle()
								.frame(width: 20, height: 20)
								.foregroundStyle(person.isSick ? .red : .green)
								.animation(.bouncy, value: person.isSick)
						}
						.buttonStyle(.plain)
						
					}
				}
			}
			.scaleEffect(currentZoom + totalZoom)

			.simultaneousGesture(MagnifyGesture()
					.onChanged { value in
						currentZoom = value.magnification - 1
					}
					.onEnded { value in
						totalZoom += currentZoom
						currentZoom = 0
					})
			
			VStack {
				VStack {
					Text("Размер группы: \(infectionSpread.people.count)")
					Text("Заразность болезни: \(infectionSpread.infectionFactor)")
					Text("Частота заболевания: \(infectionSpread.infectionFrequency)")
				}
				.padding()
				.background {
					RoundedRectangle(cornerRadius: 16)
						.foregroundStyle(.thinMaterial)
				}
				Spacer()
			}
		}
		
		
	}
	
	
	init(peopleCount: Int, infectionFactor: Int, infectionFrequency: Int) {
		let cols = InfectionSpread.getGridLimits(for: peopleCount).cols
		self.columns = [GridItem](repeating: GridItem(), count: cols)
		self._infectionSpread = State(initialValue: InfectionSpread(peopleNumber: peopleCount,
																	infectionFactor: infectionFactor,
																	infectionFrequency: infectionFrequency))
	}
}


//#Preview {
//    SimulationView(infectionSpread: InfectionSpread())
//}
