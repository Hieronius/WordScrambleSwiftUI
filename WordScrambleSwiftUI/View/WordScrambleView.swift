import SwiftUI

struct WordScrambleView: View {

	// MARK: - Private Properties

	@StateObject private var viewModel = WordScrambleViewModel()

	// MARK: - Body

	var body: some View {

		NavigationStack {
			List {
				Section {
					TextField("Enter your word", text: $viewModel.newWord)
						.onSubmit { viewModel.addNewWord() }
						.textInputAutocapitalization(.never)
				}

				Section("Used words") {
					ForEach(viewModel.usedWords, id: \.self) { word in
						HStack {
							Image(systemName: "\(word.count).circle")
							Text(word)
						}
					}
				}

				Section("Score") {
					Text("\(viewModel.score)")
				}
			}
			.navigationTitle(viewModel.rootWord)
			.onAppear(perform: { viewModel.startGame() })
			.toolbar() {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Start New Game") {
						viewModel.startGame()
					}
				}
			}
		}
		.alert(viewModel.errorTitle, isPresented: $viewModel.showingError) {
			Button("OK") { }
		} message: {
			Text(viewModel.errorMessage)
		}
	}
}

#Preview {
	WordScrambleView()
}
