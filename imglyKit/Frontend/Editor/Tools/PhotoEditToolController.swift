//
//  PhotoEditToolController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 11/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYPhotoEditToolController) public class PhotoEditToolController: UIViewController {

    public var preferredRenderMode: IMGLYRenderMode

    // MARK: - Initializers

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        preferredRenderMode = .All
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {
        preferredRenderMode = .All
        super.init(coder: aDecoder)
    }

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - PhotoEditToolController

    public var wantsDefaultPreviewView: Bool {
        return true
    }

    public var preferredPreviewBackgroundColor: UIColor? {
        return nil
    }

    public var preferredPreviewViewInsets: UIEdgeInsets {
        return UIEdgeInsetsZero
    }

}
