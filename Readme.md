# sjt - Simple Jabber Tools

## Summary

User interfaces for simple jabber.  An attempt to produces some easy-to-use
front ends for simple jabber.  Of course it depends on and requires
[sj](https://github.com/younix/sj).

## Getting, building, installing

To download, `git clone https://github.com/GReagle/sjt`.  All programs are
interpreted, so there is no need to build/compile.  I add the sjt directory
to my $PATH, and that is the only step in installation.  If you want to,
you can copy the programs to /usr/local/bin or whatever you fancy; I don't
bother with that since I change the programs so much.

## Runtime dependencies

Some of the scripts are written in rc, which you can get from [9base](http://tools.suckless.org/9base) or [Plan 9 from User Space](https://github.com/9fans/plan9port).  The [version of rc written by Byron Rakitzis](http://tobold.org/article/rc) is, unfortunately, incompatible (`else` versus `if not`).

sj-many-windows requires [runit](http://smarden.org/runit/) to ensure that
there is at most one window per chat.

Some of the sjfs commands can use notify-send (on my system in package
libnotify-bin), but it is optional.  Unset the environment variable
note_time to disable.

## sjfs - Simple Jabber From Shell

The sjfs commands are a command line interface (CLI) for simple jabber.
Some of them happen to be written in shell script, but that is not what
"from shell" means; it means that they are intended to be used *from your
shell*.

### Using sjfs

Start with `sjfs-connect` (which runs `sj`), and keep that running as long as
you want to be connected.  It will ask for your pasword (because it runs
sj).  Don't forget to set the SJ_ variables or use the drsu options; `man
sj` for details.  `sjfs-connect` will not automtically run in the background
(i.e. it stays in the foreground), so if you need to get your shell prompt
back while staying connected, run it in its own terminal emulator window or
use a tool like dvtm, tmux, dtach, or abduco.  When you want to close
the connection, interrupt/kill `sjfs-connect` by hitting Control-C.

Once you are connected, you can run the rest of the sjfs commands at will.

## sj-many-windows - using the window manager for the GUI

`sj-many-windows` creates a new terminal emulator window (e.g. xterm or st)
for every function and chat.  This takes advantage of the fact that a
window manager can make a window blink when a bell character (Control-g or
code 7) is displayed, so this is a form of notification for new messages.
In xterm, this is controlled by "Enable Bell Urgency", and on my system is
off by default.

If you interrupt/kill `sj-many-windows`, it will shut down everything.
However, you can close any of the other windows that pop up if you wish.
Of course if you close the "connect" window you will lose your connection.

`sj-many-windows` interoperates well with sjfs commands in general; you can
mix them together.  For example, if you have started `sj-many-windows`, you
can still run `sjfs-online-buddies` or `sjfs-chat` whenever you want.

## runtime configuration via environment variables

Many of the commands use environment variables for runtime configuration.
See the beginning of the script for such variables.  For example: `env
DEBUG=1 note_time=200 sjfs-monitor-all-chats`
