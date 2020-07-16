//
//  InputViewController.swift
//  PDFGenerate
//
//  Created by Hanson on 2020/7/16.
//  Copyright © 2020 Hanson. All rights reserved.
//

import UIKit

class InputViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var headlineTextField: UITextField!
    @IBOutlet weak var bodyTextField: UITextView!
    @IBOutlet weak var addImageStackView: UIStackView!
    
    private var selectedImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addImageStackView.translatesAutoresizingMaskIntoConstraints = false
    }

    @IBAction func addImage(_ sender: Any) {
        let actionSheet = UIAlertController(title: "选取图片", message: "", preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "图库", style: .default) { (action) in
            guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else { return }
            let photoPicker = UIImagePickerController()
            photoPicker.delegate = self
            photoPicker.sourceType = .photoLibrary
            photoPicker.allowsEditing = false
            self.present(photoPicker, animated: true, completion: nil)
        }
        actionSheet.addAction(photoAction)
        
        let cameraAction = UIAlertAction(title: "拍摄", style: .default) { (action) in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            let cameraPicker = UIImagePickerController()
            cameraPicker.delegate = self
            cameraPicker.sourceType = .camera
            self.present(cameraPicker, animated: true, completion: nil)
        }
        actionSheet.addAction(cameraAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func generatePDF(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PDFPreviewViewController") as? PDFPreviewViewController {
            let render = PDFGraphicsRenderer()
            render.headlineText = headlineTextField.text ?? "标题"
            render.bodyText = bodyTextField.text
            render.images = selectedImages
            vc.pdfDocumentData = render.generatePDFData()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension InputViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        selectedImages.append(selectedImage)
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = selectedImage
        let height = imageView.heightAnchor.constraint(equalToConstant: 200)
        NSLayoutConstraint.activate([height])
        addImageStackView.addArrangedSubview(imageView)
        dismiss(animated: true, completion: nil)
    }
}
