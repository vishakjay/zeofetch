const std = @import("std");
const u = @cImport({
    @cInclude("unistd.h");
});
const s = @cImport({
    @cInclude("sys/types.h");
});
const st = @cImport({
    @cInclude("stdio.h");
});
const ArrayList = std.ArrayList;
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const path = "/etc/pop-os/os-release";
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    const writer = line.writer();
    var line_no: usize = 0;

    while (reader.streamUntilDelimiter(writer, '\n', null)) {
        defer line.clearRetainingCapacity();
        line_no += 1;
        //std.debug.print("{s}", .{line.items});
    } else |err| switch (err) {
        error.EndOfStream => { // end of file
            if (line.items.len > 0) {
                line_no += 1;
                std.debug.print("OS: {s}\n", .{line.items});
            }
        },
        else => return err, // Propagate error
    }
    // HOSTNAME AND USERNAME
    const envVarUserName = "LOGNAME";
    var uName: []const u8 = "";
    const userName: ?[:0]const u8 = std.posix.getenv(envVarUserName);
    if (userName) |username| {
        uName = username;
    } else {
        std.debug.print("The USER environment variable is not set\n", .{});
    }

    const envVarShell: []const u8 = "SHELL";
    var shName: []const u8 = "";
    const shellName: ?[]const u8 = std.posix.getenv(envVarShell);

    if (shellName) |shellname| {
        shName = shellname;
    }

    //std.debug.print("{}", .{@TypeOf(std.ChildProcess)});
    const argv = [_][]const u8{ "grep", "-m", "1", "model name", "/proc/cpuinfo" };

    var gen_allocator: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gen_allocator.deinit();
    const allocator_1 = gen_allocator.allocator();

    var child = std.process.Child.init(&argv, allocator_1);
    child.stdout_behavior = .Pipe;
    try child.spawn();
    const child_stdout = child.stdout.?.reader();

    var buf: [1024]u8 = undefined;
    var cpu_len: usize = undefined;
    while (true) {
        cpu_len = try child_stdout.readAll(&buf);
        //std.debug.print("CPU: {s}", .{buf[0..len]});
        if (cpu_len < buf.len) break;
    }
    _ = try child.wait();
    //std.debug.print("Shell: {s}\n ", .{shName[9..shName.len]});

    const argv_hostname = [_][]const u8{"hostname"};

    var child_hostname = std.process.Child.init(&argv_hostname, allocator_1);
    child_hostname.stdout_behavior = .Pipe;
    try child_hostname.spawn();
    const child_stdout_hostname = child_hostname.stdout.?.reader();

    var buf_hostname: [1024]u8 = undefined;
    var hname_len: usize = undefined;
    while (true) {
        hname_len = try child_stdout_hostname.readAll(&buf_hostname);
        //std.debug.print("{s}@{s}", .{ uName, buf_hostname[0..len] });
        if (hname_len < buf_hostname.len) break;
    }
    _ = try child_hostname.wait();

    const argv_os = [_][]const u8{ "cat", "/etc/issue.net" };
    var child_os = std.process.Child.init(&argv_os, allocator_1);
    child_os.stdout_behavior = .Pipe;
    try child_os.spawn();
    const child_stdout_os = child_os.stdout.?.reader();

    var buf_os: [1024]u8 = undefined;
    var osname_len: usize = undefined;
    while (true) {
        osname_len = try child_stdout_os.readAll(&buf_os);
        //        std.debug.print("OS: {s}\n", .{buf_os[0..osname_len]});
        if (osname_len < buf_os.len) break;
    }
    _ = try child_os.wait();

    //KERNAL
    const argv_kernal = [_][]const u8{ "uname", "-srm" };

    var child_kernal = std.process.Child.init(&argv_kernal, allocator_1);
    child_kernal.stdout_behavior = .Pipe;
    try child_kernal.spawn();
    const child_stdout_kernal = child_kernal.stdout.?.reader();

    var buf_kernal: [1024]u8 = undefined;
    var ker_len: usize = undefined;
    while (true) {
        ker_len = try child_stdout_kernal.readAll(&buf_kernal);
        //std.debug.print("Kernal: {s}\n", .{buf_kernal[5..len]});
        if (ker_len < buf_kernal.len) break;
    }
    _ = try child_kernal.wait();
    //UPTIME
    const argv_uptime = [_][]const u8{ "uptime", "-p" };

    var child_uptime = std.process.Child.init(&argv_uptime, allocator_1);
    child_uptime.stdout_behavior = .Pipe;
    try child_uptime.spawn();
    const child_stdout_uptime = child_uptime.stdout.?.reader();

    var buf_uptime: [1024]u8 = undefined;
    var uptime_len: usize = undefined;

    while (true) {
        uptime_len = try child_stdout_uptime.readAll(&buf_uptime);
        //std.debug.print("Uptime: {s}\n", .{buf_uptime[0..len]});
        if (uptime_len < buf_uptime.len) break;
    }
    _ = try child_uptime.wait();

    //WINDOW MANAGER
    const envVarWMName = "DESKTOP_SESSION";
    var wmName: []const u8 = "";
    const windManName: ?[:0]const u8 = std.posix.getenv(envVarWMName);

    if (windManName) |wmname| {
        wmName = wmname;
    } else {
        std.debug.print("The desktop session environment variable is not set\n", .{});
    }
    //std.debug.print("Window Manager: {s}\n\n", .{wmName});
    //TERMINAL
    const envVarTerName = "TERM";
    var tName: []const u8 = "";
    const termName: ?[:0]const u8 = std.posix.getenv(envVarTerName);

    if (termName) |termname| {
        tName = termname;
    } else {
        std.debug.print("The TERM environment variable is not set\n", .{});
    }
    // std.debug.print("Terminal: {s}\n\n", .{tName});
    const argv_battery = [_][]const u8{"acpi"};

    var child_battery = std.process.Child.init(&argv_battery, allocator_1);
    child_battery.stdout_behavior = .Pipe;
    try child_battery.spawn();
    const child_stdout_battery = child_battery.stdout.?.reader();

    var buf_battery: [1024]u8 = undefined;
    var battery_len: usize = undefined;
    while (true) {
        battery_len = try child_stdout_battery.readAll(&buf_battery);
        //std.debug.print("Kernal: {s}\n", .{buf_kernal[5..len]});
        if (battery_len < buf_battery.len) break;
    }
    _ = try child_battery.wait();

    var pipefd: [2]c_int = undefined; // Define the pipefd array
    var pid: u.pid_t = undefined;

    // Create pipe
    if (u.pipe(&pipefd[0]) == -1) { // Pass the pointer to the array
        st.perror("pipe");
        return;
    }

    // Create child process
    pid = u.fork();
    if (pid == -1) {
        st.perror("fork");
        return;
    } else if (pid == 0) {
        // Child process: execute 'echo "hello"' and write to pipe
        _ = u.close(pipefd[0]); // Close unused read end
        _ = u.dup2(pipefd[1], 1); // Redirect stdout to pipe write end (1 is STDOUT_FILENO)
        _ = u.close(pipefd[1]); // Close original pipe write end

        // Execute echo command
        const ptr: ?*u8 = null;
        _ = u.execlp("lspci", "lspci", ptr);
        st.perror("execlp");
        return;
    } else {
        // Parent process: execute 'grep h' and read from pipe
        _ = u.close(pipefd[1]); // Close unused write end
        _ = u.dup2(pipefd[0], 0); // Redirect stdin to pipe read end (0 is STDIN_FILENO)
        _ = u.close(pipefd[0]); // Close original pipe read end

        // Execute grep command
        const ptr: ?*u8 = null;

        const line1: []const u8 = "@@@@@@@#*@##**%%+####*+##+*#+%%@@@@@@@@%"; //vishak@pop-os
        const line2: []const u8 = "@@@@@@@@#%*+#*#@=%***%%%-*+=*%%@@@@@@@@%";
        const line3: []const u8 = "@@@@@#%@@##-+#*%##*%%*#=**.=##@@@@@@@@@%";
        const line4: []const u8 = "@@@@@@%**=+*:*#*#*+**+=**.:=*@@@@@@@@@@%"; //Kernel
        const line5: []const u8 = "@@@@@@@@*::=+:-=++=*++==:-=*@@@@@@@@@@@%";
        const line6: []const u8 = "@@@@@@@@@%=.:..::-=-..--=+#@@@@@@@@@@@@%";
        const line7: []const u8 = "@@@@@@@@@@@#--%#==-:-*@@*+%@@@@@@@@@@@@%"; //Uptime
        const line8: []const u8 = "@@@@@@@@@@@%--##%@#*+%@*+=%@@@@@@@@@@@@%";
        const line9: []const u8 = "@@@@@@@@@@%%=-++##****+++#%@@@@@@@@@@@@%";
        const line10: []const u8 = "%%%%%%%%%%@@*.=*-:+#+-*#=%@%%%%%%%%%%%%%"; //Shell
        const line11: []const u8 = "%%%%%%%%%%*-   =%@*%%*%=+#%@@@%%%%%%%%%#";
        const line12: []const u8 = "%%%%%%%%*:      .+#+*#--###%%@@@##%%%%%#";
        const line13: []const u8 = "%%%%%#**#.        :--: +#%%@%##%%%######"; //Wm
        const line14: []const u8 = "%###**#**=            #@@@@@@@%**@@@@%%%";
        const line15: []const u8 = "#%%%@@@@#%#:         *@@@@@@@@@@@@@@@@@%";
        const line16: []const u8 = "%@@@@%%%%@@%=   ....-@@%@@@@@@@@@@%#%@%#"; //Terminal
        const line17: []const u8 = "####**%%%@@@@%*#@@%%%%@@@@@@@@@@@@@%-  .";
        const line18: []const u8 = "--..=%@@@@##@@@@@@@###@@@@@@@@@@@@*=.+##";
        const line19: []const u8 = "=##%-:=+*#*#%%%%%#*+*++*%%@@@@@@#:  *@@%"; //CPU
        const line20: []const u8 = "@@@@@= .::-=------=##%=::=++**+-    =%@@";
        const line21: []const u8 = "@%@@%=       .-+#%@@%@@@@@*##*+:-=%- =*%";
        const line22: []const u8 = "@@@@%:  .:.-###@@%#=:-*#@@#%@@*=++=:+*=="; //GPU
        const line23: []const u8 = "%@@@#*: :.=#%@*==.:-:..::-=@@%@*::.+***=";
        const line24: []const u8 = "%@@%+**:.:-+*=-   .:. ..  .=%@@+::+*****";
        const line25: []const u8 = "###+****===:-. .:=*+:-**+-:..:-==+***+*+"; //Battery life
        const line26: []const u8 = ".:-+++++*-.:   .:-:=+*==++**=-=++******+";
        const line27: []const u8 = "-++=-====-..:.-*+*#%#*##@%#*%@%*++++++++";
        const line28: []const u8 = "*++====---#%#%*+--=*+*######%%@%++++++++"; //OS
        const line29: []const u8 = "+++=-----=%@@@#*++#%*+=:-=*%%%@@++++++++";
        const line30: []const u8 = "====--===-*#@@#@%%@#*+%%#+#%@@#*====+++=";
        const line31: []const u8 = "==-=====-*#+=*+*%%%#%@%@%@%*#*+%=--=====";
        const line32: []const u8 = "==----==-=+=.:+++*+**+++++++=:-=--==----";
        const line33: []const u8 = "---:::::..::.=+**+==-:-=====-:::..::----";
        std.debug.print("\t\t\t\t\t\t{s}@{s}", .{ uName, buf_hostname[0..hname_len] });
        std.debug.print("====================================================================================\n", .{});
        std.debug.print("{s}\n{s}\n{s}\n{s}\tKernel: {s}{s}\n{s}\n{s}\tUptime: {s}{s}\n{s}\n{s}\tShell: {s}\n{s}\n{s}\n{s}\tWM: {s}\n{s}\n{s}\n{s}\tTerminal: {s}\n{s}\n{s}\n{s}\tCPU: {s}{s}\n{s}\n{s}\t{s}{s}\n{s}\n{s}", .{
            line1,
            line2,
            line3,
            line4,
            buf_kernal[5..ker_len],
            line5,
            line6,
            line7,
            buf_uptime[5..uptime_len],
            line8,
            line9,
            line10,
            shName,
            line11,
            line12,
            line13,
            wmName,
            line14,
            line15,
            line16,
            tName,
            line17,
            line18,
            line19,
            buf[0..cpu_len],
            line20,
            line21,
            line22,
            buf_battery[0..battery_len],
            line23,
            line24,
            line25,
        });
        std.debug.print("\tOS: {s}{s}\n{s}\n{s}\n{s}\n{s}\n{s}\n{s}\n{s}\n", .{ buf_os[0..osname_len], line26, line27, line28, line29, line30, line31, line32, line33 });
        std.debug.print("\t\t\t\t\t\t", .{});
        _ = u.execlp("grep", "grep", "NVIDIA", ptr);

        st.perror("execlp");
    }
    std.debug.print("==============================================================", .{});

    //GPU
    //MEMORY
    // Handle the case where the environment variable doesn't exis
    // Handle the case where the environment variable doesn't exist
}
//var:uName username: $LOGNAME
// OS: /etc/issue.net (done)
// Host : $HOSTNAME
// Kernal: uname -srm
// Uptime: uptime -p
// Shell :$0
// Resolution:
// WM: wmctrl -m
// var: tName Terminal: $TERM
// CPU: /proc/cpuinfo
// GPU: lshw -C display
// Memory:/proc/meminfo
