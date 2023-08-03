//
//  XBPageCurlAppDelegate.m
//  XBPageCurl
//
//  Created by xiss burg on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XBPageCurlAppDelegate.h"
#import "RootViewController.h"
#import "PageCurlViewController.h"

@implementation XBPageCurlAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIViewController *rootViewController = [[PageCurlViewController alloc] initWithNibName:@"PageCurlViewController_iPhone" bundle:nil];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
