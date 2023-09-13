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

type MapleResult = enum
    InvalidState
    Success
    InvalidScreen
    InvalidPosition
    InvalidColorDepth

proc mapleSetPixel(fbRes: ptr LimineFramebufferResponse, screen, x, y, red, green, blue: uint64): MapleResult =
    if fbRes.framebuffer_count <= screen:
        return InvalidScreen
    var buffer = fbRes.framebuffers[screen]
    if buffer.width <= x or buffer.height <= y:
        return InvalidPosition
    var size = cast[uint](buffer.bpp shr 3)
    var index = (buffer.pitch * y) + (size * x)
    if buffer.red_mask_size > 64 or buffer.green_mask_size > 64 or buffer.blue_mask_size > 64:
        return InvalidColorDepth
    var r = (red shr (64 - buffer.red_mask_size)) shl buffer.red_mask_shift
    var g = (green shr (64 - buffer.green_mask_size)) shl buffer.green_mask_shift
    var b = (blue shr (64 - buffer.blue_mask_size)) shl buffer.blue_mask_shift
    var data = r or g or b
    for i in 0..size:
        buffer.address[index + i] = cast[uint8](data and 0xFF)
        data = data shr 8
    return Success

proc mapleMain() {.exportc.} =
    const fragment = high(uint64) shr 8
    if framebufferRequest.response != nil:
        var framebufferResponse = cast[ptr LimineFramebufferResponse](framebufferRequest.response)
        for y in 0..255'u:
            for x in 0..255'u:
                discard mapleSetPixel(framebufferResponse, 0, x, y, x * fragment, y * fragment, high(uint64))
        while true:
            discard