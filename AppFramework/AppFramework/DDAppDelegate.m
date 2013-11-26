//
//  DDAppDelegate.m
//  AppFramework
//
//  Created by Dong Yiming on 10/23/13.
//  Copyright (c) 2013 ToMaDon. All rights reserved.
//

#import "DDAppDelegate.h"

#import "DDViewController.h"
#import "MMDrawerController.h"
#import "MMExampleDrawerVisualStateManager.h"


#import "DDPlayAround.h"

@implementation DDAppDelegate

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //self.viewController = [[DDViewController alloc] initWithNibName:@"DDViewController" bundle:nil];
    
    
    UIViewController * leftDrawer = [[UINavigationController alloc] initWithRootViewController:[DDTestLeftVC new]];
    UIViewController * center = [[UINavigationController alloc] initWithRootViewController:[DDTestCenterVC new]];
    UIViewController * rightDrawer = [[UINavigationController alloc] initWithRootViewController:[DDTestRightVC new]];
    
    MMDrawerController * drawerController = [[MMDrawerController alloc]
                                             initWithCenterViewController:center
                                             leftDrawerViewController:leftDrawer
                                             rightDrawerViewController:rightDrawer];
    
    [drawerController setRestorationIdentifier:@"MMDrawer"];
    [drawerController setMaximumRightDrawerWidth:100.0];
    drawerController.maximumLeftDrawerWidth = 150;
    drawerController.showsShadow = YES;
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         MMExampleDrawerVisualStateManager *sharedVisualManager = [MMExampleDrawerVisualStateManager sharedManager];
         sharedVisualManager.leftDrawerAnimationType = MMDrawerAnimationTypeSwingingDoor;
         sharedVisualManager.rightDrawerAnimationType = MMDrawerAnimationTypeParallax;
         
         block = [sharedVisualManager drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
         
        //
         UIViewController * sideDrawerViewController;
//         if(drawerSide == MMDrawerSideLeft){
//             sideDrawerViewController = drawerController.leftDrawerViewController;
//         }
//         else
         
             if(drawerSide == MMDrawerSideRight){
             sideDrawerViewController = drawerController.rightDrawerViewController;
         }
         [sideDrawerViewController.view setAlpha:percentVisible];
     
     }];
    
    
    
    self.window.rootViewController = drawerController;
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [self.window makeKeyAndVisible];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"MyDatabase.sqlite"];
    
    [DDPlayAround play];
    
    return YES;
}





- (void)applicationWillResignActive:(UIApplication *)application{}
- (void)applicationDidEnterBackground:(UIApplication *)application{}
- (void)applicationWillEnterForeground:(UIApplication *)application{}
- (void)applicationDidBecomeActive:(UIApplication *)application{}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
}

@end
