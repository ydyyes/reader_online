	//
	//  PersonalInfoViewController.m
	//  NightReader
	//
	//  Created by 张俊平 on 2019/5/10.
	//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
	//

#import "PersonalInfoViewController.h"
#import "PersonalInfoCell.h"
#import "VPImageCropperViewController.h"
#import "ZJPPickerView.h"

#import "FasterReader-Swift.h"

@interface PersonalInfoViewController ()<UITableViewDelegate,UITableViewDataSource,
UIActionSheetDelegate,VPImageCropperDelegate,
UIImagePickerControllerDelegate,UINavigationControllerDelegate,
UIGestureRecognizerDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
	//@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) NSMutableDictionary *titleDict;
@property (nonatomic, strong) NSMutableArray *leftTitleArray;
@property (nonatomic, strong) NSMutableArray *rightTitleArray;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong)	UITextField *textField;;
@property (nonatomic, strong) UIButton *sureBtn;
@property (nonatomic, copy  ) NSString *sexStr;
@property (nonatomic, copy  ) NSString *nickName;
@end

@implementation PersonalInfoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        //键盘通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationItem.title = @"编辑资料";

	[self createTableView];
}
-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self.textView resignFirstResponder];

}
- (void)createTableView {
    
	NSString *nickName = [JPTool USER_NAME];
	self.nickName = nickName;
    NSNumber *sexNumber = [JPTool USER_SEX];
	NSString *sex = [NSString stringWithFormat:@"%@",sexNumber];
	if ([sex isEqualToString:@"1"]) {
		sex = @"男";
		self.sexStr = @"男";
	}else if ([sex isEqualToString:@"2"]){
		sex = @"女";
		self.sexStr = @"女";
	}else {
		sex = @"保密";
		self.sexStr = @"保密";
	}
	self.leftTitleArray  = [NSMutableArray arrayWithObjects:@"头像",@"昵称",@"性别", nil];
    self.rightTitleArray = [NSMutableArray arrayWithObjects:@"",nickName,sex, nil];

	self.titleDict = [[NSMutableDictionary alloc]init];
	[self.titleDict setObject:self.leftTitleArray forKey:@"left"];
	[self.titleDict setObject:self.rightTitleArray forKey:@"right"];

    
	self.tableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenHeight]) style:UITableViewStylePlain];
	self.tableView.backgroundColor = [UIColor lightGray_F0F0F0];
	self.tableView.delegate   = self;
	self.tableView.dataSource = self;
	self.tableView.bounces = NO;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:_tableView];

	UITapGestureRecognizer *tableViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tableViewTouchInSide)];
	tableViewGesture.delegate = self;
//	tableViewGesture.numberOfTapsRequired = 1;//几个手指点击
//	tableViewGesture.cancelsTouchesInView = NO;//是否取消点击处的其他action
	[self.tableView addGestureRecognizer:tableViewGesture];


}

- (void)tableViewTouchInSide {
		// ------结束编辑，隐藏键盘
	[self.textField resignFirstResponder];
	[self.textView resignFirstResponder];
	[self.view endEditing:YES];
	[self.tableView endEditing:YES];
}

#pragma mark - TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		return 90.f;
	}else{
		return 44.f;
	}

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PersonalInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:PersonalInfoCell_Identifier];
	if (!cell) {
		cell = [[PersonalInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PersonalInfoCell_Identifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	[cell setCellData:self.titleDict AtIndexPath:indexPath];
	if (indexPath.row ==1) {
		[cell.contentView addSubview:self.textView];
	}
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

	if (indexPath.row == 0) {
		[self changeImgVClick];
	} else if (indexPath.row == 1) {
		[self.textView becomeFirstResponder];
		self.nickName = self.rightTitleArray[indexPath.row];
	} else {
		[self.textView resignFirstResponder];
		[self.textField resignFirstResponder];
		[self.view endEditing:YES];
		[[ZJPPickerView shareAlert] setResultArr:@[@"男",@"女",@"保密"] withType:@"1" selectIndex:self.rightTitleArray.lastObject withSureBlock:^(NSString * _Nonnull nameStr, NSString * _Nonnull idStr) {

			NSMutableDictionary *dict = [NSMutableDictionary new];
			if ([nameStr isEqualToString:@"男"]) {
				[dict setValue:@"1" forKey:@"sex"];
			}else if ([nameStr isEqualToString:@"女"]){
				[dict setValue:@"2" forKey:@"sex"];
			}else {
				[dict setValue:@"-1" forKey:@"sex"];
			}
			self.sexStr = nameStr;
			[self uploadInfo:dict];//修改性别

		} withCancelClick:^{
		}];

	}
}
#pragma mark - lazy
- (UITextView *)textView {
	if (!_textView) {

		self.toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], 50)];
//		self.toolbar.backgroundColor = [UIColor redColor];

		UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(15, 5, 200, 40)];
		self.textField = textField;
		self.textField.placeholder = @"请输入";
		self.textField.delegate = self;
		[self.toolbar addSubview:self.textField];

		UIView *btnback = [[UIView alloc]initWithFrame:CGRectMake( [JPTool screenWidth]-70, 0, 60, 50)];
		self.sureBtn = [[UIButton alloc]initWithFrame:CGRectMake( 0, 5, 60, 40)];
		[btnback addSubview:self.sureBtn];
		[self.sureBtn setTitle:@"确定" forState:UIControlStateNormal];
		[self.sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.sureBtn addTarget:self action:@selector(sureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
		self.sureBtn.backgroundColor = [UIColor buttonHigh];
		self.sureBtn.layer.cornerRadius = 5;
		self.sureBtn.layer.masksToBounds = YES;

		UIBarButtonItem *finish = [[UIBarButtonItem alloc]initWithCustomView:btnback];
		UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil	action:nil];
		space.width = 100;
		self.toolbar.items = @[space,finish];

		_textView = [[UITextView alloc]initWithFrame:CGRectMake([JPTool screenWidth]-100, 5, 0, 30)];
		_textView.inputAccessoryView = _toolbar;
		_textView.backgroundColor = [UIColor redColor];
	}
	return _textView;
}
#pragma mark - 修改昵称
	//MARK: 输入框确定按钮
- (void)sureButtonClick:(UIButton*)sender {

	[self.textView resignFirstResponder];
	[self.textField resignFirstResponder];
	[self.view endEditing:YES];

	NSMutableDictionary *dict = [NSMutableDictionary new];
	[dict setValue:self.textField.text forKey:@"nickname"];
	if (self.textField.text.length > 7) {
		[ZJPAlert showAlertWithMessage:@"昵称长度不能超过7个字符" time:1.0];
		return;
	}
	[self uploadInfo:dict];//修改性别


}
- (BOOL)canBecomeFirstResponder {
	if (self.textField.resignFirstResponder&&self.textView.resignFirstResponder) {
		return NO;
	}
	return YES;
}
#pragma mark - 键盘显示、隐藏
	//键盘高度
- (void)keyboardWillShow:(NSNotification *)notification {
	[self.textField becomeFirstResponder];
	self.textField.text = self.nickName;
}
- (void)keyboardWillHide:(NSNotification *)notification {
	[self.textView resignFirstResponder];
	[self.textField resignFirstResponder];
	self.sureBtn.backgroundColor = [UIColor buttonHigh];
}
#pragma mark - - UITextField
- (void)textFieldDidBeginEditing:(UITextField *)textField {

}
- (void)textFieldDidChange:(UITextField*)textField {
	if (self.textField.text.length > 0) {
		self.sureBtn.backgroundColor = [UIColor buttonNor];
		self.sureBtn.userInteractionEnabled = YES;
	}else{
		self.sureBtn.backgroundColor = [UIColor buttonHigh];
		self.sureBtn.userInteractionEnabled = NO;
	}

}
#pragma mark - -- 修改头像
- (void)changeImgVClick {

	[self.textView resignFirstResponder];
	[self.textField resignFirstResponder];
	[self.toolbar resignFirstResponder];
	[self.view endEditing:YES];

    
    [ZJPAlert showAlertWithMessage:@"该功能已暂时关闭" time: 1.5];

    return;
    
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	[alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		NSLog(@"点击拍照");

		if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
			UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"此设备无照相功能" message:nil preferredStyle:UIAlertControllerStyleAlert];
			[alertController addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
				NSLog(@"点击");
			}]];
			[self presentViewController:alertController animated:YES completion:nil];

		}else{
			AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
			if(authStatus == AVAuthorizationStatusAuthorized) {
				picker.sourceType = UIImagePickerControllerSourceTypeCamera;
				NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
				[mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
				picker.mediaTypes = mediaTypes;
				picker.sourceType = picker.sourceType;
				picker.delegate   = self;
				picker.allowsEditing = NO;
				[self presentViewController:picker animated:NO completion:^{
					[UIApplication sharedApplication].statusBarHidden = YES;
				}];
			}
			else if (authStatus == AVAuthorizationStatusDenied){
				UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"提示" message:@"尚未开启相机权限,您可以去设置->隐私 开启" preferredStyle:(UIAlertControllerStyleAlert)];
				UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
				UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
					[[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
				}];

				[alert addAction:cancelAction];
				[alert addAction:okAction];
				[self presentViewController:alert animated:YES completion:nil];
				return;
			}
			else if (authStatus == AVAuthorizationStatusNotDetermined) {
				[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
					if (granted == YES) {
						picker.sourceType = UIImagePickerControllerSourceTypeCamera;
						NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
						[mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
						picker.mediaTypes = mediaTypes;
						picker.sourceType = picker.sourceType;
						picker.delegate   = self;
						picker.allowsEditing = NO;
						[self presentViewController:picker animated:NO completion:^{
							[UIApplication sharedApplication].statusBarHidden = YES;
						}];
					} else {
					}
				}];
			}

		}

	}]];

	[alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		NSLog(@"点击取消");
	}]];
	[alertController addAction:[UIAlertAction actionWithTitle:@"从相册中选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		NSLog(@"点击从相册中选取");
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
		[mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
		picker.mediaTypes = mediaTypes;
		picker.sourceType = picker.sourceType;
		picker.delegate   = self;
		picker.allowsEditing = NO;
		[self presentViewController:picker animated:NO completion:nil];
	}]];

	[self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

	[UIApplication sharedApplication].statusBarHidden = NO;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

	if (![ZJPNetWork netWorkAvailable]) {
		[picker dismissViewControllerAnimated:NO completion:^{
			[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		}];
		return;
	}
	[picker dismissViewControllerAnimated:YES completion:^() {
		UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
		portraitImg = [self imageByScalingToMaxSize:portraitImg];
			// 裁剪
		VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, ([JPTool screenHeight]-50-self.view.frame.size.width)/2, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
		imgEditorVC.delegate = self;
		[self presentViewController:imgEditorVC animated:NO completion:nil];
	}];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
	[UIApplication sharedApplication].statusBarHidden = NO;
	[picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -- image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {

	if (sourceImage.size.width < [JPTool screenWidth]) return sourceImage;
	CGFloat btWidth  = 0.0f;
	CGFloat btHeight = 0.0f;
	if (sourceImage.size.width > sourceImage.size.height) {
		btHeight = [JPTool screenWidth];
		btWidth  = sourceImage.size.width * ([JPTool screenWidth] / sourceImage.size.height);
	} else {
		btWidth  = [JPTool screenWidth];
		btHeight = sourceImage.size.height * ([JPTool screenWidth] / sourceImage.size.width);
	}
	CGSize targetSize = CGSizeMake(btWidth, btHeight);
	return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {

	UIImage *newImage = nil;
	CGSize imageSize  = sourceImage.size;
	CGFloat width  = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth  = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor  = 0.0;
	CGFloat scaledWidth  = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
		CGFloat widthFactor  = targetWidth / width;
		CGFloat heightFactor = targetHeight / height;

		if (widthFactor > heightFactor)
			scaleFactor = widthFactor; // scale to fit height
		else
			scaleFactor = heightFactor; // scale to fit width
		scaledWidth  = width * scaleFactor;
		scaledHeight = height * scaleFactor;

			// center the image
		if (widthFactor > heightFactor) {
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
		}
		else if (widthFactor < heightFactor) {
			thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
		}

	}
	UIGraphicsBeginImageContext(targetSize); // this will crop
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;

	[sourceImage drawInRect:thumbnailRect];

	newImage = UIGraphicsGetImageFromCurrentImageContext();
	if(newImage == nil){
	}else {
		UIGraphicsEndImageContext();
	}
	return newImage;
}

#pragma mark -- VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
		//图像压缩
		//    editedImage = [FileMgr scaleToSize:editedImage width:800];
	float size = 1.0f;
	while ([UIImageJPEGRepresentation(editedImage, size) length]/1024 > 500) {
		size-= 0.5;
		editedImage = [UIImage imageWithData:UIImageJPEGRepresentation(editedImage, size)];
	}
		//把图片转换成imageDate格式
	NSData *imageData = [[NSData alloc]init];
	imageData = UIImageJPEGRepresentation(editedImage, 1.0f);
	[self performSelector:@selector(saveImg:) withObject:imageData afterDelay:0.8];
	[UIApplication sharedApplication].statusBarStyle  = UIStatusBarStyleLightContent;
	[cropperViewController dismissViewControllerAnimated:NO completion:^{
			// TO DO
	}];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
	[UIApplication sharedApplication].statusBarStyle  = UIStatusBarStyleLightContent;
	[cropperViewController dismissViewControllerAnimated:NO completion:^{

	}];
}
#pragma mark -上传头像方法
- (void)saveImg:(NSData *)imageData {

	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		return;
	}
	[SVProgressHUD showWithStatus:@"数据上传中..."];
	[[JPNetWork sharedManager] requestPostUploadImageWithImageData:imageData Success:^(id responseObject) {
		
        [SVProgressHUD dismiss];

		if ([responseObject[@"errorno"] integerValue] ==200 ) {
			
			[[NSUserDefaults standardUserDefaults] setObject:imageData forKey:@"avatar"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			[ZJPAlert showAlertWithMessage:@"上传成功" time:1.5];
			UIImage *img = [UIImage imageWithData:imageData];
			[self.titleDict setValue:img forKey:@"headImg"];
			[self.tableView reloadData];
        }else{
            [ZJPAlert showAlertWithMessage:responseObject[@"msg"] time: 1.5];
        }
	} failure:^(NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"数据上传失败"];
	}];
}
#pragma mark -上传 用户信息
- (void)uploadInfo:(NSMutableDictionary*)dict {

	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		return;
	}
	[SVProgressHUD showWithStatus:@"数据上传中..."];
	[[JPNetWork sharedManager] requestPostUploadInfoWithParamsDict:dict Success:^(id responseObject) {

		if ([responseObject[@"errorno"] integerValue] <=200 ) {

			[ZJPAlert showAlertWithMessage:@"上传成功" time:1.5];
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];

			if ([dict containsObjectForKey:@"sex"]) {// 性别

				indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
				[[NSUserDefaults standardUserDefaults] setObject:dict[@"sex"] forKey:@"gender"];
				[self.rightTitleArray replaceObjectAtIndex:self.rightTitleArray.count-1 withObject:self.sexStr];// 改变数据源

			}else {

				indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
				[[NSUserDefaults standardUserDefaults] setObject:dict[@"nickname"] forKey:@"username"];// 昵称
				[self.rightTitleArray replaceObjectAtIndex:1 withObject:self.textField.text];
			}

			[[NSUserDefaults standardUserDefaults] synchronize];
			[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];// 刷新cell
		}
		[SVProgressHUD dismiss];

	} failure:^(NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"数据上传失败"];
	}];
}
#pragma mark - 手势代理  解决点击cell不响应问题
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
	if (touch.view != self.tableView) {
		return NO;
	}
	return YES;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[self.textView resignFirstResponder];
}

@end
