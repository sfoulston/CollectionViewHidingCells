//
//  CollectionViewController.m
//  CollectionViewHidingCells
//
//  Created by Stuart Foulston on 17/05/2014.
//  Copyright (c) 2014. All rights reserved.
//

#import "CollectionViewController.h"
#import "GridLayout.h"
#import "ExplodedLayout.h"
#import "Cell.h"


@interface CollectionViewController ()

/*! Properties to help transition between layouts. */
@property(nonatomic, strong) UICollectionViewTransitionLayout *transitionLayout;
@property(nonatomic, assign) UINavigationControllerOperation navigationOperation;
@property(nonatomic, assign) CGFloat initialPinchDistance;

@end


@implementation CollectionViewController

#pragma mark - Managing the View

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self addPinchGestureRecognizer];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return 200;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
	cell.label.text = [NSString stringWithFormat:@"%lu", (unsigned long)indexPath.item];
	return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	/* Create a layout to transition to. */
	GridLayout *toLayout;
	if ([self.collectionView.collectionViewLayout isMemberOfClass:[GridLayout class]]) {
		self.navigationOperation = UINavigationControllerOperationPush;
		toLayout = [ExplodedLayout new];
	} else {
		self.navigationOperation = UINavigationControllerOperationPop;
		toLayout = [GridLayout new];
	}
	toLayout.pinchPoint = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath].center;
	
	__weak CollectionViewController *weakSelf = self;
	[self.collectionView setCollectionViewLayout:toLayout animated:YES completion:^(BOOL finished) {
		weakSelf.navigationOperation = UINavigationControllerOperationNone;
	}];
}


#pragma mark - Pinch Gesture

- (void)addPinchGestureRecognizer
{
	UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[self.view addGestureRecognizer:pinch];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch
{
	if (pinch.numberOfTouches < 2) {
        return;
    }
    CGPoint p1 = [pinch locationOfTouch:0 inView:pinch.view];
    CGPoint p2 = [pinch locationOfTouch:1 inView:pinch.view];
    CGFloat distance = sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
	
	switch (pinch.state) {
		case UIGestureRecognizerStateBegan:
			if (self.navigationOperation != UINavigationControllerOperationNone) {
				return;
			}
			self.initialPinchDistance = distance;
			CGPoint pinchPoint = [pinch locationInView:pinch.view];
			UINavigationControllerOperation navOperation = (pinch.velocity > 0.0f) ? UINavigationControllerOperationPush : UINavigationControllerOperationPop;
			[self beginInteractiveLayoutTransitionAtPoint:pinchPoint forNavigationOperation:navOperation];
			break;

		case UIGestureRecognizerStateChanged:
			if (self.navigationOperation == UINavigationControllerOperationNone) {
				return;
			}
			CGFloat progress = [self progressForPinchDistance:distance];
			[self updateInteractiveLayoutTransition:progress];
			break;
			
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled:
			if (self.navigationOperation == UINavigationControllerOperationNone) {
				return;
			}
			BOOL success = NO;
			if (pinch.state == UIGestureRecognizerStateEnded) {
				if ([self progressForPinchDistance:distance] > 0.5f) {
					success = YES;
				}
			}
			[self endInteractiveLayoutTransitionWithSuccess:success];
			break;

		default:
			break;
	}
}

- (CGFloat)progressForPinchDistance:(CGFloat)pinchDistance
{
	CGFloat distanceDelta = pinchDistance - self.initialPinchDistance;
	if (self.navigationOperation == UINavigationControllerOperationPop) {
		distanceDelta = -distanceDelta;
	}
	CGFloat dimension = MIN(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
	CGFloat progress = MAX(MIN((distanceDelta / dimension), 1.0), 0.0);
	return progress;
}


#pragma mark - Interactive Layout Transition

- (void)beginInteractiveLayoutTransitionAtPoint:(CGPoint)point forNavigationOperation:(UINavigationControllerOperation)operation
{
	/* Create a layout to transition to. */
	GridLayout *toLayout;
	if (operation == UINavigationControllerOperationPush) {
		toLayout = [ExplodedLayout new];
	} else {
		toLayout = [GridLayout new];
	}
	toLayout.pinchPoint = point;
	
	/* Begin the transition if the new layout is different from the current layout. */
	if (![self.collectionView.collectionViewLayout isMemberOfClass:[toLayout class]]) {
		self.navigationOperation = operation;
		self.transitionLayout = [self.collectionView startInteractiveTransitionToCollectionViewLayout:toLayout completion:^(BOOL completed, BOOL finished) {
			self.navigationOperation = UINavigationControllerOperationNone;
		}];
	}
}

- (void)updateInteractiveLayoutTransition:(CGFloat)progress
{
	self.transitionLayout.transitionProgress = progress;
	[self.transitionLayout invalidateLayout];
}

- (void)endInteractiveLayoutTransitionWithSuccess:(BOOL)success
{
	if (success) {
		[self.collectionView finishInteractiveTransition];
	} else {
		[self.collectionView cancelInteractiveTransition];
	}
}

@end
