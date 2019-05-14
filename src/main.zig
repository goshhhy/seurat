const c = @cImport(@cInclude("SDL2/SDL.h"));
const std = @import("std");

const SDL_WINDOWPOS_UNDEFINED = @bitCast(c_int, c.SDL_WINDOWPOS_UNDEFINED_MASK);

var wsurface: [*c]c.SDL_Surface = undefined;
var rsurface: [*c]c.SDL_Surface = undefined;
var pixel: [*c]c.SDL_Surface = undefined;
var window: *c.SDL_Window = undefined;

var sw: u16 = 0;
var sh: u16 = 0;

export const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};

export fn init( w: u16, h: u16 ) void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log(c"Unable to initialize SDL: %s", c.SDL_GetError());
        return;
    }

    window = c.SDL_CreateWindow( c"lantern", 
                    SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                    w * 2, h * 2, 0) orelse {
        c.SDL_Log(c"Unable to create window: %s", c.SDL_GetError());
        return;
    };

    wsurface = c.SDL_GetWindowSurface( window );
    rsurface = c.SDL_CreateRGBSurface( 0, w, h, 32, 0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000 );
    pixel = c.SDL_CreateRGBSurface( 0, 1, 1, 32, 0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000 );
    sw = w;
    sh = h;
}

export fn drawPixel( x: u16, y: u16, r: u8, g: u8, b: u8 ) void {
    const rect = c.SDL_Rect{ .x = 0, .y = 0, .w = 1, .h = 1 };
    if ( c.SDL_FillRect( pixel, &rect, c.SDL_MapRGB(pixel.*.format, r, g, b) ) != 0 ) {
        std.debug.warn("fillrect failed");
    }
    var dest = c.SDL_Rect{ .x = x, .y = y, .w = 1, .h = 1 };
    if ( c.SDL_BlitSurface( pixel, &rect, rsurface, &dest ) != 0 ) {
        std.debug.warn("blit failed");
    } 
}

export fn flush() void {
    const rect1 = c.SDL_Rect{ .x = 0, .y = 0, .w = sw, .h = sh };
    var rect2 = c.SDL_Rect{ .x = 0, .y = 0, .w = sw * 2, .h = sh * 2 };
    if ( c.SDL_BlitScaled(  rsurface, &rect1, wsurface, &rect2) != 0 ) {
        std.debug.warn("SdlBlitFailed");
        return;
    }
    if ( c.SDL_UpdateWindowSurface( window ) != 0 ) {
        std.debug.warn("SdlUpdateWindowSurfaceFailed");
        return;
    }

    var e: c.SDL_Event = undefined;
    while ( c.SDL_PollEvent( &e ) != 0 ) {
        if ( e.type == c.SDL_QUIT ) {
            std.debug.warn("SdlQuitEventReceived");
            return;
        }
    }
}