import limine

var framebufferRequest {.exportc.} = LimineRequest(
    id: [
        0xC7B1DD30DF4C8B88u64,
        0x0A82E883A194F07Bu64,
        0x9D5827DCD881DD75u64,
        0xA3148604F6FAB11Bu64
    ],
    revision: 0,
    response: nil
)

type MapleSetPixelResult = enum
    Success
    InvalidScreen
    InvalidCoords
    InvalidDepth

proc mapleSetPixel(fbRes: ptr LimineFramebufferResponse, screen, x, y: uint64, red, green, blue: uint16): MapleSetPixelResult =
    if fbRes.framebuffer_count > screen:
        var buffer = fbRes.framebuffers[screen]
        if buffer.width > x and buffer.height > y:
            var index = (buffer.pitch * y) + ((buffer.bpp shr 3) * x)
            if buffer.red_mask_size <= 16 or buffer.green_mask_size <= 16 or buffer.blue_mask_size <= 16:
                var r: uint32 = red shr (16 - buffer.red_mask_size)
                var g: uint32 = green shr (16 - buffer.green_mask_size)
                var b: uint32 = blue shr (16 - buffer.blue_mask_size)
                var data = (r shl buffer.red_mask_shift) or (g shl buffer.green_mask_shift) or (b shl buffer.blue_mask_shift)
                for i in 0..cast[uint](buffer.bpp shr 3):
                    buffer.address[index + i] = cast[uint8](data and 0xFF)
                    data = data shr 8
                return Success
            else:
                return InvalidDepth
        else:
            return InvalidCoords
    else:
        return InvalidScreen

proc mapleMain() {.exportc.} =
    if framebufferRequest.response != nil:
        var framebufferResponse = cast[ptr LimineFramebufferResponse](framebufferRequest.response)
        for y in 0..256'u:
            for x in 0..256'u:
                discard mapleSetPixel(framebufferResponse, 0, x, y, cast[uint16](x) * 255, cast[uint16](y) * 255, 65535)
        while true:
            discard