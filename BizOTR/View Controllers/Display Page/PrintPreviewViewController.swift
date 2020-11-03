//
//  PrintPreviewViewController.swift
//  BizOTR
//
//  Created by Keanu Freitas on 11/2/20.
//  Copyright © 2020 AppKumu. All rights reserved.
//

import UIKit
import PDFKit
import Foundation

class PrintPreviewViewController: UIViewController {
    
    // PDF variables
    var pdfView: PDFView!
    var passedExpenses: [Expense]!
    var expenses = [Expense]()
    var expensesYear = "2020"
    var url: URL!
    var pdfData: Data!
    
    let defaults = UserDefaults.standard
    
    var numberformatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tabBarController?.tabBar.isHidden = true
        expenses = passedExpenses
        createUI()
        pdfData = createPDF()
        if let year = defaults.string(forKey: "systemYear") {
            expensesYear = year
        } else {
            expensesYear = ""
        }
    }
    
    func getTodayString() -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let date = Date()
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    func createUI() {
        pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func createPDF() -> Data {
        var tableDataItems = [PrintableData]()
        for itemIndex in 0..<expenses.count {
            tableDataItems.append(PrintableData(printName: expenses[itemIndex].vendorName, printDate: expenses[itemIndex].expenseDate, printAmount: getValue(amount: expenses[itemIndex].expenseAmount)))
        }
        let tableDataHeaderTitles =  ["VendorName", "Date", "Amount"]
        let pdfCreator = PDFCreator(tableDataItems: tableDataItems, tableDataHeaderTitles: tableDataHeaderTitles)
        
        let data = pdfCreator.create()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        
        return data
    }
    
    @IBAction func printBtnTapped(_ sender: Any) {
        //url = savePdf(data: pdfData, fileName: "BizOTR-\(getTodayString()).pdf")
        share(data: pdfData)
    }
    
    func share(data: Data) {
        let vc = UIActivityViewController(activityItems: ["\(expensesYear) Expenses", data], applicationActivities: nil)
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - PDF Setup
    
    class PDFCreator: NSObject {
        let defaultOffset: CGFloat = 20
        let tableDataHeaderTitles: [String]
        let tableDataItems: [PrintableData]
        
        init(tableDataItems: [PrintableData], tableDataHeaderTitles: [String]) {
            self.tableDataItems = tableDataItems
            self.tableDataHeaderTitles = tableDataHeaderTitles
        }
        
        func create() -> Data {
            // default page format
            let pageWidth = 8.5 * 72.0
            let pageHeight = 11 * 72.0
            let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: UIGraphicsPDFRendererFormat())
            
            let numberOfElementsPerPage = calculateNumberOfElementsPerPage(with: pageRect)
            let tableDataChunked: [[PrintableData]] = tableDataItems.chunkedElements(into: numberOfElementsPerPage)
            
            let data = renderer.pdfData { context in
                for tableDataChunk in tableDataChunked {
                    context.beginPage()
                    let cgContext = context.cgContext
                    drawTableHeaderRect(drawContext: cgContext, pageRect: pageRect)
                    drawTableHeaderTitles(titles: tableDataHeaderTitles, drawContext: cgContext, pageRect: pageRect)
                    drawTableContentInnerBordersAndText(drawContext: cgContext, pageRect: pageRect, tableDataItems: tableDataChunk)
                }
            }
            return data
        }
        
        func calculateNumberOfElementsPerPage(with pageRect: CGRect) -> Int {
            let rowHeight = (defaultOffset * 3)
            let number = Int((pageRect.height - rowHeight) / rowHeight)
            return number
        }
        
        
        // Move ths stuff later!
        func drawTableHeaderRect(drawContext: CGContext, pageRect: CGRect) {
            drawContext.saveGState()
            drawContext.setLineWidth(3.0)
            
            // Draw header's 1 top horizontal line
            drawContext.move(to: CGPoint(x: defaultOffset, y: defaultOffset))
            drawContext.addLine(to: CGPoint(x: pageRect.width - defaultOffset, y: defaultOffset))
            drawContext.strokePath()
            
            // Draw header's 1 bottom horizontal line
            drawContext.move(to: CGPoint(x: defaultOffset, y: defaultOffset * 3))
            drawContext.addLine(to: CGPoint(x: pageRect.width - defaultOffset, y: defaultOffset * 3))
            drawContext.strokePath()
            
            // Draw header's 3 vertical lines
            drawContext.setLineWidth(2.0)
            drawContext.saveGState()
            let tabWidth = (pageRect.width - defaultOffset * 2) / CGFloat(3)
            for verticalLineIndex in 0..<4 {
                let tabX = CGFloat(verticalLineIndex) * tabWidth
                drawContext.move(to: CGPoint(x: tabX + defaultOffset, y: defaultOffset))
                drawContext.addLine(to: CGPoint(x: tabX + defaultOffset, y: defaultOffset * 3))
                drawContext.strokePath()
            }
            
            drawContext.restoreGState()
        }
        
        func drawTableHeaderTitles(titles: [String], drawContext: CGContext, pageRect: CGRect) {
            // prepare title attributes
            let textFont = UIFont.systemFont(ofSize: 16.0, weight: .medium)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byWordWrapping
            let titleAttributes = [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: textFont
            ]
            
            // draw titles
            let tabWidth = (pageRect.width - defaultOffset * 2) / CGFloat(3)
            for titleIndex in 0..<titles.count {
                let attributedTitle = NSAttributedString(string: titles[titleIndex].capitalized, attributes: titleAttributes)
                let tabX = CGFloat(titleIndex) * tabWidth
                let textRect = CGRect(x: tabX + defaultOffset,
                                      y: defaultOffset * 3 / 2,
                                      width: tabWidth,
                                      height: defaultOffset * 2)
                attributedTitle.draw(in: textRect)
            }
        }
        
        func drawTableContentInnerBordersAndText(drawContext: CGContext, pageRect: CGRect, tableDataItems: [PrintableData]) {
            drawContext.setLineWidth(1.0)
            drawContext.saveGState()
            
            let defaultStartY = defaultOffset * 3
            
            for elementIndex in 0..<tableDataItems.count {
                let yPosition = CGFloat(elementIndex) * defaultStartY + defaultStartY
                
                // Draw content's elements texts
                let textFont = UIFont.systemFont(ofSize: 13.0, weight: .regular)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                paragraphStyle.lineBreakMode = .byWordWrapping
                let textAttributes = [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    NSAttributedString.Key.font: textFont
                ]
                let tabWidth = (pageRect.width - defaultOffset * 2) / CGFloat(3)
                for titleIndex in 0..<3 {
                    var attributedText = NSAttributedString(string: "", attributes: textAttributes)
                    switch titleIndex {
                    case 0: attributedText = NSAttributedString(string: tableDataItems[elementIndex].printName, attributes: textAttributes)
                    case 1: attributedText = NSAttributedString(string: tableDataItems[elementIndex].printDate, attributes: textAttributes)
                    case 2: attributedText = NSAttributedString(string:  tableDataItems[elementIndex].printAmount, attributes: textAttributes)
                    default:
                        break
                    }
                    let tabX = CGFloat(titleIndex) * tabWidth
                    let textRect = CGRect(x: tabX + defaultOffset,
                                          y: yPosition + defaultOffset,
                                          width: tabWidth,
                                          height: defaultOffset * 3)
                    attributedText.draw(in: textRect)
                }
                
                // Draw content's 3 vertical lines
                for verticalLineIndex in 0..<4 {
                    let tabX = CGFloat(verticalLineIndex) * tabWidth
                    drawContext.move(to: CGPoint(x: tabX + defaultOffset, y: yPosition))
                    drawContext.addLine(to: CGPoint(x: tabX + defaultOffset, y: yPosition + defaultStartY))
                    drawContext.strokePath()
                }
                
                // Draw content's element bottom horizontal line
                drawContext.move(to: CGPoint(x: defaultOffset, y: yPosition + defaultStartY))
                drawContext.addLine(to: CGPoint(x: pageRect.width - defaultOffset, y: yPosition + defaultStartY))
                drawContext.strokePath()
            }
            drawContext.restoreGState()
        }
    }
    
    func getValue(amount: Int) -> String {
        let number = Double(amount/100) + Double(amount%100)/100
        return numberformatter.string(from: NSNumber(value: number))!
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension Array {
    func chunkedElements(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
