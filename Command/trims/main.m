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
#import "JBImageTrimmer.h"

static char* const kAppName = "trims";
static char* const kAppVersion = "1.0.2";



void JBPrintVersion () {
  fprintf (stdout, "%s version %s by Joachim Bondo <osteslag@gmail.com>\n", kAppName, kAppVersion);
}


void JBPrintHelp () {
	
	JBPrintVersion ();
  fprintf (stdout, "\n");
  fprintf (stdout, "Description:\n");
  fprintf (stdout, "  Trims iOS screenshots by cropping away the status bar.\n\n");
  
  fprintf (stdout, "Usage:\n");
  fprintf (stdout, "  %s [-v | -h] | [[-r] path ...]\n\n", kAppName);
  
  fprintf (stdout, "Options:\n");
  fprintf (stdout, "  -r             Traverses folder paths recursively.\n");
  fprintf (stdout, "  -v, --version  Prints program name and version.\n");
  fprintf (stdout, "  -h, --help     Prints this help text.\n\n");
  
  fprintf (stdout, "Notes:\n");
  fprintf (stdout, "  - Status bar must be at the top edge of the image.\n");
  fprintf (stdout, "  - Input files are overwritten with the trimed images.\n");
  fprintf (stdout, "  - Run `man trims' for more information.\n");

}


void JBPrintErrorMessage (NSString* errorMessage) {
	fprintf (stderr, "%s" ,[[NSString stringWithFormat:@"Error: %@\n", errorMessage] UTF8String]);
}


void JBTrimImagesAtPathRecursively (NSString* path, BOOL recursively) {
	
	JBImageTrimmer *trimmer = [JBImageTrimmer defaultTrimmer];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isDirectory;
	NSError *error = nil;
	path = [path stringByExpandingTildeInPath];
	
	if (![fm fileExistsAtPath:path isDirectory:&isDirectory]) {
		JBPrintErrorMessage ([NSString stringWithFormat:NSLocalizedString (@"Invalid input path: %@", @"Error message when providing a path to a file or folder that doesn't exist."), path]);
		return; // Continue processing
	}
	
	// Prepare the completion block to be called in the two execution paths below.
	void (^completion_block)(NSError *error) = ^(NSError *error) {
		if (error) {
			JBPrintErrorMessage ([error localizedDescription]); // Continue processing
		}
	};
	
	if (!isDirectory) {
		[trimmer addTrimOperationForImageAtPath:path completion:completion_block];
	}
	
	else {
		
		// Process all files in directory and possibly all folders herein.
		NSArray *subpaths = [fm contentsOfDirectoryAtPath:path error:&error];
		
		if (!subpaths) {
			JBPrintErrorMessage ([error localizedDescription]);
			return; // Continue processing
		}
		
		[subpaths enumerateObjectsUsingBlock:^(NSString *subpath, NSUInteger idx, BOOL *stop) {
			
			// Is the subpath a directory that should be processed? Store the full path into the path variable as it's being accessed in the completion block.
			
			subpath = [path stringByAppendingPathComponent:subpath];
			BOOL isDirectory;
			
			[fm fileExistsAtPath:subpath isDirectory:&isDirectory];
			
			if (!isDirectory && [[subpath.pathExtension lowercaseString] isEqualToString:@"png"]) {
				[trimmer addTrimOperationForImageAtPath:subpath completion:completion_block];
			}
			
			else if (recursively) {
				JBTrimImagesAtPathRecursively (subpath, YES);
			}
			
		}];
		
	}
	
}


#pragma mark -


int main (int argc, const char * argv[]) {
	
	@autoreleasepool {
		
		if (argc == 1) {
			JBPrintErrorMessage (NSLocalizedString (@"No parameters given. Run with -h option to see proper usage.", @"Error message when providing no parameters to the program."));
			return EXIT_FAILURE;
		}
		
		BOOL is_recursive = NO;
		NSFileManager *fm = [NSFileManager defaultManager];
		
		for (int i = 1; i < argc; i++) {
			
			if (strcmp (argv[i], "--help") == 0 || strcmp (argv[i], "-h") == 0) {
				JBPrintHelp ();
				return EXIT_FAILURE;
			}
			
			else if (strcmp (argv[i], "--version") == 0|| strcmp (argv[i], "-v") == 0) {
				JBPrintVersion ();
				return EXIT_FAILURE;
			}
			
			else if (strcmp (argv[i], "-r") == 0) {
				is_recursive = YES;
			}
			
			else {
				
				NSString *path = [NSString stringWithUTF8String:argv[i]];
				
				if (argv[i][0] == '-' && ![fm fileExistsAtPath:path]) {
					JBPrintErrorMessage ([NSString stringWithFormat:NSLocalizedString (@"Illegal option %s. Run with -h to see proper usage.", @"Error message when providing the program with a non-valid parameter (%s)."), argv[i]]);
					return EXIT_FAILURE;
				}
				
				// Finally, do what we're supposed to do.
				JBTrimImagesAtPathRecursively (path, is_recursive);
				
			}
			
		}
		
		// Keep run loop going while images are being trimmed.
		while ([[[JBImageTrimmer defaultTrimmer] operationQueue] operationCount] > 0) {
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
		}
		
	}
	
	return EXIT_SUCCESS;
	
}
