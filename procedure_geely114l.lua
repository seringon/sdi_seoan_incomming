------------------------------------------------------------
-- Interface Implemeation Start
------------------------------------------------------------
declare "tcinfo_table_geely114l"
tcinfo_table_geely114l = {}
declare "param_table_geely114l"
param_table_geely114l = {}
declare "h_sync_task_geely114l"
h_sync_task_geely114l = nil

declare "change_test_model_geely114l"
function change_test_model_geely114l()
	tas.writestring("can1.@reopen",  "BaudRate=500000, Node=BMS, DB=C:\\Users\\abc\\Desktop\\TAS_Project\\CAN\\GEELY_BP114L_V02_tas.xml, FrameDB=GEELY_BP114L_V02_xnet, RevDir=0, TransceiverType=HS, Termination=1, ListenOnly=0, ReadInterval=10")
	dbc_load(2)
end

declare "set_param_geely114l"
function set_param_geely114l(seqid, subseqid, param_name, value)
	param_table_geely114l[seqid .. "_" .. subseqid .. "_" .. param_name] = value
end

declare "get_param_geely114l"
function get_param_geely114l(seqid, subseqid, param_name, default_value)
	local ret = param_table_geely114l[seqid .. "_" .. subseqid .. "_" .. param_name]
	if ret == nil then
		return default_value
	else
		return ret
	end
end

declare "clear_param_geely114l"
function clear_param_geely114l()
	param_table_geely114l = {}
end

declare "manual_start_bmc_sync_geely114l"
function manual_start_bmc_sync_geely114l()
	--no need sync
end

declare "manual_stop_bmc_sync_geely114l"
function manual_stop_bmc_sync_geely114l()
	--no need sync
end

declare "manual_init1_geely114l"
function manual_init1_geely114l()
	tc_geely114l_1_init(true, 0)
end

declare "manual_init2_geely114l"
function manual_init2_geely114l()

end

declare "manual_init3_geely114l"
function manual_init3_geely114l()

end

declare "manual_cmc_id_assign_geely114l"
function manual_cmc_id_assign_geely114l(setid)

	CtrlBrd(RelaySet.Power.A0_SELIn, 1)
	manual_selin_freq(0, 0) -- 0V
	tas.wait(500)
			
	------------------- 2. ID Erase -------------------
	tas.writestring("can1.@frame:0x6C0", "0210830000000000")
	tas.wait(100)
	tas.writestring("can1.@frame:0x6C0", "043181F014000000")
	tas.wait(500)
	
	manual_selin_freq(12, 10) -- 12V, 10Hz, 50%
	tas.wait(1000)
	tas.write("ao_SEL_IN", 0) -- DAQ AO_0 set 0 volt
	tas.wait(200)
	
	------------------- 3. ID Assign -------------------
	tas.writestring("can1.@frame:0x6C0", "0210830000000000")
	tas.wait(100)
	tas.writestring("can1.@frame:0x6C0", "043181F014000000")
	tas.wait(100)
	tas.writestring("can1.@frame:0x6C0", "053181F019000000")
	tas.wait(100)
	
	--manual_selin_freq(12, 10)
	tas.writestring("ao_SEL_IN.square", "3, 3, 10, 0.5")
	tas.wait(200)
	
end

declare "manual_cmc_id_clear_geely114l"
function manual_cmc_id_clear_geely114l()

	CtrlBrd(RelaySet.Power.A0_SELIn, 1)
	manual_selin_freq(0, 0) -- 0V
	tas.wait(500)
			
	------------------- 2. ID Erase -------------------
	tas.writestring("can1.@frame:0x6C0", "0210830000000000")
	tas.wait(100)
	tas.writestring("can1.@frame:0x6C0", "043181F014000000")
	tas.wait(500)
	
	manual_selin_freq(12, 10) -- 12V, 10Hz, 50%
	tas.wait(100)
end

declare "manual_get_version_read_geely114l"
function manual_get_version_read_geely114l()

	------------------- 1. SW Version Check -------------------
	tas.writestring("can1.@frame:0x6B0", "0322F18900000000") -- request message
	tas.wait(100)
	
	byte_data = read_dev_msg(0x4B0) -- read SW Message

	read_value = ""
	if byte_data == nil or #byte_data < 8 then
		read_value = "NIL"
	else
		for idx = 6, 8, 1 do
			read_value = read_value .. string.char(tonumber("0x"..byte_data[idx]))
		end
	end
	
	tas.writestring("can1.@frame:0x6B0", "3000000000000000") -- request message
	tas.wait(100)
	
	byte_data = read_dev_msg(0x4B0) -- read SW Message

	if byte_data == nil or #byte_data < 8 then
		read_value = "NIL"
	else
		for idx = 2, 6, 1 do
			read_value = read_value .. string.char(tonumber("0x"..byte_data[idx]))
		end
	end

	tas.writestring("share.swver", read_value)
	
	------------------- 2. HW Version Check -------------------
	tas.writestring("can1.@frame:0x6B0", "0322F19300000000") -- request message
	tas.wait(100)
	
	byte_data = read_dev_msg(0x4B0) -- read SW Message

	read_value = ""
	if byte_data == nil or #byte_data < 8 then
		read_value = "NIL"
	else
		for idx = 6, 8, 1 do
			read_value = read_value .. string.char(tonumber("0x"..byte_data[idx]))
		end
	end
	
	tas.writestring("share.hwver", read_value)
end

declare "manual_balancing_start_geely114l"
function manual_balancing_start_geely114l(bal_time_sec, ch_onoff_list)
	local chidx_10 = 0
	local chidx_1 = 0
	local msgidx = 1
	
	if #ch_onoff_list > 12 then -- if input channel is over 12 channel, then send error
		tas.fail("Balancing Channel Select Error(max channel:12)")
	else
		for chidx = 1, #ch_onoff_list, 1 do
			if ch_onoff_list[chidx] ~= nil and ch_onoff_list[chidx] == true then
				chidx_10 = math.floor(chidx/10)
				chidx_1 = chidx%10
				cmc_can_write("BMS_BMM_01_02", "BMS_BMM_01_ReqBalCell_"..chidx_10..chidx_1, tonumber(bal_time_sec))
			else
				chidx_10 = math.floor(chidx/10)
				chidx_1 = chidx%10
				cmc_can_write("BMS_BMM_01_02", "BMS_BMM_01_ReqBalCell_"..chidx_10..chidx_1, 0)
			end
			tas.wait(10)
		end
	end
end
declare "manual_balancing_stop_geely114l"
function manual_balancing_stop_geely114l()
	local bal_state = {false,false,false,false,false,false,false,false,false,false,false,false}
	manual_balancing_start_geely114l(0, bal_state)
end

declare "test_stop_geely114l"
function test_stop_geely114l()
	-- TODO:
	tc_geely114l_25_all_power_reset(true, 100)
	cylinder_up()
end
------------------------------------------------------------
-- Interface Implemeation FINISH
------------------------------------------------------------

--------------------------------------
-- Sync Message Send/Stop
--------------------------------------
declare "cmc_can_init_geely114l"
function cmc_can_init_geely114l()
	-- No Sync Message
	tas.write("can1.onoff", 1)
end

declare "cmc_can_finish_geely114l"
function cmc_can_finish_geely114l()
	-- No Sync Message
	tas.write("can1.onoff", 0)
end

-------------------------------------------------------------------------   
-- 1. Initialization   
-------------------------------------------------------------------------
declare "tc_geely114l_1_init"
function tc_geely114l_1_init(run, seqno)
	local tcid = 1
	local unit = ""
	local p_LVCurrent = 1
	
	if run == false then
		local tcinfo = {tcid, "Initialization_geely114l", "tc_geely114l_1_init",
					{1, "Init", unit}
				}
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
		
	test_start(tcid, seqno, 1)
	
	-- Cell Simulator CAN
	tas.write("can2.onoff", 1)

	-- CellSimulator CAN Enable
	CellSimulator_CAN(0, 1)
	
	-- power off
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 0)
	CtrlBrd(RelaySet.Power.LV_PWR_NEG, 0)
	LVPower_Volt(0)
	LVPower_Onoff(0)
	tas.wait(200)
	
	CtrlBrd(RelaySet.Power.A0_SELIn, 0)
	manual_selin_freq(0, 0)
	tas.wait(200)	
	
	-- cell simulator init
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, 0, 0, 0, 0)
	end
	
	CtrlBrd(RelaySet.Power.All_Off, 1) -- Control Board Reset
	tas.wait(200)
	
	-- Board Select
	CtrlBrd(RelaySet.Model.M12S1P, 1)

	CELL8_9_STACK(1) -- enable 8,9 Stack
	
	-- Control Board Connect(normal)
	for i = 10, 21, 1 do -- 10~21 is "Cell_CellSenGND~11" connect logic number in CtrlBrd function
		CtrlBrd(i, 1)
	end
	CtrlBrd(RelaySet.Cell.CellPOS_Cell12, 1)
	cap1_enable_sig(1) -- SEL OUT Pull Up
	cap2_enable_sig(1) -- SEL OUT Pull Down
	
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 1)
	CtrlBrd(RelaySet.Power.LV_PWR_NEG, 1)
	CtrlBrd(RelaySet.Power.A0_SELIn, 1)
	--CtrlBrd(RelaySet.Power.SELOut_3kohm, 1) -- SEL Out 3kohm connect
	CtrlBrd(RelaySet.Power.CAH_connect, 1) -- CAN Connect
	tas.wait(1000)
	
	-- cell simulator input
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, 3700, 3700, 3700, 3700)
	end
	tas.wait(500)
	
	-- Turn on Power
	LVPower_Curr(1)
	LVPower_Onoff(1)
	LVPower_Volt(12)
	tas.wait(500)
	--tas.wait(1000)

	-- initialization DUT CAN
	cmc_can_init_geely114l()
	
	--tas.writestring("ao_SEL_IN.square", "3, 3, 10, 0.5")
	manual_selin_freq(12, 10) --12V 10Hz 50%
	tas.wait(1000)
		
	test_finish(tcid, seqno, 1, "", true)
end

-------------------------------------------------------------------------   
--  2. Current_No ID   
-------------------------------------------------------------------------
declare "tc_geely114l_2_operating_current_measure"
function tc_geely114l_2_operating_current_measure(run, seqno)
	local tcid = 2
	local unit = "mA"
	
	-- default parameter
	local p_tol_min_lv = 50
	local p_tol_max_lv = 80
	local p_tol_min_hv = 6 --TODO: Report 데이터 기준, EOL시트는(10~30)
	local p_tol_max_hv = 15
	
	-- local variable
	local read_value = 0
	local result = false
	
	if run == false then
		local tcinfo = {tcid, "Current_No ID_geely114l", "tc_geely114l_2_operating_current_measure",
					{1, "LV Side Operating Current Measurement", unit, 
						{"Min", p_tol_min_lv, "Tolerance Min", "mA"},
						{"Max", p_tol_max_lv, "Tolerance Max", "mA"}
					},
					{2, "HV Side Operating Current Measurement", unit,
						{"Min", p_tol_min_hv, "Tolerance Min", "mA"},
						{"Max", p_tol_max_hv, "Tolerance Max", "mA"}
					}
				}
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min_lv = get_param_geely114l(seqno, 1, "Min", p_tol_min_lv)
	p_tol_max_lv = get_param_geely114l(seqno, 1, "Max", p_tol_max_lv)
	p_tol_min_hv = get_param_geely114l(seqno, 2, "Min", p_tol_min_hv)
	p_tol_max_hv = get_param_geely114l(seqno, 2, "Max", p_tol_max_hv)
	
	------------------- lv side operating current measure -------------------
	test_start(tcid, seqno, 1)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM Init
	CtrlBrd(RelaySet.DMMRly.VBATNegCurrMeasOn, 1) -- DMM LV Curr+ent measure mode on
	
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadCurr) * 1000 -- DMM Read Current
	read_value = read_value - read_value%0.0001
	if read_value >= p_tol_min_lv and read_value <= p_tol_max_lv then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM Reset
	CtrlBrd(RelaySet.Power.LV_PWR_NEG, 1)
	test_finish(tcid, seqno, 1, read_value, result)
	
	
	------------------- hv side operation current measure -------------------
	test_start(tcid, seqno, 2)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM Init
	CtrlBrd(RelaySet.DMMRly.HVPosCurrMeasOn, 1) -- DMM HV Current measure mode on
	tas.wait(1000)
	
	read_value = -1 * DMM_Set(DMM.ReadCurr) * 1000 -- DMM Read Current
	read_value = read_value - read_value%0.0001
	if read_value >= p_tol_min_hv and read_value <= p_tol_max_hv then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM Reset
	CtrlBrd(RelaySet.Cell.CellPOS_Cell12, 1)
	
	test_finish(tcid, seqno, 2, read_value, result)
end

-------------------------------------------------------------------------
--  3. CMC ID Assign
-------------------------------------------------------------------------
declare "tc_geely114l_3_id_assign"
function tc_geely114l_3_id_assign(run, seqno)
	local tcid = 3
	local unit_freq = "Hz"
	local unit_duty = "%"
	local unit_volt = "V"
	
	-- default parameter
	local p_tol_med_bmmmsg = 1
		--{HIghVolt, LowVolt, Frequency, Duty}
	local p_tol_min_selout = {4.5, 0, 9, 0.49}
	local p_tol_max_selout = {18, 2, 11, 0.51}
	
	-- local variable
	local readSELOut = nil
	local read_value = 0
	local result = false
	
	if run == false then
		local tcinfo = {tcid, "CMC ID Assign_geely114l", "tc_geely114l_3_id_assign",
					{1, "CMC CAN Message", "",
						{"Med", p_tol_med_bmmmsg, "Tolerance Med", ""}
					},
					{2, "SEL_OUT", "",
						{"Min", p_tol_min_selout[1], "Tolerance Min", unit_volt},
						{"Max", p_tol_max_selout[1], "Tolerance Max", unit_volt}
					},
					{3, "SEL_OUT Low", "",
						{"Min", p_tol_min_selout[2], "Tolerance Min", unit_volt},
						{"Max", p_tol_max_selout[2], "Tolerance Max", unit_volt}
					},
					{4, "SEL_OUT Frequency", "",
						{"Min", p_tol_min_selout[3], "Tolerance Min", unit_freq},
						{"Max", p_tol_max_selout[3], "Tolerance Max", unit_freq}
					},
					{5, "SEL_OUT Duty", "",
						{"Min", p_tol_min_selout[4], "Tolerance Min", unit_duty},
						{"Max", p_tol_max_selout[4], "Tolerance Max", unit_duty}
					}					
				}
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_med_bmmmsg = get_param_geely114l(seqno, 1, "Med", p_tol_med_bmmmsg)
	for idx = 1, 4 do
		p_tol_min_selout[idx] = get_param_geely114l(seqno, idx+1, "Min", p_tol_min_selout[idx])
		p_tol_max_selout[idx] = get_param_geely114l(seqno, idx+1, "Max", p_tol_max_selout[idx])
	end
	
	CtrlBrd(RelaySet.Power.A0_SELIn, 1)
	manual_selin_freq(0, 0) -- 0V
	tas.wait(500)
	
	test_start(tcid, seqno, 1)
	
	for idx = 1, 4, 1 do -- Retry with change wait time
		------------------- 2. ID Erase -------------------
		tas.writestring("can1.@frame:0x6C0", "0210830000000000")
		tas.wait(100)
		tas.writestring("can1.@frame:0x6C0", "043181F014000000")
		tas.wait(500)
		
		manual_selin_freq(12, 10) -- 12V, 10Hz, 50%
		tas.wait(1000)
		manual_selin_freq(0, 0) -- 0V
		tas.wait(200)
		
		------------------- 3. ID Assign -------------------
		tas.writestring("can1.@frame:0x6C0", "0210830000000000")
		tas.wait(100)
		tas.writestring("can1.@frame:0x6C0", "043181F014000000")
		tas.wait(100)
		tas.writestring("can1.@frame:0x6C0", "053181F019000000")
		tas.wait(100)
		
		manual_selin_freq(12, 10) -- 12V, 10Hz, 50%
		tas.wait(200)
		
		local readflag = 0
		readflag = tas.read("can1.BMM_01_01")
		
		local readmsg = {"0x410", "0x420", "0x430", "0x450", "0x460", "0x480", "0x4E0"}
		
		tas.wait(2000)
		
	--	for chkidx = 1,7,1 do
	--		local read_value = tas.readstring("can1.@frame:"..readmsg[chkidx])
	--		tas.progress(read_value)
	--		if read_value <= "" or read_value == nil then
	--			result = false
	--			break
	--		else
	--			result = true
	--			read_value = 1
	--		end	
	--	end
		if tas.read("can1.BMM_01_01") ~= readflag then
			read_value = 1
			result = true
			break
		else
			result = false
		end
	end
	test_finish(tcid, seqno, 1, read_value, result)
	
	------------------- 2. SEL_OUT Check -------------------	
	local selout_value = read_pwm_sel_out()
	
	for subidx = 1, 4 do
		test_start(tcid, seqno, subidx+1)
		
		read_value = selout_value[subidx]
		read_value = read_value - read_value%0.0001
		if read_value >= p_tol_min_selout[subidx] and read_value <= p_tol_max_selout[subidx] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, subidx+1, read_value, result)
	end
end

-------------------------------------------------------------------------
--  4. Version check
-------------------------------------------------------------------------
declare "tc_geely114l_4_version_check"
function tc_geely114l_4_version_check(run, seqno)
	local tcid = 4
	local unit = ""
	
	-- default parameter
	local p_tol_med_swversion = "GEP2C000"
	local p_tol_med_hwversion = "H02"
	
	-- local parameter
	local res_data_str = ""
	local read_value = 0
	local byte_data = {0, 0, 0, 0, 0, 0, 0, 0}
	local result = false
		
	if run == false then
		local tcinfo = {tcid, "DEV Message Check_geelyfe3hp", "tc_geely114l_4_version_check",
					{1, "Software Version", unit,
						{"Med", p_tol_med_swversion, "Tolerance Med", ""}					
					},
					{2, "Hardware Version", unit,
						{"Med", p_tol_med_hwversion, "Tolerance Med", ""}					
					}
				}
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_med_swversion = get_param_geely114l(seqno, 1, "Med", p_tol_med_swversion)
	p_tol_med_hwversion = get_param_geely114l(seqno, 2, "Med", p_tol_med_hwversion)
	
	------------------- 1. SW Version Check -------------------
	test_start(tcid, seqno, 1)
	
	tas.writestring("can1.@frame:0x6B0", "0322F18900000000") -- request message
	tas.wait(100)
	
	byte_data = read_dev_msg(0x4B0) -- read SW Message

	read_value = ""
	if byte_data == nil or #byte_data < 8 then
		read_value = "NIL"
	else
		for idx = 6, 8, 1 do
			read_value = read_value .. string.char(tonumber("0x"..byte_data[idx]))
		end
	end
	
	tas.writestring("can1.@frame:0x6B0", "3000000000000000") -- request message
	tas.wait(100)
	
	byte_data = read_dev_msg(0x4B0) -- read SW Message

	if byte_data == nil or #byte_data < 8 then
		read_value = "NIL"
	else
		for idx = 2, 6, 1 do
			read_value = read_value .. string.char(tonumber("0x"..byte_data[idx]))
		end
	end

	if read_value.."" == p_tol_med_swversion.."" then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	------------------- 2. HW Version Check -------------------
	test_start(tcid, seqno, 2)
	
	tas.writestring("can1.@frame:0x6B0", "0322F19300000000") -- request message
	tas.wait(100)
	
	byte_data = read_dev_msg(0x4B0) -- read SW Message

	read_value = ""
	if byte_data == nil or #byte_data < 8 then
		read_value = "NIL"
	else
		for idx = 6, 8, 1 do
			read_value = read_value .. string.char(tonumber("0x"..byte_data[idx]))
		end
	end
	
	test_finish(tcid, seqno, 2, read_value, result)
end

-------------------------------------------------------------------------
--  5. LV & HV side Leakage and Operating current measure
-------------------------------------------------------------------------
declare "tc_geely114l_5_lv_and_hv_current_measure"
function tc_geely114l_5_lv_and_hv_current_measure(run, seqno)
	local tcid = 5
	local unit = "uA"
	local unit_op = "mA"
	
	-- default parameter
	local p_tol_min_lv_leak = -0.1
	local p_tol_max_lv_leak = 20
	local p_tol_min_hv_leak = 0
	local p_tol_max_hv_leak = 100
	local p_tol_min_lv_op = 50
	local p_tol_max_lv_op = 80
	local p_tol_min_hv_op = 10
	local p_tol_max_hv_op = 30
	local result = false
	
	if run == false then
		local tcinfo = {tcid, "Current_ID Asign_geely114l", "tc_geely114l_5_lv_and_hv_current_measure",
					{1, "LV side sleep current", unit,
						{"Min", p_tol_min_lv_leak, "Tolerance Min", "uA"},
						{"Max", p_tol_max_lv_leak, "Tolerance Max", "uA"}
					},
					{2, "HV side sleep current (Measuring after Record)", unit,
						{"Min", p_tol_min_hv_leak, "Tolerance Min", "uA"},
						{"Max", p_tol_max_hv_leak, "Tolerance Max", "uA"}
					},
					{3, "LV side (Measuring after Record)", unit_op,
						{"Min", p_tol_min_lv_op, "Tolerance Min", "mA"},
						{"Max", p_tol_max_lv_op, "Tolerance Max", "mA"}
					},
					{4, "HV side (Measuring after Record)", unit_op,
						{"Min", p_tol_min_hv_op, "Tolerance Min", "mA"},
						{"Max", p_tol_max_hv_op, "Tolerance Max", "mA"}
					}
				}
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min_lv_leak = get_param_geely114l(seqno, 1, "Min", p_tol_min_lv_leak)
	p_tol_max_lv_leak = get_param_geely114l(seqno, 1, "Max", p_tol_max_lv_leak)
	p_tol_min_hv_leak = get_param_geely114l(seqno, 2, "Min", p_tol_min_hv_leak)
	p_tol_max_hv_leak = get_param_geely114l(seqno, 2, "Max", p_tol_max_hv_leak)
	p_tol_min_lv_op = get_param_geely114l(seqno, 3, "Min", p_tol_min_lv_op)
	p_tol_max_lv_op = get_param_geely114l(seqno, 3, "Max", p_tol_max_lv_op)
	p_tol_min_hv_op = get_param_geely114l(seqno, 4, "Min", p_tol_min_hv_op)
	p_tol_max_hv_op = get_param_geely114l(seqno, 4, "Max", p_tol_max_hv_op)
	
	------------------- 1. sleep Mode LV side Leakage current measure -------------------
	test_start(tcid, seqno, 1)
		
	-- power off
	LVPower_Volt(0)
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 0)
	CtrlBrd(RelaySet.Power.LV_PWR_NEG, 0)
	CtrlBrd(RelaySet.Power.A0_SELIn, 0)
	tas.wait(1000)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	CtrlBrd(RelaySet.DMMRly.VBATNegCurrMeasOn, 1) -- DMM relay lv current mode on
	tas.wait(500)
	
	local read_value = DMM_Set(DMM.ReadCurr) -- DMM current read
	read_value = read_value - read_value%0.0001
	if read_value >= p_tol_min_lv_leak and read_value <= p_tol_max_lv_leak then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1)
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	------------------- 2. sleep Mode HV side Leakage current measure -------------------
	test_start(tcid, seqno, 2)
	
	-- Cell Pos Sen Off 기능 필요예상
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	CtrlBrd(RelaySet.DMMRly.HVPosCurrMeasOn, 1) -- DMM relay hv current mode on
	tas.wait(1000)
	
	local read_value = -1 * DMM_Set(DMM.ReadCurr) * 1000 * 1000 -- DMM current read
	read_value = read_value - read_value%0.0001
	if read_value >= p_tol_min_hv_leak and read_value <= p_tol_max_hv_leak then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1)
	CtrlBrd(RelaySet.Cell.CellPOS_Cell12, 1)
	
	test_finish(tcid, seqno, 2, read_value, result)
	
	------------------- 3. Normal Mode LV side Operating current measure -------------------
	test_start(tcid, seqno, 3)
	-- power on
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 1)
	CtrlBrd(RelaySet.Power.LV_PWR_NEG, 1)
	CtrlBrd(RelaySet.Power.A0_SELIn, 1)
	tas.wait(500)
	LVPower_Volt(12)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1) -- DMM relay selout volt measure mode on
	tas.wait(500)
	
	--for i = 0,4,1 do
		local read_selout = DMM_Set(DMM.ReadVolt) -- Check if SEL_OUT voltage is high
		if read_selout >= 9.5 and read_selout <= 10.5 then
			--break
		else
			CtrlBrd(RelaySet.Power.LV_PWR_POS, 0)
			tas.wait(3000)
			CtrlBrd(RelaySet.Power.LV_PWR_POS, 1)
		end
	--end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	CtrlBrd(RelaySet.DMMRly.VBATNegCurrMeasOn, 1) -- DMM relay lv current mode on
	tas.wait(2000)
	
	local read_value = DMM_Set(DMM.ReadCurr) * 1000 -- check lv side operating current(mA)
	read_value = read_value - read_value%0.0001
	if read_value >= p_tol_min_lv_op and read_value <= p_tol_max_lv_op then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.Power.LV_PWR_NEG, 1)
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	
	test_finish(tcid, seqno, 3, read_value, result)
		
	------------------- 4. Normal Mode HV side Operating current measure -------------------
	test_start(tcid, seqno, 4)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	CtrlBrd(RelaySet.DMMRly.HVPosCurrMeasOn, 1) -- DMM relay hv current mode on
	tas.wait(1000)
	
	local read_value = -1 * DMM_Set(DMM.ReadCurr) * 1000 -- DMM current read
	read_value = read_value - read_value%0.0001
	if read_value >= p_tol_min_hv_op and read_value <= p_tol_max_hv_op then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1)
	CtrlBrd(RelaySet.Cell.CellPOS_Cell12, 1)
	
	test_finish(tcid, seqno, 4, read_value, result)
end

-------------------------------------------------------------------------
--  6. Power Supply Test
-------------------------------------------------------------------------
declare "tc_geely114l_6_power_supply_test"
function tc_geely114l_6_power_supply_test(run, seqno)
	local tcid = 6
	local unit = "V"
	local strlst = {"LV(6V),HV(44.4V=3.7*12)-CELL_SUM", 
				"LV(6V),HV(44.4V=3.7*12)-READ_SELOUT",
				"SELOUT_Low",
				"SELOUT_Frequency", 
				"SELOUT_Duty",
				"LV(18V),HV(21.6V=1.8*12)-CELL_SUM", 
				"LV(18V),HV(21.6V=1.8*12)-READ.SELOUT",
				"SELOUT_Frequency", 
				"LV(18V),HV(52.8V=4.4*12)-CELL_SUM",
				"LV(18V),HV(52.8V=4.4*12)-READ_SELOUT",
				"SELOUT Frequency",
				"LV(12V),HV(44.4V=3.7*12)-READ.SELOUT",
				"SELOUT_Low",
				"SELOUT_Frequency",
				"SELOUT_Duty"
				}
	
	-- default parameter
	local p_tol_min = {44.3, 4.5, 0, 9, 0.49, 
							21.5, 0, 0, 
							52.7, 0, 0, 
							4.5, 0, 9, 0.49}
	local p_tol_max = {44.5, 18, 2, 11, 0.51, 
							21.7, 2, 0, 
							52.9, 2, 0, 
							18, 2, 11, 0.51}
	
	-- local variable
	local read_value = 0
	local result = false
	local cellvolt = 0
	local read_value_selout = {}
	
	if run == false then
		local tcinfo = {tcid, "Power Supply Test_geely114l", "tc_geely114l_6_power_supply_test"}
		for substepidx = 1, 15, 1 do
			table.insert(tcinfo,
							{substepidx, strlst[substepidx], unit,
								{"Min", p_tol_min[substepidx], "Tolerance Min", "V"},
								{"Max", p_tol_max[substepidx], "Tolerance Max", "V"}		
							}
						)
		end
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1, 15, 1 do
		p_tol_min[idx] = get_param_geely114l(seqno, idx, "Min", p_tol_min[idx])
		p_tol_max[idx] = get_param_geely114l(seqno, idx, "Max", p_tol_max[idx])
	end
	
	------------------- 1. LV(6V),HV(44.4V=3.7*12) @ BMS_SUM(V) -------------------
	test_start(tcid, seqno, 1)
	
	-- cell simulator input
	cellvolt = 3700
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(1000)
	
	LVPower_Volt(6)
	tas.wait(500)
	
	-- Read current from cell simulator
	for i = 1, 3, 1 do
		for j = 1, 4, 1 do
			read_value = read_value + cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j)
		end
	end
	
	read_value = read_value/1000 -- convert voltage unit
	read_value = read_value - read_value%0.0001
	if read_value >= p_tol_min[1] and read_value <= p_tol_max[1] then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	------------------- 2~5. READ.SELOUT -------------------
	read_value_selout = read_pwm_sel_out()
	
	for idx = 1, 4 do
		test_start(tcid, seqno, idx + 1)
		read_value_selout[idx] = read_value_selout[idx] - read_value_selout[idx]%0.0001
		if read_value_selout[idx] >= p_tol_min[idx + 1] and read_value_selout[idx] <= p_tol_max[idx + 1] then
			result = true
		else
			result = false
		end
		test_finish(tcid, seqno, idx + 1, read_value_selout[idx], result)
	end
	
	------------------- 6~8. LV(18V),HV(21.6V=1.8*12) @ BMS_SUM(V) -------------------
	test_start(tcid, seqno, 6)
	
	cellvolt = 1800
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(1000)
	
	LVPower_Volt(18)
	tas.wait(500)
	
	for i = 1, 3, 1 do
		for j = 1, 4, 1 do
			read_value = read_value + cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j)
		end
	end
	
	read_value = read_value/1000 -- convert voltage unit
	read_value = read_value - read_value%0.0001
	if read_value >= p_tol_min[6] and read_value <= p_tol_max[6] then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 6, read_value, result)
	
	read_value_selout = read_pwm_sel_out()
	
	for idx = 1, 2 do
		test_start(tcid, seqno, idx + 6)
		read_value_selout[idx+1] = read_value_selout[idx+1] - read_value_selout[idx+1]%0.0001
		if read_value_selout[idx+1] >= p_tol_min[idx + 6] and read_value_selout[idx+1] <= p_tol_max[idx + 6] then
			result = true
		else
			result = false
		end
		test_finish(tcid, seqno, idx + 6, read_value_selout[idx+1], result)
	end
	
	------------------- 9~11. LV(18V),HV(52.8V=4.4*12) @ BMS_SUM(V) -------------------
	test_start(tcid, seqno, 9)
	
	cellvolt = 4400
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(1000)
	
	LVPower_Volt(18)
	tas.wait(500)
	
	for i = 1, 3, 1 do
		for j = 1, 4, 1 do
			read_value = read_value + cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j)
		end
	end
	
	read_value = read_value/1000 -- convert voltage unit
	read_value = read_value - read_value%0.0001
	if read_value >= p_tol_min[9] and read_value <= p_tol_max[9] then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 9, read_value, result)
	
	read_value_selout = read_pwm_sel_out()
	
	for idx = 1, 2 do
		test_start(tcid, seqno, idx + 9)
		read_value_selout[idx+1] = read_value_selout[idx+1] - read_value_selout[idx+1]%0.0001
		if read_value_selout[idx+1] >= p_tol_min[idx + 9] and read_value_selout[idx+1] <= p_tol_max[idx + 9] then
			result = true
		else
			result = false
		end
		test_finish(tcid, seqno, idx + 9, read_value_selout[idx+1], result)
	end
		
	------------------- 12~15. LV(12V),HV(44.4V=3.7*12) @ READ.SELOUT -------------------
	cellvolt = 3700
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	
	LVPower_Volt(12)
	tas.wait(500)
		
	read_value_selout = read_pwm_sel_out()
	
	for idx = 1, 4 do
		test_start(tcid, seqno, idx + 11)
		read_value_selout[idx] = read_value_selout[idx] - read_value_selout[idx]%0.0001
		if read_value_selout[idx] >= p_tol_min[idx + 11] and read_value_selout[idx] <= p_tol_max[idx + 11] then
			result = true
		else
			result = false
		end
		test_finish(tcid, seqno, idx + 11, read_value_selout[idx], result)
	end
end

-------------------------------------------------------------------------
--  7. Cell 1,3,5,7,9,11 current consumption(No balancing)-1
------------------------------------------------------------------------- TODO  : Spec과 맞지 않음
declare "tc_geely114l_7_oddcell_no_balancing_current_consum"
function tc_geely114l_7_oddcell_no_balancing_current_consum(run, seqno)
	local tcid = 7
	local unit = "A"
	local unit_cell = "mA"
	
	
	-- default parameter
	local p_tol_min = {-1, -1, -1, -1, -1, -1, -1}
	local p_tol_max = {1, 1, 1, 1, 1, 1, 1}
	local strlst = {"Cell 1-11current consumption_cell_1", 
					"Cell 1-11current consumption_cell_3", 
					"Cell 1-11current consumption_cell_5", 
					"Cell 1-11current consumption_cell_7",
					"Cell 1-11current consumption_cell_9",
					"Cell 1-11current consumption_cell_11"
					}
	
	-- local variable
	local read_value = 0
	local result = false
		
	if run == false then
		local subseqlst = {}
		local tcinfo = {tcid, "Cell 1,3,5,7,9,11 current consumption(No balancing)-1_geely114l", "tc_geely114l_7_oddcell_no_balancing_current_consum"}
		table.insert(tcinfo, 
						{1, "BMS_SUM(C)", unit,
							{"Min", p_tol_min[1], "Tolerance Min", "A"},
							{"Max", p_tol_max[1], "Tolerance Max", "A"}
						}
					)
		for substepidx = 2, 7, 1 do
			table.insert(tcinfo,
							{substepidx, strlst[substepidx-1], unit_cell,
								{"Min", p_tol_min[substepidx-1], "Tolerance Min", "mA"},
								{"Max", p_tol_max[substepidx-1], "Tolerance Max", "mA"}
							}
						)
		end
		
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1, 7, 1 do
		p_tol_min[idx] = get_param_geely114l(seqno, idx, "Min", p_tol_min[idx])
		p_tol_max[idx] = get_param_geely114l(seqno, idx, "Max", p_tol_max[idx])
	end
	
	------------------- 1. BMS_SUM(C) -------------------
	-- cell simulator input
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, 3700, 3700, 3700, 3700)
	end
	tas.wait(500)
	
	test_start(tcid, seqno, 1)
	
	-- no balancing
	local noBal = {false, false, false, false, false, false, false, false, false, false, false, false}
	manual_balancing_start_geely114l(1, noBal)
	tas.wait(1500)
	
	local ReadCurrMean = 0
	local ReadCurrLow = 0
	
	for i = 1,3,1 do
		for j = 1, 2, 1 do
			ReadCurrMean = ReadCurrMean + cs_can_read("CellSim"..i.."SendCurrent", "CellSim"..i.."SendCurrent"..((j - 1) * 2 + 1)) -- bms odd mean sum
			ReadCurrLow = ReadCurrLow + cs_can_read("CellSim"..i.."SendCurrentLowMean", "CellSim"..i.."SendCurrentLowMean"..((j - 1) * 2 + 1)) -- bms odd low mean sum
		end 
	end
	
	read_value = (ReadCurrMean - ReadCurrLow)/1000 -- change from "mA" unit to "A" unit
	read_value = read_value - read_value%0.01
	if read_value >= p_tol_min[1] and read_value <= p_tol_max[1] then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	------------------- 2. GET_CELL_001~011(C) -------------------
	for idx = 1, 6, 1 do
		test_start(tcid, seqno, idx+1)
		
		local ReadCurrMean = 0
		local ReadCurrLow = 0
		
		ReadCurrMean = ReadCurrMean + cs_can_read("CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrent", 
									"CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrent"..3^((idx + 1) % 2)) -- odd cell current mean value
		ReadCurrLow = ReadCurrLow + cs_can_read("CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrentLowMean", 
								"CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrentLowMean"..3^((idx + 1) % 2)) -- odd cell current low mean value
								
		read_value = (ReadCurrMean - ReadCurrLow)
		read_value = read_value - read_value%0.01
		if read_value >= p_tol_min[idx+1] and read_value <= p_tol_max[idx+1] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, idx+1, read_value, result)
	end
	
end

-------------------------------------------------------------------------
--  8. Cell 1,3,5,7,9,11 balancing status
-------------------------------------------------------------------------
declare "tc_geely114l_8_oddcell_balancing_status"
function tc_geely114l_8_oddcell_balancing_status(run, seqno)
	local tcid = 8
	local unit = ""
	local strlst = {"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"}
	
	
	-- default parameter
	local p_tol_med = {1,0,1,0,1,0,1,0,1,0,1,0}
	
	-- local variable
	local read_value = nil
	local result = false
	
	if run == false then
		local subseqlst = {}
		local tcinfo = {tcid, "Cell 1,3,5,7,9,11 balancing status_geely114l", "tc_geely114l_8_oddcell_balancing_status"}
		for substepidx = 1, 12, 1 do
			table.insert(tcinfo, 
							{substepidx, "CMC_01_ZellBalStatus_" .. strlst[substepidx], unit, 
								{"Med", p_tol_med[substepidx], "Tolerance Med", ""}
							}
						)
		end
				
				
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	for idx=1,12,1 do
		p_tol_med[idx] = get_param_geely114l(seqno, idx, "Med", p_tol_med[idx])
	end
	
	-- test case here
	local oddBal = {true, false, true, false, true, false, true, false, true, false, true, false}
	manual_balancing_start_geely114l(1, oddBal)
	tas.wait(3000)
	
	
	for idx=1,12,1 do
		test_start(tcid, seqno, idx)		
		read_value = cmc_can_read("BMM_01_08", "BMM_01_BalState_" .. strlst[idx])
		result=false
		if read_value == p_tol_med[idx] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, idx, read_value, result)
	end
	
end

-------------------------------------------------------------------------
--  9. Cell 1,3,5,7,9,11 balancing current
-------------------------------------------------------------------------
declare "tc_geely114l_9_oddcell_balancing_current"
function tc_geely114l_9_oddcell_balancing_current(run, seqno)
	local tcid = 9
	local unit = "A"
	local unit_cell = "mA"
	
	-- default parameter
	local p_tol_min = {0.36, 60, 60, 60, 60, 60, 60}
	local p_tol_max = {0.54, 90, 90, 90, 90, 90, 90}
	local strlst = {"GET_CELL_001(C)", 
					"GET_CELL_003(C)", 
					"GET_CELL_005(C)", 
					"GET_CELL_007(C)",
					"GET_CELL_009(C)",
					"GET_CELL_011(C)"
					}
	
	-- local variable
	local read_value = 0
	local result = false
		
	if run == false then
		local tcinfo = {tcid, "Cell 1,3,5,7,9,11 balancing current_geely114l", "tc_geely114l_9_oddcell_balancing_current"}
		table.insert(tcinfo, 
						{1, "BMS_SUM(C)", unit,
							{"Min", p_tol_min[1], "Tolerance Min", "A"},
							{"Max", p_tol_max[1], "Tolerance Max", "A"}
						}
					)
		for substepidx = 2, 7, 1 do
			table.insert(tcinfo,
							{substepidx, strlst[substepidx-1], unit_cell,
								{"Min", p_tol_min[substepidx-1], "Tolerance Min", "mA"},
								{"Max", p_tol_max[substepidx-1], "Tolerance Max", "mA"}
							}
						)
		end
		
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1, 7, 1 do
		p_tol_min[idx] = get_param_geely114l(seqno, idx, "Min", p_tol_min[idx])
		p_tol_max[idx] = get_param_geely114l(seqno, idx, "Max", p_tol_max[idx])
	end
	
	------------------- 1. BMS_SUM(C) -------------------
	test_start(tcid, seqno, 1)
	
	local ReadCurrMean = 0
	local ReadCurrLow = 0
	
	for i = 1,3,1 do
		for j = 1, 2, 1 do
			ReadCurrMean = ReadCurrMean + tonumber(cs_can_read("CellSim"..i.."SendCurrent", 
										"CellSim"..i.."SendCurrent"..((j - 1) * 2 + 1))) -- bms odd mean sum
			ReadCurrLow = ReadCurrLow + tonumber(cs_can_read("CellSim"..i.."SendCurrentLowMean",
										"CellSim"..i.."SendCurrentLowMean"..((j - 1) * 2 + 1))) -- bms odd low mean sum
		end 
	end
	
	read_value = (ReadCurrMean - ReadCurrLow)/1000
	read_value = read_value - read_value%0.01
	
	if read_value >= p_tol_min[1] and read_value <= p_tol_max[1] then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	------------------- 2. GET_CELL_001~011(C) -------------------
	for idx = 1, 6, 1 do
		test_start(tcid, seqno, idx+1)
		
		local ReadCurrMean = 0
		local ReadCurrLow = 0
		
		ReadCurrMean = cs_can_read("CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrent", 
									"CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrent"..3^((idx + 1) % 2)) -- odd cell current mean value
		ReadCurrLow = cs_can_read("CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrentLowMean", 
								"CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrentLowMean"..3^((idx + 1) % 2)) -- odd cell current low mean value
		
		read_value = (ReadCurrMean - ReadCurrLow)
		read_value = read_value - read_value%0.01
		if read_value >= p_tol_min[idx+1] and read_value <= p_tol_max[idx+1] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, idx+1, read_value, result)
	end
end

-------------------------------------------------------------------------
--  10. Cell 2,4,6,8,10,12 current consumption(No balancing)
-------------------------------------------------------------------------
declare "tc_geely114l_10_evencell_no_balancing_current_consum"
function tc_geely114l_10_evencell_no_balancing_current_consum(run, seqno)
	local tcid = 10
	local unit = "A"
	local unit_cell = "mA"
	
	-- default parameter
	local p_tol_min = {-1, -1, -1, -1, -1, -1, -1}
	local p_tol_max = {1, 1, 1, 1, 1, 1, 1}
	local strlst = {"GET_CELL_002(C)", 
					"GET_CELL_004(C)", 
					"GET_CELL_006(C)", 
					"GET_CELL_008(C)",
					"GET_CELL_010(C)",
					"GET_CELL_012(C)"
					}
	
	-- local variable
	local read_value = 0
	local result = false
		
	if run == false then
		local tcinfo = {tcid, "Cell 2,4,6,8,10,12 current consumption(No balancing)_geely114l", "tc_geely114l_10_evencell_no_balancing_current_consum"}
		table.insert(tcinfo, 
						{1, "BMS_SUM(C)", unit,
							{"Min", p_tol_min[1], "Tolerance Min", "A"},
							{"Max", p_tol_max[1], "Tolerance Max", "A"}
						}
					)
		for substepidx = 2, 7, 1 do
			table.insert(tcinfo,
							{substepidx, strlst[substepidx-1], unit_cell,
								{"Min", p_tol_min[substepidx-1], "Tolerance Min", "mA"},
								{"Max", p_tol_max[substepidx-1], "Tolerance Max", "mA"}
							}
						)
		end
		
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1, 7, 1 do
		p_tol_min[idx] = get_param_geely114l(seqno, idx, "Min", p_tol_min[idx])
		p_tol_max[idx] = get_param_geely114l(seqno, idx, "Max", p_tol_max[idx])
	end
	
	------------------- 1. BMS_SUM(C) -------------------
	test_start(tcid, seqno, 1)
	
	local noBal = {false, false, false, false, false, false, false, false, false, false, false, false}
	manual_balancing_start_geely114l(1, noBal)
	tas.wait(1500)
	
	local ReadCurrMean = 0
	local ReadCurrLow = 0
	
	for i = 1,3,1 do
		for j = 1, 2, 1 do
			ReadCurrMean = ReadCurrMean + tonumber(cs_can_read("CellSim"..i.."SendCurrent", "CellSim"..i.."SendCurrent"..(j * 2))) -- bms even mean sum
			ReadCurrLow = ReadCurrLow + tonumber(cs_can_read("CellSim"..i.."SendCurrentLowMean", "CellSim"..i.."SendCurrentLowMean"..(j * 2))) -- bms even low mean sum
		end 
	end
	
	read_value = (ReadCurrMean - ReadCurrLow)/1000
	read_value = read_value - read_value%0.01
	
	if read_value >= p_tol_min[1] and read_value <= p_tol_max[1] then
		result = true
	else
		result = false
	end
	
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	------------------- 2. GET_CELL_002~012(C) -------------------
	for idx = 1, 6, 1 do
		test_start(tcid, seqno, idx+1)
		
		local ReadCurrMean = 0
		local ReadCurrLow = 0
		
		ReadCurrMean = cs_can_read("CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrent", 
									"CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrent"..(3^((idx + 1) % 2)) + 1) -- odd cell current mean value
		ReadCurrLow = cs_can_read("CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrentLowMean", 
								"CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrentLowMean"..(3^((idx + 1) % 2)) + 1) -- odd cell current low mean value
		
		read_value = (ReadCurrMean - ReadCurrLow)
		read_value = read_value - read_value%0.01
		
		if read_value >= p_tol_min[idx+1] and read_value <= p_tol_max[idx+1] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, idx+1, read_value, result)
	end
	
end

-------------------------------------------------------------------------
--  11. Cell 2,4,6,8,10,12 balancing status
-------------------------------------------------------------------------
declare "tc_geely114l_11_evencell_balancing_status"
function tc_geely114l_11_evencell_balancing_status(run, seqno)
	local tcid = 11
	local unit = ""
	local strlst = {"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"}
	
	-- default parameter
	local p_tol_med = {0,1,0,1,0,1,0,1,0,1,0,1}
	
	-- local variable
	local read_value = nil
	local result = false
	
	if run == false then
		local tcinfo = {tcid, "Cell 2,4,6,8,10,12 balancing status_geely114l", "tc_geely114l_11_evencell_balancing_status"}
		for substepidx = 1, 12, 1 do
			table.insert(tcinfo, 
							{substepidx, "CMC_01_ZellBalStatus_" .. strlst[substepidx], unit, 
								{"Med", p_tol_med[substepidx], "Tolerance Med", ""}
							}
						)
		end
				
				
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	for idx=1,12,1 do
		p_tol_med[idx] = get_param_geely114l(seqno, idx, "Med", p_tol_med[idx])
	end
	
	local evenBal = {false, true, false, true, false, true, false, true, false, true, false, true}
	manual_balancing_start_geely114l(1, evenBal)
	tas.wait(3000)
	
	for idx=1,12,1 do
		test_start(tcid, seqno, idx)		
		read_value = cmc_can_read("BMM_01_08", "BMM_01_BalState_" .. strlst[idx])
		result=false
		if read_value == p_tol_med[idx] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, idx, read_value, result)
	end
	
end

-------------------------------------------------------------------------
--  12. Cell 2,4,6,8,10,12 balancing current
-------------------------------------------------------------------------
declare "tc_geely114l_12_evencell_balancing_current"
function tc_geely114l_12_evencell_balancing_current(run, seqno)
	local tcid = 12
	local unit = "A"
	local unit_cell = "mA"
	
	-- default parameter
	local p_tol_min = {0.36, 60, 60, 60, 60, 60, 60}
	local p_tol_max = {0.54, 90, 90, 90, 90, 90, 90}
	local strlst = {"GET_CELL_002(C)", 
					"GET_CELL_004(C)", 
					"GET_CELL_006(C)", 
					"GET_CELL_008(C)",
					"GET_CELL_010(C)",
					"GET_CELL_012(C)"
					}
	
	-- local variable
	local read_value = 0
	local result = false
		
	if run == false then
		local tcinfo = {tcid, "Cell 2,4,6,8,10,12 balancing current_geely114l", "tc_geely114l_12_evencell_balancing_current"}
		table.insert(tcinfo, 
						{1, "BMS_SUM(C)", unit,
							{"Min", p_tol_min[1], "Tolerance Min", "A"},
							{"Max", p_tol_max[1], "Tolerance Max", "A"}
						}
					)
		for substepidx = 2, 7, 1 do
			table.insert(tcinfo,
							{substepidx, strlst[substepidx-1], unit_cell,
								{"Min", p_tol_min[substepidx-1], "Tolerance Min", "mA"},
								{"Max", p_tol_max[substepidx-1], "Tolerance Max", "mA"}
							}
						)
		end
		
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1, 7, 1 do
		p_tol_min[idx] = get_param_geely114l(seqno, idx, "Min", p_tol_min[idx])
		p_tol_max[idx] = get_param_geely114l(seqno, idx, "Max", p_tol_max[idx])
	end
	
	------------------- 1. BMS_SUM(C) -------------------
	test_start(tcid, seqno, 1)
	
	local ReadCurrMean = 0
	local ReadCurrLow = 0
	
	for i = 1,3,1 do
		for j = 1, 2, 1 do
			ReadCurrMean = ReadCurrMean + tonumber(cs_can_read("CellSim"..i.."SendCurrent", "CellSim"..i.."SendCurrent"..(j * 2))) -- bms even mean sum
			ReadCurrLow = ReadCurrLow + tonumber(cs_can_read("CellSim"..i.."SendCurrentLowMean", "CellSim"..i.."SendCurrentLowMean"..(j * 2))) -- bms even low mean sum
		end 
	end
	
	read_value = (ReadCurrMean - ReadCurrLow)/1000
	read_value = read_value - read_value%0.01
	
	if read_value >= p_tol_min[1] and read_value <= p_tol_max[1] then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	------------------- 2. GET_CELL_002~012(C) -------------------
	for idx = 1, 6, 1 do
		test_start(tcid, seqno, idx+1)
		
		local ReadCurrMean = 0
		local ReadCurrLow = 0
		
		ReadCurrMean = cs_can_read("CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrent", 
									"CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrent"..(3^((idx + 1) % 2) + 1)) -- odd cell current mean value
		ReadCurrLow = cs_can_read("CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrentLowMean", 
								"CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrentLowMean"..(3^((idx + 1) % 2) + 1)) -- odd cell current low mean value
		
		read_value = ReadCurrMean - ReadCurrLow
		read_value = read_value - read_value%0.01
		
		if read_value >= p_tol_min[idx+1] and read_value <= p_tol_max[idx+1] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, idx+1, read_value, result)
	end
end

-------------------------------------------------------------------------
--  13. Cell 1,3,5,7,9,11 current consumption(No balancing)-2
-------------------------------------------------------------------------
declare "tc_geely114l_13_oddcell_no_balancing_current_consum_2"
function tc_geely114l_13_oddcell_no_balancing_current_consum_2(run, seqno)
	local tcid = 13
	local unit = "A"
	local unit_cell = "mA"
	
	-- default parameter
	local p_tol_min = {-1, -1, -1, -1, -1, -1, -1}
	local p_tol_max = {1, 1, 1, 1, 1, 1, 1}
	local strlst = {"GET_CELL_001(C)", 
					"GET_CELL_003(C)", 
					"GET_CELL_005(C)", 
					"GET_CELL_007(C)",
					"GET_CELL_009(C)",
					"GET_CELL_011(C)"
					}
	
	-- local variable
	local read_value = 0
	local result = false
		
	if run == false then
		local tcinfo = {tcid, "Cell 1,3,5,7,9,11 current consumption(No balancing)-2_geely114l", "tc_geely114l_13_oddcell_no_balancing_current_consum_2"}
		table.insert(tcinfo, 
						{1, "BMS_SUM(C)", unit,
							{"Min", p_tol_min[1], "Tolerance Min", "A"},
							{"Max", p_tol_max[1], "Tolerance Max", "A"}
						}
					)
		for substepidx = 2, 7, 1 do
			table.insert(tcinfo,
							{substepidx, strlst[substepidx-1], unit_cell,
								{"Min", p_tol_min[substepidx-1], "Tolerance Min", "mA"},
								{"Max", p_tol_max[substepidx-1], "Tolerance Max", "mA"}
							}
						)
		end
		
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1, 7, 1 do
		p_tol_min[idx] = get_param_geely114l(seqno, idx, "Min", p_tol_min[idx])
		p_tol_max[idx] = get_param_geely114l(seqno, idx, "Max", p_tol_max[idx])
	end
	
	------------------- 1. BMS_SUM(C) -------------------
	test_start(tcid, seqno, 1)
	
	--cmc_cell_balancing(CellBalMode.NoBalancing) -- no balancing
	local noBal = {false, false, false, false, false, false, false, false, false, false, false, false}
	manual_balancing_start_geely114l(1, noBal)
	tas.wait(1500)
	
	local ReadCurrMean = 0
	local ReadCurrLow = 0
	
	for i = 1,3,1 do
		for j = 1, 2, 1 do
			ReadCurrMean = ReadCurrMean + tonumber(cs_can_read("CellSim"..i.."SendCurrent", "CellSim"..i.."SendCurrent"..((j - 1) * 2 + 1))) -- bms odd mean sum
			ReadCurrLow = ReadCurrLow + tonumber(cs_can_read("CellSim"..i.."SendCurrentLowMean", "CellSim"..i.."SendCurrentLowMean"..((j - 1) * 2 + 1))) -- bms odd low mean sum
		end 
	end
	
	read_value = (ReadCurrMean - ReadCurrLow)/1000
	read_value = read_value - read_value%0.01
	
	if read_value >= p_tol_min[1] and read_value <= p_tol_max[1] then
		result = true
	else
		result = false
	end
	
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	------------------- 2. GET_CELL_001~011(C) -------------------
	for idx = 1, 6, 1 do
		test_start(tcid, seqno, idx+1)
		
		local ReadCurrMean = 0
		local ReadCurrLow = 0
		
		ReadCurrMean = cs_can_read("CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrent", 
									"CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrent"..3^((idx + 1) % 2)) -- odd cell current mean value
		ReadCurrLow = cs_can_read("CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrentLowMean", 
								"CellSim"..(idx%2 + math.floor(idx/2)).."SendCurrentLowMean"..3^((idx + 1) % 2)) -- odd cell current low mean value
		
		read_value = ReadCurrMean - ReadCurrLow
		read_value = read_value - read_value%0.01
		
		if read_value >= p_tol_min[idx+1] and read_value <= p_tol_max[idx+1] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, idx+1, read_value, result)
	end
	
end

-------------------------------------------------------------------------
--  14. Voltage(Over voltage, Under voltage check)
-------------------------------------------------------------------------
declare "tc_geely114l_14_ovp_uvp"
function tc_geely114l_14_ovp_uvp(run, seqno)
	local tcid = 14
	local unit = "V"
	
	-- default parameter
	--{High Volt, Low Volt, Frequency, Duty}
	local p_tol_min_normal = {4.5, 0, 9, 0.49}
	local p_tol_max_normal = {18, 2, 11, 0.51}
	local p_tol_min_ov = -0.1
	local p_tol_max_ov = 2
	local p_tol_min_un = -0.1
	local p_tol_max_un = 2
	local OV_voltage = 4400
	local UN_voltage = 1800
	
	-- local variable
	local read_value = nil
	local result = false
	local Can_delay = 100
	local Cell_delay = 1000
	local cellvolt = 0
	local read_value_selout = {}
	
	if run == false then
		local tcinfo = {tcid, "Voltage_geely114l", "tc_geely114l_14_ovp_uvp"}
		for substepidx = 1, 12, 1 do
			table.insert(tcinfo, 
							{((substepidx * 5) - 4), "Cell OV Normal Voltage "..substepidx.." @ READ.SELOUT High Voltage" .. substepidx, unit, 
								{"Min", p_tol_min_normal[1], "Tolerance Min", "V"},
								{"Max", p_tol_max_normal[1], "Tolerance Max", "V"}
							}
						)
			table.insert(tcinfo, 
							{((substepidx * 5) - 3), "Cell OV Normal Voltage "..substepidx.." @ READ.SELOUT Low Voltage" .. substepidx, unit, 
								{"Min", p_tol_min_normal[2], "Tolerance Min", "V"},
								{"Max", p_tol_max_normal[2], "Tolerance Max", "V"}
							}
						)
			table.insert(tcinfo, 
							{((substepidx * 5) - 2), "Cell OV Normal Voltage "..substepidx.." @ READ.SELOUT Freq" .. substepidx, unit, 
								{"Min", p_tol_min_normal[3], "Tolerance Min", "V"},
								{"Max", p_tol_max_normal[3], "Tolerance Max", "V"}
							}
						)
			table.insert(tcinfo, 
							{((substepidx * 5) - 1), "Cell OV Normal Voltage "..substepidx.." @ READ.SELOUT Duty" .. substepidx, unit, 
								{"Min", p_tol_min_normal[4], "Tolerance Min", "V"},
								{"Max", p_tol_max_normal[4], "Tolerance Max", "V"}
							}
						)
			table.insert(tcinfo, 
							{(substepidx * 5), "Cell Over Voltage "..substepidx.." @ READ.SELOUT" .. substepidx, unit, 
								{"Min", p_tol_min_ov, "Tolerance Min", "V"},
								{"Max", p_tol_max_ov, "Tolerance Max", "V"}
							}
						)						
		end
		for substepidx = 13, 24, 1 do
			table.insert(tcinfo, 
							{((substepidx * 5) - 4), "Cell UN Normal Voltage "..substepidx.." @ READ.SELOUT High Voltage" .. substepidx, unit, 
								{"Min", p_tol_min_normal[1], "Tolerance Min", "V"},
								{"Max", p_tol_max_normal[1], "Tolerance Max", "V"}
							}
						)
			table.insert(tcinfo, 
							{((substepidx * 5) - 3), "Cell UN Normal Voltage "..substepidx.." @ READ.SELOUT Low Voltage" .. substepidx, unit, 
								{"Min", p_tol_min_normal[2], "Tolerance Min", "V"},
								{"Max", p_tol_max_normal[2], "Tolerance Max", "V"}
							}
						)
			table.insert(tcinfo, 
							{((substepidx * 5) - 2), "Cell UN Normal Voltage "..substepidx.." @ READ.SELOUT Freq" .. substepidx, unit, 
								{"Min", p_tol_min_normal[3], "Tolerance Min", "V"},
								{"Max", p_tol_max_normal[3], "Tolerance Max", "V"}
							}
						)
			table.insert(tcinfo, 
							{((substepidx * 5) - 1), "Cell UN Normal Voltage "..substepidx.." @ READ.SELOUT Duty" .. substepidx, unit, 
								{"Min", p_tol_min_normal[4], "Tolerance Min", "V"},
								{"Max", p_tol_max_normal[4], "Tolerance Max", "V"}
							}
						)
			table.insert(tcinfo, 
							{(substepidx * 5), "Cell Under Voltage "..substepidx.." @ READ.SELOUT" .. substepidx, unit, 
								{"Min", p_tol_min_un, "Tolerance Min", "V"},
								{"Max", p_tol_max_un, "Tolerance Max", "V"}
							}
						)
		end
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1,4 do
		p_tol_min_normal[idx] = get_param_geely114l(seqno, idx, "Min", p_tol_min_normal[idx])
		p_tol_max_normal[idx] = get_param_geely114l(seqno, idx, "Max", p_tol_max_normal[idx])
	end
	p_tol_min_ov = get_param_geely114l(seqno, 5, "Min", p_tol_min_ov)
	p_tol_max_ov = get_param_geely114l(seqno, 5, "Max", p_tol_max_ov)
	p_tol_min_un = get_param_geely114l(seqno, 65, "Min", p_tol_min_un)
	p_tol_max_un = get_param_geely114l(seqno, 65, "Max", p_tol_max_un)

	-- Check Cell OV Normal and Over Voltage
	for idx = 1, 12, 1 do
	
		cellvolt = 3700
		for brd_num = 1, 3, 1 do
			CellSimulator_Volt(brd_num, cellvolt, cellvolt, cellvolt, cellvolt)
		end
		
		tas.wait(Cell_delay)
		
		read_value_selout = read_pwm_sel_out()
	
		for pwmidx = 1, 4 do
			test_start(tcid, seqno, ((idx * 5) - (5 - pwmidx)))
			read_value_selout[pwmidx] = read_value_selout[pwmidx] - read_value_selout[pwmidx]%0.0001
			if read_value_selout[pwmidx] >= p_tol_min_normal[pwmidx] and read_value_selout[pwmidx] <= p_tol_max_normal[pwmidx] then
				result = true
			else
				result = false
			end
			test_finish(tcid, seqno, ((idx * 5) - (5 - pwmidx)), read_value_selout[pwmidx], result)
		end
				
		--check over voltage-------------------------------------------------------------
		test_start(tcid, seqno, (idx * 5))
		
		can_write_cellsim_volt_set("CellSim"..math.floor((idx+3)/4).."VoltSet", "CellSim"..math.floor((idx+3)/4).."ValueSetVolt"..((idx-1)%4+1), OV_voltage)
		
		tas.wait(Cell_delay)
		
		read_value_selout = read_pwm_sel_out()
		read_value_selout[1] = read_value_selout[1] - read_value_selout[1]%0.0001
		if read_value_selout[1] >= p_tol_min_ov and read_value_selout[1] <= p_tol_max_ov then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, (idx * 5), read_value_selout[1], result)
	end
	
	-- Check Cell UN Normal and Under Voltage
	for idx = 13, 24, 1 do
	
		cellvolt = 3700
		for brd_num = 1, 3, 1 do
			CellSimulator_Volt(brd_num, cellvolt, cellvolt, cellvolt, cellvolt)
		end
		
		tas.wait(Cell_delay)
		
		read_value_selout = read_pwm_sel_out()
		
		for pwmidx = 1, 4 do
			test_start(tcid, seqno, ((idx * 5) - (5 - pwmidx)))
			read_value_selout[pwmidx] = read_value_selout[pwmidx] - read_value_selout[pwmidx]%0.0001
			if read_value_selout[pwmidx] >= p_tol_min_normal[pwmidx] and read_value_selout[pwmidx] <= p_tol_max_normal[pwmidx] then
				result = true
			else
				result = false
			end
			test_finish(tcid, seqno, ((idx * 5) - (5 - pwmidx)), read_value_selout[pwmidx], result)
		end
		
		--check under voltage-------------------------------------------------------------
		test_start(tcid, seqno, (idx * 5))
		
		can_write_cellsim_volt_set("CellSim"..math.floor(((idx-12)+3)/4).."VoltSet", "CellSim"..math.floor(((idx-12)+3)/4).."ValueSetVolt"..(((idx-12)-1)%4+1), UN_voltage)
		
		tas.wait(Cell_delay)
		
		read_value_selout = read_pwm_sel_out()
		read_value_selout[1] = read_value_selout[1] - read_value_selout[1]%0.0001
		if read_value_selout[1] >= p_tol_min_ov and read_value_selout[1] <= p_tol_max_ov then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, (idx * 5), read_value_selout[1], result)
	end
end

-------------------------------------------------------------------------
--  15. Voltage accuracy measure
-------------------------------------------------------------------------
declare "tc_geely114l_15_voltage_accuracy_3700"
function tc_geely114l_15_voltage_accuracy_3700(run, seqno)
	local tcid = 15
	local unit = "mV"
	
	-- default parameter
	local cell_acu_tol = 5
	local p_tol_min = -cell_acu_tol
	local p_tol_max = cell_acu_tol
	local strlst = {"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"}
	
	-- local variable
	local read_value = 0
	local result = false
	local cellvolt = 0
	
	if run == false then
		local tcinfo = {tcid, "Cell Voltage(3.7V)_geely114l", "tc_geely114l_15_voltage_accuracy_3700"}
		for substepidx = 1, 24, 2 do
			table.insert(tcinfo, 
							{substepidx, "Cell"..strlst[(substepidx+1)/2].." (3.7V)", unit, 
								{"Min", p_tol_min, "Tolerance Min", "mV"},
								{"Max", p_tol_max, "Tolerance Max", "mV"}
							}
						)
			table.insert(tcinfo,
							{substepidx+1, "Cell"..strlst[(substepidx+1)/2].." (3.7V)_CAN", unit, 
								{"Min", p_tol_min, "Tolerance Min", "mV"},
								{"Max", p_tol_max, "Tolerance Max", "mV"}
							}
						)
		end	
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min = get_param_geely114l(seqno, 1, "Min", p_tol_min)
	p_tol_max = get_param_geely114l(seqno, 1, "Max", p_tol_max)

	--CellSimulator_CAN(0, 0) -- Cellsimulator can comm. off
	tas.wait(1000)
	
	-- cell simulator set
	cellvolt = 3700
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(2000)
	
	local startCell = RelaySet.DMMRly.Cell1VoltMeas
	for idx = 1, 12, 1 do
		test_start(tcid, seqno , ((idx * 2) - 1))
		tas.progress("Cell"..idx) --TODO 테스트 완료시 삭제

		CtrlBrd(RelaySet.DMMRly.Reset, 1) -- dmm relay reset
		CtrlBrd(startCell + (idx - 1), 1) -- Ch1 Voltage measure relay on
		tas.wait(500)
		
		-- result = (can_data)-(dmm_data)
		local can_data = cmc_can_read("BMM_01_0"..math.floor((idx+3)/4), "BMM_01_Vcell_"..strlst[idx])
		if idx%2 == 1 then
			read_value = tonumber(can_data) - DMM_Set(DMM.ReadVolt)*1000
		else
			read_value = tonumber(can_data) + DMM_Set(DMM.ReadVolt)*1000
		end
		
		read_value = read_value - read_value%0.0001
		if read_value >= p_tol_min and read_value <= p_tol_max then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, ((idx * 2) - 1), read_value, result)
		
		test_start(tcid, seqno , (idx * 2))
		-- add can data
		test_finish(tcid, seqno, (idx * 2), can_data, result)

		tas.wait(500)
	end	
end

declare "tc_geely114l_16_voltage_accuracy_3400"
function tc_geely114l_16_voltage_accuracy_3400(run, seqno)
	local tcid = 16
	local unit = "mV"
	
	-- default parameter
	local cell_acu_tol = 5
	local p_tol_min = -cell_acu_tol
	local p_tol_max = cell_acu_tol
	local strlst = {"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"}
	
	-- local variable
	local read_value = 0
	local result = false
	local cellvolt = 0
	
	if run == false then
		local tcinfo = {tcid, "Cell Voltage(3.4V)_geely114l", "tc_geely114l_16_voltage_accuracy_3400"}
		for substepidx = 1, 24, 2 do
			table.insert(tcinfo, 
							{substepidx, "Cell"..strlst[(substepidx+1)/2].." (3.4V)", unit, 
								{"Min", p_tol_min, "Tolerance Min", "mV"},
								{"Max", p_tol_max, "Tolerance Max", "mV"}
							}
						)
			table.insert(tcinfo,
							{substepidx+1, "Cell"..strlst[(substepidx+1)/2].." (3.4V)_CAN", unit, 
								{"Min", p_tol_min, "Tolerance Min", "mV"},
								{"Max", p_tol_max, "Tolerance Max", "mV"}
							}
						)
		end	
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min = get_param_geely114l(seqno, 1, "Min", p_tol_min)
	p_tol_max = get_param_geely114l(seqno, 1, "Max", p_tol_max)

	--CellSimulator_CAN(0, 0) -- Cellsimulator can comm. off
	tas.wait(1000)
	
	-- cell simulator set
	cellvolt = 3400
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(2000)
	
	local startCell = RelaySet.DMMRly.Cell1VoltMeas
	for idx = 1, 12, 1 do
		test_start(tcid, seqno , ((idx * 2) - 1))

		CtrlBrd(RelaySet.DMMRly.Reset, 1) -- dmm relay reset
		CtrlBrd(startCell + (idx - 1), 1) -- Ch1 Voltage measure relay on
		tas.wait(500)
		
		-- result = (can_data)-(dmm_data)
		local can_data = cmc_can_read("BMM_01_0"..math.floor((idx+3)/4), "BMM_01_Vcell_"..strlst[idx])
		if idx%2 == 1 then
			read_value = tonumber(can_data) - DMM_Set(DMM.ReadVolt)*1000
		else
			read_value = tonumber(can_data) + DMM_Set(DMM.ReadVolt)*1000
		end
		
		read_value = read_value - read_value%0.0001
		if read_value >= p_tol_min and read_value <= p_tol_max then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, ((idx * 2) - 1), read_value, result)
		
		test_start(tcid, seqno , (idx * 2))
		-- add can data
		test_finish(tcid, seqno, (idx * 2), can_data, result)
	end	
end

declare "tc_geely114l_17_voltage_accuracy_4100"
function tc_geely114l_17_voltage_accuracy_4100(run, seqno)
	local tcid = 17
	local unit = "mV"
	
	-- default parameter
	local cell_acu_tol = 5
	local p_tol_min = -cell_acu_tol
	local p_tol_max = cell_acu_tol
	local strlst = {"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"}
	
	-- local variable
	local read_value = 0
	local result = false
	local cellvolt = 0
	
	if run == false then
		local tcinfo = {tcid, "Cell Voltage(4.1V)_geely114l", "tc_geely114l_17_voltage_accuracy_4100"}
		for substepidx = 1, 24, 2 do
			table.insert(tcinfo, 
					 		{substepidx, "Cell"..strlst[(substepidx+1)/2].." (4.1V)", unit, 
								{"Min", p_tol_min, "Tolerance Min", "mV"},
								{"Max", p_tol_max, "Tolerance Max", "mV"}
							}
						)
			table.insert(tcinfo,
							{substepidx+1, "Cell"..strlst[(substepidx+1)/2].." (4.1V)_CAN", unit, 
								{"Min", p_tol_min, "Tolerance Min", "mV"},
								{"Max", p_tol_max, "Tolerance Max", "mV"}
							}
						)
		end	
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min = get_param_geely114l(seqno, 1, "Min", p_tol_min)
	p_tol_max = get_param_geely114l(seqno, 1, "Max", p_tol_max)

	--CellSimulator_CAN(0, 0) -- Cellsimulator can comm. off
	tas.wait(1000)
	
	-- cell simulator set
	cellvolt = 4100
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(2000)
	
	local startCell = RelaySet.DMMRly.Cell1VoltMeas
	for idx = 1, 12, 1 do
		test_start(tcid, seqno , ((idx * 2) - 1))

		CtrlBrd(RelaySet.DMMRly.Reset, 1) -- dmm relay reset
		CtrlBrd(startCell + (idx - 1), 1) -- Ch1 Voltage measure relay on
		tas.wait(500)
		
		-- result = (can_data)-(dmm_data)
		local can_data = cmc_can_read("BMM_01_0"..math.floor((idx+3)/4), "BMM_01_Vcell_"..strlst[idx])
		
		if idx%2 == 1 then
			read_value = tonumber(can_data) - DMM_Set(DMM.ReadVolt)*1000
		else
			read_value = tonumber(can_data) + DMM_Set(DMM.ReadVolt)*1000
		end
		
		read_value = read_value - read_value%0.0001
		if read_value >= p_tol_min and read_value <= p_tol_max then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, ((idx * 2) - 1), read_value, result)
		
		test_start(tcid, seqno , (idx * 2))
		-- add can data
		test_finish(tcid, seqno, (idx * 2), can_data, result)
	end	
end

-------------------------------------------------------------------------
--  18. CVN value reading
------------------------------------------------------------------------- Not adapted for china spec
--[[
declare "tc_geely114l_18_cvn_value_reading"
function tc_geely114l_18_cvn_value_reading(run, seqno)
	local tcid = 18
	local unit = ""
	local strlst = {"MUX M", "CVN_1 m0", "CVN_1 m1", "CVN_1 m2", "CVN_1 m3"}
	
	-- default parameter
	local mux0 = 72
	local mux1 = 37
	local mux2 = 254
	local mux3 = 139
	local p_tol_med = {0, mux0, mux0, mux0, mux0, 1, mux1, mux1, mux1, mux1, 2, mux2, mux2, mux2, mux2, 3, mux3, mux3, mux3, mux3}
		
	-- local variable
	local read_value = 0
	local result = false

	if run == false then
		local tcinfo = {tcid, "CVN value reading_geely114l", "tc_geely114l_18_cvn_value_reading"}
		for substepidx = 1, 20, 1 do
			table.insert(tcinfo, 
							{substepidx, "CVN value reading (MUX "..((math.floor((substepidx+4)/5))-1)..") @ CMC_01_"..strlst[(substepidx-1)%5+1], unit, 
								{"Med", p_tol_med[substepidx], "Tolerance Min", ""},
							}
						)
		end	
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1, 20, 1 do
		p_tol_med[idx] = get_param_geely114l(seqno, idx, "Med", p_tol_med[idx])
	end
	
	--MUX 0-------------------------------------------------------------
	test_start(tcid, seqno, 1)
	
	for mux_read_loop = 1, 20, 1 do
		read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_MUX")
		if read_value == p_tol_med[1] then
			result = true
			break
		else
			result = false
		end
		tas.wait(200)
	end	
	test_finish(tcid, seqno, 1, read_value, result)
			
	--------------------------
	test_start(tcid, seqno, 2)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_1")
	if read_value == p_tol_med[2] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 2, read_value, result)
	--------------------------
	test_start(tcid, seqno, 3)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_1")
	if read_value == p_tol_med[3] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 3, read_value, result)
	--------------------------
	test_start(tcid, seqno, 4)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_1")
	if read_value == p_tol_med[4] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 4, read_value, result)
	--------------------------
	test_start(tcid, seqno, 5)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_1")
	if read_value == p_tol_med[5] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 5, read_value, result)

	
	--MUX 1-------------------------------------------------------------
	test_start(tcid, seqno, 6)
	
	for mux_read_loop = 1, 20, 1 do
		read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_MUX")
		if read_value == p_tol_med[6] then
			result = true
			break
		else
			result = false
		end
		tas.wait(200)
	end	
	test_finish(tcid, seqno, 6, read_value, result)
			
	--------------------------
	test_start(tcid, seqno, 7)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_2")
	if read_value == p_tol_med[7] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 7, read_value, result)
	--------------------------
	test_start(tcid, seqno, 8)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_2")
	if read_value == p_tol_med[8] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 8, read_value, result)
	--------------------------
	test_start(tcid, seqno, 9)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_2")
	if read_value == p_tol_med[9] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 9, read_value, result)
	---------------------------
	test_start(tcid, seqno, 10)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_2")
	if read_value == p_tol_med[10] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 10, read_value, result)
	
	
	--MUX 2-------------------------------------------------------------
	test_start(tcid, seqno, 11)
	
	for mux_read_loop = 1, 20, 1 do
		read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_MUX")
		if read_value == p_tol_med[11] then
			result = true
			break
		else
			result = false
		end
		tas.wait(200)
	end	
	test_finish(tcid, seqno, 11, read_value, result)
			
	-----------------------------------------------------------------
	test_start(tcid, seqno, 12)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_3")
	if read_value == p_tol_med[12] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 12, read_value, result)
	-----------------------------------------------------------------
	test_start(tcid, seqno, 13)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_3")
	if read_value == p_tol_med[13] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 13, read_value, result)
	-----------------------------------------------------------------
	test_start(tcid, seqno, 14)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_3")
	if read_value == p_tol_med[14] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 14, read_value, result)
	-----------------------------------------------------------------
	test_start(tcid, seqno, 15)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_3")
	if read_value == p_tol_med[15] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 15, read_value, result)
	
	
	--MUX 3-------------------------------------------------------------
	test_start(tcid, seqno, 16)
	
	for mux_read_loop = 1, 20, 1 do
		read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_MUX")
		if read_value == p_tol_med[16] then
			result = true
			break
		else
			result = false
		end
		tas.wait(200)
	end	
	test_finish(tcid, seqno, 16, read_value, result)
			
	-----------------------------------------------------------------
	test_start(tcid, seqno, 17)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_4")
	if read_value == p_tol_med[17] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 17, read_value, result)
	-----------------------------------------------------------------
	test_start(tcid, seqno, 18)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_4")
	if read_value == p_tol_med[18] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 18, read_value, result)
	-----------------------------------------------------------------
	test_start(tcid, seqno, 19)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_4")
	if read_value == p_tol_med[19] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 19, read_value, result)
	-----------------------------------------------------------------
	test_start(tcid, seqno, 20)
	
	read_value = cmc_can_read("CMC_01_CALID_CVN", "CMC_01_CVN_4")
	if read_value == p_tol_med[20] then
		result = true
	else
		result = false
	end
	test_finish(tcid, seqno, 20, read_value, result)
	
end
--]]
-------------------------------------------------------------------------
--  19. Alarm Line Check
------------------------------------------------------------------------- TODO : STB, STG, Open logic need to check
declare "tc_geely114l_19_alarm_line_check"
function tc_geely114l_19_alarm_line_check(run, seqno)
	local tcid = 19
	local unit = "V"
	
	-- default parameter
	local p_tol_min_normal_selout = 9.5
	local p_tol_max_normal_selout = 10.5
	local p_tol_min_off_selout = -0.1
	local p_tol_max_off_selout = 2.25
	local p_tol_min_selout_pwm = {4.5, 0, 9, 0.49}
	local p_tol_max_selout_pwm = {18, 2, 11, 0.51}
	local p_tol_med_selout_remove_status = 1
	local p_tol_med_selout_status = 3
		
	-- local variable
	local read_value = 0
	local result = false

	if run == false then
		local tcinfo = {tcid, "Alram Line Check_geely114l", "tc_geely114l_19_alarm_line_check",	
					{1, "SEL_IN Voltage (4.5V) 1_READ.SELOUT", unit,
						{"Min", p_tol_min_normal_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_normal_selout, "Tolerance Max", "V"}
					},
					{2, "SEL_IN Voltage (4.0V) 1_READ.SELOUT", unit,
						{"Min", p_tol_min_normal_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_normal_selout, "Tolerance Max", "V"}
					},
					{3, "SEL_IN Voltage (3.0V) 1_READ.SELOUT", unit,
						{"Min", p_tol_min_normal_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_normal_selout, "Tolerance Max", "V"}
					},
					{4, "SEL_IN Voltage (2.0V) 1_READ.SELOUT", unit,
						{"Min", p_tol_min_off_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_off_selout, "Tolerance Max", "V"}
					},
					{5, "SEL_IN Voltage (2.0V) 2_READ.SELOUT", unit,
						{"Min", p_tol_min_off_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_off_selout, "Tolerance Max", "V"}
					},
					{6, "SEL_IN Voltage (3.0V) 2_READ.SELOUT", unit,
						{"Min", p_tol_min_off_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_off_selout, "Tolerance Max", "V"}
					},
					{7, "SEL_IN Voltage (4.0V) 2_READ.SELOUT", unit,
						{"Min", p_tol_min_normal_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_normal_selout, "Tolerance Max", "V"}
					},
					{8, "SEL_IN Voltage (4.5V) 1_READ.SELOUT", unit,
						{"Min", p_tol_min_normal_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_normal_selout, "Tolerance Max", "V"}
					},
					{9, "Normal_READ.SELOUT High Voltage", unit,
						{"Min", p_tol_min_selout_pwm[1], "Tolerance Min", "V"},
						{"Max", p_tol_max_selout_pwm[1], "Tolerance Max", "V"}
					},
					{10, "Normal_READ.SELOUT Low Voltage", unit,
						{"Min", p_tol_min_selout_pwm[2], "Tolerance Min", "V"},
						{"Max", p_tol_max_selout_pwm[2], "Tolerance Max", "V"}
					},
					{11, "Normal_READ.SELOUT Frequency", unit,
						{"Min", p_tol_min_selout_pwm[3], "Tolerance Min", "V"},
						{"Max", p_tol_max_selout_pwm[3], "Tolerance Max", "V"}
					},
					{12, "Normal_READ.SELOUT Duty", unit,
						{"Min", p_tol_min_selout_pwm[4], "Tolerance Min", "V"},
						{"Max", p_tol_max_selout_pwm[4], "Tolerance Max", "V"}
					},
					-------------------------------------------------------------
					{13, "Short BAT 2_CMC_01_KompFehlerModus2_11", "",
						{"Med", p_tol_med_selout_status, "Tolerance Med", ""},
					},
					-------------------------------------------------------------
					{14, "Short BAT Reverted 2_CMC_01_KompFehlerModus2_11", unit,
						{"Med", p_tol_med_selout_remove_status, "Tolerance Med", ""},
					},
					-------------------------------------------------------------
					{15, "Short GND_CMC_01_KompFehlerModus2_11", unit,
						{"Med", p_tol_med_selout_status, "Tolerance Med", ""},
					},
					-------------------------------------------------------------
					{16, "Short GND Reverted_CMC_01_KompFehlerModus2_11", unit,
						{"Med", p_tol_med_selout_remove_status, "Tolerance Med", ""},
					},
					-------------------------------------------------------------
					{17, "SEL OUT OPEN_CMC_01_KompFehlerModus2_11", unit,
						{"Med", p_tol_med_selout_status, "Tolerance Med", ""},
					},
					-------------------------------------------------------------
					{18, "SEL OUT OPEN Reverted_CMC_01_KompFehlerModus2_11", unit,
						{"Med", p_tol_med_selout_remove_status, "Tolerance Med", ""},
					},
				}
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min_normal_selout = get_param_geely114l(seqno, 1, "Min", p_tol_min_normal_selout)
	p_tol_max_normal_selout = get_param_geely114l(seqno, 1, "Max", p_tol_max_normal_selout)
	p_tol_min_off_selout = get_param_geely114l(seqno, 4, "Min", p_tol_min_off_selout)
	p_tol_max_off_selout = get_param_geely114l(seqno, 4, "Max", p_tol_max_off_selout)
	for idx = 1,4 do
		p_tol_min_selout_pwm[idx] = get_param_geely114l(seqno, idx+8, "Max", p_tol_min_selout_pwm[idx])
		p_tol_max_selout_pwm[idx] = get_param_geely114l(seqno, idx+8, "Max", p_tol_max_selout_pwm[idx])
	end
	p_tol_med_selout_status = get_param_geely114l(seqno, 13, "Med", p_tol_med_selout_status)
	p_tol_med_selout_remove_status = get_param_geely114l(seqno, 14, "Med", p_tol_med_selout_remove_status)

	
	--SEL_IN Voltage (4.5V) 1-----------------------------------------------------------
	test_start(tcid, seqno, 1)
	
	--CtrlBrd(RelaySet.DMMRly.Reset, 1)
	--CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1)
	--tas.wait(500)
	
	--SELInPower_Volt(4.5)
	manual_selin_freq(4.5, 10)
	tas.wait(1000)
	
	--read_value = DMM_Set(DMM.ReadVolt)
	local read_value_selout = read_pwm_sel_out()
	read_value = read_value_selout[1]
	
	if read_value >= p_tol_min_normal_selout and read_value <= p_tol_max_normal_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	
	--SEL_IN Voltage (4.0V) 1-----------------------------------------------------------
	test_start(tcid, seqno, 2)
	
	--SELInPower_Volt(4)
	manual_selin_freq(4, 10)
	tas.wait(1000)
	
	--read_value = DMM_Set(DMM.ReadVolt)
	local read_value_selout = read_pwm_sel_out()
	read_value = read_value_selout[1]
	
	if read_value >= p_tol_min_normal_selout and read_value <= p_tol_max_normal_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 2, read_value, result)
	
	
	--SEL_IN Voltage (3.0V) 1-----------------------------------------------------------
	test_start(tcid, seqno, 3)
	--SELInPower_Volt(3)
	manual_selin_freq(3, 10)
	tas.wait(1000)
	
	--read_value = DMM_Set(DMM.ReadVolt)
	local read_value_selout = read_pwm_sel_out()
	read_value = read_value_selout[1]
	
	if read_value >= p_tol_min_normal_selout and read_value <= p_tol_max_normal_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 3, read_value, result)
	
	
	--SEL_IN Voltage (2.0V) 1-----------------------------------------------------------
	test_start(tcid, seqno, 4)
	--SELInPower_Volt(2)
	manual_selin_freq(2, 10)
	tas.wait(1000)
	
	--read_value = DMM_Set(DMM.ReadVolt)
	local read_value_selout = read_pwm_sel_out()
	read_value = read_value_selout[1]
	
	if read_value >= p_tol_min_off_selout and read_value <= p_tol_max_off_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 4, read_value, result)
	
	--SEL_IN Voltage (2.0V) 2-----------------------------------------------------------
	test_start(tcid, seqno, 5)
	
	--SELInPower_Volt(2)
	manual_selin_freq(2, 10)
	tas.wait(1000)
	
	--read_value = DMM_Set(DMM.ReadVolt)
	local read_value_selout = read_pwm_sel_out()
	read_value = read_value_selout[1]
	
	if read_value >= p_tol_min_off_selout and read_value <= p_tol_max_off_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 5, read_value, result)
	
	
	--SEL_IN Voltage (3.0V) 2-----------------------------------------------------------
	test_start(tcid, seqno, 6)
	
	--SELInPower_Volt(3)
	manual_selin_freq(3, 10)
	tas.wait(1000)
	
	--read_value = DMM_Set(DMM.ReadVolt)
	local read_value_selout = read_pwm_sel_out()
	read_value = read_value_selout[1]
	
	if read_value >= p_tol_min_off_selout and read_value <= p_tol_max_off_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 6, read_value, result)
	
	
	--SEL_IN Voltage (4.0V) 2-----------------------------------------------------------
	test_start(tcid, seqno, 7)
	
	--SELInPower_Volt(4)
	manual_selin_freq(4, 10)
	tas.wait(1000)
	
	--read_value = DMM_Set(DMM.ReadVolt)
	local read_value_selout = read_pwm_sel_out()
	read_value = read_value_selout[1]
	
	if read_value >= p_tol_min_normal_selout and read_value <= p_tol_max_normal_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 7, read_value, result)
	
	--SEL_IN Voltage (4.5V) 2-----------------------------------------------------------
	test_start(tcid, seqno, 8)
	
	--SELInPower_Volt(4)
	manual_selin_freq(4.5, 10)
	tas.wait(1000)
	
	--read_value = DMM_Set(DMM.ReadVolt)
	local read_value_selout = read_pwm_sel_out()
	read_value = read_value_selout[1]
	
	if read_value >= p_tol_min_normal_selout and read_value <= p_tol_max_normal_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 8, read_value, result)
	
	--SEL_IN Normal-----------------------------------------------------------
	
	manual_selin_freq(12, 10)
	tas.wait(1000)
	
	--read_value = DMM_Set(DMM.ReadVolt)
	local read_value_selout = read_pwm_sel_out()
	
	for seloutlst = 1,4 do
		test_start(tcid, seqno, seloutlst+8)
		
		read_value = read_value_selout[seloutlst]
		
		if read_value >= p_tol_min_selout_pwm[seloutlst] and read_value <= p_tol_max_selout_pwm[seloutlst] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, seloutlst+8, read_value, result)
	end
	
	--Short BAT ----------------------------------------------------------- TODO selout change logic check
	CtrlBrd(RelaySet.Power.SELOut_Short_LVPwr, 1) -- SEL_OUT Short to battery
	CtrlBrd(RelaySet.Power.SELOut_3kohm, 0)
	tas.wait(1000)

	test_start(tcid, seqno, 13)
	
	read_value = cmc_can_read("CSC_01_CompError_01", "CSC_01_CompErrorMode2_06")
	tas.wait(1000)
	
	if read_value == p_tol_med_selout_status then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 13, read_value, result)
	
	
	--Short BAT Reverted 2------------------------------------------------- TODO selout change logic check
	CtrlBrd(RelaySet.Power.SELOut_Short_LVPwr, 0) -- SEL_OUT Short to battery relay off
	CtrlBrd(RelaySet.Power.SELOut_3kohm, 1)
	tas.wait(1000)
		
	test_start(tcid, seqno, 14)
	
	read_value = cmc_can_read("CSC_01_CompError_01", "CSC_01_CompErrorMode2_06")
	tas.wait(1000)
	
	if read_value == p_tol_med_selout_remove_status then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 14, read_value, result)

	--Short GND----------------------------------------------------------- TODO selout change logic check
	CtrlBrd(RelaySet.Power.SELOut_10kohm, 1) -- SEL_OUT Short to ground relay on
	tas.wait(2000)
	
	test_start(tcid, seqno, 15)
	
	read_value = cmc_can_read("CSC_01_CompError_01", "CSC_01_CompErrorMode2_06")
	tas.wait(400)
	
	if read_value == p_tol_med_selout_status then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 15, read_value, result)
	
	
	--Short GND Reverted-----------------------------------------------------------	
	CtrlBrd(RelaySet.Power.SELOut_10kohm, 0) -- SEL_OUT Short to ground relay on
	CtrlBrd(RelaySet.Power.SELOut_3kohm, 1)
	tas.wait(400)
	
	test_start(tcid, seqno, 16)
	
	read_value = cmc_can_read("CSC_01_CompError_01", "CSC_01_CompErrorMode2_06")
	tas.wait(400)
	
	if read_value == p_tol_med_selout_remove_status then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 16, read_value, result)
	
	
	--SEL OUT OPEN-----------------------------------------------------------
	CtrlBrd(RelaySet.Power.SELOut_3kohm, 0) -- SEL_OUT open relay on
	tas.wait(1000)
	
	
	test_start(tcid, seqno, 17)
	
	read_value = cmc_can_read("CSC_01_CompError_01", "CSC_01_CompErrorMode2_06")
	tas.wait(1000)
	
	if read_value == p_tol_med_selout_status then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 17, read_value, result)
	
	
	--SEL OUT OPEN Reverted-----------------------------------------------------------
	CtrlBrd(RelaySet.Power.SELOut_3kohm, 1) -- SEL_OUT open relay on
	tas.wait(1000)
	
	test_start(tcid, seqno, 18)
	
	read_value = cmc_can_read("CSC_01_CompError_01", "CSC_01_CompErrorMode2_06")
	tas.wait(1000)
	
	if read_value == p_tol_med_selout_remove_status then
		result = true
	else
		result = false
	end
	
	-- Reverted
	SELInPower_Volt(12)
	CtrlBrd(RelaySet.DMMRly.Reset, 1)
	
	test_finish(tcid, seqno, 18, read_value, result)
end

-------------------------------------------------------------------------
--  20. Temperature Measurement
-------------------------------------------------------------------------
declare "tc_geely114l_20_temp_measurement"
function tc_geely114l_20_temp_measurement(run, seqno)
	local tcid = 20
	local unit = "℃"
	
	-- default parameter
	local p_tol_min_25dgree = 23
	local p_tol_max_25dgree = 27
	local p_tol_min_0dgree = -2
	local p_tol_max_0dgree = 2
	local p_tol_min_50dgree = 48
	local p_tol_max_50dgree = 52
	
	-- local variable
	local result = false
	local read_value = 0

	local module_num = 0
	if run == false then
		local tcinfo = {tcid, "Cell temperature_geely114l", "tc_geely114l_20_temp_measurement",
							{1, "Cell temperature : module "..module_num.." (25℃)", unit, 
								{"Min", p_tol_min_25dgree, "Tolerance Min", unit},
								{"Max", p_tol_min_25dgree, "Tolerance Max", unit}
							},
							{2, "Cell temperature : module "..module_num.." (0℃)", unit, 
								{"Min", p_tol_min_0dgree, "Tolerance Min", unit},
								{"Max", p_tol_max_0dgree, "Tolerance Max", unit}
							},
							{3, "Cell temperature : module "..module_num.." (50℃)", unit, 
								{"Min", p_tol_min_50dgree, "Tolerance Min", unit},
								{"Max", p_tol_max_50dgree, "Tolerance Max", unit}
							}
						}
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min_25dgree = get_param_geely114l(seqno, 1, "Min", p_tol_min_25dgree)
	p_tol_max_25dgree = get_param_geely114l(seqno, 1, "Max", p_tol_max_25dgree)
	p_tol_min_0dgree = get_param_geely114l(seqno, 2, "Min", p_tol_min_0dgree)
	p_tol_max_0dgree = get_param_geely114l(seqno, 2, "Max", p_tol_max_0dgree)
	p_tol_min_50dgree = get_param_geely114l(seqno, 3, "Min", p_tol_min_50dgree)
	p_tol_max_50dgree = get_param_geely114l(seqno, 3, "Max", p_tol_max_50dgree)
	
	local ch_val = 6 -- variable of resistor board id number
	
	-- 25 dgree ------------------------------------------------------------------------------
	test_start(tcid, seqno, 1)
	
	ProgrammableResistor(ch_val, TemperatValue.dgree25, 0) -- programmable resistor board setting
	tas.wait(2000)
	
	read_value = cmc_can_read("BMM_01_05", "BMM_01_Temp_1") -- read can temperature value
	if read_value >= p_tol_min_25dgree and read_value <= p_tol_max_25dgree then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	-- 0dgree ------------------------------------------------------------------------------
	test_start(tcid, seqno, 2)
	
	ProgrammableResistor(ch_val, TemperatValue.dgree0, 0) -- programmable resistor board setting
	tas.wait(2000)
	
	read_value = cmc_can_read("BMM_01_05", "BMM_01_Temp_1") -- read can temperature value
	if read_value >= p_tol_min_0dgree and read_value <= p_tol_max_0dgree then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 2, read_value, result)
	
	-- 50dgree ------------------------------------------------------------------------------
	test_start(tcid, seqno, 3)
	
	ProgrammableResistor(ch_val, TemperatValue.dgree50, 0) -- programmable resistor board setting
	tas.wait(2000)
	
	read_value = cmc_can_read("BMM_01_05", "BMM_01_Temp_1") -- read can temperature value
	if read_value >= p_tol_min_50dgree and read_value <= p_tol_max_50dgree then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 3, read_value, result)
	
end

-------------------------------------------------------------------------
--  21. Openwire Detection
-------------------------------------------------------------------------
declare "tc_geely114l_21_cell_openwire_detection"
function tc_geely114l_21_cell_openwire_detection(run, seqno)
	local tcid = 21
	local unit = ""

	-- default parameter
	local p_tol_med_normal = 1
	local p_tol_med_fault = 3
	
	-- local variable
	local on_delay = 1000
	local off_delay = 2000
	local selout_value = 0
	local result = false
	local read_value = 0
	
	if run == false then
		local tcinfo = {tcid, "Cell voltage wire open_geely114l", "tc_geely114l_21_cell_openwire_detection"}
		table.insert(tcinfo, 
						{1, "Cell normal voltage input @ BMM_01_CompErrorMode2_04", unit, 
							{"Med", p_tol_med_normal, "Tolerance Med", ""},
						}
					)
		for substepidx = 1, 12, 1 do
			table.insert(tcinfo, 
							{substepidx+1, "Cell voltage wire open(cell #"..(13-substepidx)..") @ BMM_01_CompErrorMode2_04", unit, 
								{"Med", p_tol_med_fault, "Tolerance Med", ""},
							}
						)
		end	
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_med_normal = get_param_geely114l(seqno, 1, "Med", p_tol_med_normal)
	p_tol_med_fault = get_param_geely114l(seqno, 2, "Med", p_tol_med_fault)
	
	--normal state check------------------------------------------------------------------------
	test_start(tcid, seqno, 1)
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- Reset all dmm relay
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1) -- SEL_OUT Volt measure relay on
	
	local cellvolt = 3700
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt) -- cell simulator set
	end
	tas.wait(on_delay)
	
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 0)
	tas.wait(off_delay)
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 1)
	tas.wait(3000)
	
	read_value = cmc_can_read("BMM_01_CompError_01", "BMM_01_CompErrorMode2_04")
	if read_value == p_tol_med_normal then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	--open wire check(#12)--------------------------------------------------------------------
	test_start(tcid, seqno, 2)
	
	CtrlBrd(RelaySet.Cell.CellPOS_Cell12, 0)
	
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 0)
	tas.wait(off_delay)
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 1)
	tas.wait(3000) 
	
	read_value = cmc_can_read("BMM_01_CompError_01", "BMM_01_CompErrorMode2_04")
	if read_value == p_tol_med_fault then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.Cell.CellPOS_Cell12, 1)
	tas.wait(1000)
	
	test_finish(tcid, seqno, 2, read_value, result)
	
	--open wire check------------------------------------------------------------------------
	for substepidx = 2, 12, 1 do
		test_start(tcid, seqno, substepidx+1)
		
		CtrlBrd(RelaySet.Cell.Cell12_CellSen12-(substepidx-1), 0) -- each cell open wire
		
		CtrlBrd(RelaySet.Power.LV_PWR_POS, 0)
		tas.wait(off_delay)
		CtrlBrd(RelaySet.Power.LV_PWR_POS, 1)
		tas.wait(3000)
		
		read_value = cmc_can_read("BMM_01_CompError_01", "BMM_01_CompErrorMode2_04")
		if read_value == p_tol_med_fault then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, substepidx+1, read_value, result)
	end
		
end

-------------------------------------------------------------------------
--  22. All Power & Relay Off
-------------------------------------------------------------------------
declare "tc_geely114l_22_all_power_reset"
function tc_geely114l_22_all_power_reset(run, seqno)
	local tcid = 22
	local unit = ""
	
	local result = true

	if run == false then
		local tcinfo = {tcid, "Power All Off & End Test_geely114l", "tc_geely114l_22_all_power_reset",
					{1, "Power All Off & End Test", unit}
				}
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
		
	test_start(tcid, seqno, 1)
	
	-- power off
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 0)
	CtrlBrd(RelaySet.Power.LV_PWR_NEG, 0)
	LVPower_Volt(0)
	LVPower_Onoff(0)
	tas.wait(500)
	
	--CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 0)
	CtrlBrd(RelaySet.Power.A0_SELIn, 0)
	SELInPower_Volt(0)
	SELInPower_Onoff(0)
	tas.wait(500)	
	
	-- cell simulator init
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, 0, 0, 0, 0)
	end
	
	CtrlBrd(RelaySet.Power.All_Off, 1) -- Control Board Reset
	tas.wait(500)
	
	CtrlBrd(RelaySet.Model.VW12S1P, 0)

	result = true

	cmc_can_finish_geely114l()
	
	test_finish(tcid, seqno, 1, "", result)
	
end

declare "geely114l_voltage_accuracy_test"
function geely114l_voltage_accuracy_test(run, seqno)
	local tcid = 101
	local unit = "mV"
	
	--Cell Accuracy-----------------------------------------------------------------
	local p_tol_min = 3699
	local p_tol_max = 3701
	local strlst = {"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"}

	local read_value = 0
	local result = false
	local cellvolt = 0
	
	if run == false then
		local tcinfo = {tcid, "Accuracy test", "geely114l_voltage_accuracy_test"}
		for substepidx = 1, 12, 1 do
			table.insert(tcinfo, 
							{substepidx, "Cell"..strlst[substepidx].." (3.7V)", unit, 
								{"Min", p_tol_min, "Tolerance Min", "mV"},
								{"Max", p_tol_max, "Tolerance Max", "mV"}
							}
						)
		end
		table.insert(tcinfo,
								{13, "LV Power Accuracy", "V",
									{"Min", 11.9, "Tolerance Min", "V"},
									{"Max", 12.1, "Tolerance Max", "V"}
								}
						)
		table.insert(tcinfo,
								{14, "SEL_IN Accuracy", "V",
									{"Min", 11.9, "Tolerance Min", "V"},
									{"Max", 12.1, "Tolerance Max", "V"}
							}
					)
		table.insert(tcinfo,
							{15, "SEL_IN Low", "V",
								{"Min", 9.5, "Tolerance Min", "V"},
								{"Max", 10.5, "Tolerance Max", "V"}
							}
						)
		table.insert(tcinfo,
							{16, "SEL_IN Frequency", "Hz",
								{"Min", 9.5, "Tolerance Min", "Hz"},
								{"Max", 10.5, "Tolerance Max", "Hz"}
							}
						)
		table.insert(tcinfo,
							{17, "SEL_IN Duty", "%",
								{"Min", 9.5, "Tolerance Min", "%"},
								{"Max", 10.5, "Tolerance Max", "%"}
							}
						)
		table.insert(tcinfo,
							{18, "SEL_OUT", "V",
								{"Min", 9.5, "Tolerance Min", "V"},
								{"Max", 10.5, "Tolerance Max", "V"}
							}
						)
		table.insert(tcinfo,
							{19, "SEL_OUT Low", "V",
								{"Min", 9.5, "Tolerance Min", "V"},
								{"Max", 10.5, "Tolerance Max", "V"}
							}
						)
		table.insert(tcinfo,
							{20, "SEL_OUT Frequency", "Hz",
								{"Min", 9.5, "Tolerance Min", "Hz"},
								{"Max", 10.5, "Tolerance Max", "Hz"}
							}
						)
		table.insert(tcinfo,
							{21, "SEL_OUT Duty", "%",
								{"Min", 9.5, "Tolerance Min", "%"},
								{"Max", 10.5, "Tolerance Max", "%"}
							}
						)
		table.insert(tcinfo_table_geely114l, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min = get_param_geely114l(seqno, 1, "Min", p_tol_min)
	p_tol_max = get_param_geely114l(seqno, 1, "Max", p_tol_max)

	--CellSimulator_CAN(0, 0) -- Cellsimulator can comm. off
	tas.wait(1000)
	
	-- cell simulator set
	cellvolt = 3700
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(2000)
	
	local startCell = RelaySet.DMMRly.Cell1VoltMeas
	for idx = 1, 12, 1 do
		test_start(tcid, seqno , idx)

		CtrlBrd(RelaySet.DMMRly.Reset, 1) -- dmm relay reset
		CtrlBrd(startCell + (idx - 1), 1) -- Ch1 Voltage measure relay on
		tas.wait(500)
		
		if idx%2 == 1 then
			read_value = (DMM_Set(DMM.ReadVolt)*1000)
		else
			read_value = -1 * (DMM_Set(DMM.ReadVolt)*1000)
		end
		
		if read_value >= p_tol_min and read_value <= p_tol_max then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, idx, read_value, result)
		
		tas.wait(500)
	end	
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM Init
	tas.wait(200)
	
	--LV Power Accuracy-----------------------------------------------------------------
	p_tol_min = 12 - (12*0.01)
	p_tol_max = 12 + (12*0.01)
	
	test_start(tcid, seqno , 13)
	
	CtrlBrd(RelaySet.DMMRly.VBATVoltMeas, 1)
	tas.wait(500)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min and read_value <= p_tol_max then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM Init
	tas.wait(200)
	
	test_finish(tcid, seqno, 13, read_value, result)
	
	--SEL_IN Accuracy-----------------------------------------------------------------
--	p_tol_min = 12 - (12*0.01)
--	p_tol_max = 12 + (12*0.01)
--
--	test_start(tcid, seqno , 14)
--	
--	CtrlBrd(RelaySet.DMMRly.SELInVoltMeas, 1)
--	tas.wait(500)
--	
--	read_value = DMM_Set(DMM.ReadVolt)
--	
--	if read_value >= p_tol_min and read_value <= p_tol_max then
--		result = true
--	else
--		result = false
--	end
--	
--	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM Init
--	tas.wait(200)
--	
--	test_finish(tcid, seqno, 14, read_value, result)	
	
	local p_tol_min_selout = {4.5, 0, 9, 0.49}
	local p_tol_max_selout = {18, 2, 11, 0.51}
	
	local selin_value = read_pwm_sel_in()
	
	for subidx = 1, 4 do
		test_start(tcid, seqno, subidx+13)
		
		read_value = selin_value[subidx]
		read_value = read_value - read_value%0.0001
		if read_value >= p_tol_min_selout[subidx] and read_value <= p_tol_max_selout[subidx] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, subidx+13, read_value, result)
	end	
	
	--SEL_OUT Accuracy-----------------------------------------------------------------
--	p_tol_min = 9.5
--	p_tol_max = 10.5
--	
--	test_start(tcid, seqno , 15)
--	
--	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1)
--	tas.wait(500)
--	
--	read_value = DMM_Set(DMM.ReadVolt)
--	
--	if read_value >= p_tol_min and read_value <= p_tol_max then
--		result = true
--	else
--		result = false
--	end
--	
--	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM Init
--	tas.wait(200)
--	
--	test_finish(tcid, seqno, 15, read_value, result)	
	local p_tol_min_selout = {4.5, 0, 9, 0.49}
	local p_tol_max_selout = {18, 2, 11, 0.51}
	
	local selout_value = read_pwm_sel_out()
	
	for subidx = 1, 4 do
		test_start(tcid, seqno, subidx+17)
		
		read_value = selout_value[subidx]
		read_value = read_value - read_value%0.0001
		if read_value >= p_tol_min_selout[subidx] and read_value <= p_tol_max_selout[subidx] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, subidx+17, read_value, result)
	end	
	
end

declare "get_tc_list_geely114l"
function get_tc_list_geely114l()
	tcinfo_table_geely114l = {}
	param_table_geely114l = {}
	tc_geely114l_1_init(false, 0)
	tc_geely114l_2_operating_current_measure(false, 0)
	tc_geely114l_3_id_assign(false, 0)
	tc_geely114l_4_version_check(false, 0)
	tc_geely114l_5_lv_and_hv_current_measure(false, 0)
	tc_geely114l_6_power_supply_test(false, 0)
	tc_geely114l_7_oddcell_no_balancing_current_consum(false, 0)
	tc_geely114l_8_oddcell_balancing_status(false, 0)
	tc_geely114l_9_oddcell_balancing_current(false, 0)
	tc_geely114l_10_evencell_no_balancing_current_consum(false, 0)
	tc_geely114l_11_evencell_balancing_status(false, 0)
	tc_geely114l_12_evencell_balancing_current(false, 0)
	tc_geely114l_13_oddcell_no_balancing_current_consum_2(false, 0)
	tc_geely114l_14_ovp_uvp(false, 0)
	tc_geely114l_15_voltage_accuracy_3700(false, 0)
	tc_geely114l_16_voltage_accuracy_3400(false, 0)
	tc_geely114l_17_voltage_accuracy_4100(false, 0)
	--tc_geely114l_18_cvn_value_reading(false, 0)
	tc_geely114l_19_alarm_line_check(false, 0)
	tc_geely114l_20_temp_measurement(false, 0)
	tc_geely114l_21_cell_openwire_detection(false, 0)
	tc_geely114l_22_all_power_reset(false, 0)
	geely114l_voltage_accuracy_test(false, 0)
end
get_tc_list_geely114l()

declare "geely114l_sequence_run"
function geely114l_sequence_run()
	tc_geely114l_1_init(true, 1)
	tc_geely114l_2_operating_current_measure(true, 2)
	tc_geely114l_3_id_assign(true, 3)
	tc_geely114l_4_version_check(true, 4)
	tc_geely114l_5_lv_and_hv_current_measure(true, 5)
	tc_geely114l_6_power_supply_test(true, 6)
	tc_geely114l_7_oddcell_no_balancing_current_consum(true, 7)
	tc_geely114l_8_oddcell_balancing_status(true, 8)
	tc_geely114l_9_oddcell_balancing_current(true, 9)
	tc_geely114l_10_evencell_no_balancing_current_consum(true, 10)
	tc_geely114l_11_evencell_balancing_status(true, 11)
	tc_geely114l_12_evencell_balancing_current(true, 12)
	tc_geely114l_13_oddcell_no_balancing_current_consum_2(true, 13)
	tc_geely114l_14_ovp_uvp(true, 14)
	tc_geely114l_15_voltage_accuracy_3700(true, 15)
	tc_geely114l_16_voltage_accuracy_3400(true, 16)
	tc_geely114l_17_voltage_accuracy_4100(true, 17)
	--tc_geely114l_18_cvn_value_reading(true, 18)
	tc_geely114l_19_alarm_line_check(true, 19)
	tc_geely114l_20_temp_measurement(true, 20)
	tc_geely114l_21_cell_openwire_detection(true, 21)
	tc_geely114l_22_all_power_reset(true, 22)
end















