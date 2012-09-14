/*
 
 Copyright (c) 2012, Joachim Bondo <https://github.com/osteslag/>
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 - Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, 
   this list of conditions and the following disclaimer in the documentation 
   and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "JBImageTrimmer.h"


NSString* const JBImageTrimmerErrorDomain = @"JBImageTrimmerError";


typedef struct {
	CGSize size;
	CGFloat status_bar_height;
	BOOL is_retina;
} JBScreenGeometry;

// Declare known screen sizes:
static JBScreenGeometry const k_known_screen_geometries[] = {
	{{960, 640}, 40, YES},
	{{640, 960}, 40, YES},
	{{1136, 640}, 40, YES},
	{{640, 1136}, 40, YES},
	{{2048, 1536}, 40, YES},
	{{1536, 2048}, 40, YES},
	{{480, 320}, 20, NO},
	{{320, 480}, 20, NO},
	{{1024, 768}, 20, NO},
	{{768, 1024}, 20, NO},
};


#pragma mark Private Helper Functions


static void JBErrorWithCodeAndSpec (NSError **error, JBImageTrimmerErrorCode error_code, id spec) {
	
	if (!error)
		return;
	
	NSString *description = nil;
	
	switch (error_code) {
			
		case JBImageTrimmerErrorCodeCannotCreateImageSourceFromFile:
			description = NSLocalizedString (@"Could not create image source from file.", @"Error message when the program tried read data from the given file.");
			break;
			
		case JBImageTrimmerErrorCodeCannotCreateImageFromSource:
			description = NSLocalizedString (@"Could not create image from image source.", @"Error message when the program tried to make an image out of the data in the given file.");
			break;
			
		case JBImageTrimmerErrorCodeCannotWriteImageToFile:
			description = NSLocalizedString (@"Could not create image from image source.", @"Error message when the program tried to make an image out of the data in the given file.");
			break;
			
		case JBImageTrimmerErrorCodeImageAlreadyTrimmed:
			description = NSLocalizedString (@"Image is already trimmed.", @"Error message when the image to be trimmed already has trimmed dimensions.");
			break;
			
		case JBImageTrimmerErrorCodeImageNotRetina:
			description = NSLocalizedString (@"Image is not Retina resolution.", @"Error message when the image doesn't have the preferred Retina resolution.");
			break;
			
		default:
			assert (false); // Throw
			break;
	}
	
	if (spec) {
		description = [description stringByAppendingFormat:@" (%@)", spec];
	}
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedDescriptionKey, description, nil];
	*error = [NSError errorWithDomain:JBImageTrimmerErrorDomain code:error_code userInfo:userInfo];
	
}


static CGImageRef JBCreateImageWithContentsOfURL (NSURL *url, NSError **error) {
	
	// Use Image I/O to read the contents of the given image URL.
	
	CGImageSourceRef imageSource = CGImageSourceCreateWithURL ((__bridge CFURLRef)url, NULL);
	
	if (!imageSource) {
		JBErrorWithCodeAndSpec (error, JBImageTrimmerErrorCodeCannotCreateImageSourceFromFile, url);
		return NULL;
	}
	
	CGImageRef image = CGImageSourceCreateImageAtIndex (imageSource, 0, NULL);
	CFRelease (imageSource);
	
	if (!image) {
		JBErrorWithCodeAndSpec (error, JBImageTrimmerErrorCodeCannotCreateImageFromSource, url);
		return NULL;
	}
	
	return image;
	
}


static CGRect JBTrimRectFromImageSize (CGSize size, BOOL *isRetina) {
	
	// Calculate the desired crop rect depending on the dimensions of the original image. If the given size is not among the known screen sizes, the crop size is left unchanged (and the image won't get processed). This function assumes the status bar is at the top.
	
	CGRect crop = {CGPointZero, size};
	
	BOOL is_retina = NO;
	
	for (int i = 0; i < sizeof (k_known_screen_geometries) / sizeof (JBScreenGeometry); i++) {
		
		if (CGSizeEqualToSize (size, k_known_screen_geometries[i].size)) {
			
			crop.origin.y = k_known_screen_geometries[i].status_bar_height;
			crop.size.height -= k_known_screen_geometries[i].status_bar_height;
			is_retina = k_known_screen_geometries[i].is_retina;
			
			break;
			
		}
		
	}
	
	if (isRetina) {
		*isRetina = is_retina;
	}
	
	return crop;
	
}


static CGImageRef JBCreateTrimmedImageFromSourceImage (CGImageRef sourceImage, NSError **error, NSURL *url) {
	
	// The URL is optional and only provided to augment error messages.
	
	BOOL is_retina;
	CGSize size = CGSizeMake (CGImageGetWidth (sourceImage), CGImageGetHeight (sourceImage));
	CGRect crop = JBTrimRectFromImageSize (size, &is_retina);
	
	// If there's no change in size, leave image and report error.
	if (CGSizeEqualToSize (size, crop.size)) {
		JBErrorWithCodeAndSpec (error, JBImageTrimmerErrorCodeImageAlreadyTrimmed, url);
		return NULL;
	}
	
	// Report error if image is not Retina (and continue processing).
	if (!is_retina) {
		JBErrorWithCodeAndSpec (error, JBImageTrimmerErrorCodeImageNotRetina, url);
	}
	
	CGImageRef trimmedImage = CGImageCreateWithImageInRect (sourceImage, crop);
	return trimmedImage;
	
}


static BOOL JBWriteImageToURL (CGImageRef trimmedImage, NSURL *url, NSError **error) {
	
	// Save the trimmed image back to the path.
	CGImageDestinationRef imageDestination = CGImageDestinationCreateWithURL ((__bridge CFURLRef)url, kUTTypePNG, 1, NULL);
	CGImageDestinationAddImage (imageDestination, trimmedImage, NULL);
	bool success = CGImageDestinationFinalize (imageDestination);
	CFRelease (imageDestination);
	
	if (!success) {
		JBErrorWithCodeAndSpec (error, JBImageTrimmerErrorCodeCannotWriteImageToFile, url);
	}
	
	return success;
	
}


#pragma mark -


@implementation JBImageTrimmer

@synthesize operationQueue = _operationQueue;

+ (id)defaultTrimmer {
	
	static dispatch_once_t onceToken;
	static id defaultTrimmer;
	
	dispatch_once (&onceToken, ^{
    defaultTrimmer = [[self alloc] init];
	});
	
	return defaultTrimmer;
	
}

- (id)init {
	
	if ((self = [super init])) {
		
		_operationQueue = [[NSOperationQueue alloc] init];
		[_operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
		
	}
	
	return self;
	
}

- (void)addTrimOperationForImageAtPath:(NSString *)path completion:(void (^)(NSError *error))completion {
	
	[_operationQueue addOperationWithBlock:^{
		
		NSError *error = nil;
		NSURL *url = [NSURL fileURLWithPath:path];
		
		// Read input image from file.
		CGImageRef sourceImage = JBCreateImageWithContentsOfURL (url, &error);
		if (!sourceImage) {
			if (completion) {
				completion (error);
			}
			return;
		}
		
		// Trim input image.
		CGImageRef trimmedImage = JBCreateTrimmedImageFromSourceImage (sourceImage, &error, url);
		CGImageRelease (sourceImage);
		if (!trimmedImage) {
			if (completion) {
				completion (error);
			}
			return;
		}
		
		// Write trimmed image to file.
		JBWriteImageToURL (trimmedImage, url, &error);
		CGImageRelease (trimmedImage);
		
		// Call back caller with any error from the last operation.
		if (completion) {
			completion (error);
		}
		
	}];
	
}

@end
