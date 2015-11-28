//
//  ViewController.swift
//  Filterer
//
//  Created by Markus Torpvret on 2015-11-03.
//  Copyright © 2015 Markus Torpvret. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var originalImage: UIImage?
    var imageProcessor: ImageProcessor?
    var filters = [String: Filter]()
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var textOverlay: UIView!
    @IBOutlet var bottomMenu: UIStackView!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var compareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterButton.enabled = false
        shareButton.enabled = false
        compareButton.enabled = false
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        imageView.userInteractionEnabled = true
        textOverlay.translatesAutoresizingMaskIntoConstraints = false
        textOverlay.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
    }
    
    @IBAction func onPress(sender: UILongPressGestureRecognizer) {
        if compareButton.enabled {
            if sender.state == .Began {
                showOriginalImage()
            }
            else if sender.state == .Ended {
                showFilteredImage()
            }
        }
    }
    
    @IBAction func onApplyFilter(sender: UIButton) {
        let filterName = sender.currentTitle!
        var filter = filters[filterName]
        if sender.selected {
            sender.selected = false
            if filter != nil {
                filters[filterName] = nil
                imageProcessor = ImageProcessor(image: originalImage!)
                imageProcessor?.applyFilters(Array(filters.values))
                showFilteredImage()
            }
        }
        else {
            sender.selected = true
            if filter == nil {
                filter = Gamma.getFilterByName(filterName)  // Can't call protocol extension on the protocol itself :(
                filters[filterName] = filter
                imageProcessor?.applyFilter(filter!)
                showFilteredImage()
                compareButton.enabled = true
            }
        }
    }
    
    @IBAction func onCompare(sender: UIButton) {
        hideSecondaryMenu()
        toggleSelectAndHandle(compareButton, selectFunc: showOriginalImage, deselectFunc: showFilteredImage)
    }
    
    func toggleSelectAndHandle(button: UIButton, selectFunc: () -> Void, deselectFunc: () -> Void) {
        if button.selected {
            deselectFunc()
            button.selected = false
        }
        else {
            selectFunc()
            button.selected = true
        }
    }
    
    func showOriginalImage() {
        imageView.addSubview(textOverlay)
        let topConstraint = textOverlay.topAnchor.constraintEqualToAnchor(imageView.topAnchor)
        let leftConstraint = textOverlay.leftAnchor.constraintEqualToAnchor(imageView.leftAnchor)
        let rightConstraint = textOverlay.rightAnchor.constraintEqualToAnchor(imageView.rightAnchor)
        let heightConstraint = textOverlay.heightAnchor.constraintEqualToConstant(44)
        NSLayoutConstraint.activateConstraints([topConstraint, leftConstraint, rightConstraint, heightConstraint])
        showImage(originalImage)
    }
    
    func showFilteredImage() {
        textOverlay.removeFromSuperview()
        showImage(imageProcessor?.getImage())
    }
    
    func showImage(image: UIImage?) {
        if image != nil {
            imageView.image = image!
            view.layoutIfNeeded()
        }
    }

    func setImage(image: UIImage) {
        self.originalImage = image
        self.imageProcessor = ImageProcessor(image: image)
        showOriginalImage()
    }
    
    @IBAction func onShare(sender: UIButton) {
        hideSecondaryMenu()
        if compareButton.selected {
            showFilteredImage()
            compareButton.selected = false
        }
        let activityController = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }

    @IBAction func onNewPhoto(sender: UIButton) {
        hideSecondaryMenu()
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
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            setImage(image)
            compareButton.enabled = false
            filterButton.enabled = true
            shareButton.enabled = true
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
                showFilteredImage()
                compareButton.selected = false
            }
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
}

