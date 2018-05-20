//
//  NLTransLib.h
//  ISO8583_package
//
//  Created by xututu on 15/11/29.
//  Copyright © 2015年 Defore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLTransLib : NSObject
/**
 *  十六 进制字符串转换为 data
 *  24211D3498FF62AF  -->  <24211D34 98FF62AF>
 *
 *  @param str 要转换的字符串
 *
 *  @return 转换后的数据
 */
+ (NSData*)hexToBytes:(NSString *)str;


/**
 *  data 转换为十六进制字符串
 *  <24211D34 98FF62AF>  -->  24211D3498FF62AF
 *
 *  @param data 要转换的data
 *
 *  @return 转换后的字符串
 */
+ (NSString *)hexStringFromData:(NSData *)data;

/**
 *  由byte转为字符串
 *
 *  @param byteVal byte
 *
 */
+ (NSString *)stringFromByte:(Byte)byteVal;

/**
 *  hex字符串转为ASC码  00 --> 3030
 *
 *  @param hex hex字符串
 *
 *  @return 转码后的ASC字符串
 */
+ (NSString *)hexToAsc:(NSString *)hex;

/**
 *  ASC码转为Hex字符串  3030 --> 00
 *
 *  @param asc ASC字符串
 *
 *  @return 转码后的Hex字符串
 */
+ (NSString *)ascToHex:(NSString *)asc;

/**
 *  十六进制字符串转二进制字符串
 *
 *  @param hex 十六进制字符串
 *
 *  @return 二进制字符串
 */
+(NSString *)HexToBinary:(NSString *)hex;

/**
 *  2进制字符串转16进制字符串,如 11110011 -> F3
 *
 *  @param Binary 二进制字符串
 *
 *  @return 16进制字符串
 */
+(NSString *)BinaryToHex:(NSString *)Binary;

/**
 *  Des加密
 *
 *  @param plaintStr 待加密的数：NSString 1234567890ABCDEF,传入后变为<1234567890ABCDEF>再操作
 *  @param keyStr    密钥：NSString 3131313131313131,传入后变为<3131313131313131>再操作
 *
 *  @return 加密数，<XXXXXXXXXXXXXXXX> 的 NSString显示 XXXXXXXXXXXXXXXX
 */
+(NSString*)DesWithSrcString:(NSString*)plaintStr KeyString:(NSString*)keyStr;

/**
 *  3DES加密
 *
 *  @param plaintStr 待加密的数：NSString 1234567890ABCDEF,传入后变为<1234567890ABCDEF>再操作
 *  @param keyStr    密钥：NSString 3131313131313131_3131313131313131,
 传入后变为<3131313131313131_3131313131313131>再操作
 *
 *  @return 加密数，<XXXXXXXXXXXXXXXX> 的 NSString显示 XXXXXXXXXXXXXXXX
 */
+(NSString*)ThreeDesWithSrcString:(NSString*)plaintStr KeyString:(NSString*)keyStr;

@end
