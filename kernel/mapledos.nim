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

proc mapleMain() {.exportc.} =
    if framebufferRequest.response != nil:
        var framebufferResponse = cast[ptr LimineFramebufferResponse](framebufferRequest.response)
        if framebufferResponse.framebuffer_count > 0:
            var framebuffer = framebufferResponse.framebuffers[][0]
            for i in 0..400:
                framebuffer.address[i] = 0xFF
        while true:
            discard