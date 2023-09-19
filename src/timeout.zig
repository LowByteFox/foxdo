const std = @import("std");
const utils = @import("utils.zig");
const c = @cImport({
    @cInclude("unistd.h");
});

pub fn register_self(username: []const u8, time: i64, allocator: std.mem.Allocator) !void {
    const pth: []const u8 = "/tmp/foxdo";
    std.os.mkdir(pth, 0o755) catch {};

    const len = pth.len + username.len + 1;
    var new_pth: []u8 = try allocator.alloc(u8, len);
    defer allocator.free(new_pth);

    utils.copy_over(new_pth, 0, pth);
    new_pth[pth.len] = '/';
    utils.copy_over(new_pth, pth.len + 1, username);

    std.os.mkdir(new_pth, 0o755) catch {};
    const ppid = try std.fmt.allocPrint(allocator, "{s}/{d}", .{new_pth, c.getppid()});
    defer allocator.free(ppid);

    var outfile: std.fs.File = std.fs.createFileAbsolute(ppid, .{ .read = true }) catch |e| {
        std.debug.print("Unable to create {s}! {}\n", .{ppid, e});
        std.os.exit(1);
    };

    defer outfile.close();

    var timestamp_str = try std.fmt.allocPrint(allocator, "{d}", .{time});
    defer allocator.free(timestamp_str);
    _ = outfile.write(timestamp_str) catch |e| {
        std.debug.print("Unable to write to {s}! {}\n", .{ppid, e});
    };
}

pub fn check_self(username: []const u8, time: i64, allocator: std.mem.Allocator) !bool {
    const pth: []const u8 = "/tmp/foxdo";
    _ = std.fs.openDirAbsolute(pth, .{}) catch {
        return false;
    };

    const len = pth.len + username.len + 1;
    var new_pth: []u8 = try allocator.alloc(u8, len);
    defer allocator.free(new_pth);

    utils.copy_over(new_pth, 0, pth);
    new_pth[pth.len] = '/';
    utils.copy_over(new_pth, pth.len + 1, username);

    _ = std.fs.openDirAbsolute(new_pth, .{}) catch {
        return false;
    };

    const ppid = try std.fmt.allocPrint(allocator, "{s}/{d}", .{new_pth, c.getppid()});
    defer allocator.free(ppid);

    var infile = std.fs.openFileAbsolute(ppid, .{}) catch {
        return false;
    };

    defer infile.close();

    var num = try infile.readToEndAlloc(allocator, 21);
    defer allocator.free(num);

    var innum = try std.fmt.parseInt(i64, num, 10);

    return time < innum;
}
