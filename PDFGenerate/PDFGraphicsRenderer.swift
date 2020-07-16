//
//  PDFGraphicsRenderer.swift
//  PDFGenerate
//
//  Created by Hanson on 2020/7/16.
//  Copyright © 2020 Hanson. All rights reserved.
//

import UIKit

/// UIGraphicsPDFRenderer + PDFKit 生成 PDF
class PDFGraphicsRenderer {
    
    static let A4Width: CGFloat = 595.2
    static let A4Height: CGFloat = 841.8
    
    let pageRect = CGRect(x: 0, y: 0, width: A4Width, height: A4Height)
    
    var headlineText: String = ""
    var bodyText: String = ""
    var images: [UIImage] = []
    
    func generatePDFData() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Hanson",
            kCGPDFContextAuthor: "Hanson",
            kCGPDFContextTitle: headlineText
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            var imageOffset = addHeadline(headlineText, topOffset: 40)
            for image in images {
                imageOffset = addImage(image, topOffset: imageOffset)
            }
            print("BodyText Top : \(imageOffset)")
            // TODO: - 两张图片后，无法显示 Body
            addBody(bodyText, topOffset: imageOffset)
        }
        
        return data
    }
}

extension PDFGraphicsRenderer {
    @discardableResult
    func addHeadline(_ headline: String, topOffset: CGFloat) -> CGFloat {
        let headlineFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        let headlineAttributes: [NSAttributedString.Key: Any] = [.font: headlineFont]
        let attributedheadline = NSAttributedString(string: headline, attributes: headlineAttributes)
        let headlineStringSize = attributedheadline.size()
        let headlineStringRect = CGRect(x: (pageRect.width - headlineStringSize.width) / 2.0, y: topOffset,
                                        width: headlineStringSize.width, height: headlineStringSize.height)
        attributedheadline.draw(in: headlineStringRect)
        return headlineStringRect.origin.y + headlineStringRect.size.height
    }

    @discardableResult
    func addBody(_ body: String, topOffset: CGFloat) -> CGFloat {
        let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        let textAttributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle, .font: textFont]
        let attributedText = NSAttributedString(string: body, attributes: textAttributes)
        // TODO: - Change Height
        let textRect = CGRect(x: 10, y: topOffset, width: pageRect.width - 20,
                              height: pageRect.height - topOffset - pageRect.height / 5.0)
        attributedText.draw(in: textRect)
        return textRect.origin.y + textRect.size.height
    }

    @discardableResult
    func addImage(_ image: UIImage, topOffset: CGFloat) -> CGFloat {
        let maxHeight = pageRect.height * 0.4
        let maxWidth = pageRect.width * 0.8
        let aspectWidth = maxWidth / image.size.width
        let aspectHeight = maxHeight / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        let scaledWidth = image.size.width * aspectRatio
        let scaledHeight = image.size.height * aspectRatio
        let imageX = (pageRect.width - scaledWidth) / 2.0
        let imageRect = CGRect(x: imageX, y: topOffset, width: scaledWidth, height: scaledHeight)
        image.draw(in: imageRect)
        return imageRect.origin.y + imageRect.size.height
    }
}
