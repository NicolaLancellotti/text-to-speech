import Cocoa
import AVFoundation

class ViewController: NSViewController {
  @IBOutlet var textView: NSTextView!
  @IBOutlet weak var playButton: NSButton!
  @IBOutlet weak var stopButton: NSButton!
  @IBOutlet weak var rateSlider: NSSlider!
  @IBOutlet weak var voiceComboBox: NSComboBox!
  @IBOutlet weak var resetButton: NSButton!
  
  private var synthesizer: NSSpeechSynthesizer!
  
  private enum State {
    case play
    case pause
    case stop
  }
  
  private var state: State = .stop {
    didSet {
      updateUI()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    voiceComboBox.dataSource = self
    textView.font = NSFont.systemFont(ofSize: 18)
    reset()
  }
  
}

extension ViewController {
  
  private func updateUI() {
    switch state {
    case .play:
      playButton.title = "Pause"
      rateSlider.isEnabled = false
      voiceComboBox.isEnabled = false
      resetButton.isEnabled = false
    case .pause:
      playButton.title = "Play"
      rateSlider.isEnabled = false
      voiceComboBox.isEnabled = false
      resetButton.isEnabled = false
    case .stop:
      playButton.title = "Play"
      rateSlider.isEnabled = true
      voiceComboBox.isEnabled = true
      resetButton.isEnabled = true
    }
  }
  
  private func reset() {
    synthesizer = NSSpeechSynthesizer()
    synthesizer.delegate = self
    voiceComboBox.deselectItem(at: voiceComboBox.indexOfSelectedItem)
  }
  
}

extension ViewController {
  
  @IBAction func playAction(_ sender: NSButton) {
    switch state {
    case .play:
      state = .pause
      synthesizer.pauseSpeaking(at: .immediateBoundary)
    case .pause:
      state = .play
      synthesizer.continueSpeaking()
    case .stop:
      state = .play
      synthesizer.rate = rateSlider.floatValue
      let index = voiceComboBox.indexOfSelectedItem
      if index != -1 {
        synthesizer.setVoice(NSSpeechSynthesizer.availableVoices[index])
      }
      synthesizer.startSpeaking(textView.string)
    }
  }
  
  @IBAction func stopAction(_ sender: NSButton) {
    synthesizer.stopSpeaking()
    state = .stop
  }
  
  @IBAction func resetAction(_ sender: NSButton) {
    reset()
  }
  
}

extension ViewController: NSSpeechSynthesizerDelegate {
  
  func speechSynthesizer(_ sender: NSSpeechSynthesizer, willSpeakWord characterRange: NSRange, of string: String) {
    let attributedString = NSMutableAttributedString(string:string, attributes: [NSAttributedString.Key.foregroundColor : NSColor.textColor])
    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.systemRed , range: characterRange)
    textView.string = ""
    textView.textStorage?.append(attributedString)
    textView.font = NSFont.systemFont(ofSize: 18)
  }
  
}

extension ViewController: NSComboBoxDataSource {
  
  func numberOfItems(in comboBox: NSComboBox) -> Int {
    NSSpeechSynthesizer.availableVoices.count
  }
  
  func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
    NSSpeechSynthesizer.availableVoices[index]
  }
  
}
