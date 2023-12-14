//
//  board.swift
//  WordCraft1
// Resources Used: Apple Swift Documentation, SwiftByExample, StackOverflow (For errors), Ray Wenderlich (Kokedo), YouTube - @LetsBuildThatApp

import UIKit
import Foundation
import GameStatistics


class TileButton: UIButton {
    var originalPosition: CGPoint?
    var homeIndex: Int?
    var sessionName: String?
    var currentLetter: String? {
        return self.title(for: .normal)
    }
    var gameStatistics: GameStatistics1?
}

class BoardViewController: UIViewController {
    @IBOutlet var tileButtons: [TileButton]!
    @IBOutlet var boardSpaces: [UIView]!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet var submissionTileButtons: [UIView]!
    
    var letterPopupLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTiles()
        setupLetterPopup()
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)

        if let sessionName = sessionName {
            if let statistics = StatisticsManager.shared.loadStatistics(forSession: sessionName) {
                gameStatistics = statistics
            } else {
                gameStatistics = GameStatistics1(highestScoreWord: nil, totalPoints: 0, playedWords: [])
                print("No game statistics found for Session: \(sessionName)")
            }
        }
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for tile in tileButtons {
            if let index = tile.homeIndex, index >= 0 && index < boardSpaces.count {
                tile.originalPosition = boardSpaces[index].center
            }
        }
    }
    
    let letterScores: [Character: Int] = [
        "A": 1, "B": 3, "C": 3, "D": 2, "E": 1,
        "F": 4, "G": 2, "H": 4, "I": 1, "J": 8,
        "K": 5, "L": 1, "M": 3, "N": 1, "O": 1,
        "P": 3, "Q": 10, "R": 1, "S": 1, "T": 1,
        "U": 1, "V": 4, "W": 4, "X": 8, "Y": 4,
        "Z": 10
    ]

    private func setupTiles() {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        for (index, tile) in tileButtons.enumerated() {
            let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            tile.addGestureRecognizer(panRecognizer)
            tile.homeIndex = index
            
            let randomIndex = letters.index(letters.startIndex, offsetBy: Int(arc4random_uniform(UInt32(letters.count))))
            
            let randomLetter = String(letters[randomIndex])
            tile.setTitle(randomLetter, for: .normal)
        }
    }

    private func setupLetterPopup() {
        letterPopupLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        letterPopupLabel.backgroundColor = .white
        letterPopupLabel.textAlignment = .center
        letterPopupLabel.isHidden = true
        view.addSubview(letterPopupLabel)
    }
    
    private func showLetterPopup(for tile: TileButton) {
        if let letter = tile.titleLabel?.text {
            letterPopupLabel.text = letter
            letterPopupLabel.center = CGPoint(x: tile.center.x, y: tile.center.y - 30)
            letterPopupLabel.isHidden = false
        }
    }

    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let tile = recognizer.view as? TileButton else { return }
        
        switch recognizer.state {
        case .began:
            showLetterPopup(for: tile)
            fallthrough
        case .changed:
            moveTileWithGesture(recognizer, tile: tile)
        case .ended, .cancelled:
            hideLetterPopup()
            dropTile(tile)
        default:
            break
        }
    }

    private func moveTileWithGesture(_ recognizer: UIPanGestureRecognizer, tile: TileButton) {
        let translation = recognizer.translation(in: self.view)
        tile.center.x += translation.x
        tile.center.y += translation.y
        recognizer.setTranslation(.zero, in: self.view)
        letterPopupLabel.center = CGPoint(x: tile.center.x, y: tile.center.y - 30)
    }
    
    func reportGameResults(validWords: [String], totalScore: Int) {
        print("Game Results:")
        validWords.forEach { word in
            print("Word: \(word) - Score: \(calculateScore(for: word))")
        }
        print("Final Score: \(totalScore)")
    }
    
    var totalGameScore: Int = 0
    var gameStatistics: GameStatistics1?
    
    @objc func submitButtonTapped() {
        let wordsCreated = collectWords()
        var validWords: [String] = []
        var invalidWords: [String] = []
        let group = DispatchGroup()
        
        for word in wordsCreated {
            group.enter()
            checkWord(word: word) { isValid in
                DispatchQueue.main.async {
                    if isValid {
                        validWords.append(word)
                        print("Word '\(word)' is valid.")
                    } else {
                        invalidWords.append(word)
                        print("Word '\(word)' is invalid.")
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.showWordsPopup(validWords: validWords, invalidWords: invalidWords)
            self.totalGameScore = validWords.reduce(0) { $0 + self.calculateScore(for: $1) }
            print("Total Score: \(self.totalGameScore)")
            self.updateAndSaveGameStatistics(with: validWords)
        }
        
        if let sessionName = self.sessionName {
            StatisticsManager.shared.saveStatistics(gameStatistics!, forSession: sessionName)
            print("Game statistics updated and saved for session \(sessionName).") 
        }
    }
    
    func updateAndSaveGameStatistics(with validWords: [String]) {
        let currentGameStatistics = GameStatistics1(totalPoints: totalGameScore, playedWords: validWords)

        StatisticsManager.shared.saveStatistics(currentGameStatistics, forSession: "currentGame")

        print("Game statistics saved: \(currentGameStatistics)")
    }


    var sessionName: String?

    private func showWordsPopup(validWords: [String], invalidWords: [String]) {
        let allWordsValid = invalidWords.isEmpty
        var message = allWordsValid ? "All words are valid!\n" : "Some invalid words were found.\n"

        var totalScore = 0
        for word in validWords {
            let score = calculateScore(for: word)
            totalScore += score
            message += "\(word) - \(score) points\n"
        }
        
        message += "\nTotal Score: \(totalScore)"
        
        let alertController = UIAlertController(title: "Word Check Results", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel) { _ in
        }
        alertController.addAction(okAction)
    
        if allWordsValid {
            let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
                self.submitWords(validWords)
            }
            alertController.addAction(submitAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }


    func calculateScore(for word: String) -> Int {
        return word.uppercased().reduce(0) { total, letter in
            total + (letterScores[letter] ?? 0)
        }
    }

    private func submitWords(_ words: [String]) {
        let totalScore = words.reduce(0) { $0 + calculateScore(for: $1) }
    
        let message = "You scored \(totalScore) points!"
        let alertController = UIAlertController(title: "Total Points", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }

    

    private func collectWords() -> [String] {
        var wordMap = [Int: String]()
        let gridSize = 3
        for (index, space) in submissionTileButtons.enumerated() {
            let spaceFrame = view.convert(space.frame, from: space.superview)
            
            for tile in tileButtons {
                let tileCenter = view.convert(tile.center, from: tile.superview)
                
                if spaceFrame.contains(tileCenter) {
                    wordMap[index] = tile.currentLetter ?? ""
                    break                }
            }
        }
        
        var words = [String]()
        for row in 0..<gridSize {
            var word = ""
            for col in 0..<gridSize {
                if let letter = wordMap[row * gridSize + col] {
                    word += letter
                } else {
                    if !word.isEmpty {
                        words.append(word)
                        word = ""
                    }
                }
            }
            if word.count == 3 {
                words.append(word)
            }
        }
        for col in 0..<gridSize {
            var word = ""
            for row in 0..<gridSize {
                if let letter = wordMap[row * gridSize + col] {
                    word += letter
                } else {
                    if !word.isEmpty {
                        words.append(word)
                        word = ""
                    }
                }
            }
            if word.count == 3 {
                words.append(word)
            }
        }

        words = words.filter { $0.count == 3 }
        return words
    }

    
    
    func checkWord(word: String, completion: @escaping (Bool) -> Void) {
        let urlString = "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false)
                return
            }
            
            completion(httpResponse.statusCode == 200)
        }
        task.resume()
    }

    

    private func showWordsPopup(words: [String]) {
        let message = words.isEmpty ? "No words created" : words.joined(separator: ", ")
        let alertController = UIAlertController(title: "Words Created", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    
    private func hideLetterPopup() {
        letterPopupLabel.isHidden = true
    }

    private func dropTile(_ tile: TileButton) {
        let tileCenterInView = self.view.convert(tile.center, from: tile.superview)
        
        let closestBoardSpace = boardSpaces.min {
            self.view.convert($0.center, from: $0.superview).distance(to: tileCenterInView) <
            self.view.convert($1.center, from: $1.superview).distance(to: tileCenterInView)
        }

        if let closestBoardSpace = closestBoardSpace, let newIndex = boardSpaces.firstIndex(of: closestBoardSpace) {
            if tile.homeIndex != newIndex {
                tile.homeIndex = newIndex
            }
            
            UIView.animate(withDuration: 0.3) {
                tile.center = closestBoardSpace.center
            }
        } else {
            returnTileToOriginalPosition(tile)
        }
    }

    private func returnTileToOriginalPosition(_ tile: TileButton) {
        if let originalPosition = tile.originalPosition {
            UIView.animate(withDuration: 0.3) {
                tile.center = originalPosition
            }
        }
    }

}

private extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(x - point.x, y - point.y)
    }
}
