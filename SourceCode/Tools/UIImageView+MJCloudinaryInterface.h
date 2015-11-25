//
//  MJCloudinaryInterface+Haneke.h
//  MJ-iOS-Toolkit
//
//  Created by Joan Martin on 25/11/15.
//  Copyright © 2015 Mobile Jazz. All rights reserved.
//

#import "MJCloudinaryInterface.h"

/**
 * UIImageView extension for MJCloudinaryInterface to load images with Haneke.
 **/
@interface UIImageView (MJCloudinaryInterface)

/** *************************************************** **
 * @name Configuring the instance
 ** *************************************************** **/

/**
 * The used `MJCloudinaryInterface` instance. Default value is nil.
 * @return The used MJCloudinaryInterface. Can be nil.
 * @discussion If nil, the `defaultInstance` is used.
 **/
@property (nonatomic, weak, setter=mjz_setCloudinaryInterface:) MJCloudinaryInterface *mjz_cloudinaryInterface UI_APPEARANCE_SELECTOR;

/**
 * The image crop mode. For example, to run a face detection set it to `MJCloudinaryImageCropModeFace`.
 * @discussion If not manually defined, the image crop mode will be corresponding imageView's contentMode.
 **/
@property (nonatomic, assign, setter=mjz_setImageCropMode:) MJCloudinaryImageCropMode mjz_imageCropMode;

/** *************************************************** **
 * @name Setting images
 ** *************************************************** **/

- (void)mjz_setImageFromImageKey:(NSString*)imageKey;

- (void)mjz_setImageFromImageKey:(NSString*)imageKey radius:(CGFloat)radius;

- (void)mjz_setImageFromImageKey:(NSString*)imageKey placeholder:(UIImage*)placeholder;

- (void)mjz_setImageFromImageKey:(NSString*)imageKey
                          radius:(CGFloat)radius
                     placeholder:(UIImage*)placeholder;

- (void)mjz_setImageFromImageKey:(NSString*)imageKey
                pretransformCrop:(CGRect)pretransformCrop
                          radius:(CGFloat)radius
                     placeholder:(UIImage*)placeholder;

- (void)mjz_setImageFromImageKey:(NSString*)imageKey
                     placeholder:(UIImage*)placeholder
                         success:(void (^)(UIImage *image))successBlock
                         failure:(void (^)(NSError *error))failureBlock;

- (void)mjz_setImageFromImageKey:(NSString*)imageKey
                          radius:(CGFloat)radius
                     placeholder:(UIImage*)placeholder
                         success:(void (^)(UIImage *image))successBlock
                         failure:(void (^)(NSError *error))failureBlock;

- (void)mjz_setImageFromImageKey:(NSString*)imageKey
                pretransformCrop:(CGRect)pretransformCrop
                          radius:(CGFloat)radius
                     placeholder:(UIImage*)placeholder
                         success:(void (^)(UIImage *image))successBlock
                         failure:(void (^)(NSError *error))failureBlock;
@end
