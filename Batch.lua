function list_iter (t)
	local i = 0
	--local n = table.getn(t)
	local n = #t
	return function ()
		i = i + 1
		if i <= n then return t[i] end
	end
end

function print(v)
	tas.print(v)
end

local declaredNames = {tas, nil, arg}
function declare (name, initval)
  rawset(_G, name, initval)
  declaredNames[name] = true
end
setmetatable(_G, {
  __newindex = function (t, n, v)
	if not declaredNames[n] then
	  error("attempt to write to undeclared var. "..n, 2)
	else
	  rawset(t, n, v)   -- do the actual set
	end
  end,
  __index = function (_, n)
	if not declaredNames[n] then
	  error("attempt to read undeclared var. "..n, 2)
	else
	  return nil
	end
  end,
})

declare "send_alert"
function send_alert(msg)
	tas.fail("ALERT:" .. msg)

	tas.ExtCtr_SendMessage("ALERT", msg)
end

declare "send_critical_stop"
function send_critical_stop(msg)
	tas.fail("CRITICAL_STOP:" .. msg)

	tas.ExtCtr_SendMessage("CRITICALSTOP", msg)
end


declare "send_signal_cyclic_egolf"
function send_signal_cyclic_egolf()
	while true do
		tas.write("can1.BMC_Control_01/BMC_SYNC_CMC",0)
		tas.wait(10)
		tas.write("can1.BMC_Control_01/BMC_SYNC_CMC",0)
		tas.wait(10)
		tas.write("can1.BMC_Control_01/BMC_SYNC_CMC",1)
		tas.wait(10)
	end
end

declare "send_signal_cyclic_vw12s1p"
function send_signal_cyclic_vw12s1p()
	while true do
		tas.write("can1.BMC_Control_01/BMC_SYNC_CMC",0)
		tas.wait(10)
		tas.write("can1.BMC_Control_01/BMC_SYNC_CMC",0)
		tas.wait(10)
		tas.write("can1.BMC_Control_01/BMC_SYNC_CMC",1)
		tas.wait(10)
	end
end

declare "task_check_barcode_and_send_to_ui"
function task_check_barcode_and_send_to_ui()
	while true do
		local ocode = tas.readstring("barcode.o_code")
		if ocode ~= nil and ocode ~= "" then
			tas.write("barcode.clear", 1)
			tas.ExtCtr_SendMessage("BARCODE", ocode)
		end
		tas.wait(100)
	end
end

declare "task_critical_stop_check"
function task_critical_stop_check()
	local prevCriticalStopStatus = false
	while true do
		if prevCriticalStopStatus == false then
			if tas.read("smartio.di_4") == 1 then --
				prevCriticalStopStatus = true
				send_critical_stop("EMERGENCY BUTTON PRESSED!!")
			end
		else
			if tas.read("smartio.di_4") == 0 then -- 원상복구 되면
				prevCriticalStopStatus = false
			end
		end
		tas.wait(100)
	end
end

-- share.light_curtain_state

declare "task_lightcurtain_check"
function task_lightcurtain_check()
	local prevLightCurtainStatus = false
	while true do
		--if prevLightCurtainStatus == false then
		--	if tas.read("smartio.di_3") == 0 then --
		--		prevLightCurtainStatus = true
		--		send_critical_stop("Light Curtain Detected!!")
		--	end
		--else
		--	if tas.read("smartio.di_3") == 1 then -- 원상복구 되면
		--		prevLightCurtainStatus = false
		--	end
		--end
		if tas.readstring("share.light_curtain_state") == 1 then
			if tas.read("smartio.di_3") == 0 then
				send_critical_stop("Light Curtain Detected!!")
				tas.writestring("share.light_curtain_state", 0)
			end
		else
			if tas.read("smartio.di_3") == 1 then
				tas.writestring("share.light_curtain_state", 1) -- 원상복귀 되면
			end
		end
		tas.wait(100)
	end
end

