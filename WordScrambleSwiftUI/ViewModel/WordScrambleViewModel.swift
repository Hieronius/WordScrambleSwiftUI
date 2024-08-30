import SwiftUI

final class WordScrambleViewModel: ObservableObject {

	// MARK: - Published Properties

	@Published var people = ["Finn", "Leia", "Luke", "Rey"]

	@Published var usedWords = [String]()
	@Published var rootWord = ""
	@Published var newWord = ""

	@Published var score = 0

	@Published var errorTitle = ""
	@Published var errorMessage = ""
	@Published var showingError = false

	// MARK: - Public Methods

	/// Check resources for txt file or crush the app
	func startGame() {
		if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
			if let startWords = try? String(contentsOf: startWordsURL) {
				let allWords = startWords.components(separatedBy: "\n")
				rootWord = allWords.randomElement() ?? "silkdown"
				score = 0

				return
			}
			fatalError("Coult not load start.txt from the bundle")
		}
	}

	/// Check is a new word didn't been used before
	func isOriginal(word: String) -> Bool {
		!usedWords.contains(word)
	}

	/// Method to check if letters of User's word can be result of the given rootword.
	/// Example: "peal" is a word you can make from rootWord "apple"
	func isPossible(word: String) -> Bool {
		var tempWord = rootWord

		for letter in word {
			if let position = tempWord.firstIndex(of: letter) {
				tempWord.remove(at: position)
			} else {
				return false
			}
		}
		return true
	}

	/// Method to validate user's word of being real and possible to write
	func isReal(word: String) -> Bool {
		let checker = UITextChecker()
		let range = NSRange(location: 0, length: word.utf16.count)
		let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

		return misspelledRange.location == NSNotFound
	}

	/// Check is the word not copy of the root word and long enough to be counted as answer
	func isValid(word: String) -> Bool {
		word != rootWord && word.count > 2
	}

	/// Accordingly to the user's answer add some points to the score
	func evaluateAnswer(word: String) {
		switch word.count {
		case 3...7:
			score += 1
		case 8...11:
			score += 2
		default:
			score += 3
		}

		switch usedWords.count {
		case 0...5:
			score += 1
		case 6...10:
			score += 2
		default:
			score += 3
		}
	}

	/// Method to validate a new word and add it to the `usedWords` array
	func addNewWord() {
		let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

		// guard answer.count > 0 else { return }
		guard isValid(word: answer) else {
			wordError(title: "Word is too small or equal to the given word", message: "Come up with something different")
			score -= 1
			return
		}

		guard isOriginal(word: answer) else {
			wordError(title: "Word used already", message: "Be more original")
			score -= 1
			return
		}

		guard isPossible(word: answer) else {
			wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
			score -= 1
			return
		}

		guard isReal(word: answer) else {
			wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
			score -= 1
			return
		}

		evaluateAnswer(word: answer)

		usedWords.insert(answer, at: 0)
		newWord = ""
	}

	func wordError(title: String, message: String) {
		errorTitle = title
		errorMessage = message
		showingError = true
	}
}
