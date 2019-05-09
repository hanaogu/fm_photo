#import <Flutter/Flutter.h>
#include "FmPhotoPluginImp.h"
#import "TZImagePickerController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface FmPhotoPluginImpDel: NSObject<UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate>
-(void)cameraPhoto:(NSMutableDictionary *)arg result:(FlutterResult)result;
-(void)pickPhoto:(NSMutableDictionary *)arg result:(FlutterResult)result;
@end

@implementation FmPhotoPluginImpDel{
    UIViewController *topRootViewController;
    FlutterResult _result;
//    NSString* _path;
    NSMutableDictionary* params;
    NSFileManager* fileManager;
}
-(void)pickPhoto:(NSMutableDictionary *)arg result:(FlutterResult)result{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        params = [[NSMutableDictionary alloc] init];
        _result = result;
        params[@"path"] = [arg objectForKey:@"path"];
        // 最大可选数,每行显示个数
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc]
                                                  initWithMaxImagesCount:[[arg objectForKey:@"max"] integerValue] columnNumber:[[arg objectForKey:@"spanCount"] integerValue] delegate:self];
        // You can get the photos by block, the same as by delegate.
        // 你可以通过block或者代理，来得到用户选择的照片.
//        [imagePickerVc setDidFinishPickingPhotosWithInfosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto, NSArray<NSDictionary *> *infos) {
    //        NSMutableArray<NSMutableDictionary*>* array = [[NSMutableArray alloc] init];
    //        for (int i=0; i<infos.count; i++){
    //            // 转换为UTF-8编码 - 去除 file://
//                NSString *path = [NSString stringWithCString:[[infos[i] valueForKey:@"PHImageFileURLKey"] fileSystemRepresentation] encoding:NSUTF8StringEncoding];
//                NSString *duration = [NSString stringWithFormat:@"%@",[assets[i] valueForKey:@"duration"]];
//                NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys: path ,@"path",
//                                             duration, @"duration", nil];
//                [array addObject:dict];
    //        }
    //        result(array);
//        }];
        // 在内部显示拍照按钮
        imagePickerVc.allowTakePicture = [[arg objectForKey:@"enableCamera"] boolValue] && ([[arg objectForKey:@"openGallery"] integerValue] == 1 || [[arg objectForKey:@"openGallery"] integerValue] == 0);
        // 在内部显示拍视频按
        imagePickerVc.allowTakeVideo = [[arg objectForKey:@"enableCamera"] boolValue] && ([[arg objectForKey:@"openGallery"] integerValue] == 2 || [[arg objectForKey:@"openGallery"] integerValue] == 0);
        // 允许选择图片
        imagePickerVc.allowPickingImage = [[arg objectForKey:@"openGallery"] integerValue] == 1 || [[arg objectForKey:@"openGallery"] integerValue] == 0;
        // 允许选择视频
        imagePickerVc.allowPickingVideo = [[arg objectForKey:@"openGallery"] integerValue] == 2 || [[arg objectForKey:@"openGallery"] integerValue] == 0;
        // 允许选择原图(是否不进行压缩)
        imagePickerVc.allowPickingOriginalPhoto = ![[arg objectForKey:@"enableCompress"] boolValue];
        // 允许选择gif
        imagePickerVc.allowPickingGif = [[arg objectForKey:@"enableGif"] integerValue];
        // 是否可以多选视频
        imagePickerVc.allowPickingMultipleVideo = [[arg objectForKey:@"max"] integerValue] > 1;
        // 是否裁剪
        imagePickerVc.allowCrop = [[arg objectForKey:@"enableCrop"] boolValue];
        // 是否圆形裁剪
        imagePickerVc.needCircleCrop = [[arg objectForKey:@"enableCircleDimmedLayer"] boolValue];
        // 录像时间
        imagePickerVc.videoMaximumDuration = [[arg objectForKey:@"recordVideoSecond"] integerValue];
        
        topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topRootViewController.presentedViewController)
        {
            topRootViewController = topRootViewController.presentedViewController;
        }
        
        [topRootViewController presentViewController:imagePickerVc animated:YES completion:nil];
    }
}

-(void)cameraPhoto:(NSMutableDictionary *)arg result:(FlutterResult)result{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        params = [[NSMutableDictionary alloc] init];
        _result = result;
        params[@"path"] = [arg objectForKey:@"path"];
        params[@"saveGallery"] = [arg objectForKey:@"saveGallery"];
        
        UIImagePickerController *imagePickerVc = [[UIImagePickerController alloc] init];
        
        UIImagePickerControllerSourceType source_type = UIImagePickerControllerSourceTypeCamera;
        imagePickerVc.sourceType = source_type;
        NSMutableArray *mediaTypes = [NSMutableArray array];
        if ([[arg objectForKey:@"openCamera"] integerValue] == 2) {
            [mediaTypes addObject:(NSString *)kUTTypeMovie];
            imagePickerVc.mediaTypes = mediaTypes;
            imagePickerVc.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
            imagePickerVc.videoMaximumDuration = 60;
            if ([arg objectForKey:@"duration"] != nil && [[arg objectForKey:@"duration"] doubleValue] > 0) {
                imagePickerVc.videoMaximumDuration = [[arg objectForKey:@"duration"] doubleValue];
            }
            
            imagePickerVc.videoQuality = UIImagePickerControllerQualityTypeHigh;
            if ([arg objectForKey:@"quality"] != nil && [arg objectForKey:@"quality"] == 0) {
                imagePickerVc.videoQuality = UIImagePickerControllerQualityTypeLow;
            }else{
                imagePickerVc.videoQuality = UIImagePickerControllerQualityTypeHigh;
            }
        }
        if ([[arg objectForKey:@"openCamera"] integerValue] == 1) {
            [mediaTypes addObject:(NSString *)kUTTypeImage];
            imagePickerVc.mediaTypes = mediaTypes;
            imagePickerVc.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        }
        imagePickerVc.delegate = self;
        imagePickerVc.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        imagePickerVc.allowsEditing = NO;
        
        topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topRootViewController.presentedViewController)
        {
            topRootViewController = topRootViewController.presentedViewController;
        }
        imagePickerVc.navigationBar.barTintColor = topRootViewController.navigationController.navigationBar.barTintColor;
        imagePickerVc.navigationBar.tintColor = topRootViewController.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (@available(iOS 9, *)) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
        
        [topRootViewController presentViewController:imagePickerVc animated:YES completion:nil];
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSMutableDictionary* nd = [[NSMutableDictionary alloc] init];
    if ([[info valueForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        NSString* toUrl = [self imagePath];
        
        NSData *imageData = UIImageJPEGRepresentation(image, 1); // 1为不缩放保存,取值为(0~1)
        // 将照片写入文件
        if ([imageData writeToFile:toUrl atomically:NO]) {
            nd[@"path"] = toUrl;
            _result(nd);
        }else{
            NSLog(@"save image error");
            _result(false);
        }
        
        if(params[@"saveGallery"]){
            // save photo and get asset / 保存图片，获取到asset
            [[TZImageManager manager] savePhotoWithImage:image completion:^(PHAsset *asset, NSError *error){
                if (error) {
                    NSLog(@"图片保存失败 %@",error);
                } else {
                    NSLog(@"图片保存成功");
                }
            }];
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
    }else{
        // 获得视频的URL - 此时视频在temp文件夹
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        
        fileManager = [NSFileManager defaultManager];
        
        NSString* toUrl = [self videoPath];
        // 转换为UTF-8编码 - 去除 file://
        NSString *targetPath = [NSString stringWithCString:[videoUrl fileSystemRepresentation] encoding:NSUTF8StringEncoding];
        
        if (videoUrl) {
            if(params[@"saveGallery"]){
                [[TZImageManager manager] saveVideoWithUrl:videoUrl completion:^(PHAsset *asset, NSError *error) {
                    if (error) {
                        NSLog(@"视频保存失败 %@",error);
                    } else {
                        NSLog(@"视频保存成功");
                    }
                }];
            }
            if ([fileManager copyItemAtPath:targetPath toPath:toUrl error:nil]) {
                [fileManager removeItemAtPath:targetPath error:nil];
                nd[@"path"] = toUrl;
                _result(nd);
            } else if ([fileManager moveItemAtPath:targetPath toPath:toUrl error:nil]){
                nd[@"path"] = toUrl;
                _result(nd);
            } else {
                NSLog(@"save video error");
                _result(false);
            }
        }else{
            NSLog(@"save video error");
            _result(false);
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos{
    NSMutableArray<NSMutableDictionary*>* array = [[NSMutableArray alloc] init];
    for (int i=0; i<photos.count; i++){
        NSString *toUrl;
        NSString *fileName = [[assets[i] valueForKey:@"filename"] stringByDeletingPathExtension];
        NSInteger mediaType = [[assets[i] valueForKey: @"mediaType"] integerValue];
        // 视频:mediaType=2; 图片:mediaType=1;
        if(mediaType == 2){
            params[@"path"] = [NSString stringWithFormat:@"%@.mp4", fileName];;
            toUrl = [self videoPath];
            [[TZImageManager manager] getVideoOutputPathWithAsset:assets[i] presetName:AVAssetExportPreset640x480 success:^(NSString *outputPath) {
                [self->fileManager moveItemAtPath:outputPath toPath:toUrl error:nil];
                NSLog(@"视频导出到本地完成,沙盒路径为:%@",toUrl);
            } failure:^(NSString *errorMessage, NSError *error) {
                NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
            }];
        }else if(mediaType == 1){
            params[@"path"] = [NSString stringWithFormat:@"%@.jpg", fileName];;
            toUrl = [self imagePath];
            [fileManager createFileAtPath:toUrl contents:UIImageJPEGRepresentation(photos[i], 1.0f) attributes:nil];
        }
        
        NSString *duration = [NSString stringWithFormat:@"%@",[assets[i] valueForKey:@"duration"]];
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys: toUrl ,@"path",
                                     duration, @"duration", nil];
        [array addObject:dict];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    _result(array);
}
-(void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset{
    NSString *toUrl;
    NSString *fileName = [[asset valueForKey:@"filename"] stringByDeletingPathExtension];
    params[@"path"] = [NSString stringWithFormat:@"%@.mp4", fileName];;
    toUrl = [self videoPath];
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPreset640x480 success:^(NSString *outputPath) {
        [self->fileManager moveItemAtPath:outputPath toPath:toUrl error:nil];
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",toUrl);
    } failure:^(NSString *errorMessage, NSError *error) {
        NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
    }];
    NSMutableArray<NSMutableDictionary*>* array = [[NSMutableArray alloc] init];
    NSString *duration = [NSString stringWithFormat:@"%@",[asset valueForKey:@"duration"]];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys: toUrl ,@"path",
                                 duration, @"duration", nil];
    [array addObject:dict];
    [picker dismissViewControllerAnimated:YES completion:nil];
    _result(array);
}

-(NSString *)imagePath{
    fileManager = [NSFileManager defaultManager];
    NSString* basePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"attachment"];
    if (![fileManager fileExistsAtPath:basePath]) {
        [fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* toUrl = [NSString stringWithFormat:@"%@/%@",basePath,params[@"path"] ?: @""];
    if (![[toUrl lastPathComponent] containsString:@"."]) {
        toUrl = [[toUrl stringByAppendingString:[@"/" stringByAppendingString:[NSUUID UUID].UUIDString]] stringByAppendingString:@".jpg"];
    }
    if (![fileManager fileExistsAtPath:toUrl]) {
        [fileManager createDirectoryAtPath:[toUrl stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return toUrl;
}
-(NSString *)videoPath{
    fileManager = [NSFileManager defaultManager];
    NSString* basePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"attachment"];
    if (![fileManager fileExistsAtPath:basePath]) {
        [fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* toUrl = [NSString stringWithFormat:@"%@/%@",basePath,params[@"path"] ?: @""];
    if (![[toUrl lastPathComponent] containsString:@"."]) {
        toUrl = [[toUrl stringByAppendingString:[@"/" stringByAppendingString:[NSUUID UUID].UUIDString]] stringByAppendingString:@".mp4"];
    }
    if (![fileManager fileExistsAtPath:toUrl]) {
        [fileManager createDirectoryAtPath:[toUrl stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return toUrl;
}

@end

@interface FmPhotoPluginImp() <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@end

@implementation FmPhotoPluginImp{
    NSObject<FlutterPluginRegistrar>* _registrar;
    FmPhotoPluginImpDel*p;
}

-(id)initWithRegist:(NSObject<FlutterPluginRegistrar>*)registrar{
    _registrar = registrar;
    p = [[FmPhotoPluginImpDel alloc] init];
    return self;
}

-(void)pickPhoto:(NSMutableDictionary *)arg result:(FlutterResult)result{
    [p pickPhoto:arg result:result];
}

-(void)cameraPhoto:(NSMutableDictionary *)arg result:(FlutterResult)result{
    [p cameraPhoto:arg result:result];
}

-(void)getThumbnail:(NSMutableDictionary *)arg result:(FlutterResult)result{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* path = [arg objectForKey:@"path"];
    NSString* namePath = [[[path lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"jpg"];
    NSString* basePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"attachment"];
    if (![fileManager fileExistsAtPath:basePath]) {
        [fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    namePath = [basePath stringByAppendingPathComponent:namePath];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys: p ,@"path", nil];
    if ([fileManager fileExistsAtPath:namePath]) {
        result(dict);
        return;
    }
    NSURL* url;
    if ([path hasPrefix:@"/"]) {
        if (![fileManager fileExistsAtPath:path]) {
            NSLog(@"%@",@"getThumbnail err: file not found");
            result(false);
            return;
        }
        url = [NSURL fileURLWithPath:path];
    }else{
        url = [NSURL URLWithString:path];
    }
    AVURLAsset* asset = [AVURLAsset assetWithURL:url];
    AVAssetImageGenerator* generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0, 600);
    [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:time]] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult i_result, NSError * _Nullable error) {
        if (i_result == AVAssetImageGeneratorSucceeded) {
            if (error) {
                NSLog(@"%@",error.description);
                return;
            }
            UIImage* jpg = [[UIImage alloc] initWithCGImage:image];
            NSData* data = UIImageJPEGRepresentation(jpg, 100);
            [data writeToFile:namePath atomically:YES];
            result(dict);
            return;
        }
        result(false);
    }];
}
@end
