//
//  HomepageViewModel.swift
//  ScanMeCalculator
//
//  Created by Zein Rezky Chandra on 27/03/23.
//

import CryptoSwift
import Combine
import UIKit
import Vision

class HomepageViewModel {
    // Public Properties
    var inputResultData = PassthroughSubject<[InputResult], Never>()
    var isSaveToDatabaseStorage = CurrentValueSubject<Bool, Never>(true)
    var imageResources = CurrentValueSubject<(UIImage, UIImagePickerController.SourceType)?, Never>(nil)
    
    var showAlertPublisher: AnyPublisher<(title: String, message: String, action: (() -> Void)?), Never> {
        showAlertSubject.eraseToAnyPublisher()
    }
    
    // Private Properties
    private let showAlertSubject = PassthroughSubject<(title: String, message: String, action: (() -> Void)?), Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init() {
        setupObserver()
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Public Func
    
    func viewDidLoad() {
        fetchCoreDataToDomain()
    }
    
    // MARK: - Private Function
    
    private func setupObserver() {
        imageResources.sink { [weak self] imageResources in
            guard let imageResources = imageResources else { return }
            self?.performCaptureArithmaticByImage(image: imageResources.0, sourceType: imageResources.1)
        }
        .store(in: &cancellables)
    }
    
    private func handleStoreData(input: String, result: Double) {
        if isSaveToDatabaseStorage.value {
            CoreDataManager.shared.saveInputResult(input: input, result: result)
            
            // Alert
            showAlertSubject.send((title: "Success",
                                   message: "Data Added",
                                   action: { [weak self] in
                self?.fetchCoreDataToDomain()
            }))
        } else {
            if saveToEncryptedFile(expression: input, result: result) {
                let location = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                showAlertSubject.send((title: "Success",
                                       message: "Successfully encrypted and wrote data to file \(location?.absoluteString ?? "")/encryptedFile.bin",
                                       action: nil))
            }
        }
    }
    
    private func fetchCoreDataToDomain() {
        let inputResultCoreData = CoreDataManager.shared.fetchInputResultData()
        let inputResult = inputResultCoreData.map({ InputResult(input: $0.inputCoreData ?? "", result: $0.resultCoreData) })
        
        inputResultData.send(inputResult)
    }
    
    // MARK: - Save to encrypted file Func
    
    private func saveToEncryptedFile(expression: String, result: Double) -> Bool {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Unable to access Documents directory")
        }
        
        let encryptedFilePath = "encryptedFile.bin"
        let encryptedFileURL = URL(string: documentsDirectory.appendingPathComponent(encryptedFilePath).absoluteString)!
        do {
            let encryptedData = (expression + " = " + "\(result)").AESCBCEncrypt(secretKey: "I4FE9peuUTpAXaIt",
                                                                                 ivKey: "1234567890123456",
                                                                                 padding: .pkcs7) ?? ""
            try encryptedData.data(using: .utf8)!.write(to: encryptedFileURL)
            print("Successfully encrypted and wrote data to file \(encryptedFilePath)")
            return true
        } catch {
            showAlertSubject.send((title: "Error",
                                   message: "Failed to create an encrypted file: \(error.localizedDescription)",
                                   action: nil))
            return false
        }
    }
    
    // MARK: - Recognition Text Func
    
    private func performCaptureArithmaticByImage(image: UIImage, sourceType: UIImagePickerController.SourceType) {
        lazy var textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.usesLanguageCorrection = false
        
        guard let ciImage = CIImage(image: image) else {
            return
        }
        
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, orientation: sourceType == .camera ? .right : CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!, options: [:])
        
        do {
            try imageRequestHandler.perform([textRecognitionRequest])
            guard let results = textRecognitionRequest.results else {
                return
            }
            
            let recognizedText = results.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            if let result = preProcessingResponse(text: recognizedText) {
                guard let input = result.0, let amount = result.1 else { return }
                handleStoreData(input: input, result: amount)
            } else {
                showAlertSubject.send((title: "Not found number/arithmetic to calculate",
                                       message: "\(recognizedText)",
                                       action: nil))
            }
        } catch {
            showAlertSubject.send((title: "Error", message: "\(error.localizedDescription)", action: nil))
        }
    }
    
    private func preProcessingResponse(text: String) -> (String?, Double?)? {
        let arithmeticRegex = try! NSRegularExpression(pattern: #"\b(-?\d+(\.\d+)?|\.\d+)\s*([-+*/])\s*(-?\d+(\.\d+)?|\.\d+)\b"#)
        guard let match = arithmeticRegex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else {
            return nil
        }
        
        // Extract the numbers and operator from the match
        let num1Range = Range(match.range(at: 1), in: text)!
        let num2Range = Range(match.range(at: 4), in: text)!
        let operatorRange = Range(match.range(at: 3), in: text)!
        let num1 = Double(text[num1Range])
        let num2 = Double(text[num2Range])
        let op = text[operatorRange]
        
        // Perform the arithmetic operation
        switch op {
        case "+":
            return ("\(num1 ?? 0) \(op) \(num2 ?? 0)", (num1! + num2!))
        case "-":
            return ("\(num1 ?? 0) \(op) \(num2 ?? 0)", (num1! - num2!))
        case "*":
            return ("\(num1 ?? 0) \(op) \(num2 ?? 0)", (num1! * num2!))
        case "/":
            return ("\(num1 ?? 0) \(op) \(num2 ?? 0)", (num1! / num2!))
        default:
            return nil
        }
    }
}
