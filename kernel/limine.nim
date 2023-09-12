# Based on https://github.com/limine-bootloader/limine/blob/v5.x-branch/PROTOCOL.md

type LimineResponse* = object
    revision*: uint64

type LimineRequest* = object
    id*: array[4, uint64]
    revision*: uint64
    response*: ptr LimineResponse

type LimineFramebuffer* = object
    address*: ptr UncheckedArray[uint8]
    width*: uint64
    height*: uint64
    pitch*: uint64
    bpp*: uint16
    memory_model*: uint8
    red_mask_size*: uint8
    red_mask_shift*: uint8
    green_mask_size*: uint8
    green_mask_shift*: uint8
    blue_mask_size*: uint8
    blue_mask_shift*: uint8
    unused*: array[7, uint8]
    edid_size*: uint64
    edid*: ptr UncheckedArray[uint8]

type LimineFramebufferResponse* = object
    revision*: uint64
    framebuffer_count*: uint64
    framebuffers*: ptr UncheckedArray[ptr LimineFramebuffer]