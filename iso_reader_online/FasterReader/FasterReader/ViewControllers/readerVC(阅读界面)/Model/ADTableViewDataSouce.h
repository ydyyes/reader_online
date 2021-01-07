//
//  ADTableViewDataSouce.h
//  reader
//
//  Created by beequick on 2017/8/11.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AATableViewCellEditingStyle) {
    AATableViewCellEditingStyleNone,
    AATableViewCellEditingStyleDelete,
    AATableViewCellEditingStyleInsert
};
typedef void (^TableViewCellConfigureBlock)(id cell, id item, NSIndexPath *indexpath);
typedef void (^TableViewCellDidSelectedBlock)(id item, NSIndexPath *indexpath);
typedef void (^TableViewCellDidEditBlock)(AATableViewCellEditingStyle type, id item, NSIndexPath *indexpath);
typedef void (^TableViewCellDidEditDeleteBlock)(id item, NSIndexPath *indexpath);
typedef void (^TableViewCellDidEditInsertBlock)(id item, NSIndexPath *indexpath);
//cellForRowAtIndexPath
typedef UITableViewCell* (^TableViewCellForRowBlock)(NSIndexPath *indexpath);

@protocol ADTableViewDelegate <NSObject>
@optional
- (UITableViewCell *)adTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)adTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)adScrollViewDidScroll:(UIScrollView *)scrollview;
- (void)adScrollViewWillBeginDragging:(UIScrollView *)scrollview;
- (void)adScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)adScrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (CGFloat)adTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ADTableViewDataSouce : NSObject<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

- (id)initWithItems:(NSArray *)items
     cellIdentifier:(NSString *)aCellIdentifier
 ConfigureCellBlock:(TableViewCellConfigureBlock)ConfigureCellBlock;
- (id)initWithItems:(NSArray *)items
         editEnable:(BOOL)editEnable
     cellIdentifier:(NSString *)aCellIdentifier
 ConfigureCellBlock:(TableViewCellConfigureBlock)ConfigureCellBlock;
- (id)initWithCellIdentifier:(NSString *)aCellIdentifier
          ConfigureCellBlock:(TableViewCellConfigureBlock)ConfigureCellBlock;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) TableViewCellConfigureBlock ConfigureCellBlock;
@property (nonatomic, copy) TableViewCellDidSelectedBlock cellSelectBlock;
@property (nonatomic, copy) TableViewCellForRowBlock cellForRowBlock;
@property (nonatomic, copy) TableViewCellDidEditBlock cellEditBlock;
@property (nonatomic, copy) TableViewCellDidEditDeleteBlock cellDeleteBlock;
@property (nonatomic, copy) TableViewCellDidEditInsertBlock cellInsertBlock;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) BOOL editEnable;
@property (nonatomic, weak) id<ADTableViewDelegate> delegate;

@end
