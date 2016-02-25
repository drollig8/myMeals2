//
//  UIFunctions.swift
//  MYMEALS2
//
//  Created by Marc Felden on 25.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import UIKit


class UIFunctions
{
    class func addDoneButton(view: UIViewController)
    {
        view.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: view, action: "done:")
    }
    class func addCancelButton(view: UIViewController)
    {
        view.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: view, action: "cancel:")
    }
    
    
}
