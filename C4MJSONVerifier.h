/*******************************************************************************
 * This file is part of the C4MiOS_JSONVerifier project.
 * 
 * Copyright (c) 2012 C4M PROD.
 * 
 * C4MiOS_JSONVerifier is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * C4MiOS_JSONVerifier is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with C4MiOS_JSONVerifier. If not, see <http://www.gnu.org/licenses/lgpl.html>.
 * 
 * Contributors:
 * C4M PROD - initial API and implementation
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "SBJSON.h"

@interface C4MJSONVerifier : NSObject {
	
}

+ (BOOL) checkValidityOf:(NSString *) _userJSON fromModel:(NSString *) _modelJSON error:(NSError **)error;

@end
