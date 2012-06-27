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

#import "C4MJSONVerifier.h"
#import "SBJSON.h"

//#define NSLog //

@interface C4MJSONVerifier()

+ (NSString *) parseAttribute:(id)_modelAttribute fromKey:(NSString *)_key andCompareWith:(id)_userJSONObject;

@end

@implementation C4MJSONVerifier

/**
 * The JSON Model provided for verification MUST follow reference http://tools.ietf.org/html/draft-zyp-json-schema-02
 * Before itegarting model JSON in you bundle please check its integrity on http://www.jsonlint.com/ 
 *
 * Current implementation does not support "link" and "ref" attribut.
 */
+ (BOOL) checkValidityOf:(NSString *)_userJSON fromModel:(NSString *)_modelJSON error:(NSError **)error
{
	//Check equality
	if ( [_userJSON isEqualToString:_modelJSON]) return YES; 
	
	//Parsers
	SBJSON * jsonParser = [SBJSON new];
	id userJSONRootObject = [jsonParser objectWithString:_userJSON error:error];
	id modelJSONRootObject = [jsonParser objectWithString:_modelJSON error:error];
    [jsonParser release];
    
	//Ckeck nullity
	if (modelJSONRootObject == nil) {
		return NO;
	}
	if (userJSONRootObject == nil){
		return NO;
	}
	
	//The verification will be done recursively attribut by attibute from the model and compared node by node in the user stream.
	//It checks the model integrity then the user corresponding node integrity.
	NSString *err = [self parseAttribute:modelJSONRootObject fromKey:nil andCompareWith:userJSONRootObject];
    if(err !=nil)
	{
		//An error occurred
		NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:err forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:@"c4m" code:0 userInfo:errorDetail];
		return NO;
	}
	else {
		return YES;
	}
;
}

/**
 * private
 */
+ (NSString *) parseAttribute:(id)_modelAttribute fromKey:(NSString *)_key andCompareWith:(id)_userJSONObject{

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"Parsing Attribut %@ from key %@ andCompareWith %@",_modelAttribute, _key, _userJSONObject);
	
	if ([_modelAttribute isKindOfClass:[NSMutableDictionary class]] == YES)
    {
        NSMutableDictionary *root_attribut = (NSMutableDictionary *)_modelAttribute;
        BOOL isOptional = FALSE;
		//if the tag optional is not present then by default is is compulsory (except for root)
		if (_key != nil) {
			id optional = [root_attribut objectForKey:@"optional"];
			if (optional == nil || [optional boolValue] ==NO) {
				
				NSLog(@"%@ compulsory", _key);
				if ([_userJSONObject objectForKey:_key] != nil){
					NSLog(@"User JSON Object contains key %@ : OK", _key);
				}
				else 
				{
                    [pool drain];
					return [NSString stringWithFormat:@"User JSON Object do not contains key %@ : NOK", _key];
				}
			}
			else
			{
				isOptional = YES;
				NSLog(@"The key %@ is optional", _key);
			}
		}
		
		for (NSString *attr_key in root_attribut)
		{
			//all attributs are optionnal (according to model reference doc)
			
			//description
			if ([attr_key isEqualToString:@"description"]){
				NSLog(@"read %@", attr_key);
				id description = [root_attribut objectForKey:@"description"];
				if ([description isKindOfClass:[NSString class]] == YES)
				{
					//nothing special
					NSLog(@"Description=%@", description);
				}
			}
			
			//title
			if ([attr_key isEqualToString:@"title"]){
				NSLog(@"read %@", attr_key);
				id title = [root_attribut objectForKey:@"title"];
				if ([title isKindOfClass:[NSString class]] == YES)
				{
					//nothing special
					NSLog(@"Title=%@", title);
				}
			}
			
			//type
			if ([attr_key isEqualToString:@"type"])
			{
				NSLog(@"Read attribut key %@", attr_key);
				id type = [root_attribut objectForKey:@"type"];
				if ([type isKindOfClass:[NSString class]] == YES)
				{
					//compare type
					//string, number, integer, array, object, null, any
					if ([type isEqualToString:@"null"])
					{
						NSLog(@"Attribut can be null");
					}
					if ([type isEqualToString:@"any"])
					{
						NSLog(@"Attribut can be any");
					}
					if ([type isEqualToString:@"string"])
					{
						//CHECK that the attribut is a NSString in the user JSON
						
						if(isOptional == NO)
						{
							NSString *value;
							if(_key == nil) //simple value attribut from array
							{
								NSLog(@"Value must be a string");
								if ([_userJSONObject isKindOfClass:[NSString class]] == YES)
								{
									NSLog(@"string \"%@\" matches NSString : OK", _userJSONObject);
									value = [NSString stringWithString:_userJSONObject];
								}
								else 
								{
                                    [pool drain];
									return [NSString stringWithFormat:@"string \"%@\" DO NOT matches NSString", _userJSONObject];
								}
								
							}
							else	//key-value attribut from a dictionnary
							{
								if([_userJSONObject objectForKey:_key] != nil) {
									NSLog(@"Attribut %@ must be a string", _key);
									if ([[_userJSONObject objectForKey:_key] isKindOfClass:[NSString class]] == YES){
										NSLog(@"string \"%@\" matches NSString : OK", [_userJSONObject objectForKey:_key]);
										value = [NSString stringWithString:[_userJSONObject objectForKey:_key]];
									}
									else 
									{
                                        [pool drain];
										return [NSString stringWithFormat:@"string \"%@\" DO NOT matches NSString", [_userJSONObject objectForKey:_key]];
									}
								}
								else 
								{
                                    [pool drain];
									return [NSString stringWithFormat:@"Cannot found string for key %d", _key];
								}
								
							}
							
							//Handle "enum", "format", "pattern", "maxLength", "minLength"
							//enum
							id enume = [root_attribut objectForKey:@"enum"];
							if(enume != nil)
							{
								NSLog(@"read enum");
								if ([enume isKindOfClass:[NSArray class]] == YES)
								{
									NSLog(@"enum model matches NSArray");
									if([enume containsObject:value])
									{
										NSLog(@"string \"%@\" is in range of enum model : OK", value);
									}
									else {
                                        [pool drain];
										return [NSString stringWithFormat:@"string \"%@\" is NOT in range of enum model : OK", value];
									}
									
								}
								else 
								{
                                    [pool drain];
									return [NSString stringWithFormat:@"enum DO NOT matches NSArray (%@)", enume];
								}
							}
							
							//format
							id format = [root_attribut objectForKey:@"format"];
							if(format != nil)
							{
								//TODO by default match (not yet fully documented)
							}
							//pattern
							id pattern = [root_attribut objectForKey:@"pattern"];
							if(pattern != nil)
							{
								//--- WARNING ----
								//iOS 4 compatible only
								//and parser BSJSON does not handle escape caracters such as "\"
								//----------------
								if ([pattern isKindOfClass:[NSString class]] == NO)
								{
                                    [pool drain];
									return @"model pattern is not a string (NSString)";
								}
								
								NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
								NSArray* matches = [regex matchesInString:value options:0 range:NSMakeRange(0, [value length])];
								[regex release];
								
								if([matches count] <= 0) {
                                    [pool drain];
									return [NSString stringWithFormat:@"string %@ does not match pattern %@", value, pattern];
								}
								else 
								{
									NSLog(@"string %@ matches pattern : OK", value);
								}
							}
							//maxLength
							id maxLength = [root_attribut objectForKey:@"maxLength"];
							if(maxLength != nil)
							{
								NSNumber *max = (NSNumber *) maxLength;
								
								if([value length] > [max intValue])
								{
                                    [pool drain];
									return [NSString stringWithFormat:@"lenght of string %@ is upper than model maxLength %d", value, [max intValue]];
								}
							}
							//minLength
							id minLength = [root_attribut objectForKey:@"minLength"];
							if(minLength != nil)
							{
								NSNumber *min = (NSNumber *) minLength;
								if([value length] < [min intValue])
								{
                                    [pool drain];
									return [NSString stringWithFormat:@"lenght of string %@ is lower than model minLength %d", value, [min intValue]];
								}
							}
						}
					}
					if ([type isEqualToString:@"number"] || [type isEqualToString:@"integer"])  //idem
					{
						//CHECK that the attribut is a NSNumber in the user JSON
						if(isOptional == NO)
						{
							NSNumber *value;
							if(_key == nil) //simple value attribut from array
							{
								NSLog(@"value must be a number or integer");
								if ([_userJSONObject isKindOfClass:[NSNumber class]] == YES)
								{
									NSLog(@"value \"%@\" matches NSNumber : OK", _userJSONObject);
									value = _userJSONObject;
								}
								else 
								{
                                    [pool drain];
									return [NSString stringWithFormat:@"value \"%@\" DO NOT matches NSNumber", _userJSONObject];
								}
								
							}
							else	//key-value attribut from a dictionnary
							{
								if([_userJSONObject objectForKey:_key] != nil) 
								{
									NSLog(@"Attribut %@ must be a number", _key);
									
									if ([[_userJSONObject objectForKey:_key] isKindOfClass:[NSNumber class]] == YES){
										NSLog(@"value \"%@\" matches NSNumber : OK", [_userJSONObject objectForKey:_key]);
										value = [_userJSONObject objectForKey:_key];
									}
									else 
									{
                                        [pool drain];
										return [NSString stringWithFormat:@"value \"%@\" DO NOT matches NSNumber", [_userJSONObject objectForKey:_key]];
									}	
								}
								else 
								{
                                    [pool drain];
									return [NSString stringWithFormat:@"Cannot found value for key %d", _key];
								}
							}
							
							//Handle "minimum", "maximum", "minimumCanEqual" , "maximumCanEqual" , "divisibleBy"
							//minimum
							id minimum = [root_attribut objectForKey:@"minimum"];
							if(minimum != nil)
							{
								NSNumber *min = (NSNumber *) minimum;
								
								if([value intValue] <= [min intValue])
								{
                                    [pool drain];
									return [NSString stringWithFormat:@"value of number %@ is lower than  model minimum %d", value, [min intValue]];
								}
							}
							//maximum
							id maximum = [root_attribut objectForKey:@"maximum"];
							if(maximum != nil)
							{
								NSNumber *max = (NSNumber *) maximum;
								
								if([value intValue] >= [max intValue])
								{
                                    [pool drain];
									return [NSString stringWithFormat:@"value of number %@ is upper than  model maximum %d", value, [max intValue]];
								}
							}
							//minimumCanEqual
							id minimumCanEqual = [root_attribut objectForKey:@"minimumCanEqual"];
							if(minimumCanEqual != nil)
							{
								NSNumber *min = (NSNumber *) minimumCanEqual;
								
								if([value intValue] < [min intValue])
								{
                                    [pool drain];
									return [NSString stringWithFormat:@"value of number %@ is lower or equal than  model minimum %d", value, [min intValue]];
								}
							}
							//maximumCanEqual
							id maximumCanEqual = [root_attribut objectForKey:@"maximumCanEqual"];
							if(maximumCanEqual != nil)
							{
								NSNumber *max = (NSNumber *) maximumCanEqual;
								
								if([value intValue] > [max intValue])
								{
                                    [pool drain];
									return [NSString stringWithFormat:@"value of number %@ is upper or equal than  model maximum %d", value, [max intValue]];
								}
							}
							//divisibleBy
							id divisibleBy = [root_attribut objectForKey:@"divisibleBy"];
							if(divisibleBy != nil)
							{
								NSNumber *nb = (NSNumber *) divisibleBy;
								
								if([value intValue]%[nb intValue] != 0)
								{
                                    [pool drain];
									return [NSString stringWithFormat:@"value of number %@ cvannot be divided by %d", value, [nb intValue]];
								}
							}
						}
					}
					if ([type isEqualToString:@"array"])
					{
						if(isOptional == NO)
						{
							NSLog(@"Found declared type array in model");
							
							//Handle "minItems", "maxItems", uniqueItems
							
							NSLog(@"Read attribut items");
							id properties = [root_attribut objectForKey:@"items"];
							if ([properties isKindOfClass:[NSMutableDictionary class]] == YES)
							{
								NSLog(@"Attribut items from model is a NSMutableDictionary");
								
								//Loop on the number of elements in the array in the range of min and max.
								//maxItems
								id maxItems = [properties objectForKey:@"maxItems"];
								if(maxItems != nil)
								{
									NSNumber *max = (NSNumber *) maxItems;
									
									if([_userJSONObject count] > [max intValue])
									{
                                        [pool drain];
										return [NSString stringWithFormat:@"lenght of array %@ is upper model maxItems %d", _userJSONObject, [max intValue]];
									}
								}
								//minItems
								id minItems = [properties objectForKey:@"minItems"];
								if(minItems != nil)
								{
									NSNumber *min = (NSNumber *) minItems;
									if([_userJSONObject count] < [min intValue])
									{
                                        [pool drain];
										return [NSString stringWithFormat:@"lenght of array %@ is lower model minItems %d", _userJSONObject, [min intValue]];
									}
								}
								//uniqueItems
								id uniqueItems = [properties objectForKey:@"uniqueItems"];
								if(uniqueItems != nil)
								{
									//TODO check single instances
								}
								
								id userCorrespondingArray;
								if(_key == nil)
								{
									NSLog(@"Key is nil, userCorrespondingArray is %@", _userJSONObject);
									userCorrespondingArray = _userJSONObject;
								}
								else 
								{
									NSLog(@"Key is not nil (%@), userCorrespondingArray is %@", _key, [_userJSONObject objectForKey:_key]);
									userCorrespondingArray = [_userJSONObject objectForKey:_key];
								}
								
								//CHECK that the attribut is a NSArray in the user JSON and check size.
								if([userCorrespondingArray isKindOfClass:[NSArray class]] == NO)
								{
                                    [pool drain];
									return [NSString stringWithFormat:@"userCorrespondingArray %@ is not a NSArray", userCorrespondingArray];
								}
								
								//the loop
								for (int i=0; i<[userCorrespondingArray count]; i++)
								{
									NSString *err = [self parseAttribute:(NSMutableDictionary *)properties fromKey:nil andCompareWith:[userCorrespondingArray objectAtIndex:i]];
									if(err != nil) {
                                        [pool drain];
										return [NSString stringWithFormat:@"Error in content of attribut items : %@", err];
									}
								}
							}
							else 
							{
                                [pool drain];
								return @"items attribut in model is not a NSMutableDictionary";
							}
						}
						
					}
					if ([type isEqualToString:@"object"])
					{
						if(isOptional == NO)
						{
							NSLog(@"%@ must contain object", _key);

							//Handle "minItems", "maxItems"
							//search in root_attribut
							id additionnal = [root_attribut objectForKey:@"additionalProperties"];
							if (additionnal != nil && [additionnal boolValue] == YES) 
							{
								//TODO
							}
							
							//CHECK that the attribut is a NSMutableDictionary in the user JSON
							if ([_userJSONObject isKindOfClass:[NSMutableDictionary class]] == NO){
                                [pool drain];
								return [NSString stringWithFormat:@"_userJSONObject %@ DO NOT matches NSDICtionary", _userJSONObject];
							}
							
							//begins with NSDict
							id properties = [root_attribut objectForKey:@"properties"];
							if ([properties isKindOfClass:[NSMutableDictionary class]] == YES)
							{
								for (id prop_attr_key in properties)
								{
									if ([prop_attr_key isKindOfClass:[NSString class]] == YES)
									{
										id userCorrespondingObject;
										if(_key == nil)
											userCorrespondingObject = _userJSONObject;
										else 
											userCorrespondingObject = [_userJSONObject objectForKey:_key];
										
										if([userCorrespondingObject isKindOfClass:[NSMutableDictionary class]] == NO)
										{
                                            [pool drain];
											return [NSString stringWithFormat:@"userCorrespondingNode %@ is not a NSDictionary", userCorrespondingObject];
										}

										//Then loop recursively
										NSString *err = [self parseAttribute:[properties objectForKey:prop_attr_key] fromKey:prop_attr_key andCompareWith:userCorrespondingObject];
										if(err != nil)
										{
                                            [pool drain];
											return [NSString stringWithFormat:@"Error in content of attribut %@ : %@", prop_attr_key, err];
										}
										
									}
									else 
									{
                                        [pool drain];
										return [NSString stringWithFormat:@"%@ from Model is not a string (NSString)", prop_attr_key];
									}
								}
							}
							else 
							{
                                [pool drain];
								return [NSString stringWithFormat:@"%@ from Model is not a object (NSDictionnary)", properties];
							}
						}
					}
				}
			}
		}
        [pool drain];
		return nil;
	}
	else {
        [pool drain];
		return [NSString stringWithFormat:@"root model is not NSMutableDictionary"];
	}
	[pool drain];
	
}
@end
