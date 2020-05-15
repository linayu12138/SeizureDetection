//
//  ViewController.swift
//  HandWritingRecognition
//
//  Created by Wei Chieh Tseng on 05/12/2017.
//

import UIKit
import Vision

class DetectSeizureViewController: UIViewController {

    
    var request = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAutoLayout()
        
        setupCoreMLRequest()
    }
    
    private func setupCoreMLRequest() {
        // load model
        let ml_model = detectSeizure().model
        
        guard let model = try? VNCoreMLModel(for: ml_model) else {
            fatalError("Cannot load Core ML Model")
        }
        
        // set up request
        let detect_request = VNCoreMLRequest(model: model, completionHandler: handleSeizureDetection)
        self.request = [detect_request]
    }
    
    // handle request
    func handleSeizureDetection(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            debugPrint("No results")
            return
        }
        
        let classification = observations
            .compactMap({ $0 as? VNClassificationObservation  })
            .filter({$0.confidence > 0.5})                      // filter confidence > 80%
            .map({$0.identifier})                               // map the identifier as answer
        
        print(classification)
        
    }
    
    private func setupAutoLayout() {
        
    }

    @IBAction func recognize(_ sender: UIButton) {
        // The model takes input with 28 by 28 pixels, check the uiimage extension for
        // - Get snapshot of an view (Canvas)
        // - Resize image
//
//        let image = UIImage(view: canvasView).scale(toSize: CGSize(width: 28, height: 28))
//
//        let imageRequest = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
//        do {
//            try imageRequest.perform(request)
//        }
//        catch {
//            print(error)
//        }
    }
    
    
}

