//
//  SmCaptcha.h
//  SmCaptcha
//
//  Created by weipingshun on 17/6/29.
//  Copyright © 2017年 shumei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

// 错误码
typedef NS_ENUM(NSUInteger, SmCaptchaCode) {
    SmCaptchaSuccess = 0,
    SMCaptchaSDKOptionEmpty = 1001,  // 调用SDK没有option为空
    SMCaptchaSDKOptionNoOrg,         // 调用SDK没有传入organization
    SMCaptchaSDKOptionNoAppId,       // 调用SDK没有传入appId
    SMCaptchaSDKNoDelegate,
    SMCaptchaWVNetworkError,         // webview加载h5页面失败
    SMCaptchaWVResultError,          // webview接收JS返回的数据格式错误
    
    SmCaptchaJSResourceError = 2001,
    SMCaptchaJSServerError,
    SMCaptchaJSOptionError,
    SmCaptchaJSInitError,
    SMCaptchaJSNetworkError
};

typedef NS_ENUM(NSUInteger, SmCaptchaMode) {
    SM_MODE_SLIDE = 0,
    SM_MODE_SELECT = 1,
    SM_MODE_SEQ_SELECT = 3,
    SM_MODE_ICON_SELECT = 4,
    SM_MODE_SPATIAL_SELECT = 5,
    SM_MODE_AUTO_SLIDE = 6
};

// 数美滑动验证码配置类
@interface SmCaptchaOption : NSObject {
}

@property(readwrite, nonatomic) NSString* organization;
@property(readwrite, nonatomic) NSString* appId;
@property(readwrite, nonatomic) NSString* deviceId;
@property(readwrite, nonatomic) NSString* channel;
@property(readwrite, nonatomic) NSString* tipMessage;
@property(readwrite, nonatomic) NSDictionary* data;
@property(readwrite, nonatomic) NSDictionary* extOption;
@property(readwrite, nonatomic) BOOL https;
@property(readwrite, nonatomic) SmCaptchaMode mode;
@property(readwrite, nonatomic) NSString* host;        //conf接口的host
@property(readwrite, nonatomic) NSString* cdnHost;     //index.html资源的host
@property(readwrite, nonatomic) NSString* captchaHtml; //index.html的url
@property(readwrite, nonatomic) NSString* captchaUuid; //sessionId,支持传入设置
@end


// 数美滑动验证码回调类
@protocol  SmCaptchaProtocol <NSObject>

@required
/**
 * 加载成功回调函数
 */
- (void)onReady;

/**
 * 处理成功回调函数
 */
 - (void)onSuccess:(NSString*) rid pass:(BOOL) pass;

/**
 * 中途出现异常回调函数
 */
- (void)onError:(NSInteger) code;

/**
 * 处理点击验证码上的的X关闭验证码的回调函数
 */
- (void)onClose;


@optional

- (void)onInitWithContent:(NSDictionary *) content;

- (void)onReadyWithContent:(NSDictionary *) content;

- (void)onSuccessWithContent:(NSDictionary *) content;

- (void)onCloseWithContent:(NSDictionary *) content;

- (void)onErrorWithContent:(NSDictionary *) content;

@end


// 数美滑动验证码View类
@interface SmCaptchaWKWebView : WKWebView

// 初始化接口，如果初始化失败，返回error非空
-(NSInteger) createWithOption: (SmCaptchaOption*)option delegate:(id<SmCaptchaProtocol>) delegate;
-(void) reloadCaptcha;

-(void) enableCaptcha;
-(void) disableCaptcha;

@end
