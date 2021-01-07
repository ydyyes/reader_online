//
//  LDYSelectivityTableViewCell.m
//  LDYSelectivityAlertView
//
//  Created by 李东阳 on 2018/8/15.
//

#import "LDYSelectivityTableViewCell.h"
#import "UIFont+LDY.h"

@interface LDYSelectivityTableViewCell()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *selectIV;

@end

@implementation LDYSelectivityTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUp];
    }
    return self;
}

-(void)setUp{
	
	CGFloat width  = 	[JPTool screenWidth]-2*70*[JPTool WidthScale];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 11, width-20-40, 20)];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont ldy_fontFor2xPixels:28];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.titleLabel];
    
    self.selectIV = [[UIImageView alloc]initWithFrame:CGRectMake(width -  40, 11, 20, 20)];
    [self.selectIV setImage:[UIImage imageNamed:@"noselect"]];
    [self.contentView addSubview:self.selectIV];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
