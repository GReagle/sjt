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

while true do
	r = posix.poll(fds, -1)
	if r == 0 then  -- timeout
		break
	elseif r == 1 then
		if  fds[tail_out_fd].revents.IN then
			io.write(tail_out:read('*l') .. '\a\n')
		end
		if  fds[stdin_fd].revents.IN then
			in_fifo:write(io.read('*l'))
		end
	else
		print "finish!"
		break
	end
end

tail_out:flush()
tail_out:close()
in_fifo:flush()
in_fifo:close()
