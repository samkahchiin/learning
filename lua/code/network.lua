require 'luasocket'

host = 'www.w3.org'
file = '/TR/REC-html32.html'

c = assert(socket.connect(host, 80))
c:send("GET " .. file .. " HTTP/1.0\r\n\r\n")
c.close()


-- Coroutine network
function download (host, file)
  local c = assert(socket.connect(host, 80))
  local count = 0    -- counts number of bytes read
  c:send("GET " .. file .. " HTTP/1.0\r\n\r\n")
  while true do
    local s, status = receive(c)
    count = count + string.len(s)
    if status == "closed" then break end
  end
  c:close()
  print(file, count)
end


-- Thread
threads = {}    -- list of all live threads
function get (host, file)
  -- create coroutine
  local co = coroutine.create(function ()
    download(host, file)
  end)
  -- insert it in the list
  table.insert(threads, co)
end


function dispatcher ()
  while true do
    local n = table.getn(threads)
    if n == 0 then break end   -- no more threads to run
    for i=1,n do
      local status, res = coroutine.resume(threads[i])
      if not res then    -- thread finished its task?
        table.remove(threads, i)
        break
      end
    end
  end
end