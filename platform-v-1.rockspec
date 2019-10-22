package = "platform"

version = "v-1"

source = {
   url = "git://github.com/shmel1k/platform.git",
   branch = "master"
}

description = {
   summary = "Citymobil Tarantool platform.",
   detailed = [[
        This is a Citymobil Tarantool platform. It should be used when
        you want to create your own tarantool and dont know how to add
        timings or some kind of monitoring.
   ]],
   homepage = "https://gitlab.city-mobil.ru",
   license = "Citymobil LLC"
}

dependencies = {
    "lua >= 5.1, < 5.4",
    "metrics >= 1.0.0",
    "http >= 1.0.0",
}

build = {
    type = "builtin",
    modules = {
        ['platform'] = 'platform.lua',
    }
}
