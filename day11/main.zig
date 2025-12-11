const std = @import("std");

const example_input =
    \\aaa: you hhh
    \\you: bbb ccc
    \\bbb: ddd eee
    \\ccc: ddd eee fff
    \\ddd: ggg
    \\eee: out
    \\fff: out
    \\ggg: out
    \\hhh: ccc fff iii
    \\iii: out
;

const example_input2 =
    \\svr: aaa bbb
    \\aaa: fft
    \\fft: ccc
    \\bbb: tty
    \\tty: ccc
    \\ccc: ddd eee
    \\ddd: hub
    \\hub: fff
    \\eee: dac
    \\dac: fff
    \\fff: ggg hhh
    \\ggg: out
    \\hhh: out
;

const inputfile = @embedFile("input");

fn recur(devices: *std.StringArrayHashMap([][]const u8), visited: *std.StringArrayHashMap(usize), next: []const u8, end: []const u8) !usize {
    if (std.mem.eql(u8, end, next)) {
        return 1;
    }

    if (visited.get(next)) |c| {
        return c;
    }

    const outputs = devices.get(next) orelse {
        return 0;
    };

    var count: usize = 0;

    for (outputs) |value| {
        count += try recur(devices, visited, value, end);
    }

    try visited.putNoClobber(next, count);

    return count;
}

fn run_part1(input: anytype, alloc: std.mem.Allocator) !usize {
    var devices: std.StringArrayHashMap([][]const u8) = .init(alloc);

    var lineIter = std.mem.tokenizeScalar(u8, input, '\n');

    while (lineIter.next()) |line| {
        var wordIter = std.mem.tokenizeAny(u8, line, ": ");

        const device = wordIter.next().?;
        var outputs: std.ArrayList([]const u8) = .empty;

        while (wordIter.next()) |word| {
            try outputs.append(alloc, word);
        }

        try devices.put(device, try outputs.toOwnedSlice(alloc));
    }

    var visited: std.StringArrayHashMap(usize) = .init(alloc);
    return recur(&devices, &visited, "you", "out");
}

fn run_part2(input: anytype, alloc: std.mem.Allocator) !usize {
    var devices: std.StringArrayHashMap([][]const u8) = .init(alloc);

    var lineIter = std.mem.tokenizeScalar(u8, input, '\n');

    while (lineIter.next()) |line| {
        var wordIter = std.mem.tokenizeAny(u8, line, ": ");

        const device = wordIter.next().?;
        var outputs: std.ArrayList([]const u8) = .empty;

        while (wordIter.next()) |word| {
            try outputs.append(alloc, word);
        }

        try devices.put(device, try outputs.toOwnedSlice(alloc));
    }

    var visited: std.StringArrayHashMap(usize) = .init(alloc);

    var c1 = try recur(&devices, &visited, "svr", "fft");
    visited.clearRetainingCapacity();
    c1 *= try recur(&devices, &visited, "fft", "dac");
    visited.clearRetainingCapacity();
    c1 *= try recur(&devices, &visited, "dac", "out");
    visited.clearRetainingCapacity();

    var c2 = try recur(&devices, &visited, "svr", "dac");
    visited.clearRetainingCapacity();
    c2 *= try recur(&devices, &visited, "dac", "fft");
    visited.clearRetainingCapacity();
    c2 *= try recur(&devices, &visited, "fft", "out");

    return c1 + c2;
}

pub fn main() !void {
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    const p1 = try run_part1(inputfile, alloc);
    const p2 = try run_part2(inputfile, alloc);

    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

test "input1" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(5, run_part1(example_input, alloc));
}

test "input2" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(2, run_part2(example_input2, alloc));
}

test "star1" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(585, run_part1(inputfile, alloc));
}

test "star2" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(349322478796032, run_part2(inputfile, alloc));
}
