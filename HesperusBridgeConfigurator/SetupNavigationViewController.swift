//
//  SetupNavigationViewController.swift
//  HesperusBridgeConfigurator
//
//  Created by Khaos Tian on 1/30/16.
//  Copyright © 2016 Oltica. All rights reserved.
//

import UIKit

class SetupNavigationViewController: UINavigationController {
    
    var animationDelegate: UINavigationControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.shadowImage = UIImage()
        self.updateDelegate(NavigationStackPlainAnimationDelegate())
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateDelegate(delegate: UINavigationControllerDelegate) {
        animationDelegate = delegate
        self.delegate = animationDelegate
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

class NavigationStackPlainAnimationDelegate: NSObject, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let transition = NavigationStackPlainAnimator(navigationOperation: operation)
        
        return transition
    }
}

class NavigationStackPlainAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var navigationControllerOperation: UINavigationControllerOperation!
    var linearCurve = false
    
    init(navigationOperation: UINavigationControllerOperation) {
        super.init()
        self.navigationControllerOperation = navigationOperation
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.33
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()!
        
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let fromView = fromVC.view
        let toView = toVC.view
        
        let containerWidth = container.frame.size.width
        
        var toInitialFrame = container.frame
        var fromDestinationFrame = fromView.frame
        
        if self.navigationControllerOperation == UINavigationControllerOperation.Push {
            toInitialFrame.origin.x = containerWidth
            toView.frame = toInitialFrame
            fromDestinationFrame.origin.x = -containerWidth
        } else if self.navigationControllerOperation == UINavigationControllerOperation.Pop {
            toInitialFrame.origin.x = -containerWidth
            toView.frame = toInitialFrame
            fromDestinationFrame.origin.x = containerWidth
        }
        
        container.addSubview(toView)
        
        var animationCurve = UIViewAnimationOptions.CurveEaseInOut
        if linearCurve {
            animationCurve = .CurveLinear
        }
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, options: [animationCurve, .BeginFromCurrentState], animations:
            {
                toView.frame = container.frame
                fromView.frame = fromDestinationFrame
            }, completion: {
                finish in
                if !(transitionContext.transitionWasCancelled()) {
                    if !container.subviews.contains(toView) {
                        container.addSubview(toView)
                    }
                    
                    toView.frame = container.frame
                    fromView.removeFromSuperview()
                }
                transitionContext.completeTransition(!(transitionContext.transitionWasCancelled()))
            }
        )
    }
}