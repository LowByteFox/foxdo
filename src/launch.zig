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

pub fn with_args(prog: [:0]const u8, args: [][:0]const u8, allocator: std.mem.Allocator) !void {
    var run_args = try allocator.allocSentinel(?[*:0]const u8, 1 + args.len, null);
    run_args[0] = prog;

    for (args, 1..) |arg, i| {
        run_args[i] = arg;
    }

    _ = c.setenv("HOME", "/root", 1);
    _ = c.setenv("LOGNAME", "root", 1);

    std.os.execvpeZ(prog, run_args, std.c.environ) catch {};
    allocator.free(run_args);
}
