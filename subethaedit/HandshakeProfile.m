//
//  HandshakeProfile.m
//  SubEthaEdit
//
//  Created by Dominik Wagner on Fri Feb 27 2004.
//  Copyright (c) 2004 TheCodingMonkeys. All rights reserved.
//

#import "HandshakeProfile.h"
#import "TCMBEEPMessage.h"
#import "TCMBEEPChannel.h"

@implementation HandshakeProfile

- (id)initWithChannel:(TCMBEEPChannel *)aChannel {
    self = [super initWithChannel:aChannel];
    if (self) {
        I_remoteInfos=[NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc {
    [I_remoteInfos release];
    [super dealloc];
}

- (NSDictionary *)remoteInfos {
    return I_remoteInfos;
}

- (NSData *)handshakePayloadWithUserID:(NSString *)aUserID {
    NSMutableData *payload = [NSMutableData dataWithData:[[NSString stringWithFormat:@"GRTuserid=%@\001version=2.00\001token=none",aUserID] dataUsingEncoding:NSUTF8StringEncoding]];
    return payload;
}

- (void)shakeHandsWithUserID:(NSString *)aUserID
{
    [[self channel] sendMSGMessageWithPayload:[self handshakePayloadWithUserID:aUserID]];
}

- (void)processBEEPMessage:(TCMBEEPMessage *)aMessage
{
    // simple message reply model
    if ([aMessage isMSG]) {
        NSString *string=[NSString stringWithData:[aMessage payload] encoding:NSUTF8StringEncoding];
        NSString *type=[string substringToIndex:3];
        if ([type isEqualToString:@"GRT"]) {
            string=[string substringFromIndex:3];
            NSArray *pairsArray=[string componentsSeparatedByString: @"\001"];
            NSEnumerator *pairs=[pairsArray objectEnumerator];
            NSString *pair;
            while ((pair = [pairs nextObject])) {
                NSRange foundRange=[pair rangeOfString:@"="];
                if (foundRange.location!=NSNotFound) {
                    NSString *key = [[pair substringToIndex:foundRange.location] lowercaseString];
                    NSString *value=[pair substringFromIndex:NSMaxRange(foundRange)];
                    [I_remoteInfos setObject:value forKey:key];
                }
            }
            NSLog(@"Handshake greeting was: %@",string);
            NSString *userID=[[self delegate] profile:self shouldProceedHandshakeWithUserID:[I_remoteInfos objectForKey:@"userid"]];
            if (userID) {
                TCMBEEPMessage *message = [[TCMBEEPMessage alloc] initWithTypeString:@"RPY" messageNumber:[aMessage messageNumber] payload:[self handshakePayloadWithUserID:userID]];
                [[self channel] sendMessage:[message autorelease]];        
            } else {
                // brich ab
            }
        } else {
            if ([type isEqualToString:@"ACK"]) {
                [[self delegate] profile:self receivedAckHandshakeWithUserID:[I_remoteInfos objectForKey:@"userid"]];
            }
        }
    } else if ([aMessage isRPY]) {
        NSString *string=[NSString stringWithData:[aMessage payload] encoding:NSUTF8StringEncoding];
        NSLog(@"ShakeHandRPY was: %@",string);
        string=[string substringFromIndex:3];
        NSArray *pairsArray=[string componentsSeparatedByString: @"\001"];
        NSEnumerator *pairs=[pairsArray objectEnumerator];
        NSString *pair;
        while ((pair = [pairs nextObject])) {
            NSRange foundRange=[pair rangeOfString:@"="];
            if (foundRange.location!=NSNotFound) {
                NSString *key = [[pair substringToIndex:foundRange.location] lowercaseString];
                NSString *value=[pair substringFromIndex:NSMaxRange(foundRange)];
                [I_remoteInfos setObject:value forKey:key];
            }
        }
        BOOL shouldAck=NO;
        if ([[self delegate] respondsToSelector:@selector(profile:shouldAckHandshakeWithUserID:)]) {
            shouldAck=[[self delegate] profile:self shouldAckHandshakeWithUserID:[I_remoteInfos objectForKey:@"userid"]];
        }
        if (shouldAck) {
            NSMutableData *payload = [NSMutableData dataWithData:[[NSString stringWithFormat:@"ACK"] dataUsingEncoding:NSUTF8StringEncoding]];
            TCMBEEPMessage *message = [[TCMBEEPMessage alloc] initWithTypeString:@"MSG" messageNumber:[[self channel] nextMessageNumber] payload:payload];
            [[self channel] sendMessage:[message autorelease]];
            [[self delegate] profile:self didAckHandshakeWithUserID:[I_remoteInfos objectForKey:@"userid"]];
        } else {
            // brich ab
        }
    }
}

@end
