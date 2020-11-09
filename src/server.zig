const std = @import("std");
const hzzp = @import("hzzp");

pub const FileServer = hzzp.base.Server.BaseServer(std.fs.File.Reader, std.fs.File.Writer);
const HandlerFn = fn (*FileServer) void;
const HandlerMap = std.StringHashMap(HandlerFn);

pub const Options = struct {
    port: u16 = 8080,
};

pub const Server = struct {
    allocator: *std.mem.Allocator,
    handlers: HandlerMap,
    options: Options,

    const Self = @This();

    pub fn init(allocator: *std.mem.Allocator, options: Options) @This() {
        return .{
            .allocator = allocator,
            .options = options,
            .handlers = HandlerMap.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.handlers.deinit();
    }

    pub fn addHandler(self: *Self, comptime route: []const u8, handler: HandlerFn) !void {
        try self.handlers.put(route, handler);
    }

    pub fn run(self: *Self) !void {
        std.debug.warn("port: {}\n", .{self.options.port});
        var addr = try std.net.Address.parseIp("127.0.0.1", self.options.port);
        var stream_server = std.net.StreamServer.init(.{ .reuse_address = true });
        defer stream_server.deinit();

        try stream_server.listen(addr);

        while (true) {
            var buffer: [1024]u8 = undefined;
            var conn = try stream_server.accept();
            defer conn.file.close();

            var client = hzzp.base.Server.create(&buffer, conn.file.reader(), conn.file.writer());

            var status_event = (try client.readEvent()).?;
            std.testing.expect(status_event == .status);
            std.debug.warn("http: got status: {} {}\n", .{ status_event.status.method, status_event.status.path });

            var handler_opt = self.handlers.get(status_event.status.path);
            if (handler_opt) |handler| {
                handler(&client);
            } else {
                try client.writeHead(404, "Not Found");
                try client.writeHeaderValue("Server", "zeb/0.1");
                try client.writeHeadComplete();
            }
        }
    }
};
