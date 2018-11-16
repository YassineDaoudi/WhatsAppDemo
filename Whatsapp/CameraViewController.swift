//
//  CameraViewController.swift
//  WhatsApp
//
//  Created by Findl MAC on 02/11/2018.
//

import UIKit

class CameraViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        imagePickerController.sourceType = UIImagePickerController.SourceType.camera
        
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    

 

}
