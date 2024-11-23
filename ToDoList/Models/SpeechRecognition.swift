import Foundation
import Speech
import AVFoundation

protocol SpeechRecognitionDelegate: AnyObject {
    func didRecognizeSpeech(text: String)
    func didFailWithError(error: Error)
}

final class SpeechRecognition {
    // MARK: - Delegate
    weak var delegate: SpeechRecognitionDelegate?

    // MARK: - Private Properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    // MARK: - Public Methods
    func startRecognition() {
        if audioEngine.isRunning {
            stopRecognition()
            return
        }

        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self.startRecording()
                case .denied, .restricted, .notDetermined:
                    self.delegate?.didFailWithError(error: NSError(domain: "SpeechManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition is not available."]))
                @unknown default:
                    break
                }
            }
        }
    }

    func stopRecognition() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil
    }

    private func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            delegate?.didFailWithError(error: error)
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            delegate?.didFailWithError(error: NSError(domain: "SpeechManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request."]))
            return
        }

        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                let spokenText = result.bestTranscription.formattedString
                self.delegate?.didRecognizeSpeech(text: spokenText)
            }

            if let error = error {
                self.delegate?.didFailWithError(error: error)
                self.stopRecognition()
            }

            if result?.isFinal == true {
                self.stopRecognition()
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            delegate?.didFailWithError(error: error)
        }
    }
}

