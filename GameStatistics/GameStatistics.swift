//
//  GameStatistics.swift
//  WordCraft1

import UIKit

struct GameStatistics1: Codable {
    var highestScoreWord: String?
    var totalPoints: Int
    var playedWords: [String]
    
    public init(highestScoreWord: String? = nil, totalPoints: Int = 0, playedWords: [String] = []) {
        self.highestScoreWord = highestScoreWord
        self.totalPoints = totalPoints
        self.playedWords = playedWords
    }
}
