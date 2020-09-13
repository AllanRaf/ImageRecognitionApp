//
//  ViewController.swift
//  MachineLearningImageRecognition
//
//  Created by Allan Man on 13/09/2020.
//  Copyright © 2020 Allan Man. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var chosenImage = CIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.borderColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 0.1).cgColor
        imageView.layer.borderWidth = 2
        
    }
    
    @IBAction func changeClicked(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!) {
            
            chosenImage = ciImage
            
            
        }
        
        recognizeImage(image: chosenImage)
        
    }
    
    func recognizeImage(image: CIImage) {
        // 1) Create Request
        // 2) Handler
        
        resultLabel.text = "...processing"
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
                
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    
                    if results.count > 0 {
                        
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            //
                            if (topResult != nil) {
                                
                                let confidenceLevel = Int((topResult?.confidence ?? 0) * 100)
                                self.resultLabel.text = "\(confidenceLevel)% is \(topResult!.identifier)"
                            }
                            
                            
                        }
                        
                    }
                    
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    
                    print("error with handler")
                }
            }
            
        }
        
        
        
        
        
    }
    
}

