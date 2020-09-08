//
//  ExtUIViewController+Keyboard.swift
//
//  Created by Mikhail Muravev on 11/01/2019.
//  Copyright © 2019 M-Technology. All rights reserved.
//

import UIKit

private var scrollViewKey : UInt8 = 0
private var yConstraintForBottomViewKey : UInt8 = 0

extension UIViewController {
    
    func setupKeyboardNotifcationListenerForScrollView(_ scrollView: UIScrollView) {
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        internalScrollView = scrollView
    }
    
    func setupKeyboardNotifcationListenerForScrollView(_ scrollView: UIScrollView, yConstraintForBottomView: NSLayoutConstraint) {
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShowWithBottomBar(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHideWithBottomBar(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        internalScrollView = scrollView
        internalYConstraintForBottomView = yConstraintForBottomView
    }
    
    func setupKeyboardNotifcationListener(_ yConstraintForBottomView: NSLayoutConstraint) {
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShowWithoutScroll(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHideWithoutScroll(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        internalYConstraintForBottomView = yConstraintForBottomView
    }
    
    func removeKeyboardNotificationListeners() {
        Foundation.NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        Foundation.NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate var internalScrollView: UIScrollView! {
        get {
            return objc_getAssociatedObject(self, &scrollViewKey) as? UIScrollView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &scrollViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    fileprivate var internalYConstraintForBottomView: NSLayoutConstraint! {
        get {
            return objc_getAssociatedObject(self, &yConstraintForBottomViewKey) as? NSLayoutConstraint
        }
        set(newValue) {
            objc_setAssociatedObject(self, &yConstraintForBottomViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]!.int32Value
        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]?.cgRectValue
        let keyboardFrameConvertedToViewFrame = view.convert(keyboardFrame!, from: nil)
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(animationCurve!))
        let options = UIView.AnimationOptions.beginFromCurrentState.union(curveAnimationOption)
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            let insetHeight = (self.internalScrollView.frame.height + self.internalScrollView.frame.origin.y) - keyboardFrameConvertedToViewFrame.origin.y
            self.internalScrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: insetHeight, right: 0)
            self.internalScrollView.scrollIndicatorInsets  = UIEdgeInsets.init(top: 0, left: 0, bottom: insetHeight, right: 0)
        }) { (complete) -> Void in
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]!.int32Value
        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]?.cgRectValue
        _ = view.convert(keyboardFrame!, from: nil)
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(animationCurve!))
        let options = UIView.AnimationOptions.beginFromCurrentState.union(curveAnimationOption)
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            self.internalScrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
            self.internalScrollView.scrollIndicatorInsets  = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        }) { (complete) -> Void in
        }
    }
    
    @objc func keyboardWillShowWithBottomBar(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]!.int32Value
        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]?.cgRectValue
        let keyboardFrameConvertedToViewFrame = view.convert(keyboardFrame!, from: nil)
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(animationCurve!))
        let options = UIView.AnimationOptions.beginFromCurrentState.union(curveAnimationOption)
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            let insetHeight = (self.internalScrollView.frame.height + self.internalScrollView.frame.origin.y) - keyboardFrameConvertedToViewFrame.origin.y
            self.internalScrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: insetHeight, right: 0)
            self.internalScrollView.scrollIndicatorInsets  = UIEdgeInsets.init(top: 0, left: 0, bottom: insetHeight, right: 0)
            self.internalYConstraintForBottomView.constant = self.view.frame.size.height - CGFloat(55.0) - keyboardFrameConvertedToViewFrame.height
        }) { (complete) -> Void in
        }
    }
    
    @objc func keyboardWillHideWithBottomBar(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]!.int32Value
        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]?.cgRectValue
        _ = view.convert(keyboardFrame!, from: nil)
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(animationCurve!))
        let options = UIView.AnimationOptions.beginFromCurrentState.union(curveAnimationOption)
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            self.internalScrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
            self.internalScrollView.scrollIndicatorInsets  = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
            self.internalYConstraintForBottomView.constant = self.view.frame.size.height - CGFloat(55.0)
        }) { (complete) -> Void in
        }
    }
    
    @objc func keyboardWillShowWithoutScroll(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]!.int32Value
        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]?.cgRectValue
        let keyboardFrameConvertedToViewFrame = view.convert(keyboardFrame!, from: nil)
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(animationCurve!))
        let options = UIView.AnimationOptions.beginFromCurrentState.union(curveAnimationOption)
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            self.internalYConstraintForBottomView.constant = self.view.frame.size.height - CGFloat(55.0) - keyboardFrameConvertedToViewFrame.height
        }) { (complete) -> Void in
        }
    }
    
    @objc func keyboardWillHideWithoutScroll(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]!.int32Value
        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]?.cgRectValue
        _ = view.convert(keyboardFrame!, from: nil)
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(animationCurve!))
        let options = UIView.AnimationOptions.beginFromCurrentState.union(curveAnimationOption)
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            self.internalYConstraintForBottomView.constant = self.view.frame.size.height - CGFloat(55.0)
        }) { (complete) -> Void in
        }
    }
}

