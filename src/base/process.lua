-- 
-- process.lua
-- Helper functions to execute processes and retrieve the stderr, stdout data and the return code
-- Copyright (c) 2009 Vinzenz Feenstra
-- 

premake.process = {}

--
-- Run a process and retrieve the output from stdout, stderr and the return code of the process
-- 
-- options:
--  `process` process which should be executed {mandatory}
--  `args`    a list of arguments which should be passed {optional}
--  `stdin`   a string which will be written to the stdin of the process execute {optional}
--
function premake.process.execute( options )

    local process   = options.process 
    local proc_args = options.args

    local in_read,  in_write  = io.pipe()
    local out_read, out_write = io.pipe()
    local err_read, err_write = io.pipe()

    local arguments = {
            command= process,
            stdin  = in_read,
            stdout = out_write,
            stderr = err_write
    }

    if proc_args then
        arguments.args = proc_args
    end

    local proc = os.spawn(arguments)
    
    in_read:close()
    out_write:close()
    err_write:close()

    local out  = nil
    local err  = nil
    local code = nil

    if proc then

        if options.stdin then
            in_write:write( options.stdin )
        end
      
        err  = err_read:read "*all"
        out  = out_read:read "*all"
        code = proc:wait()

    end           
    
    in_write:close()
    err_read:close() 
    out_read:close()

    return out, err, code

end 


