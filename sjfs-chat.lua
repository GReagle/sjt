#!/usr/bin/env lua
require('strict')
posix = require('posix')

tail_out = assert(io.popen('tail -n +0 -f out', 'r'))
assert(tail_out:setvbuf('no'))
tail_out_fd = posix.fileno(tail_out)

stdin_fd = posix.fileno(io.stdin)

fds = {
	[tail_out_fd] = { events = {IN=true} },
	[stdin_fd] = { events = {IN=true} }
}

in_fifo = io.open('in', 'w')
assert(in_fifo:setvbuf('no'))

--os.execute("stty cbreak")
line = ''
while true do
	r = posix.poll(fds, -1)
	if r == 0 then  -- timeout
		break
	elseif r == 1 then
		if  fds[tail_out_fd].revents.IN then
			io.write(tail_out:read('*l') .. '\n') -- '\a' for bell
		end
		if  fds[stdin_fd].revents.IN then
			in_fifo:write(io.read('*l'))
			--[[
			c = io.read(1)
			if c == '\n' then
				in_fifo:write(line)
				line = ''
			elseif c == 't' then
				io.write('\x1b[D')
				--os.execute("tput cub1")
				--os.execute("tput kcub1")
			else
				line = line .. c
			end
			]]
		end
	else
		print "finish!"
		break
	end
end
--os.execute("stty -cbreak");

tail_out:flush()
tail_out:close()
in_fifo:flush()
in_fifo:close()
