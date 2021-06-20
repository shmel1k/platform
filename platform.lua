require('strict').on()

log = require('log')
clock = require('clock')
metrics = require('metrics')
math = require('math')

metrics.enable_default_metrics()

local httpd = require('http.server')
local http_handler = require('metrics.plugins.prometheus').collect_http

local INF = math.huge
local DEFAULT_BUCKETS = {.0001, .0005, .001, .005, .01, .025, .05, .075, .1, .25, .5, 1, INF}

local function_execution_time = metrics.histogram('metrics_function_execution_time', 'Real execution time', DEFAULT_BUCKETS)
local function_cpu_execution_time = metrics.histogram('metrics_function_cpu_execution_time', 'Spent only cpu time', DEFAULT_BUCKETS)
local requests_error_counter = metrics.counter('requests_error_total')

local function start_metrics_server(port)
    local server = httpd.new('0.0.0.0', port)
    local router = require('http.router').new({})
    router:route({
        path = '/metrics',
        public = true,
        method = 'GET',
    }, http_handler)
    server:set_router(router)
    server:start()
end

local function execution(func)
    return function(...)
        return pcall(func)
    end
end

local ABS = math.abs

local function wrap_func(function_name, func)
    return function(...)
        local start = clock.monotonic()
        local response = clock.bench(execution(func), ...)
        local finish = clock.monotonic()

        local diff = ABS(finish - start)
        function_execution_time:observe(diff, {
            method = function_name,
        })

        local exec_time = ABS(response[1])
        function_cpu_execution_time:observe(exec_time, {
            method = function_name,
        })
        if not response[2] then
            requests_error_counter:inc(1, {method = function_name})
            error(..., 2)
        end

        return response[3]
    end
end

local function init(options)
    local tbl = _G
    for k, v in pairs(options.functions) do
        -- TODO(a.petrukhin): add roles.
        -- TODO(a.petrukhin): probably improve function wrapping.
        box.schema.func.create(k, {setuid = true, if_not_exists = true})
        rawset(tbl, k, v)
    end
end

return {
    init = init,
    start_metrics_server = start_metrics_server,
    wrap_func = wrap_func,
}
