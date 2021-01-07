//
//  LKZoomableView.h
//  
//
//  Created by luke on 10-11-15.
//  Copyright 2010 pica.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LKZoomableView : UIScrollView {
	
	BOOL isInfoboxHidden;
}

@property (nonatomic, assign) BOOL isInfoboxHidden;

- (void)zoomRectWithCenter:(CGPoint)center;
@end
