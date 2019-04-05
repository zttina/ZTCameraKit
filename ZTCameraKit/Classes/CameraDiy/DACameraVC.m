//
//  DACameraVC.m
//  TechnicianApp
//
//  Created by zt on 2019/3/15.
//  Copyright © 2019年 Captain. All rights reserved.
//

#import "DACameraVC.h"
#import <AVFoundation/AVFoundation.h>
//#import <Photos/Photos.h>
//视频播放器
#import "DAPlayer.h"
#import "DAPhotoLibraryVC.h"
#import "ZTCameraKitHeader.h"
#define kInnerViewScale .4//外圈大小
#define kOuterViewScale .6//外圈大小

typedef void(^DismissPhoto)(void);
typedef void(^TakePhoto)(void);
typedef void(^ReTakePhoto)(void);
typedef void(^TakeVideo)(void);
typedef void(^FinishVideo)(void);
typedef void(^SelectPhoto)(void);
typedef void(^ShowLibrary)(void);

@interface DACameraToolView : UIView<CAAnimationDelegate>
//MARK:block操作
@property (nonatomic,copy) DismissPhoto dismissBlock;//取消这个vc页面
@property (nonatomic,copy) TakePhoto takePhotoBlock;//拍照
@property (nonatomic,copy) ReTakePhoto retakePhoto;//重拍时唤醒相机
@property (nonatomic,copy) TakeVideo takeVideoBlock;//拍摄block
@property (nonatomic,copy) FinishVideo finishVideoBlock;//结束拍摄block
@property (nonatomic,copy) SelectPhoto selectPhoto;//确认选择此照片
@property (nonatomic,copy) ShowLibrary showLibraryBlock;//调出相册


//MARK:button
@property (nonatomic,strong) UIButton *dismissBtn;//取消button
@property (nonatomic,strong) UIButton *libraryBtn;//相册的button
@property (nonatomic,strong) UIButton *cancelBtn;//照片拍完后的重拍的button
@property (nonatomic,strong) UIButton *okBtn;//照片拍完后的对勾确认button
@property (nonatomic,strong) UIView *innerView;//拍照圆button里面
@property (nonatomic,strong) UIView *outterView;//拍照圆button外面

@property (nonatomic, strong) CAShapeLayer *animateLayer;//画圆

@property (nonatomic,assign) BOOL allowVideo;

- (void)startAnimate;
@end

@implementation DACameraToolView
//MARK:初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame allowVideo:(BOOL)allowVideo{
    if (self = [super initWithFrame:frame]) {
        self.allowVideo = allowVideo;
        [self setUI];
    }
    return self;
}
//MARK:拍照的外圈layer
- (CAShapeLayer *)animateLayer {
    if (!_animateLayer) {
        
        _animateLayer = [CAShapeLayer layer];
        CGFloat width = CGRectGetWidth(self.outterView.frame)*kOuterViewScale;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, width, width) cornerRadius:width/2.0];
        _animateLayer.strokeColor = ZTgradient1.CGColor;
        _animateLayer.fillColor = [UIColor clearColor].CGColor;
        _animateLayer.path = path.CGPath;
        _animateLayer.lineWidth = 4;
        
    }
    return _animateLayer;
}
//MARK:创建UI
- (void)setUI {
    
    CGFloat innerW = self.frame.size.height * kInnerViewScale;
    CGFloat outterW = self.frame.size.height * kOuterViewScale;

    self.dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dismissBtn.frame = CGRectMake(60, self.bounds.size.height/2-25/2, 25, 25);
    [self.dismissBtn setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    [self addSubview:self.dismissBtn];
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.frame = CGRectMake((ZTSCREENW - 35*2 - 80)/2.0, self.bounds.size.height/2-35/2, 35, 35);
    [self.cancelBtn setImage:[UIImage imageNamed:@"retake"] forState:UIControlStateNormal];
    [self addSubview:self.cancelBtn];
    self.cancelBtn.hidden = YES;
    self.cancelBtn.layer.cornerRadius = 35/2.0;
    self.cancelBtn.layer.masksToBounds = YES;
    self.cancelBtn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];

    self.okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.okBtn.frame = CGRectMake(ZTSCREENW - (ZTSCREENW - 35*2 - 80)/2.0 - 35, self.bounds.size.height/2-35/2, 35, 35);
    [self.okBtn setImage:[UIImage imageNamed:@"takeok"] forState:UIControlStateNormal];
    [self addSubview:self.okBtn];
    self.okBtn.layer.cornerRadius = 35/2.0;
    self.okBtn.layer.masksToBounds = YES;
    self.okBtn.backgroundColor = [UIColor whiteColor];
    self.okBtn.hidden = YES;
    
    self.outterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, outterW, outterW)];
    [self addSubview:self.outterView];
    self.outterView.layer.cornerRadius = outterW/2.0;
    self.outterView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.9];
    self.outterView.center = CGPointMake(ZTSCREENW/2.0, self.bounds.size.height/2.0);
    
    self.innerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, innerW, innerW)];
    [self addSubview:self.innerView];
    self.innerView.layer.cornerRadius = innerW/2.0;
    self.innerView.backgroundColor = [UIColor whiteColor];
    self.innerView.center = CGPointMake(ZTSCREENW/2.0, self.bounds.size.height/2.0);
    self.innerView.userInteractionEnabled = NO;

    self.libraryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.libraryBtn];
    self.libraryBtn.frame = CGRectMake(ZTSCREENW - 60 - 30, self.bounds.size.height/2-30/2, 30, 30);
    [self.libraryBtn setImage:[UIImage imageNamed:@"library"] forState:UIControlStateNormal];
    
    [self addEvents];

}
//MARK:button点击事件
- (void)addEvents {
    [self.dismissBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn addTarget:self action:@selector(reTakePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.okBtn addTarget:self action:@selector(selectThisPhoto) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto)];
    [self.outterView addGestureRecognizer:tapGesture];
    if (self.allowVideo) {
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(takeVideo:)];
        [self.outterView addGestureRecognizer:longGesture];
        [tapGesture requireGestureRecognizerToFail:longGesture];
    }
    [self.libraryBtn addTarget:self action:@selector(showPhotoLibrary) forControlEvents:UIControlEventTouchUpInside];


}
//录像
- (void)takeVideo:(UILongPressGestureRecognizer *)longG
{
    switch (longG.state) {
        case UIGestureRecognizerStateBegan:
        {
            //此处不启动动画，由vc界面开始录制之后启动
            if (self.takeVideoBlock) {
                self.takeVideoBlock();
            }

        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            //停止动画
            [self stopAnimate];
            if (self.finishVideoBlock) {
                self.finishVideoBlock();
            }
        }
            break;
            
        default:
            break;
    }
}
//确认选择
- (void)selectThisPhoto {
    if (self.selectPhoto) {
        self.selectPhoto();
    }
}
//重拍cancelBtn事件
- (void)reTakePhoto {
    [self stopAnimate];
    if (self.retakePhoto) {
        self.retakePhoto();
    }
    [self startTaking];
    
}
//照相
- (void)takePhoto {
    [self stopAnimate];
    if (self.takePhotoBlock) {
        self.takePhotoBlock();
    }

}
//调出相册
- (void)showPhotoLibrary {
    
    if (self.showLibraryBlock) {
        self.showLibraryBlock();
    }
    
    
}
//退出照相页面
- (void)dismissVC {
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self stopAnimate];
    if (self.finishVideoBlock) {
        self.finishVideoBlock();
    }

}
#pragma mark - 动画
- (void)stopAnimate {
    if (_animateLayer) {
        [self.animateLayer removeFromSuperlayer];
        [self.animateLayer removeAllAnimations];
    }
    self.outterView.layer.transform = CATransform3DIdentity;
    self.innerView.layer.transform = CATransform3DIdentity;

    [self stopTaking];
}
- (void)startAnimate
{
    self.dismissBtn.hidden = YES;
    self.libraryBtn.hidden = YES;
    [UIView animateWithDuration:1 animations:^{
        
        self.outterView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1/kOuterViewScale, 1/kOuterViewScale, 1);
        self.innerView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.7, 0.7, 1);

    } completion:^(BOOL finished) {
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = @(0);
        animation.toValue = @(1);
        animation.duration = 5;
        animation.delegate = self;
        [self.animateLayer addAnimation:animation forKey:nil];
        
        [self.outterView.layer addSublayer:self.animateLayer];
    }];
}
//MARK:拍照或拍完页面的显示
- (void)stopTaking {
    self.outterView.hidden = YES;
    self.innerView.hidden = YES;
    self.dismissBtn.hidden = YES;
    self.libraryBtn.hidden = YES;
    self.okBtn.hidden = NO;
    self.cancelBtn.hidden = NO;
}
- (void)startTaking {
    self.outterView.hidden = NO;
    self.innerView.hidden = NO;
    self.dismissBtn.hidden = NO;
    self.libraryBtn.hidden = NO;
    self.okBtn.hidden = YES;
    self.cancelBtn.hidden = YES;
}
@end

@interface DACameraVC ()<AVCaptureFileOutputRecordingDelegate>

//底下的，拍照，确认，取消，相册，退出按钮view
@property (nonatomic,strong) DACameraToolView *toolView;
//AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic,strong) AVCaptureSession *captureSession;
//AVCaptureDeviceInput对象是输入流
@property (nonatomic,strong) AVCaptureDeviceInput *captureDeviceInput;
//照片输出流对象
@property (nonatomic,strong) AVCaptureStillImageOutput *captureImageOutput;
//视频输出对象
@property (nonatomic,strong) AVCaptureMovieFileOutput *captureMovieOutput;
//预览层
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;
//拍照view
@property (nonatomic,strong) UIImageView *takeImageView;
//拍的照片
@property (nonatomic,strong) UIImage *takeImageData;
//视频播放器
@property (nonatomic,strong) DAPlayer *playerView;
//录制视频保存的url
@property (nonatomic, strong) NSURL *videoUrl;

/**
 是否允许录像，目前仅自己设为YES
 */
@property (nonatomic,assign) BOOL allowVideo;

@end

@implementation DACameraVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allowVideo = YES;

    [self setUI];
    [self setupCamera];
    
}
- (void)setUI {
    self.toolView = [[DACameraToolView alloc]initWithFrame:CGRectMake(0, ZTSCREENH - (ZT_TAB_BAR_HEIGHT - 49) - 130, ZTSCREENW, 130) allowVideo:self.allowVideo];
    [self.view addSubview:self.toolView];
    
    @weakify(self);
    self.toolView.dismissBlock = ^{
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    self.toolView.takePhotoBlock = ^{
        @strongify(self);
        [self deleteVideo];
        [self takePhoto];
    };
    self.toolView.retakePhoto = ^{
        @strongify(self);
        self.takeImageView.hidden = YES;
        self.takeImageData = nil;
        [self deleteVideo];
        [self.captureSession startRunning];
    };
    self.toolView.selectPhoto = ^{
        @strongify(self);
        if (self.imageBlock) {
            if (self.takeImageData) {
                [self dismissViewControllerAnimated:YES completion:^{
                    @strongify(self);
                    self.imageBlock(self.takeImageData);
                }];
            }else {
                NSLog(@"没有image");
            }
        }
//        if (self.imageDataBlock) {
//            if (self.takeImageData) {
//                self.imageDataBlock(self.takeImageData);
//            }else {
//                NSLog(@"没有image");
//            }
//        }
        if (self.videoUrlBlock) {
            if (self.videoUrl) {
                self.videoUrlBlock(self.videoUrl);
            }else {
                NSLog(@"没有video");
            }
        }
    };
    self.toolView.takeVideoBlock = ^{
        @strongify(self);
        self.takeImageData = nil;
        AVCaptureConnection *movieConnection = [self.captureMovieOutput connectionWithMediaType:AVMediaTypeVideo];
        [movieConnection setVideoScaleAndCropFactor:1.0];
        if (![self.captureMovieOutput isRecording]) {
            NSURL *url = [self getVideoFileUrl];
            [self.captureMovieOutput startRecordingToOutputFileURL:url recordingDelegate:self];
        }
    };
    self.toolView.finishVideoBlock = ^{
        @strongify(self);
        [self.captureMovieOutput stopRecording];
        [self.captureSession stopRunning];
        
    };
    self.toolView.showLibraryBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            DAPhotoLibraryVC *libraryVC = [DAPhotoLibraryVC new];
            UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:libraryVC];
            @weakify(navc);
            libraryVC.imageBlock = ^(UIImage * _Nonnull image) {
                @strongify(self);
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(navc);
                    [navc dismissViewControllerAnimated:NO completion:^{
                        @strongify(self);
                        [self dismissViewControllerAnimated:NO completion:nil];
                    }];
                });
                if (self.imageBlock) {
                    self.imageBlock(image);
                }
            };
            [self presentViewController:navc animated:YES completion:nil];
        });
        
    };
    
}
- (NSURL *)getVideoFileUrl
{
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, NO).firstObject;
    filePath = [NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"1.mov"]];
    return [NSURL fileURLWithPath:filePath];
}
- (void)setupCamera {
    
    self.captureSession = [[AVCaptureSession alloc]init];
    //相机画面输入流
    self.captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[self backCamera] error:nil];
    //照片输出流
    self.captureImageOutput = [[AVCaptureStillImageOutput alloc]init];
    NSDictionary *dicOutputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [self.captureImageOutput setOutputSettings:dicOutputSettings];

    self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    self.captureMovieOutput = [[AVCaptureMovieFileOutput alloc]init];
    //将输入流添加到session
    if ([self.captureSession canAddInput:self.captureDeviceInput]) {
        [self.captureSession addInput:self.captureDeviceInput];
    }
    //将输出流添加到session
    if ([self.captureSession canAddOutput:self.captureImageOutput]) {
        [self.captureSession addOutput:self.captureImageOutput];
    }
    if ([self.captureSession canAddOutput:self.captureMovieOutput]) {
        [self.captureSession addOutput:self.captureMovieOutput];
    }
    //预览层加上
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    self.previewLayer.frame = [UIScreen mainScreen].bounds;
    
    [self.captureSession startRunning];
    
}

//MARK:拍照
- (void)takePhoto {
    
    AVCaptureConnection *connection = [self.captureImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection) {
        NSLog(@"take photo failed!");
        return;
    }
    if (!_takeImageView) {
        _takeImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        _takeImageView.backgroundColor = [UIColor blackColor];
        _takeImageView.hidden = YES;
        _takeImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view insertSubview:_takeImageView belowSubview:self.toolView];
    }
   
    @weakify(self);
    [self.captureImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        @strongify(self);
        if (imageDataSampleBuffer == NULL) {
            
            return;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [[UIImage alloc]initWithData:imageData];
        self.takeImageView.image = image;
        self.takeImageData = image;
        self.takeImageView.hidden = NO;
        [self.captureSession stopRunning];
    }];
}
//MARK:删除视频
- (void)deleteVideo
{
    if (self.videoUrl) {
        [self.playerView reset];
        self.playerView.alpha = 0;
        [[NSFileManager defaultManager] removeItemAtURL:self.videoUrl error:nil];
        self.videoUrl = nil;
    }
}
//MARK:播放视频
- (void)playVideo {
    if (!_playerView) {
        self.playerView = [[DAPlayer alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:self.playerView belowSubview:self.toolView];
    }
    self.playerView.videoUrl = self.videoUrl;
    [self.playerView play];

}
- (AVCaptureDevice *)backCamera {
    return [self getCaptureDeviceFromPosition:AVCaptureDevicePositionBack];
}
- (AVCaptureDevice *)getCaptureDeviceFromPosition:(AVCaptureDevicePosition)position {
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections
{
    //开始录制，动画出来
    [self.toolView startAnimate];
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error
{
    if (CMTimeGetSeconds(output.recordedDuration) < 1) {
        //视频长度小于1s 则拍照
        NSLog(@"视频长度小于0.5s，按拍照处理");
        [self videoHandlePhoto:outputFileURL];
        return;
    }

    self.videoUrl = outputFileURL;
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self playVideo];
    });
}

- (void)videoHandlePhoto:(NSURL *)url {
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlSet];
    imageGenerator.appliesPreferredTrackTransform = YES;    // 截图的时候调整到正确的方向
    NSError *error = nil;
    CMTime time = CMTimeMake(0,30);//缩略图创建时间 CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要获取某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actucalTime; //缩略图实际生成的时间
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actucalTime error:&error];
    if (error) {
        [self.toolView retakePhoto];
        NSLog(@"截取视频图片失败:%@",error.localizedDescription);
    }
    CMTimeShow(actucalTime);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    if (image) {
        NSLog(@"视频截取成功");
    } else {
        [self.toolView retakePhoto];
        NSLog(@"视频截取失败");
    }
    if (!_takeImageView) {
        _takeImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        _takeImageView.backgroundColor = [UIColor blackColor];
        _takeImageView.hidden = YES;
        _takeImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view insertSubview:_takeImageView belowSubview:self.toolView];
    }
    self.takeImageView.image = image;
    self.takeImageData = image;
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];


}
@end
