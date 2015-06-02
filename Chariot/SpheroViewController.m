/*
 * Copyright IBM Corp. 2015
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Contributors:
 *    Bryan Boyd
 *    Mike Robertson
 */

//
//  SpheroViewController.m
//  IoTstarter
//

#import "SpheroViewController.h"
#import "AppDelegate.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@interface SpheroViewController ()

@property (weak, nonatomic) IBOutlet UIView *imagePreview;
@property (weak, nonatomic) IBOutlet UIImageView *captureImage;
@property (nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;

@end

@implementation SpheroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.currentView = SPHERO;
}

- (void)viewDidAppear:(BOOL)animated {
    [self initializeCamera];
}

//AVCaptureSession to show live video feed in view
- (void) initializeCamera {
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    captureVideoPreviewLayer.frame = self.imagePreview.bounds;
    [self.imagePreview.layer addSublayer:captureVideoPreviewLayer];
    
    UIView *view = [self imagePreview];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    self.imageCount = 0;
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    if (!input) {
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    [session addInput:input];
    
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:self.stillImageOutput];
    
    [session startRunning];
}


- (IBAction)captureImage:(id)sender {
    //self.captureImage.image = nil; //remove old image from view
    //self.captureImage.hidden = NO; //show the captured image view
    //self.imagePreview.hidden = YES; //hide the live video feed
    //[self capImage];
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.captureImage.hidden = YES;
        self.imagePreview.hidden = NO;
        self.haveImage = NO;
    });
     */
    
    NSTimer* timer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(capImage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void) capImage { //method to capture image from AVCaptureSession video feed
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", self.stillImageOutput);
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (imageSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            [self processImage:[UIImage imageWithData:imageData]];
        }
    }];
}

- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void) processImage:(UIImage *)image { //process captured image, crop, resize and rotate
    self.haveImage = YES;
    self.imageCount++;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) { //Device is ipad
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(768, 1022));
        [image drawInRect: CGRectMake(0, 0, 768, 1022)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGRect cropRect = CGRectMake(0, 130, 768, 768);
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        //or use the UIImage wherever you like
        
        [self.captureImage setImage:[UIImage imageWithCGImage:imageRef]];
        
        NSData *imgData = UIImageJPEGRepresentation([self resizeImage:[UIImage imageWithCGImage:imageRef] newSize:CGSizeMake(256, 256)], 0.1f);
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate publishData:[imgData base64EncodedStringWithOptions:0] event:IOTPictureDataEvent];
        
        CGImageRelease(imageRef);
        
    }else{ //Device is iphone
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(512, 682));
        [image drawInRect: CGRectMake(0, 0, 512, 682)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGRect cropRect = CGRectMake(0, 85, 512, 512);
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        
        [self.captureImage setImage:[UIImage imageWithCGImage:imageRef]];
       
        NSData *imgData = UIImageJPEGRepresentation([self resizeImage:[UIImage imageWithCGImage:imageRef] newSize:CGSizeMake(128, 128)], 0.0f);
        
        
//        NSData *imgData = UIImageJPEGRepresentation([UIImage imageWithCGImage:imageRef], 0.0f);
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        
        //thumbnail
        //if (self.imageCount % 2 == 0) {
            NSData *thumbData = UIImageJPEGRepresentation([self resizeImage:[UIImage imageWithCGImage:imageRef] newSize:CGSizeMake(50, 50)], 0.0f);
            NSString* base64Thumb = [thumbData base64EncodedStringWithOptions:0];
            [appDelegate publishData:base64Thumb event:IOTPictureDataThumbnailEvent];
        //}
        
    
         NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
         NSMutableString *pictureId = [NSMutableString stringWithCapacity:6];
         for (int i=0; i<6; i++) {
             [pictureId appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
         }
        
         NSString* base64Encoded = [imgData base64EncodedStringWithOptions:0];
        
         // chunk data if more than 2 KB
         NSUInteger length = [base64Encoded length];
         NSUInteger chunkSize = 2.5 * 1024;
         NSUInteger offset = 0;
         NSUInteger chunks = ceil(length / chunkSize);
        
        NSLog(base64Encoded);
        
         int count = 0;
         do {
             NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
             NSString* chunk = [base64Encoded substringWithRange:NSMakeRange(offset,thisChunkSize)];   ///[NSData dataWithBytesNoCopy:(char *)[imgData bytes] + offset length:thisChunkSize
                                           // freeWhenDone:NO];
             offset += thisChunkSize;
             //NSString *base64Encoded = [chunk base64EncodedStringWithOptions:0];
             NSLog(chunk);
             NSDictionary *messageDictionary = @{
                                                 @"d": @{
                                                         @"msgId": pictureId,
                                                         @"index": @(count),
                                                         @"max": @(chunks),
                                                         @"data": chunk
                                                         }
                                                 };
             
             NSError *error;
             NSData *messageData = [NSJSONSerialization dataWithJSONObject:messageDictionary options:0 error:&error];
             NSString *messageString = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
             count++;
             
             [appDelegate publishData:messageString event:IOTPictureDataEvent];
         } while (offset < length);
        
        CGImageRelease(imageRef);
    }
    
    //adjust image orientation based on device orientation
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        NSLog(@"landscape left image");
        
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        self.captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(-90));
        [UIView commitAnimations];
        
    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        NSLog(@"landscape right");
        
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        self.captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
        [UIView commitAnimations];
        
    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        NSLog(@"upside down");
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        self.captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
        [UIView commitAnimations];
        
    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
        NSLog(@"upside upright");
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        self.captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(0));
        [UIView commitAnimations];
    }
}

/*
- (IBAction)button1Pressed:(id)sender {
    RKMacroObject *macro = [RKMacroObject new];
    [macro addCommand:[RKMCRotateOverTime commandWithRotation:1440 delay:1]];
    [macro playMacro];
}

- (IBAction)button2Pressed:(id)sender {
    [RKRollCommand sendStop];
}

- (IBAction)button3Pressed:(id)sender {
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green :1.0 blue :0.0];
}

- (IBAction)button4Pressed:(id)sender {
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green :0.0 blue :1.0];
}
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
