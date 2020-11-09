const std = @import("std");
const zeb = @import("zeb");
const hzzp = @import("hzzp");

pub fn helloHandler(client: *zeb.FileServer) void {
    client.writeHead(200, "Awooga") catch unreachable;
    client.writeHeaderValue("Server", "zeb/0.1") catch unreachable;
    client.writeChunk("hello world") catch unreachable;
    client.writeHeadComplete() catch unreachable;
}

pub fn main() !void {
    var allocator_instance = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = allocator_instance.deinit();
    }
    const allocator = &allocator_instance.allocator;

    var server = zeb.Server.init(allocator, .{});
    defer server.deinit();

    try server.addHandler("/", helloHandler);
    try server.run();
}
