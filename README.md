# croy-shark
Clash Royale protocol dissector for Wireshark

## How to?
To use it, simply copy those .lua files into your wireshark user plugin directory, and start a capture.

# Packet Structure

## Game Protocol Structure

**10 Bytes** `Session ID`
**1 Byte** `AckLength` = *N1*
***N1* Bytes** `AckID`

    for *N1*>0, followed by *N1* bytes of `SequenceID` indicating which package it acknowledgs on

**1 Byte** `DataField Count` = *N2*
***N2* packets** `DataField`

## DataField structure
**1 Byte** `SequenceID`
**2 Bytes** `Sender?` 

    8e:d6:02 for server->client
    a8:c9:01 for client->server

**1 Byte** `FieldLength` = *N3*
***N3* Bytes** `Data`
