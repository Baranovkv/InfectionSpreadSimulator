//
//  ContentView.swift
//  InfectionSpreadSimulator
//
//  Created by Kirill Baranov on 26/03/24.
//

import SwiftUI

struct ParametersView: View {
	
	@State var groupSize: Int? = 103
	@State var infectionFactor: Int? = 2
	@State var infectionFrequency: Int? = 1
	@State var showSimulation = false
	
	var body: some View {
		VStack {
			Form {
				Section(header: Text("Количество людей:")) {
					TextField("Размер группы", value: $groupSize, format: .number)
				}
				Section(header: Text("Заразность болезни:")) {
					
					TextField("Заразность болезни", value: $infectionFactor, format: .number)
				}
				Section(header: Text("Частота заболевания:")) {
					
					TextField("Частота заболевания", value: $infectionFrequency, format: .number)
				}
			}
			Spacer()
			Button("Start") {
				showSimulation = true
			}
			.buttonStyle(.borderedProminent)
			.padding(32)
		}
		.padding()
		.fullScreenCover(isPresented: $showSimulation) {
			if let groupSize, let infectionFactor, let infectionFrequency {
				SimulationView(peopleCount: groupSize, infectionFactor: infectionFactor, infectionFrequency: infectionFrequency)
			}
		}
	}
}

#Preview {
	ParametersView()
}
