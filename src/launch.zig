const std = @import("std");

const c = @cImport({
    @cInclude("stdlib.h");
    @cInclude("unistd.h");
});

pub fn without_args(prog: [:0]const u8) void {
    const args = &[_:null]?[*:0]const u8{prog};
    _ = c.setenv("HOME", "/root", 1);
    _ = c.setenv("LOGNAME", "root", 1);
    std.os.execvpeZ(prog, args, std.c.environ) catch {};
}
