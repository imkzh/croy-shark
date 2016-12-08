
croy_match_frame = Proto("croy_frame", "Clash Royale Match Frame")
croy_match_frame.fields = {}
 
local header_field={
    [0xa8c901] = "client->server",
    [0x8ed602] = "server->client",
    [0xbc9d01] = "sync"
}
 
local fds = croy_match_frame.fields

fds.seqID = ProtoField.new("Sequence ID", "croy_frame.seqID", ftypes.UINT8)
fds.frameHeader = ProtoField.new("Header", "croy_frame.header", ftypes.UINT32, header_field, base.HEX)
fds.frameLength = ProtoField.new("Length", "croy_frame.frameLength", ftypes.UINT8)
fds.data = ProtoField.new("data", "croy_frame.data", ftypes.BYTES)


function croy_match_frame.dissector(buffer,pinfo,tree)
    local dataptr = 0

    local seqID = buffer(dataptr,1):uint()
    local subtree = tree:add(croy_match_frame, buffer(), "Clash Royale Frame #" .. seqID)

    subtree:add(fds.seqID,buffer(dataptr,1))
    dataptr = dataptr + 1
    subtree:add(fds.frameHeader,buffer(dataptr,3))
    dataptr = dataptr + 3
    subtree:add(fds.frameLength,buffer(dataptr,1))
    dataptr = dataptr + 1
    subtree:add(fds.data,buffer(dataptr,buffer:len()-dataptr))
end

