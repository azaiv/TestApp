//
//  DocumentBrowserViewController.swift
//  absolute
//
//  Created by aiv on 21.05.2023.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        allowsDocumentCreation = false
        allowsPickingMultipleItems = false
    }
    
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL: URL? = nil
        
        if newDocumentURL != nil {
            importHandler(newDocumentURL, .move)
        } else {
            importHandler(nil, .none)
        }
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {}

    
    func presentDocument(at documentURL: URL) {
        
        let vc = DocumentViewController()
        let navBarController = UINavigationController(rootViewController: vc)
        
        vc.document = Document(fileURL: documentURL)
        navBarController.modalPresentationStyle = .fullScreen
        
        present(navBarController, animated: true, completion: nil)
    }
}

