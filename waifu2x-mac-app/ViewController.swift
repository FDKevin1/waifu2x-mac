//
//  ViewController.swift
//  waifu2x-mac-app
//
//  Created by 谢宜 on 2018/1/24.
//  Copyright © 2018年 谢宜. All rights reserved.
//

import Cocoa
import waifu2x_mac

class ViewController: NSViewController {

    @IBOutlet weak var inImg: NSImageView!
    @IBOutlet weak var outImg: NSImageView!
    @IBOutlet weak var pickBtn: NSButton!
    @IBOutlet weak var processBtn: NSButton!
    @IBOutlet weak var saveBtn: NSButton!
    @IBOutlet weak var status: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.styleMask.remove(.resizable)
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func pickImage(_ sender: Any) {
        let dialog = NSOpenPanel()
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowedFileTypes = ["public.image"]
        dialog.beginSheetModal(for: view.window!) { (resp) in
            if resp == NSApplication.ModalResponse.OK {
                let url = dialog.urls[0]
                self.inImg.image = NSImage(contentsOf: url)
            }
        }
    }
    
    @IBAction func processImage(_ sender: Any) {
        let background = DispatchQueue(label: "background")
        guard let img = inImg.image else {
            return
        }
        pickBtn.isEnabled = false
        processBtn.isEnabled = false
        saveBtn.isEnabled = false
        let start = DispatchTime.now().uptimeNanoseconds
        background.async {
            guard let outImage = Waifu2x.run(img, model: Model.anime_noise2_scale2x) else {
                return
            }
            DispatchQueue.main.async {
                self.outImg.image = outImage
                debugPrint("\(outImage.size)")
                self.pickBtn.isEnabled = true
                self.processBtn.isEnabled = true
                self.saveBtn.isEnabled = true
                let end = DispatchTime.now().uptimeNanoseconds
                self.status.stringValue = "Time elapsed: \(Float(end - start) / 1_000_000_000)"
            }
        }
    }
    
    @IBAction func saveImage(_ sender: Any) {
        guard let oImg = outImg.image else {
            return
        }
        let dialog = NSSavePanel()
        dialog.allowedFileTypes = ["public.png"]
        dialog.beginSheetModal(for: view.window!) { (resp) in
            if resp == NSApplication.ModalResponse.OK {
                guard let url = dialog.url else {
                    return
                }
                oImg.pngWrite(to: url)
            }
        }
    }
    
}

