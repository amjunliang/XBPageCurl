//
//  PageCurlViewController.m
//  XBPageCurl
//
//  Created by xiss burg on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PageCurlViewController.h"
#import <QuartzCore/QuartzCore.h>

#define kDuration 0.3

@interface PageCurlViewController ()

@property (nonatomic, strong) UIPanGestureRecognizer* coverViewPan;
@property (nonatomic, strong) XBSnappingPoint* cornerSnappingPoint;
@property (nonatomic, strong) XBPageCurlView *pageCurlView;

@end

@implementation PageCurlViewController
- (void)refreshPageCurlView
{
    self.mapView.userInteractionEnabled = false;
    XBPageCurlView *pageCurlView = [[XBPageCurlView alloc] initWithFrame:self.view.bounds];
    pageCurlView.pageOpaque = YES;
    pageCurlView.opaque = NO;
    pageCurlView.snappingEnabled = YES;
    [pageCurlView drawViewOnFrontOfPage:_frontView];
    
    if (self.pageCurlView != nil) {
        pageCurlView.maximumCylinderAngle = self.pageCurlView.maximumCylinderAngle;
        pageCurlView.minimumCylinderAngle = self.pageCurlView.minimumCylinderAngle;
        [pageCurlView addSnappingPointsFromArray:self.pageCurlView.snappingPoints];
        [self.pageCurlView removeFromSuperview];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XBPageCurlViewDidSnapToPointNotification object:self.pageCurlView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageCurlViewDidSnapToPointNotification:) name:XBPageCurlViewDidSnapToPointNotification object:pageCurlView];
    self.pageCurlView = pageCurlView;
}
- (XBSnappingPoint *)cornerSnappingPoint
{
    if (_cornerSnappingPoint == nil) {
        _cornerSnappingPoint = [[XBSnappingPoint alloc] initWithPosition:CGPointMake(0, self.view.frame.size.height) angle:3*M_PI_4 radius:self.view.bounds.size.width];
    }
    return _cornerSnappingPoint;
}

- (void)uncurlPageAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    NSTimeInterval duration = animated? 0.3: 0;
    __weak PageCurlViewController *weakSelf = self;
    [self.pageCurlView setCylinderPosition:self.cornerSnappingPoint.position cylinderAngle:self.cornerSnappingPoint.angle cylinderRadius:self.cornerSnappingPoint.radius animatedWithDuration:duration completion:^{
        weakSelf.frontView.hidden = NO;
        [weakSelf.pageCurlView removeFromSuperview];
        [weakSelf.pageCurlView stopAnimating];
        if (completion) {
            completion();
        }
    }];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _coverViewPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandle:)];
    [_frontView addGestureRecognizer:_coverViewPan];
    [self refreshPageCurlView];
}

-(void) gestureHandle:(UIPanGestureRecognizer *)ges {
    BOOL isDirectForward = true;
    if ([ges isKindOfClass:UIPanGestureRecognizer.class] && ges.state == UIGestureRecognizerStateBegan) {
        CGPoint speed = [ges velocityInView:self.view];
        if (speed.x< 0) {
            isDirectForward = true;
        }
    }
    UIPanGestureRecognizer *pan = ges;
    CGPoint speed = [pan velocityInView:self.view];
    CGPoint touchLocation =  [ges locationInView:self.view];
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        if (CGRectContainsPoint(self.view.frame, touchLocation)) {
            [self.pageCurlView drawViewOnFrontOfPage:_frontView];
            self.pageCurlView.cylinderPosition = self.cornerSnappingPoint.position;
            self.pageCurlView.cylinderAngle = self.cornerSnappingPoint.angle;
            self.pageCurlView.cylinderRadius = self.cornerSnappingPoint.radius;
            [self.pageCurlView touchBeganAtPoint:touchLocation];
            [self.view addSubview:self.pageCurlView];
            _frontView.hidden = YES;
            [self.pageCurlView startAnimating];
        }
    }else if (pan.state == UIGestureRecognizerStateChanged){
        [self.pageCurlView touchMovedToPoint:touchLocation];
    }else if (pan.state == UIGestureRecognizerStateEnded
              || pan.state == UIGestureRecognizerStateCancelled){
        if (isDirectForward && speed.x > 0) {
            //back
        }
        
        if (!isDirectForward && speed.x < 0) {
            //back
        }
        [self.pageCurlView touchEndedAtPoint:CGPointMake(-self.view.frame.size.width, self.view.frame.size.height/2)];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // If the viewController was pushed in a landscape orientation its frame was that of a portrait view yet, then we have to reset the
    // page curl view's mesh here.
    [self refreshPageCurlView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Buttons Actions

- (IBAction)buttonAction:(id)sender
{
    [self uncurlPageAnimated:YES completion:nil];
}

- (void)standardButtonAction:(id)sender
{
    self.mapView.mapType = MKMapTypeStandard;
}

- (void)satelliteButtonAction:(id)sender
{
    self.mapView.mapType = MKMapTypeSatellite;
}

- (void)hybridButtonAction:(id)sender
{
    self.mapView.mapType = MKMapTypeHybrid;
}

@end
