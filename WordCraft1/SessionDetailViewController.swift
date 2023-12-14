import UIKit

class SessionDetailViewController: UIViewController {
    
    @IBOutlet weak var highestScoreWordLabel: UILabel!
    @IBOutlet weak var totalPointsLabel: UILabel!
    @IBOutlet weak var playedWordsTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameStatistics()
    }
    
    private func loadGameStatistics() {
        if let statistics = StatisticsManager.shared.loadStatistics(forSession: "currentGame") {
            displayGameStatistics(statistics)
        } else {
            print("Game statistics are not available.")
        }
    }
    
    private func displayGameStatistics(_ statistics: GameStatistics1) {

        totalPointsLabel.text = "Total Points: \(statistics.totalPoints)"
        playedWordsTextView.text = "Played Words: \(statistics.playedWords.joined(separator: ", "))"
    }
}
