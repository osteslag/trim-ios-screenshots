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

#import <Foundation/Foundation.h>


/// The error domain used for errors encountered by instances of this class.
extern NSString* const JBImageTrimmerErrorDomain;

/// Defines error codes.
typedef enum {
	JBImageTrimmerErrorCodeCannotCreateImageSourceFromFile = 1,
	JBImageTrimmerErrorCodeCannotCreateImageFromSource,
	JBImageTrimmerErrorCodeCannotWriteImageToFile,
	JBImageTrimmerErrorCodeImageAlreadyTrimmed, //< The image is already trimmed.
	JBImageTrimmerErrorCodeImageNotRetina, //< The image is of known dimensions, but is not Retina resolution. The image is still trimmed.
} JBImageTrimmerErrorCode;


/** Instances of this class do the work of queueing and executing iOS screenshot trim jobs. Jobs are carried out on secondary threads. Callers can choose the get a callback after the completion of a trim job.
 */
@interface JBImageTrimmer : NSObject

/** Since `JBImageTrimmer` instances maintain their own operation queue managing iOS screenshot trim jobs, users of this class may want to use the singleton in order to limit the work to one overall queue.
 
 @return The default `JBImageTrimmer` singleton.
 */
+ (id)defaultTrimmer;

/** Call this method for every image to trim. The operation will be added to `operationQueue`.
 
 It is assumed the status bar is located at the top 20 points (40 pixels on a Retina display). Screenshots with dimensions different from the known iOS device screen sizes are left untouched.
 
 @param path The path of the image file.
 @param completion A block to called after processing the image. If an error occured, *error* will be non-`nil`. Pass `NULL` to prevent callback. Callbacks take place on a secondary thread.
 @warning The file at *path* will be overwritten with the trimmed image.
 @see operationQueue
 */
- (void)addTrimOperationForImageAtPath:(NSString *)path completion:(void (^)(NSError *error))completion;

/// The trimmer's operation queue (read-only).
@property (readonly, strong) NSOperationQueue *operationQueue;

@end
