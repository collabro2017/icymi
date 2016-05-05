//
//  LMNavigationSegue.m
//  Management
//
//  Created by Olga Dalton on 16/04/14.
//

#import "MMNavigationSegue.h"
#import "FTTabBarController.h"

@implementation MMNavigationSegue

- (void) perform
{
    FTTabBarController *tabBarController = (FTTabBarController *) self.sourceViewController;
    UIViewController *destinationController = (UIViewController *) tabBarController.currentViewController;
    
//    if ([tabBarController.currentViewController isKindOfClass:[destinationController class]]) {
//        return;
//    }
    
    for (UIView *view in tabBarController.placeholderView.subviews)
    {
        [view removeFromSuperview];
    }
    
    // Add view to placeholder view
    tabBarController.currentViewController = destinationController;
    [tabBarController.placeholderView addSubview: destinationController.view];
    
    // Set autoresizing
    [tabBarController.placeholderView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UIView *childview = destinationController.view; 
    [childview setTranslatesAutoresizingMaskIntoConstraints: NO];
     
    // fill horizontal
    [tabBarController.placeholderView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[childview]|" options: 0 metrics: nil views: NSDictionaryOfVariableBindings(childview)]];
    
    // fill vertical
    [tabBarController.placeholderView addConstraints:[ NSLayoutConstraint constraintsWithVisualFormat: @"V:|-0-[childview]-0-|" options: 0 metrics: nil views: NSDictionaryOfVariableBindings(childview)]];
    
    [tabBarController.placeholderView layoutIfNeeded]; 
    
    // notify did move
    [destinationController didMoveToParentViewController: tabBarController];
}

@end
  