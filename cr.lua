
croy_match_proto = Proto("croy_match", "Clash Royale Match Protocol")
croy_match_proto.fields = {}

local fds = croy_match_proto.fields

fds.session_token = ProtoField.new("Session Token", "croy_match.session", ftypes.BYTES)

fds.ack_t = ProtoField.new("Acknowledgments", "croy_match.ack", ftypes.UINT8)
fds.data_fields = ProtoField.new("Data Fields", "croy_match.datafields", ftypes.UINT8)

-- always 0x00 * 1387?
fds.init_data = ProtoField.new("init data", "croy_match.init_data", ftypes.BYTES)

fds.data = ProtoField.new("data", "croy_match.data", ftypes.BYTES)

function croy_match_proto.dissector(buffer,pinfo,tree)
    pinfo.cols.protocol = "CROY_MATCH"
    local subtree = tree:add(croy_match_proto, buffer(), "Clash Royale Match")
    subtree:add(fds.session_token, buffer(0, 10))
    local data_start = 10
    if buffer:len() > 10 then

        data_start = 10

        local c = buffer(data_start,1):uint()
        subtree:add(fds.ack_t, buffer(data_start,1))
        data_start = data_start+1
        if c>0 then 
            local acks = subtree:add(croy_match_proto, buffer(data_start,c),"This package is an ack on Frame #:")
            
            while c > 0 do
                local seq = buffer(data_start,1):uint()
                acks:add(croy_match_proto, buffer(data_start,1), seq)
                data_start = data_start+1
                c = c - 1
            end
        end
        
        local croyframe = Dissector.get("croy_frame")

        if (data_start < buffer:len()-1) then

            local treeId = 0
            c = buffer(data_start,1):uint()
            subtree:add(fds.data_fields, buffer(data_start, 1))
            data_start = data_start+1
            while (c>0) do
                
                local dlen = buffer(data_start + 4, 1):uint()

                croyframe:call(buffer(data_start,dlen+5):tvb(),pinfo,tree)
                data_start = data_start + dlen + 1 + 4
                c = c-1

            end 
        end
       
    end

    if data_start < buffer:len() - 1 then
        local data = buffer(data_start, buffer:len() - data_start)
        subtree:add(fds.data, data)
    end
end

-- load the udp.port table
udp_table = DissectorTable.get("udp.port")
udp_table:add(9339, croy_match_proto)
