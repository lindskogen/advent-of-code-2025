const std = @import("std");

const example_input =
    \\987654321111111
;

const inputfile = @embedFile("input");

fn run_part1(_: anytype, _: std.mem.Allocator) !usize {

    return 0;
}

fn run_part2(_: anytype, _: std.mem.Allocator) !usize {
    return 0;
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
    try std.testing.expectEqual(1227775554, run_part1(example_input, alloc));
}

test "input2" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(4174379265, run_part2(example_input, alloc));
}

test "star1" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(44854383294, run_part1(inputfile, alloc));
}

test "star2" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(55647141923, run_part2(inputfile, alloc));
}
