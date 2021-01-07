//
//  ESIntroduceViewController.h
//  ESWineGrandCru
//
//  Created by Apple on 13-1-4.
//  Copyright (c) 2013年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroduceViewController : UIViewController<UIScrollViewDelegate>
    
{
    BOOL isRemove;
    NSArray *imageArray;
}
@property(nonatomic,retain) UIPageControl *advertPageControl;


@end


@interface AppIntroduceScrollView : UIScrollView<UIScrollViewDelegate>
{
    BOOL isRemove;
    NSArray *imageArray;
}
@property(nonatomic,retain) UIPageControl *advertPageControl;


@end
