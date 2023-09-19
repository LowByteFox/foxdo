const c = @cImport({
    @cInclude("grp.h");
    @cInclude("limits.h");
    @cInclude("string.h");
});

const std = @import("std");
const conf = @import("config.zig");

pub fn check_groups(config: *conf.Config) bool {
    var user_groups: [c.NGROUPS_MAX]std.os.gid_t = undefined;

    var size = std.os.linux.getgroups(c.NGROUPS_MAX, &user_groups[0]);

    for (0..size) |i| {
        var group = c.getgrgid(user_groups[i])[0];
        var len = c.strlen(group.gr_name);
        for (config.allow.groups.a_s.items) |item| {
            const fixed_item = item[1..item.len - 1];

            if (fixed_item.len < len) {
                len = fixed_item.len;
            }

            if(c.strncmp(@ptrCast(fixed_item), group.gr_name, len) == 0) {
                return true;
            }
        }
    }

    return false;
}

pub fn check_users(config: *conf.Config) bool {
    const login = std.os.getenv("USER").?;

    for (config.allow.users.a_s.items) |item| {
        const fixed_item = item[1..item.len - 1];

        if (std.mem.eql(u8, login, fixed_item)) {
            return true;
        }
    }

    return false;
}
