//
//  ExplodedLayout.m
//  CollectionViewHidingCells
//
//  Created by Stuart Foulston on 17/05/2014.
//  Copyright (c) 2014. All rights reserved.
//

#import "ExplodedLayout.h"

@implementation ExplodedLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
	
	for (UICollectionViewLayoutAttributes *attr in layoutAttributes) {
		[self explodeLayoutAttributes:attr];
	}
	
	return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewLayoutAttributes *attr = [super layoutAttributesForItemAtIndexPath:indexPath];
	[self explodeLayoutAttributes:attr];
	return attr;
}

- (void)explodeLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes
{
	CGPoint offsetFromCenter = CGPointMake(attributes.center.x - self.pinchPoint.x,
										   attributes.center.y - self.pinchPoint.y);
	attributes.center = CGPointMake(attributes.center.x + offsetFromCenter.x/2.0f,
									attributes.center.y + offsetFromCenter.y/2.0f);
}

@end
