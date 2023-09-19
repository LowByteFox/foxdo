pub fn copy_over(buff: []u8, start: usize, str: []const u8) void {
    for (0..str.len) |i| {
        buff[i + start] = str[i];
    }
}
