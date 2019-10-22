mkdir -p /usr/local/etc/luarocks/

echo "rocks_trees = {
   { name = [[user]], root = home..[[/.luarocks]] },
   { name = [[system]], root = [[/usr/local]] }
}

rocks_servers = {[[http://rocks.tarantool.org/]]}" >> /usr/local/etc/luarocks/config-5.1.lua
luarocks install metrics
luarocks install https://raw.githubusercontent.com/shmel1k/platform/master/platform-v-1.rockspec
