//
//  PDFPreviewViewController.swift
//  PDFGenerate
//
//  Created by Hanson on 2020/7/16.
//  Copyright © 2020 Hanson. All rights reserved.
//

import UIKit
import PDFKit

class PDFPreviewViewController: UIViewController {

    @IBOutlet weak var pdfView: PDFView!
    
    var pdfDocumentData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let data = pdfDocumentData else { return }
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
    }
}
