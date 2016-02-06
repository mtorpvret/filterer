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
    var filterNames: [String] = ["Brightness", "Contrast", "Gamma", "Solarise", "Grayscale"]
    var currentFilterIndex: Int?
    var currentFilterButton: UIButton?
    var currentImageView: UIImageView?
    var oldFilterName: String?
    let Original: Bool = true
    let Filtered: Bool = false
    let reuseIdentifier = "FilterCell"
    
    @IBOutlet var lowerImageView: UIImageView!
    @IBOutlet var upperImageView: UIImageView!
    @IBOutlet var scrollingSecMenu: UICollectionView!
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
        scrollingSecMenu.translatesAutoresizingMaskIntoConstraints = false
        editView.translatesAutoresizingMaskIntoConstraints = false
        upperImageView.userInteractionEnabled = true
        lowerImageView.userInteractionEnabled = true
        lowerImageView.alpha = 1
        upperImageView.alpha = 1
        currentImageView = upperImageView
        textOverlay.translatesAutoresizingMaskIntoConstraints = false
        textOverlay.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        scrollingSecMenu.delegate = self
        scrollingSecMenu.dataSource = self
    }
    
    func filterForIndexPath(indexPath: NSIndexPath)-> Filter? {
        return Gamma.getFilterByName(filterNames[indexPath.row])
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
    
    
    func applyFiltername(filterName: String) {
        compareButton.enabled = true
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
            editButton.enabled = false
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
        showSecMenu(scrollingSecMenu, height: 150)
    }
    
    func hideSecondaryMenu() {
        hideSecMenu(scrollingSecMenu)
    }
    
    func showSecMenu(menu: UIView, height: CGFloat) {
        view.addSubview(menu)
        let bottomConstraint = menu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = menu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = menu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstraint = menu.heightAnchor.constraintEqualToConstant(height)
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        view.layoutIfNeeded()
        
        menu.alpha = 0
        UIView.animateWithDuration(0.4) {
            menu.alpha = 1
        }
        filterButton.selected = true
    }
    
    func hideSecMenu(menu: UIView) {
        if filterButton.selected {
            UIView.animateWithDuration(0.4, animations: {
                menu.alpha = 0
                }) { completed in
                    if completed {
                        menu.removeFromSuperview()
                    }
            }
            filterButton.selected = false
        }
    }

    func showOriginalText(imageView: UIImageView) {
        self.textOverlay.alpha = 0
        imageView.addSubview(textOverlay)
        let topConstraint = textOverlay.topAnchor.constraintEqualToAnchor(imageView.topAnchor)
        let leftConstraint = textOverlay.leftAnchor.constraintEqualToAnchor(imageView.leftAnchor)
        let rightConstraint = textOverlay.rightAnchor.constraintEqualToAnchor(imageView.rightAnchor)
        let heightConstraint = textOverlay.heightAnchor.constraintEqualToConstant(44)
        NSLayoutConstraint.activateConstraints([topConstraint, leftConstraint, rightConstraint, heightConstraint])
        UIView.animateWithDuration(0.4, animations: {
           self.textOverlay.alpha = 1
        })
    }

    func hideOriginalText() {
        UIView.animateWithDuration(0.4, animations: {
            self.textOverlay.alpha = 0
            }) { completed in
                if completed {
                    self.textOverlay.removeFromSuperview()
                }
        }
    }
}

extension ViewController : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //1
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FilterCell
        //2
        let fltr = filterForIndexPath(indexPath)!
        cell.backgroundColor = UIColor.blackColor()
        //3
        cell.imageView.image = fltr.thumbnail
        cell.label.text = filterNames[indexPath.row]
        
        return cell
    }}

extension ViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            let flt =  filterForIndexPath(indexPath)!

            if var size = flt.thumbnail?.size {
                size.width += 10
                size.height += 10
                return size
            }
            return CGSize(width: 100, height: 100)
    }
    
}

extension ViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView,
        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            currentFilterIndex = indexPath.row
            let newFilterName = filterNames[currentFilterIndex!]
            if oldFilterName == nil {
                editButton.enabled = true
                applyFiltername(newFilterName)
                oldFilterName = newFilterName
            }
            else if oldFilterName == newFilterName {
                editButton.enabled = false
                imageProcessor?.reset()
                oldFilterName = nil
            }
            else {
                editButton.enabled = true
                imageProcessor?.reset()
                applyFiltername(newFilterName)
                oldFilterName = newFilterName
            }
            switchImage(Filtered)
            return true
    }
    
}
