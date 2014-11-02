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

#import "JBTrimAction.h"


@implementation JBTrimAction

- (id)runWithInput:(id)input error:(NSError **)error {
	
	// This action doesn't generate any errors, but merely processes all possible image files and returns the given input. All it does, basically, is calling the command line utility, `trims`.
	
	NSString *trimsPath = [[self bundle] pathForAuxiliaryExecutable:@"trims"];
	NSMutableArray *arguments = [NSMutableArray arrayWithArray:input];
	
	BOOL is_recursive = [[[self parameters] objectForKey:@"recursive"] boolValue];
	if (is_recursive) {
		[arguments insertObject:@"-r" atIndex:0];
	}
	
	NSTask *trimTask = [[NSTask alloc] init];
	[trimTask setLaunchPath:trimsPath];
	[trimTask setArguments:arguments];
	[trimTask launch];
	[trimTask waitUntilExit];

	
	return input;
	
}

@end
