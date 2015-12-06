//
//  ViewController.swift
//  Filterer
//
//  Created by Markus Torpvret on 2015-11-03.
//  Copyright © 2015 Markus Torpvret. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imageProcessor: ImageProcessor?
    var filter: Filter?
    var currentFilterButton: UIButton?
    var currentImageView: UIImageView?
    let Original: Bool = true
    let Filtered: Bool = false
    
    @IBOutlet var lowerImageView: UIImageView!
    @IBOutlet var upperImageView: UIImageView!
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var textOverlay: UIView!
    @IBOutlet var bottomMenu: UIStackView!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var compareButton: UIButton!
    @IBOutlet var editView: UIView!
    @IBOutlet var editSlider: UISlider!
    @IBOutlet var editButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterButton.enabled = false
        editButton.enabled = false
        shareButton.enabled = true
        compareButton.enabled = false
        editView.translatesAutoresizingMaskIntoConstraints = false
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        upperImageView.userInteractionEnabled = true
        lowerImageView.userInteractionEnabled = true
        lowerImageView.alpha = 1
        upperImageView.alpha = 1
        currentImageView = upperImageView
        textOverlay.translatesAutoresizingMaskIntoConstraints = false
        textOverlay.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
    }
    
    @IBAction func onPress(sender: UILongPressGestureRecognizer) {
        if compareButton.enabled {
            if sender.state == .Began {
                switchImage(Original)
            }
            else if sender.state == .Ended {
                switchImage(Filtered)
            }
        }
    }
    
    @IBAction func setFilterValue(sender: UISlider) {
        print("Edit: " + String(sender.value))
        filter!.set(Double(sender.value))
        reapplyFilter()
        switchImage(Filtered)
    }

    @IBAction func editFilter(sender: UIButton) {
        if sender.selected {
            sender.selected = false
            hideEditBar()
        }
        else {
            sender.selected = true
            hideSecondaryMenu()
            showEditBar()
        }
    }
    
    func initSlider() {
        editSlider.minimumValue = Float(filter!.minValue)
        editSlider.maximumValue = Float(filter!.maxValue)
        editSlider.value = Float(filter!.value)
    }
    
    func showEditBar() {
        initSlider()
        view.addSubview(editView)
        let bottomConstraint = editView.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = editView.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = editView.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstraint = editView.heightAnchor.constraintEqualToConstant(44)
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        view.layoutIfNeeded()
        
        editView.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.editView.alpha = 1
        }
        editButton.selected = true
    }

    func hideEditBar() {
        UIView.animateWithDuration(0.4, animations: {
        self.editView.alpha = 0
        }) { completed in
            if completed {
                self.editView.removeFromSuperview()
            }
        }
        editButton.selected = false
    }
    
    
    @IBAction func onApplyFilter(sender: UIButton) {
        editButton.enabled = true
        imageProcessor?.reset()
        if sender.selected {
            sender.selected = false
            resetCurrentFilter()
        }
        else {
            sender.selected = true
            applyFilter(sender)
        }
        switchImage(Filtered)
    }
    
    func resetCurrentFilter() {
        currentFilterButton = nil
    }
    
    func applyFilter(sender: UIButton) {
        if currentFilterButton != nil {
            currentFilterButton!.selected = false
        }
        currentFilterButton = sender
        compareButton.enabled = true
        let filterName = sender.currentTitle!
        filter = Gamma.getFilterByName(filterName)
        imageProcessor?.applyFilter(filter!)
    }
    
    func reapplyFilter() {
        imageProcessor?.reset()
        imageProcessor?.applyFilter(filter!)
    }
    
    @IBAction func onCompare(sender: UIButton) {
        hideSecondaryMenu()
        if sender.selected {
            sender.selected = false
            switchImage(Filtered)
        }
        else {
            sender.selected = true
            switchImage(Original)
        }
    }
    
    func switchImage(type: Bool) {
        let newView = getNewImageView()
        if (type == Original) {
            showOriginalText(newView)
            newView.image = imageProcessor!.getOriginalImage()
        }
        else {
            hideOriginalText()
            newView.image = imageProcessor!.getFilteredImage()
        }
        newView.layoutIfNeeded()
        if newView == upperImageView {
            UIView.animateWithDuration(0.4) {
                self.upperImageView.alpha = 1
            }
        }
        else {
            UIView.animateWithDuration(0.4) {
                self.upperImageView.alpha = 0
            }
        }
        currentImageView = newView
        
    }
    
    func getNewImageView() -> UIImageView {
        if currentImageView == lowerImageView {
            return upperImageView
        }
        return lowerImageView
    }
   
    @IBAction func onShare(sender: UIButton) {
        hideSecondaryMenu()
        hideEditBar()
        if compareButton.selected {
            compareButton.selected = false
            switchImage(Filtered)
        }
        let activityController = UIActivityViewController(activityItems: [currentImageView!.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }

    @IBAction func onNewPhoto(sender: UIButton) {
        hideSecondaryMenu()
        hideEditBar()
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            self.selectImage(.Camera)
        }))
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
            self.selectImage(.PhotoLibrary)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func selectImage(sourceType: UIImagePickerControllerSourceType) {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = sourceType
        presentViewController(cameraPicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let newImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageProcessor = ImageProcessor(image: newImage)
            compareButton.enabled = false
            filterButton.enabled = true
            shareButton.enabled = true
            switchImage(Original)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onFilter(sender: UIButton) {
        if filterButton.selected {
            hideSecondaryMenu()
        } else {
            if compareButton.selected {
                compareButton.selected = false
                switchImage(Filtered)
            }
            hideEditBar()
            showSecondaryMenu()
        }
    }

    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        view.layoutIfNeeded()
        
        secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1
        }
        filterButton.selected = true
    }
    
    func hideSecondaryMenu() {
        if filterButton.selected {
            UIView.animateWithDuration(0.4, animations: {
                self.secondaryMenu.alpha = 0
                }) { completed in
                    if completed {
                        self.secondaryMenu.removeFromSuperview()
                    }
            }
            filterButton.selected = false
        }
    }
    
    func showOriginalText(imageView: UIImageView) {
        imageView.addSubview(textOverlay)
        let topConstraint = textOverlay.topAnchor.constraintEqualToAnchor(imageView.topAnchor)
        let leftConstraint = textOverlay.leftAnchor.constraintEqualToAnchor(imageView.leftAnchor)
        let rightConstraint = textOverlay.rightAnchor.constraintEqualToAnchor(imageView.rightAnchor)
        let heightConstraint = textOverlay.heightAnchor.constraintEqualToConstant(44)
        NSLayoutConstraint.activateConstraints([topConstraint, leftConstraint, rightConstraint, heightConstraint])
        secondaryMenu.alpha = 1
   }

    func hideOriginalText() {
//        UIView.animateWithDuration(0.4, animations: {
//            self.textOverlay.alpha = 0
//            }) { completed in
//                if completed {
                    self.textOverlay.removeFromSuperview()
//                }
//        }
    }
}

