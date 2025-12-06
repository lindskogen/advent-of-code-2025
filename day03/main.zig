const std = @import("std");

const example_input =
    \\987654321111111
    \\811111111111119
    \\234234234234278
    \\818181911112111
;

const inputfile = @embedFile("input");

fn run_part1(input: anytype) !usize {
    var lineIter = std.mem.tokenizeScalar(u8, input, '\n');
    var sum: usize = 0;

    while (lineIter.next()) |line| {
        var max: usize = 0;
        for (0..line.len) |i| {
            for (i + 1..line.len) |j| {
                const cand = (line[i] - '0') * 10 + (line[j] - '0');
                if (cand > max) {
                    max = cand;
                }
            }
        }

        sum += max;
    }

    return sum;
}

const State = struct { nbrs: [12]u8, indices_idx: usize, line_idx: usize };

fn evaluate(nbrs: []const u8) usize {
    var collect: usize = 0;
    for (0..nbrs.len) |i| {
        const c = nbrs[i];
        collect += (c - '0') * std.math.pow(usize, 10, 11 - i);
    }
    return collect;
}

fn run_part2(comptime input: anytype) !usize {
    var lineIter = std.mem.tokenizeScalar(u8, input, '\n');
    var sum: usize = 0;
    const wanted = 12;

    while (lineIter.next()) |line| {
        var nbrs: [12]u8 = undefined;
        var selected: usize = 0;
        var pos: usize = 0;

        while (selected < wanted) {
            const remaining = (wanted - selected - 1);
            var best_pos = pos;
            const end_index = @min(line.len - remaining, line.len);

            for (pos..end_index) |i| {
                if (line[i] > line[best_pos]) {
                    best_pos = i;
                }
            }

            nbrs[selected] = line[best_pos];
            pos = best_pos + 1;
            selected += 1;
        }

        sum += evaluate(&nbrs);
    }

    return sum;
}

pub fn main() !void {
    const p1 = try run_part1(inputfile);
    const p2 = try run_part2(inputfile);

    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

test "input1" {
    try std.testing.expectEqual(357, run_part1(example_input));
}
test "evaluate" {
    try std.testing.expectEqual(987654321111, evaluate("987654321111"));
    try std.testing.expectEqual(888911112111, evaluate("888911112111"));
}

test "input2" {
    try std.testing.expectEqual(3121910778619, run_part2(example_input));
}

test "star 1" {
    try std.testing.expectEqual(17694, run_part1(inputfile));
}

test "star 2" {
    try std.testing.expectEqual(175659236361660, run_part2(inputfile));
}
