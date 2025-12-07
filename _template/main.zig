const std = @import("std");

const example_input =
    \\987654321111111
;

const inputfile = @embedFile("input");

fn run_part1(_: anytype) !usize {

    return 0;
}

fn run_part2(_: anytype) !usize {
    return 0;
}

pub fn main() !void {
    const p1 = try run_part1(inputfile);
    const p2 = try run_part2(inputfile);

    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}


test "input1" {
    try std.testing.expectEqual(1227775554, run_part1(example_input));
}

test "input2" {
    try std.testing.expectEqual(4174379265, run_part2(example_input));
}

test "star1" {
    try std.testing.expectEqual(44854383294, run_part1(inputfile));
}

test "star2" {
    try std.testing.expectEqual(55647141923, run_part2(inputfile));
}
