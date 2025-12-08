const std = @import("std");

const example_input = "123 328  51 64 \n 45 64  387 23 \n  6 98  215 314\n*   +   *   +  ";

const inputfile = @embedFile("input");

fn run_part1(input: anytype) !usize {
    var operators: [1000]u8 = undefined;
    var calculations: [1000]usize = undefined;
    var lineIter = std.mem.tokenizeScalar(u8, input, '\n');
    var cols: usize = 0;

    while (lineIter.next()) |line| {
        if (line[0] == '*' or line[0] == '+') {
            var nbrIter = std.mem.tokenizeScalar(u8, line, ' ');
            var col: usize = 0;

            while (nbrIter.next()) |sym| {
                operators[col] = sym[0];
                col += 1;
            }
            cols = col;
            break;
        }
    }

    lineIter.reset();

    var firstLine = true;
    outer: while (lineIter.next()) |line| {
        var nbrIter = std.mem.tokenizeScalar(u8, line, ' ');
        var col: usize = 0;
        while (nbrIter.next()) |nbr| {
            if (nbr[0] == '*' or nbr[0] == '+') {
                break :outer;
                // reached the end. Now do math!
            }
            const num = try std.fmt.parseInt(usize, nbr, 10);
            if (firstLine) {
                calculations[col] = num;
            } else if (operators[col] == '+') {
                calculations[col] += num;
            } else if (operators[col] == '*') {
                calculations[col] *= num;
            } else {
                std.debug.print("Unhandled: {c}\n", .{operators[col]});
                @panic("Unhandled operator!");
            }
            col += 1;
        }
        firstLine = false;
    }

    var sum: usize = 0;

    for (calculations[0..cols]) |num| {
        sum += num;
    }

    return sum;
}

fn run_part2(input: anytype) !usize {
    const lines_count = std.mem.count(u8, input, "\n") + 1;
    const line_length = std.mem.indexOfScalar(u8, input, '\n') orelse return error.NoNewlineFound;

    var pos = line_length - 1;

    var sum: usize = 0;

    var nbrs: [10]usize = undefined;
    var nbrs_count: usize = 0;
    while (pos >= 0) {
        var buf: [4]u8 = undefined;
        var buf_idx: usize = 0;
        for (0..lines_count) |line_index| {
            const c = input[(line_length + 1) * line_index + pos];

            if (line_index == lines_count - 1 and c == ' ') {
                // last line, parse number in buf and add to nbrs
                const num = try std.fmt.parseInt(usize, buf[0..buf_idx], 10);

                nbrs[nbrs_count] = num;
                nbrs_count += 1;
            } else if (c == '*' or c == '+') {
                // parse number in buf and produce a number from nbrs
                const num = try std.fmt.parseInt(usize, buf[0..buf_idx], 10);

                nbrs[nbrs_count] = num;
                nbrs_count += 1;

                if (c == '*') {
                    var product: usize = 1;
                    for (nbrs[0..nbrs_count]) |n| {
                        product *= n;
                    }
                    sum += product;
                } else if (c == '+') {
                    var local_sum: usize = 0;
                    for (nbrs[0..nbrs_count]) |n| {
                        local_sum += n;
                    }
                    sum += local_sum;
                } else {
                    std.debug.print("Unhandled: {c}\n", .{c});
                    @panic("Unhandled operator!");
                }
                nbrs_count = 0;
                if (pos == 0) {
                    break;
                }
                pos -= 1;
            } else if (c == ' ') {
                // skip whitespace
            } else if (std.ascii.isDigit(c)) {
                // append number to buf
                buf[buf_idx] = c;
                buf_idx += 1;
                // std.debug.print("adding {c} to buf\n", .{ c });
            } else {
                std.debug.print("Found unhandled char: {c}\n", .{c});
                @panic("Unhandled char!");
            }
        }

        if (pos == 0) {
            break;
        }
        pos -= 1;
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
    try std.testing.expectEqual(4277556, run_part1(example_input));
}

test "input2" {
    try std.testing.expectEqual(3263827, run_part2(example_input));
}

test "star1" {
    try std.testing.expectEqual(5782351442566, run_part1(inputfile));
}

test "star2" {
    try std.testing.expectEqual(55647141923, run_part2(inputfile));
}
