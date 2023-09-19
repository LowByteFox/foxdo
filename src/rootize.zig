const std = @import("std");

const c = @cImport({
    @cInclude("grp.h");
    @cInclude("unistd.h");
    @cInclude("limits.h");
});

pub fn rootize() void {
    _ = c.setuid(0);
    _ = c.setgid(0);
    _ = c.seteuid(0);
    var gids: [1]std.os.gid_t = undefined;
    gids[0] = 0;
    _ = c.setgroups(1, gids[0..1].ptr);
}
