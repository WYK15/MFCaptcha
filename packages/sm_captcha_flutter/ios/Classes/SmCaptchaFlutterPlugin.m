#import "SmCaptchaFlutterPlugin.h"
#import <SmCaptcha/SmCaptchaWebView.h>

static FlutterMethodChannel* _channelToDart;

@implementation SmCaptchaFlutterPlugin
{
    UIView *_currentCaptchaBackgroungView;
    SmCaptchaWKWebView *_currentSmCaptchaview;
    SmCaptchaOption *_currentSmCaptchaOption;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    _channelToDart = [FlutterMethodChannel
      methodChannelWithName:@"captchachannel"
            binaryMessenger:[registrar messenger]];

    SmCaptchaFlutterPlugin *instance = [[SmCaptchaFlutterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:_channelToDart];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
      
  } else if ([@"showFlutterDialog" isEqualToString:call.method]) {
    NSDictionary *arguments = (NSDictionary *) [call arguments];
    if (arguments) {
        BOOL canceledOnTouchOutside = [arguments[@"canceledOnTouchOutside"] boolValue];
        SmCaptchaOption *option = _currentSmCaptchaOption;
        if(option.mode == SM_MODE_AUTO_SLIDE) {
            [self showFlutterDialog:_currentSmCaptchaview disapperAfterClickBlank:canceledOnTouchOutside heightWidthRatio:2.0/15];
            return;
        }
        if([option.extOption[@"style"][@"withTitle"] boolValue]){
            [self showFlutterDialog:_currentSmCaptchaview disapperAfterClickBlank:canceledOnTouchOutside heightWidthRatio:5.0/6];
        }else {
            [self showFlutterDialog:_currentSmCaptchaview disapperAfterClickBlank:canceledOnTouchOutside heightWidthRatio:2.0/3];
        }
    }
  }else if([@"load" isEqualToString:call.method]){
    NSDictionary *arguments = (NSDictionary *) [call arguments];
    if (arguments) {
        NSDictionary *creationParams = (NSDictionary *)arguments[@"creationParams"];

        _currentSmCaptchaview = [[SmCaptchaWKWebView alloc] init];
        _currentSmCaptchaOption = [self optionWithArg:creationParams];
        NSInteger code = [_currentSmCaptchaview createWithOption:_currentSmCaptchaOption delegate:self];
        if (code == SmCaptchaSuccess) {
            NSLog(@"SmCaptchaWKWebView create succeed");
        }
    }
  }else if ([@"dismissDialog" isEqualToString:call.method]) {
      [self dismissDialogBackgroundView];
  }
}

-(void) dismissDialogBackgroundView {
    [_currentCaptchaBackgroungView removeFromSuperview];
}

-(void) showFlutterDialog:(UIView *) webView disapperAfterClickBlank:(BOOL) disapperAfterClickBlank  heightWidthRatio:(float) heightWidthRatio{
    
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    CGFloat popupWidth, popupHeight;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    popupWidth = (UIInterfaceOrientationIsPortrait(orientation) ? CGRectGetWidth(rootViewController.view.bounds) :CGRectGetHeight(rootViewController.view.bounds)) * 0.8;
    popupHeight = popupWidth * heightWidthRatio;
    
    // 添加透明背景视图
    UIView *backgroundView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
    backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup:)];
    
    // 添加透明背景的手势
    if (disapperAfterClickBlank){
        [backgroundView addGestureRecognizer:tapGestureRecognizer];
    }else {
        [backgroundView removeGestureRecognizer:tapGestureRecognizer];
    }
    
    // 记录,dismiss时使用
    _currentCaptchaBackgroungView = backgroundView;
        
    // 添加弹窗视图
    UIView *popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, popupWidth, popupHeight)];
    popupView.backgroundColor = [UIColor clearColor];
    //popupView.layer.cornerRadius = 5;
    popupView.layer.masksToBounds = YES;
    
    [popupView addSubview:webView];
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [webView.centerXAnchor constraintEqualToAnchor:popupView.centerXAnchor],
        [webView.centerYAnchor constraintEqualToAnchor:popupView.centerYAnchor],
        [webView.widthAnchor constraintEqualToAnchor:popupView.widthAnchor],
        [webView.heightAnchor constraintEqualToAnchor:popupView.heightAnchor]
    ]];
    
        
    [backgroundView addSubview:popupView];
    popupView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [popupView.centerXAnchor constraintEqualToAnchor:backgroundView.centerXAnchor],
        [popupView.centerYAnchor constraintEqualToAnchor:backgroundView.centerYAnchor],
        [popupView.widthAnchor constraintEqualToConstant:popupWidth],
        [popupView.heightAnchor constraintEqualToConstant:popupHeight]
    ]];
    
    
    [rootViewController.view addSubview:backgroundView];
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    [mainWindow addSubview:backgroundView];
    [mainWindow bringSubviewToFront:backgroundView];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [backgroundView.leadingAnchor constraintEqualToAnchor:rootViewController.view.leadingAnchor],
        [backgroundView.trailingAnchor constraintEqualToAnchor:rootViewController.view.trailingAnchor],
        [backgroundView.topAnchor constraintEqualToAnchor:rootViewController.view.topAnchor],
        [backgroundView.bottomAnchor constraintEqualToAnchor:rootViewController.view.bottomAnchor]
    ]];
    
    [rootViewController.view layoutIfNeeded];
}

- (void)dismissPopup:(UITapGestureRecognizer *)recognizer {
    UIView *popupView = recognizer.view;
    [popupView removeFromSuperview];
}


-(SmCaptchaOption *) optionWithArg:(id _Nullable) args
{
    SmCaptchaOption *option = [[SmCaptchaOption alloc] init];
    if ([args objectForKey:@"organization"]) {
        [option setOrganization:args[@"organization"]];
    }
    
    if ([args objectForKey:@"appId"]) {
        [option setAppId:args[@"appId"]];
    }
    
    if ([args objectForKey:@"deviceId"]) {
        [option setDeviceId:args[@"deviceId"]];
    }
    
    if ([args objectForKey:@"channel"]) {
        [option setChannel:args[@"channel"]];
    }
    
    if ([args objectForKey:@"tipMessage"]) {
        [option setTipMessage:args[@"tipMessage"]];
    }
    
    if ([args objectForKey:@"data"]) {
        [option setData:args[@"data"]];
    }
    
    if ([args objectForKey:@"extOption"]) {
        [option setExtOption:args[@"extOption"]];
    }
    
    if ([args objectForKey:@"https"]) {
        [option setHttps:args[@"https"]];
    }
    
    if ([args objectForKey:@"mode"]) {
        NSString *mode = args[@"mode"];
        if ([mode isEqualToString:@"slide"]) {
            [option setMode:SM_MODE_SLIDE];
        }else if([mode isEqualToString:@"select"]) {
            [option setMode:SM_MODE_SELECT];
        }else if([mode isEqualToString:@"seq_select"]) {
            [option setMode:SM_MODE_SELECT];
        }else if([mode isEqualToString:@"icon_select"]) {
            [option setMode:SM_MODE_ICON_SELECT];
        }else if([mode isEqualToString:@"spatial_select"]) {
            [option setMode:SM_MODE_SPATIAL_SELECT];
        }else if ([mode isEqualToString:@"auto_slide"]) {
            [option setMode:SM_MODE_AUTO_SLIDE];
        }
    }
    
    if ([args objectForKey:@"host"]) {
        [option setHost:args[@"host"]];
    }
    
    if ([args objectForKey:@"cdnHost"]) {
        [option setCdnHost:args[@"cdnHost"]];
    }

    if ([args objectForKey:@"captchaHtml"]) {
        [option setCaptchaHtml:args[@"captchaHtml"]];
    }
    
    if ([args objectForKey:@"captchaUuid"]) {
        [option setCaptchaUuid:args[@"captchaUuid"]];
    }

    return option;
}


- (void)onReady {
    [_channelToDart invokeMethod:@"onReady" arguments:nil];
}

- (void)onSuccess:(NSString *)rid pass:(BOOL)pass{
    [_channelToDart invokeMethod:@"onSuccess" arguments:@{@"rid":rid,@"pass":@(pass)}];
}


- (void)onError:(NSInteger)code{
    [_channelToDart invokeMethod:@"onError" arguments:@{@"errCode":@(code)}];
}

- (void)onClose {
    [_channelToDart invokeMethod:@"onClose" arguments:nil];
    [self dismissDialogBackgroundView];
}

- (void)onInitWithContent:(NSDictionary *)content {
    [_channelToDart invokeMethod:@"onInitWithContent" arguments:content];
}

- (void)onReadyWithContent:(NSDictionary *)content {
    [_channelToDart invokeMethod:@"onReadyWithContent" arguments:content];
}

- (void)onSuccessWithContent:(NSDictionary *)content {
    [_channelToDart invokeMethod:@"onSuccessWithContent" arguments:content];
}

- (void)onCloseWithContent:(NSDictionary *)content {
    [_channelToDart invokeMethod:@"onCloseWithContent" arguments:content];
}

- (void)onErrorWithContent:(NSDictionary *)content {
    [_channelToDart invokeMethod:@"onErrorWithContent" arguments:content];
}

@end
