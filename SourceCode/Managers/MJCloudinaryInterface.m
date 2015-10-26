//
// Copyright 2014 Mobile Jazz SL
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "MJCloudinaryInterface.h"

#import <objc/runtime.h>
#import <Haneke/Haneke.h>
#import <Cloudinary/Cloudinary.h>

// Cloudinary Image Transformations: http://cloudinary.com/documentation/image_transformations

CGFloat const MJImageRadiusMax = CGFLOAT_MAX;

MJImageFileFormat * const MJImageFileFormatPNG = @"png";
MJImageFileFormat * const MJImageFileFormatJPG = @"jpg";
MJImageFileFormat * const MJImageFileFormatGIF = @"gif";
MJImageFileFormat * const MJImageFileFormatBMP = @"bmp";
MJImageFileFormat * const MJImageFileFormatTIFF = @"tiff";
MJImageFileFormat * const MJImageFileFormatICO = @"ico";
MJImageFileFormat * const MJImageFileFormatPDF = @"pdf";
MJImageFileFormat * const MJImageFileFormatEPS = @"eps";
MJImageFileFormat * const MJImageFileFormatPSD = @"psd";
MJImageFileFormat * const MJImageFileFormatSVG = @"svg";
MJImageFileFormat * const MJImageFileFormatWEBP = @"webp";

@implementation MJCloudinaryInterface
{
    CLCloudinary *_cloudinary;
}

+ (MJCloudinaryInterface*)defaultInterface
{
    static dispatch_once_t pred = 0;
    static MJCloudinaryInterface *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[MJCloudinaryInterface alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _cloudinary = [[CLCloudinary alloc] init];
        _fileFormat = MJImageFileFormatJPG;
        _radiusFileFormat = MJImageFileFormatPNG;
    }
    return self;
}

#pragma mark Properties

- (void)setCloudName:(NSString *)cloudName
{
    [_cloudinary.config setObject:cloudName forKey:@"cloud_name"];
}

- (void)setApiKey:(NSString *)apiKey
{
    [_cloudinary.config setObject:apiKey forKey:@"api_key"];
}

- (void)setApiSecret:(NSString *)apiSecret
{
    [_cloudinary.config setObject:apiSecret forKey:@"api_secret"];
}

- (NSString*)cloudName
{
    return _cloudinary.config[@"cloud_name"];
}

- (NSString*)apiKey
{
    return _cloudinary.config[@"api_key"];
}

- (NSString*)apiSecret
{
    return _cloudinary.config[@"api_secret"];
}

#pragma mark Public Methods

- (BOOL)uploadImage:(id)image options:(NSDictionary*)options
{
    return [self uploadImage:image options:options progress:nil completion:nil];
}

- (BOOL)uploadImage:(id)image options:(NSDictionary*)options progress:(void (^)(CGFloat progress))progressBlock completion:(void (^)(NSDictionary *result, NSString *cloudinaryId, NSString *error))completionBlock
{
    if (!image)
    {
        if (_enableDebugLogs)
            NSLog(@"[MJCloudinaryInterface] IMAGE UPLOAD: Could not upload nil image.");
        
        if (completionBlock)
            completionBlock(nil, nil, nil);
        
        return NO;
    }
        
    NSData *imageData = nil;
    if ([image isKindOfClass:UIImage.class])
    {
        if (_enableDebugLogs)
            NSLog(@"[MJCloudinaryInterface] IMAGE UPLOAD: Compressing image to JPG at 0.7 compression quality rate.");
        imageData = UIImageJPEGRepresentation(image, 0.7);
    }
    
    if (_enableDebugLogs)
        NSLog(@"[MJCloudinaryInterface] IMAGE UPLOAD: Uploading image with bytes length : %lu", imageData.length);

    CLUploader *uploader = [[CLUploader alloc] init:_cloudinary delegate:nil];
    [uploader upload:imageData?imageData:image options:options withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context) {
        
        if (_enableDebugLogs)
        {
            if (errorResult)
                NSLog(@"[MJCloudinaryInterface] IMAGE UPLOAD: Uploading finished with error: %@", [errorResult description]);
            else
                NSLog(@"[MJCloudinaryInterface] IMAGE UPLOAD: Uploading finished with result: %@", [successResult description]);
        }
        
        if (!errorResult)
            completionBlock(successResult, successResult[@"public_id"], nil);
        else
            completionBlock(nil, nil, errorResult);
    } andProgress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite, id context) {
        if (progressBlock)
        {
            CGFloat progress = ((CGFloat)totalBytesWritten)/(CGFloat)totalBytesExpectedToWrite;
            progressBlock(progress);
        }
    }];
    
    return YES;
}

- (NSURL*)URLForImageKey:(NSString *)imageKey
{
    if (imageKey == nil)
        return nil;
    
    if ([imageKey hasPrefix:@"http"])
    {
        if (_enableDebugLogs)
            NSLog(@"[MJCloudinaryInterface] URL CREATION: The used image key is already a URL: %@",imageKey);
        
        return [NSURL URLWithString:imageKey];
    }
    
    NSString *url = [_cloudinary url:imageKey];
    
    if (_enableDebugLogs)
        NSLog(@"[MJCloudinaryInterface] URL CREATION:\n{\n\tkey:%@\n}\nURL: %@\n",imageKey, url);
    
    return [NSURL URLWithString:url];
}

- (NSURL*)URLForImageKey:(NSString*)imageKey size:(CGSize)size cropMode:(MJImageCropMode)cropMode radius:(CGFloat)radius;
{
    return [self URLForImageKey:imageKey size:size scale:[[UIScreen mainScreen] scale] cropMode:cropMode radius:radius];
}

- (NSURL*)URLForImageKey:(NSString*)imageKey size:(CGSize)size scale:(CGFloat)scale cropMode:(MJImageCropMode)cropMode radius:(CGFloat)radius;
{
    if (imageKey == nil)
        return nil;
    
    if ([imageKey hasPrefix:@"http"])
    {
        if (_enableDebugLogs)
            NSLog(@"[MJCloudinaryInterface] URL CREATION: The used image key is already a URL: %@",imageKey);
        
        return [NSURL URLWithString:imageKey];
    }
    
    CLTransformation *transformation = [self mjz_transformationForSize:size scale:scale cropMode:cropMode radius:radius];
    
    NSString *url = [_cloudinary url:imageKey options:@{@"transformation": transformation}];
    
    if (_enableDebugLogs)
        NSLog(@"[MJCloudinaryInterface] URL CREATION:\n{\n\tkey:%@,\n\tsize:%@,\n\tscale:%.2f,\n\tcrop_mode:%ld,\n\tradius:%.2f,\n}\nURL: %@\n",imageKey, NSStringFromCGSize(size), scale, cropMode, radius, url);
    
    return [NSURL URLWithString:url];
}

- (NSURL*)URLForImageKey:(NSString*)imageKey
        pretransformCrop:(CGRect)pretransformCropRect
                    size:(CGSize)size
                   scale:(CGFloat)scale
                cropMode:(MJImageCropMode)cropMode
                  radius:(CGFloat)radius;
{
    if (imageKey == nil)
        return nil;
    
    CLTransformation *regularTransformation = [self mjz_transformationForSize:size scale:scale cropMode:cropMode radius:radius];

    if (CGRectEqualToRect(pretransformCropRect, CGRectZero))
    {
        NSString *url = [_cloudinary url:imageKey options:@{@"transformation": regularTransformation}];
        return [NSURL URLWithString:url];
    }
    
    CLTransformation *cropTransformation = [CLTransformation transformation];
    
    [cropTransformation setX:@(pretransformCropRect.origin.x)];
    [cropTransformation setY:@(pretransformCropRect.origin.y)];
    [cropTransformation setWidth:@(pretransformCropRect.size.width)];
    [cropTransformation setHeight:@(pretransformCropRect.size.height)];
    [cropTransformation setCrop:@"crop"];
    
    NSString *url1 = [_cloudinary url:imageKey options:@{@"transformation": cropTransformation}];
    NSString *url2 = [_cloudinary url:imageKey options:@{@"transformation": regularTransformation}];

    NSArray *pathComponents = [url2 pathComponents];
    NSString *last2Components = [pathComponents[pathComponents.count-2] stringByAppendingPathComponent:pathComponents[pathComponents.count-1]];
    
    NSString *finalUrl = [[url1 stringByDeletingLastPathComponent] stringByAppendingPathComponent:last2Components];
    
//    http://res.cloudinary.com/dkzkltsvs/image/upload/x_0,y_0,h_640,w_640,c_crop/c_fill,f_png,g_center,h_100,r_max,w_100/vj0wfi6nok3esd87j1x4
    
    if (_enableDebugLogs)
        NSLog(@"[MJCloudinaryInterface] URL CREATION:\n{\n\tkey:%@,\n\tpre_transform_crop:%@,\n\tsize:%@,\n\tscale:%.2f,\n\tcrop_mode:%ld,\n\tradius:%.2f,\n}\nURL: %@\n",imageKey, NSStringFromCGRect(pretransformCropRect), NSStringFromCGSize(size), scale, cropMode, radius, finalUrl);
    
    return [NSURL URLWithString:finalUrl];
}

#pragma mark Private Methods

- (CLTransformation*)mjz_transformationForSize:(CGSize)size scale:(CGFloat)scale cropMode:(MJImageCropMode)cropMode radius:(CGFloat)radius
{
    CLTransformation *transformation = [CLTransformation transformation];
    
    [transformation setWidthWithInt:ceilf(size.width * scale)];
    [transformation setHeightWithInt:ceilf(size.height * scale)];
    
    if (radius > 0)
    {
        if (radius == MJImageRadiusMax)
            transformation.radius = @"max";
        else
            [transformation setRadiusWithInt:ceilf(radius)];
        
        if (_radiusFileFormat)
            transformation.fetchFormat = _radiusFileFormat;
    }
    else
    {
        if (_fileFormat)
            transformation.fetchFormat = _fileFormat;
    }
    
    switch (cropMode)
    {
        case MJImageCropModeScaleToFill:
            transformation.crop = @"scale";
            break;
        case MJImageCropModeScaleAspectFill:
            transformation.crop = @"fill";
            transformation.gravity = @"center";
            break;
        case MJImageCropModeScaleAspectFit:
            transformation.crop = @"fit";
            break;
        case MJImageCropModeCenter:
            transformation.crop = @"crop";
            transformation.gravity = @"center";
            break;
        case MJImageCropModeTop:
            transformation.crop = @"fill";
            transformation.gravity = @"north";
            break;
        case MJImageCropModeBottom:
            transformation.crop = @"fill";
            transformation.gravity = @"south";
            break;
        case MJImageCropModeLeft:
            transformation.crop = @"fill";
            transformation.gravity = @"west";
            break;
        case MJImageCropModeRight:
            transformation.crop = @"fill";
            transformation.gravity = @"east";
            break;
        case MJImageCropModeTopLeft:
            transformation.crop = @"fill";
            transformation.gravity = @"north_west";
            break;
        case MJImageCropModeTopRight:
            transformation.crop = @"fill";
            transformation.gravity = @"north_east";
            break;
        case MJImageCropModeBottomLeft:
            transformation.crop = @"fill";
            transformation.gravity = @"south_west";
            break;
        case MJImageCropModeBottomRight:
            transformation.crop = @"fill";
            transformation.gravity = @"south_east";
            break;
        case MJImageCropModeFace:
            transformation.crop = @"thumb";
            transformation.gravity = @"face";
            break;
        case MJImageCropModeFaces:
            transformation.crop = @"thumb";
            transformation.gravity = @"faces";
            break;
    }
    
    return transformation;
}

@end

#pragma mark - UIImageView Extension

MJImageCropMode MJImageCropModeFromUIViewContentMode(UIViewContentMode contentMode)
{
    MJImageCropMode cropMode = MJImageCropModeScaleAspectFit;
    
    switch (contentMode)
    {
        case UIViewContentModeScaleToFill:
            cropMode = MJImageCropModeScaleToFill;
            break;
        case UIViewContentModeScaleAspectFit:
            cropMode = MJImageCropModeScaleAspectFit;
            break;
        case UIViewContentModeScaleAspectFill:
            cropMode = MJImageCropModeScaleAspectFill;
            break;
        case UIViewContentModeCenter:
            cropMode = MJImageCropModeCenter;
            break;
        case UIViewContentModeTop:
            cropMode = MJImageCropModeTop;
            break;
        case UIViewContentModeBottom:
            cropMode = MJImageCropModeBottom;
            break;
        case UIViewContentModeLeft:
            cropMode = MJImageCropModeLeft;
            break;
        case UIViewContentModeRight:
            cropMode = MJImageCropModeRight;
            break;
        case UIViewContentModeTopLeft:
            cropMode = MJImageCropModeTopLeft;
            break;
        case UIViewContentModeTopRight:
            cropMode = MJImageCropModeTopRight;
            break;
        case UIViewContentModeBottomLeft:
            cropMode = MJImageCropModeBottomLeft;
            break;
        case UIViewContentModeBottomRight:
            cropMode = MJImageCropModeBottomRight;
            break;
            
        case UIViewContentModeRedraw:
            // Nothing to do
            break;
    }
    
    return cropMode;
}

@implementation UIImageView (MJCloudinaryInterface)

#pragma mark Properties

- (void)mjz_setCloudinaryInterface:(MJCloudinaryInterface *)urlImageComposer
{
    objc_setAssociatedObject(self, @selector(mjz_cloudinaryInterface), urlImageComposer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MJCloudinaryInterface*)mjz_cloudinaryInterface
{
    return objc_getAssociatedObject(self, @selector(mjz_cloudinaryInterface));
}

- (MJImageCropMode)mjz_imageCropMode
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(mjz_imageCropMode));
    if (number)
        return [number unsignedIntegerValue];
    
    return MJImageCropModeFromUIViewContentMode(self.contentMode);
}

- (void)mjz_setImageCropMode:(MJImageCropMode)mjz_imageCropMode
{
    objc_setAssociatedObject(self, @selector(mjz_imageCropMode), @(mjz_imageCropMode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark Public Methods

- (void)mjz_setImageFromImageKey:(NSString*)imageKey
{
    [self mjz_setImageFromImageKey:imageKey radius:0 placeholder:nil];
}

- (void)mjz_setImageFromImageKey:(NSString*)imageKey radius:(CGFloat)radius
{
    [self mjz_setImageFromImageKey:imageKey radius:radius placeholder:nil];
}

- (void)mjz_setImageFromImageKey:(NSString*)imageKey placeholder:(UIImage*)placeholder
{
    [self mjz_setImageFromImageKey:imageKey radius:0 placeholder:placeholder];
}

- (void)mjz_setImageFromImageKey:(NSString*)imageKey
                          radius:(CGFloat)radius
                     placeholder:(UIImage*)placeholder
{
    MJCloudinaryInterface *cloudinaryInterface = self.mjz_cloudinaryInterface;
    
    if (!cloudinaryInterface)
        cloudinaryInterface = [MJCloudinaryInterface defaultInterface];
    
    NSURL *url = [cloudinaryInterface URLForImageKey:imageKey
                                                size:self.bounds.size
                                            cropMode:self.mjz_imageCropMode
                                              radius:radius];
    
    [self hnk_setImageFromURL:url placeholder:placeholder];
}

- (void)mjz_setImageFromImageKey:(NSString*)imageKey
                pretransformCrop:(CGRect)pretransformCrop
                          radius:(CGFloat)radius
                     placeholder:(UIImage*)placeholder
{
    MJCloudinaryInterface *cloudinaryInterface = self.mjz_cloudinaryInterface;
    
    if (!cloudinaryInterface)
        cloudinaryInterface = [MJCloudinaryInterface defaultInterface];
    
    NSURL *url = [cloudinaryInterface URLForImageKey:imageKey
                                    pretransformCrop:pretransformCrop
                                                size:self.bounds.size
                                               scale:[UIScreen mainScreen].scale
                                            cropMode:self.mjz_imageCropMode
                                              radius:radius];
    
    [self hnk_setImageFromURL:url placeholder:placeholder];
}

- (void)mjz_setImageFromImageKey:(NSString*)imageKey
                     placeholder:(UIImage*)placeholder
                         success:(void (^)(UIImage *image))successBlock
                         failure:(void (^)(NSError *error))failureBlock
{
    [self mjz_setImageFromImageKey:imageKey radius:0 placeholder:placeholder success:successBlock failure:failureBlock];
}

- (void)mjz_setImageFromImageKey:(NSString*)imageKey
                          radius:(CGFloat)radius
                     placeholder:(UIImage*)placeholder
                         success:(void (^)(UIImage *image))successBlock
                         failure:(void (^)(NSError *error))failureBlock
{
    MJCloudinaryInterface *cloudinaryInterface = self.mjz_cloudinaryInterface;
    
    if (!cloudinaryInterface)
        cloudinaryInterface = [MJCloudinaryInterface defaultInterface];
    
    NSURL *url = [cloudinaryInterface URLForImageKey:imageKey
                                                size:self.bounds.size
                                            cropMode:self.mjz_imageCropMode
                                              radius:radius];
    
    [self hnk_setImageFromURL:url placeholder:placeholder success:successBlock failure:failureBlock];
}

- (void)mjz_setImageFromImageKey:(NSString*)imageKey
                pretransformCrop:(CGRect)pretransformCrop
                          radius:(CGFloat)radius
                     placeholder:(UIImage*)placeholder
                         success:(void (^)(UIImage *image))successBlock
                         failure:(void (^)(NSError *error))failureBlock
{
    MJCloudinaryInterface *cloudinaryInterface = self.mjz_cloudinaryInterface;
    
    if (!cloudinaryInterface)
        cloudinaryInterface = [MJCloudinaryInterface defaultInterface];
    
    NSURL *url = [cloudinaryInterface URLForImageKey:imageKey
                                    pretransformCrop:pretransformCrop
                                                size:self.bounds.size
                                               scale:[UIScreen mainScreen].scale
                                            cropMode:self.mjz_imageCropMode
                                              radius:radius];

    [self hnk_setImageFromURL:url placeholder:placeholder success:successBlock failure:failureBlock];
}

@end
