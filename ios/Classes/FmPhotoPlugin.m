#import "FmPhotoPlugin.h"
#import "FmToolsBase.h"
#include "FmPhotoPluginImp.h"
@implementation FmPhotoPlugin

static FmPhotoPluginImp* _imp;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"fm_photo"
            binaryMessenger:[registrar messenger]];
  FmPhotoPlugin* instance = [[FmPhotoPlugin alloc] init];
    
    _imp = [[[FmPhotoPluginImp alloc] init] initWithRegist:registrar];
    
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ( [FmToolsBase onMethodCall:_imp method:call.method arg:call.arguments result:result]){
        return;
    }
    result(FlutterMethodNotImplemented);
    
}

@end
