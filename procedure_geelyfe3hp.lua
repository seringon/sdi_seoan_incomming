------------------------------------------------------------
-- Interface Implemeation Start
------------------------------------------------------------
declare "tcinfo_table_geelyfe3hp"
tcinfo_table_geelyfe3hp = {}
declare "param_table_geelyfe3hp"
param_table_geelyfe3hp = {}
declare "h_sync_task_geelyfe3hp"
h_sync_task_geelyfe3hp = nil

declare "change_test_model_geelyfe3hp"
function change_test_model_geelyfe3hp()
	tas.writestring("can1.@reopen",  "BaudRate=500000, Node=BMC, DB=C:\\Users\\abc\\Desktop\\TAS_Project\\CAN\\GEELY_FE3HP_V02_tas.xml, FrameDB=GEELY_FE3HP_V02_xnet, RevDir=0, TransceiverType=HS, Termination=1, ListenOnly=0, ReadInterval=10")
	dbc_load(3)
end

declare "set_param_geelyfe3hp"
function set_param_geelyfe3hp(seqid, subseqid, param_name, value)
	param_table_geelyfe3hp[seqid .. "_" .. subseqid .. "_" .. param_name] = value
end

declare "get_param_geelyfe3hp"
function get_param_geelyfe3hp(seqid, subseqid, param_name, default_value)
	local ret = param_table_geelyfe3hp[seqid .. "_" .. subseqid .. "_" .. param_name]
	if ret == nil then
		return default_value
	else
		return ret
	end
end

declare "clear_param_geelyfe3hp"
function clear_param_geelyfe3hp()
	param_table_geelyfe3hp = {}
end

declare "manual_start_bmc_sync_geelyfe3hp"
function manual_start_bmc_sync_geelyfe3hp()
	--no need sync
end

declare "manual_stop_bmc_sync_geelyfe3hp"
function manual_stop_bmc_sync_geelyfe3hp()
	--no need sync
end

declare "manual_init1_geelyfe3hp"
function manual_init1_geelyfe3hp()
	tc_geelyfe3hp_1_init(true, 0)
end

declare "manual_init2_geelyfe3hp"
function manual_init2_geelyfe3hp()

end

declare "manual_init3_geelyfe3hp"
function manual_init3_geelyfe3hp()

end

declare "manual_cmc_id_assign_geelyfe3hp"
function manual_cmc_id_assign_geelyfe3hp(setid)
	setid = setid - 1
	local setid_10 = math.floor(setid/10)
	local setid_1 = setid%10
	local read_value = ""
	local p_tol_min_erase = -0.1
	local p_tol_max_erase = 2
	local result = false

	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1) --SEL_OUT voltage measurement realy on
	tas.wait(1000)
	
	------------------- 1. Erase -------------------
	SELInPower_Volt(0) -- SEL_IN Power off(set 0 voltage immediately. if not, use analog signal)
	tas.write("ao_SEL_IN", 0) -- DAQ AO_0 set 0 volt
	CtrlBrd(RelaySet.Power.A0_SELIn, 1)
	CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 0)
	tas.wait(200)
	
	read_value = DMM_Set(DMM.ReadVolt) -- SELOUT volt measure
	tas.wait(500)
	
	if read_value >= p_tol_min_erase and read_value <= p_tol_max_erase then
		result = true
	else
		result = false
	end
			
	tas.writestring("can1.@frame:0x6C0", "0210830000000000")
	tas.wait(200)
	tas.writestring("can1.@frame:0x6C0", "043181F014000000")
	tas.wait(200)
	
	CtrlBrd(RelaySet.Power.A0_SELIn, 0)
	CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 1)
	SELInPower_Volt(12)
	tas.wait(1000)
	
	CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 0)
	CtrlBrd(RelaySet.Power.A0_SELIn, 1)
	SELInPower_Volt(0)
	tas.wait(200)
	
	------------------- 3. ID Assign -------------------
	tas.writestring("can1.@frame:0x6C0", "0210830000000000")
	tas.wait(200)
	tas.writestring("can1.@frame:0x6C0", "043181F014000000")
	tas.wait(200)
	tas.writestring("can1.@frame:0x6C0", "053181F019"..setid_10..setid_1.."0000")
	tas.wait(200)
	
	--manual_selin_freq(12, 10)
	CtrlBrd(RelaySet.Power.A0_SELIn, 0)
	CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 1)
	SELInPower_Volt(12)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1)
end

declare "manual_cmc_id_clear_geelyfe3hp"
function manual_cmc_id_clear_geelyfe3hp()
	------------------- 1. Erase -------------------
	SELInPower_Volt(0) -- SEL_IN Power off(set 0 voltage immediately. if not, use analog signal)
	tas.write("ao_SEL_IN", 0) -- DAQ AO_0 set 0 volt
	CtrlBrd(RelaySet.Power.A0_SELIn, 1)
	CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 0)
	tas.wait(700)
			
	tas.writestring("can1.@frame:0x6C0", "0210830000000000")
	tas.wait(200)
	tas.writestring("can1.@frame:0x6C0", "043181F014000000")
	tas.wait(200)
	
	CtrlBrd(RelaySet.Power.A0_SELIn, 0)
	CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 1)
	SELInPower_Volt(12)
	tas.wait(1000)
end

declare "manual_get_version_read_geelyfe3hp"
function manual_get_version_read_geelyfe3hp()
	local byte_data = {}
	local read_value = ""

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

declare "manual_balancing_start_geelyfe3hp"
function manual_balancing_start_geelyfe3hp(bal_time_sec, ch_onoff_list)
	local chidx_10 = 0
	local chidx_1 = 0
	local msgidx = 1
	
	if #ch_onoff_list > 12 then -- if input channel is over 16 channel, then send error
		tas.fail("Balancing Channel Select Error(max channel:16)")
	else
		for chidx = 1, #ch_onoff_list, 1 do
			if ch_onoff_list[chidx] ~= nil and ch_onoff_list[chidx] == true then
				chidx_10 = math.floor(chidx/10)
				chidx_1 = chidx%10
				cmc_can_write("BMC_CSC_01_02", "BMC_CSC_01_ReqBalCell_"..chidx_10..chidx_1, tonumber(bal_time_sec))
			else
				chidx_10 = math.floor(chidx/10)
				chidx_1 = chidx%10
				cmc_can_write("BMC_CSC_01_02", "BMC_CSC_01_ReqBalCell_"..chidx_10..chidx_1, 0)
			end
			tas.wait(50)
		end
	end
end

declare "manual_balancing_stop_geelyfe3hp"
function manual_balancing_stop_geelyfe3hp()
	local bal_state = {false,false,false,false,false,false,false,false,false,false,false,false}
	manual_balancing_start_geelyfe3hp(0, bal_state)
end

declare "test_stop_geelyfe3hp"
function test_stop_geelyfe3hp()
	-- TODO:
	tc_geelyfe3hp_25_all_power_reset(true, 100)
	cylinder_up()
end
------------------------------------------------------------
-- Interface Implemeation FINISH
------------------------------------------------------------

--------------------------------------
-- Sync Message Send/Stop
--------------------------------------
declare "cmc_can_init_geelyfe3hp"
function cmc_can_init_geelyfe3hp()
	-- no sync signal
end

declare "cmc_can_finish_geelyfe3hp"
function cmc_can_finish_geelyfe3hp()
	-- no sync signal
end

-------------------------------------------------------------------------   
-- 1. Initialization   
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_1_init"
function tc_geelyfe3hp_1_init(run, seqno)
	local tcid = 1
	local unit = ""
	local p_LVCurrent = 1
	
	if run == false then
		local tcinfo = {tcid, "Initialization_geelyfe3hp", "tc_geelyfe3hp_1_init",
					{1, "Init", unit}
				}
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
		
	test_start(tcid, seqno, 1)
	
	-- Cell Simulator CAN
	tas.write("can2.onoff", 1)

	-- CellSimulator CAN Enable
	CellSimulator_CAN(0, 1)
	
	CtrlBrd(RelaySet.Power.All_Off, 1) -- Control Board Reset
	
	-- power off
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 0)
	CtrlBrd(RelaySet.Power.LV_PWR_NEG, 0)
	LVPower_Volt(0)
	LVPower_Onoff(0)
	tas.wait(500)
	
	CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 0)
	SELInPower_Volt(0)
	SELInPower_Onoff(0)
	tas.wait(500)	
	
	-- cell simulator init
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, 0, 0, 0, 0)
	end
	
	-- Board Select
	CtrlBrd(RelaySet.Model.M12S1P, 1)

	-- DUT Select Board Connecct
	CELL8_9_STACK(1) -- enable 8,9 Stack

	-- Control Board Connect(normal)
	for i = 10, 21, 1 do -- 10~21 is "Cell_CellSenGND~11" connect logic number in CtrlBrd function
		CtrlBrd(i, 1)
	end	
	CtrlBrd(RelaySet.Cell.CellPOS_Cell12, 1)
	
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 1)
	CtrlBrd(RelaySet.Power.LV_PWR_NEG, 1)
	CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 1)
	CtrlBrd(RelaySet.Power.SELOut_3kohm, 1) -- SEL Out 3kohm connect
	CtrlBrd(RelaySet.Power.CAH_connect, 1) -- CAN Connect
	tas.wait(1000)
	
	-- cell simulator input
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, 1800, 1800, 1800, 1800)
	end
	tas.wait(500)
	
	-- Turn on Power
	LVPower_Curr(1)
	LVPower_Onoff(1)
	LVPower_Volt(12)
	tas.wait(500)
	--tas.wait(1000)

	-- initialization DUT CAN
	tas.write("can1.onoff", 1)
	
	SELInPower_Onoff(1)
	SELInPower_Volt(12)
	tas.wait(1000)

	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, 3700, 3700, 3700, 3700)
	end
	tas.wait(500)
		
	test_finish(tcid, seqno, 1, "", true)
end

-------------------------------------------------------------------------   
--  2. LV side Power Turn on & Reset Time   
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_2_lv_side_power_trunon_reset_time"
function tc_geelyfe3hp_2_lv_side_power_trunon_reset_time(run, seqno)
	local tcid = 2
	local unit = "ms"
	
	-- default parameter
	local p_tol_min = 1
	local p_tol_max = 50
	
	-- local variable
	local resetTime = 0
	local read_value = 0
	local result = false
	
	if run == false then
		local tcinfo = {tcid, "LV side Power Turn on & Reset Time_geelyfe3hp", "tc_geelyfe3hp_2_lv_side_power_trunon_reset_time",
					{1, "READ.SELOUT.TIME", unit,
						{"Min", p_tol_min, "Tolerance Min", "ms"},
						{"Max", p_tol_max, "Tolerance Max", "ms"}
					}
				}
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min = get_param_geelyfe3hp(seqno, 1, "Min", p_tol_min)
	p_tol_max = get_param_geelyfe3hp(seqno, 1, "Max", p_tol_max)
	
	test_start(tcid, seqno, 1)
	
	-- data logging start
	tas.osc_reset("oscchart", 5000)
	tas.osc_pause_update("oscchart")
	tas.osc_add_series("oscchart", "vbatt", "ai_LV_PWR_POS", "Yellow")
	tas.osc_add_series("oscchart", "sell_out", "ai_SEL_OUT", "Green")
	tas.osc_set_xrange("oscchart", 1)
	tas.osc_set_yrange("oscchart", -1, 15)
	tas.osc_resume_update("oscchart")
	
	tas.wait(100)
	tas.read("ai_SEL_OUT")

	for i = 1, 4, 1 do -- retry 
		-- turn off LV Power Relay
		CtrlBrd(RelaySet.Power.LV_PWR_POS, 0)
		
		-- 5sec delay
		tas.wait(5000)
		
		-- turn on LV Power Relay
		CtrlBrd(RelaySet.Power.LV_PWR_POS, 1)
		
		tas.wait(300)

		tas.osc_export_data_to_csv('oscchart', tas.get_logging_path() .. "\\..\\")

		local vbatt_tbl = get_csv_file(tas.get_logging_path() .. "\\..\\".."vbatt.csv")
		local sel_out_tbl = get_csv_file(tas.get_logging_path() .. "\\..\\".."sell_out.csv")
		local vbatt_on_time
		local sel_out_on_time
		
		for i = 2, #vbatt_tbl do
			if tonumber(vbatt_tbl[i][2]) > 5 then
				vbatt_on_time = tonumber(vbatt_tbl[i][1])
				break
			end
		end

		for i = 2, #sel_out_tbl do
			if tonumber(sel_out_tbl[i][2]) > 5 then
				sel_out_on_time = tonumber(sel_out_tbl[i][1])
				break
			end
		end
		
		tas.wait(200)	

		if vbatt_on_time ~= nil and sel_out_on_time ~= nil then
			read_value = (sel_out_on_time-vbatt_on_time)/5
		else
			tas.fail("SEL_OUT or VBATT is nil value. retry:"..i)
			read_value = 0
		end
		
		tas.wait(200)

		if read_value >= p_tol_min and read_value <= p_tol_max then
			result = true
			break
		else
			result = false
		end
	end

	tas.osc_pause_update("oscchart")
	
	test_finish(tcid, seqno, 1, read_value, result)
end

-------------------------------------------------------------------------   
--  3. Current_No ID   
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_3_operating_current_measure"
function tc_geelyfe3hp_3_operating_current_measure(run, seqno)
	local tcid = 3
	local unit = "mA"
	
	-- default parameter
	local p_tol_min_lv = 20
	local p_tol_max_lv = 30
	local p_tol_min_hv = 13
	local p_tol_max_hv = 17
	
	-- local variable
	local read_value = 0
	local result = false
	
	if run == false then
		local tcinfo = {tcid, "Current_No ID_geelyfe3hp", "tc_geelyfe3hp_3_operating_current_measure",
					{1, "LV Side Operating Current Measurement", unit, 
						{"Min", p_tol_min_lv, "Tolerance Min", "mA"},
						{"Max", p_tol_max_lv, "Tolerance Max", "mA"}
					},
					{2, "HV Side Operating Current Measurement", unit,
						{"Min", p_tol_min_hv, "Tolerance Min", "mA"},
						{"Max", p_tol_max_hv, "Tolerance Max", "mA"}
					}
				}
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min_lv = get_param_geelyfe3hp(seqno, 1, "Min", p_tol_min_lv)
	p_tol_max_lv = get_param_geelyfe3hp(seqno, 1, "Max", p_tol_max_lv)
	p_tol_min_hv = get_param_geelyfe3hp(seqno, 2, "Min", p_tol_min_hv)
	p_tol_max_hv = get_param_geelyfe3hp(seqno, 2, "Max", p_tol_max_hv)
	
	------------------- lv side operating current measure -------------------
	test_start(tcid, seqno, 1)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM Init
	CtrlBrd(RelaySet.DMMRly.VBATNegCurrMeasOn, 1) -- DMM LV Current measure mode on
	
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadCurr) * 1000 -- DMM Read Current
	if read_value >= p_tol_min_lv and read_value <= p_tol_max_lv then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.Power.LV_PWR_NEG, 1)
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM Reset
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	
	------------------- hv side operation current measure -------------------
	test_start(tcid, seqno, 2)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM Init
	CtrlBrd(RelaySet.DMMRly.HVPosCurrMeasOn, 1) -- DMM HV Current measure mode on
	tas.wait(1000)
	
	read_value = -1 * DMM_Set(DMM.ReadCurr) * 1000 -- DMM Read Current
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
--  4. CMC ID Assign
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_4_id_assign"
function tc_geelyfe3hp_4_id_assign(run, seqno)
	local tcid = 4
	local unit = "V"
	
	-- default parameter
	local p_tol_min_erase = -0.1
	local p_tol_max_erase = 2
	local p_tol_min_selout = 9.5
	local p_tol_max_selout = 10.5
	local p_tol_med_bmmmsg = 1
	
	-- local variable
	local readSELOut = nil
	local read_value = 0
	local result = false
	
	if run == false then
		local tcinfo = {tcid, "CMC ID Assign_geelyfe3hp", "tc_geelyfe3hp_4_id_assign",
					{1, "ID Erase READ.SELOUT", unit,
						{"Min", p_tol_min_erase, "Tolerance Min", "V"},
						{"Max", p_tol_max_erase, "Tolerance Max", "V"}						
					},
					{2, "BMM_01_01", "",
						{"Med", p_tol_med_bmmmsg, "Tolerance Med", ""}
					},
					{3, "BMM_01_02", "",
						{"Med", p_tol_med_bmmmsg, "Tolerance Med", ""}
					},
					{4, "BMM_01_03", "",
						{"Med", p_tol_med_bmmmsg, "Tolerance Med", ""}
					},
					{5, "BMM_01_05", "",
						{"Med", p_tol_med_bmmmsg, "Tolerance Med", ""}
					},
					{6, "BMM_01_06", "",
						{"Med", p_tol_med_bmmmsg, "Tolerance Med", ""}
					},
					{7, "BMM_01_08", "",
						{"Med", p_tol_med_bmmmsg, "Tolerance Med", ""}
					},
					{8, "BMM_01_CompError_01", "",
						{"Med", p_tol_med_bmmmsg, "Tolerance Med", ""}
					},
					{9, "READ.SELOUT", unit,
						{"Min", p_tol_min_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_selout, "Tolerance Max", "V"}		
					}
				}
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min_erase = get_param_geelyfe3hp(seqno, 1, "Min", p_tol_min_erase)
	p_tol_max_erase = get_param_geelyfe3hp(seqno, 1, "Max", p_tol_max_erase)
	p_tol_med_bmmmsg = get_param_geelyfe3hp(seqno, 2, "Med", p_tol_med_bmmmsg)
	p_tol_min_selout = get_param_geelyfe3hp(seqno, 9, "Min", p_tol_min_selout)
	p_tol_max_selout = get_param_geelyfe3hp(seqno, 9, "Max", p_tol_max_selout)
	
	------------------- 1. SEL_OUT Check -------------------
	test_start(tcid, seqno, 1)
	
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1) --SEL_OUT voltage measurement realy on
	tas.wait(1000)
	
	SELInPower_Volt(0) -- SEL_IN Power off(set 0 voltage immediately. if not, use analog signal)
	tas.write("ao_SEL_IN", 0) -- DAQ AO_0 set 0 volt
	CtrlBrd(RelaySet.Power.A0_SELIn, 1)
	CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 0)
	tas.wait(200)
	
	read_value = DMM_Set(DMM.ReadVolt) -- SELOUT volt measure
	tas.wait(500)
	
	if read_value >= p_tol_min_erase and read_value <= p_tol_max_erase then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	tas.writestring("can1.@frame:0x6C0", "0210830000000000")
	tas.wait(100)
	tas.writestring("can1.@frame:0x6C0", "043181F014000000")
	tas.wait(500)
	
	CtrlBrd(RelaySet.Power.A0_SELIn, 0)
	CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 1)
	SELInPower_Volt(12)
	tas.wait(1000)
	
	CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 0)
	CtrlBrd(RelaySet.Power.A0_SELIn, 1)
	SELInPower_Volt(0)
	tas.wait(200)
	
	------------------- 3. ID Assign -------------------
	tas.writestring("can1.@frame:0x6C0", "0210830000000000")
	tas.wait(100)
	tas.writestring("can1.@frame:0x6C0", "043181F014000000")
	tas.wait(100)
	tas.writestring("can1.@frame:0x6C0", "053181F019000000")
	tas.wait(100)
	
	--manual_selin_freq(12, 10)
	CtrlBrd(RelaySet.Power.A0_SELIn, 0)
	CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 1)
	SELInPower_Volt(12)
	
	local readmsg = {"0x410", "0x420", "0x430", "0x450", "0x460", "0x480", "0x4E0"}
	
	for chkidx = 1,7,1 do
		test_start(tcid, seqno, chkidx+1)
		
		result = true
		
		local read_value = tas.readstring("can1.@frame:"..readmsg[chkidx])
		if read_value <= "" or read_value == nil then
			result = false
		else
			read_value = 1
		end
		
		test_finish(tcid, seqno, chkidx+1, read_value, result)
	end
	
	------------------- 4. SEL_OUT Check -------------------
	test_start(tcid, seqno, 9)

	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1) --SEL_OUT voltage measurement realy on
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt) -- SELOUT volt measure
	tas.wait(200)
	
	result = false
	if read_value >= p_tol_min_selout and read_value <= p_tol_max_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 9, read_value, result)
end

-------------------------------------------------------------------------
--  5. Version check
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_5_version_check" -- TODO : HW Version can message 이상한값 응답옴
function tc_geelyfe3hp_5_version_check(run, seqno)
	local tcid = 5
	local unit = ""
	
	-- default parameter
	local p_tol_med_swversion = "GEP1B110"
	local p_tol_med_hwversion = "H04"
	
	-- local parameter
	local res_data_str = ""
	local read_value = 0
	local byte_data = {0, 0, 0, 0, 0, 0, 0, 0}
	local result = false
		
	if run == false then
		local tcinfo = {tcid, "DEV Message Check_geelyfe3hp", "tc_geelyfe3hp_5_version_check",
					{1, "SW_Version", unit,
						{"Med", p_tol_med_swversion, "Tolerance Med", ""}					
					},
					{2, "HW_Version", unit,
						{"Med", p_tol_med_hwversion, "Tolerance Med", ""}					
					}
				}
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_med_swversion = get_param_geelyfe3hp(seqno, 1, "Med", p_tol_med_swversion)
	p_tol_med_hwversion = get_param_geelyfe3hp(seqno, 2, "Med", p_tol_med_hwversion)
	
	-- readmessage를 통해 받은 payload의 0~3은 VW Version
	-- 5~7은 SDI Version (%02x %02x %02x)
	
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
	
	result = false
	if read_value.."" == p_tol_med_hwversion.."" then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 2, read_value, result)
end

-------------------------------------------------------------------------
--  6. LV & HV side Leakage and Operating current measure
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_6_lv_and_hv_current_measure"
function tc_geelyfe3hp_6_lv_and_hv_current_measure(run, seqno)
	local tcid = 6
	local unit = "uA"
	local unit_op = "mA"
	
	-- default parameter
	local p_tol_min_lv_leak = -0.1
	local p_tol_max_lv_leak = 20
	local p_tol_min_hv_leak = 60
	local p_tol_max_hv_leak = 100
	local p_tol_min_lv_op = 23
	local p_tol_max_lv_op = 29
	local p_tol_min_hv_op = 13
	local p_tol_max_hv_op = 17
	local result = false
	
	if run == false then
		local tcinfo = {tcid, "Current_ID Asign_geelyfe3hp", "tc_geelyfe3hp_6_lv_and_hv_current_measure",
					{1, "sleep Mode LV side Leakage current measure", unit,
						{"Min", p_tol_min_lv_leak, "Tolerance Min", "uA"},
						{"Max", p_tol_max_lv_leak, "Tolerance Max", "uA"}
					},
					{2, "sleep Mode HV side Leakage current measure", unit,
						{"Min", p_tol_min_hv_leak, "Tolerance Min", "uA"},
						{"Max", p_tol_max_hv_leak, "Tolerance Max", "uA"}
					},
					{3, "Normal Mode LV side Operating current measure", unit_op,
						{"Min", p_tol_min_lv_op, "Tolerance Min", "mA"},
						{"Max", p_tol_max_lv_op, "Tolerance Max", "mA"}
					},
					{4, "Normal Mode HV side Operating current measure", unit_op,
						{"Min", p_tol_min_hv_op, "Tolerance Min", "mA"},
						{"Max", p_tol_max_hv_op, "Tolerance Max", "mA"}
					}
				}
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min_lv_leak = get_param_geelyfe3hp(seqno, 1, "Min", p_tol_min_lv_leak)
	p_tol_max_lv_leak = get_param_geelyfe3hp(seqno, 1, "Max", p_tol_max_lv_leak)
	p_tol_min_hv_leak = get_param_geelyfe3hp(seqno, 2, "Min", p_tol_min_hv_leak)
	p_tol_max_hv_leak = get_param_geelyfe3hp(seqno, 2, "Max", p_tol_max_hv_leak)
	p_tol_min_lv_op = get_param_geelyfe3hp(seqno, 3, "Min", p_tol_min_lv_op)
	p_tol_max_lv_op = get_param_geelyfe3hp(seqno, 3, "Max", p_tol_max_lv_op)
	p_tol_min_hv_op = get_param_geelyfe3hp(seqno, 4, "Min", p_tol_min_hv_op)
	p_tol_max_hv_op = get_param_geelyfe3hp(seqno, 4, "Max", p_tol_max_hv_op)
	
	------------------- 1. sleep Mode LV side Leakage current measure -------------------
	test_start(tcid, seqno, 1)
	
	-- power off
	LVPower_Volt(0)
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 0)
	CtrlBrd(RelaySet.Power.LV_PWR_NEG, 0)
	CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 0)
	tas.wait(1000)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	CtrlBrd(RelaySet.DMMRly.VBATNegCurrMeasOn, 1) -- DMM relay lv current mode on
	tas.wait(500)
	
	local read_value = DMM_Set(DMM.ReadCurr) -- DMM current read
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
	if read_value >= p_tol_min_hv_leak and read_value <= p_tol_max_hv_leak then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1)
	CtrlBrd(RelaySet.Cell.CellPOS_Cell12, 1)
	
	test_finish(tcid, seqno, 2, read_value, result)
--	
	------------------- 3. Normal Mode LV side Operating current measure -------------------
	test_start(tcid, seqno, 3)
	-- power on
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 1)
	CtrlBrd(RelaySet.Power.LV_PWR_NEG, 1)
	CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 1)
	tas.wait(500)
	LVPower_Volt(12)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1) -- DMM relay selout volt measure mode on
	tas.wait(500)
	
	for i = 0,4,1 do
		local read_selout = DMM_Set(DMM.ReadVolt) -- Check if SEL_OUT voltage is high
		if read_selout >= 9.5 and read_selout <= 10.5 then
			break
		else
			CtrlBrd(RelaySet.Power.LV_PWR_POS, 0)
			tas.wait(3000)
			CtrlBrd(RelaySet.Power.LV_PWR_POS, 1)
		end
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	CtrlBrd(RelaySet.DMMRly.VBATNegCurrMeasOn, 1) -- DMM relay lv current mode on
	tas.wait(2000)
	
	local read_value = DMM_Set(DMM.ReadCurr) * 1000 -- check lv side operating current(mA)
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
	if read_value >= p_tol_min_hv_op and read_value <= p_tol_max_hv_op then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1)
	CtrlBrd(RelaySet.Cell.CellPOS_Cell12, 1)
	CellSimulator_CAN(0, 1) -- Cell simulator can communicate on
	
	test_finish(tcid, seqno, 4, read_value, result)
end

-------------------------------------------------------------------------
--  7. Power Supply Test
-------------------------------------------------------------------------
--[[
declare "tc_geelyfe3hp_7_power_supply_test"
function tc_geelyfe3hp_7_power_supply_test(run, seqno)
	local tcid = 7
	local unit = "V"
	local strlst = {"LV(5V),HV(44.4V=3.7*12) @ BMS_SUM(V)", 
				"READ.SELOUT", 
				"LV(5V),HV(21.6V=1.8*12) @ BMS_SUM(V)", 
				"LV(18V),HV(21.6V=1.8*12) @ BMS_SUM(V)",
				"LV(18V),HV(52.8V=4.4*12) @ BMS_SUM(V)",
				"LV(12V),HV(44.4V=3.7*12) @ READ.SELOUT"
				}
	
	-- default parameter
	-- {LV5V, HV21.6V, LV18V, HV52.8V, }
	local p_tol_min = {23.4, -0.1, 20.232, 20.232, 54.072, 9.5}
	local p_tol_max = {55.9, 2.25, 20.238, 20.238, 54.168, 10.5}
	
	-- local variable
	local read_value = 0
	local result = false
	local cellvolt = 0
	
	if run == false then
		local tcinfo = {tcid, "Power Supply Test_geelyfe3hp", "tc_geelyfe3hp_7_power_supply_test"}
		for substepidx = 1, 6, 1 do
			table.insert(tcinfo,
							{substepidx, strlst[substepidx], unit,
								{"Min", p_tol_min[substepidx], "Tolerance Min", "V"},
								{"Max", p_tol_max[substepidx], "Tolerance Max", "V"}		
							}
						)
		end
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1, 6, 1 do
		p_tol_min[idx] = get_param_geelyfe3hp(seqno, idx, "Min", p_tol_min[idx])
		p_tol_max[idx] = get_param_geelyfe3hp(seqno, idx, "Max", p_tol_max[idx])
	end
	
	------------------- 1. LV(5V),HV(44.4V=3.7*12) @ BMS_SUM(V) -------------------
	test_start(tcid, seqno, 1)
	
	-- cell simulator input
	cellvolt = 3700
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(1000)
	
	LVPower_Volt(5)
	tas.wait(500)
	
	for i = 1, 3, 1 do
		for j = 1, 4, 1 do
			--local cell_sendvolt[i][j] = cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j)
			read_value = read_value + cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j)
		end
	end
	
	read_value = read_value/1000 -- convert voltage unit
	
	if read_value >= p_tol_min[1] and read_value <= p_tol_max[1] then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	------------------- 2. READ.SELOUT -------------------
	test_start(tcid, seqno, 2)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1) -- DMM SEL_OUT voltage measurement
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	if read_value >= p_tol_min[2] and read_value <= p_tol_max[2] then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	
	test_finish(tcid, seqno, 2, read_value, result)
	
	------------------- 3. LV(5V),HV(20.28V=1.69*12) @ BMS_SUM(V) -------------------
	test_start(tcid, seqno, 3)
	
	cellvolt = 1800
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(1000)
	
	LVPower_Volt(5)
	tas.wait(500)
	
	for i = 1, 3, 1 do
		for j = 1, 4, 1 do
			--local cell_sendvolt[i][j] = cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j)
			read_value = read_value + cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j)
		end
	end
	
	read_value = read_value/1000 -- convert voltage unit
	
	if read_value >= p_tol_min[3] and read_value <= p_tol_max[3] then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 3, read_value, result)
	
	------------------- 4. LV(18V),HV(20.28V=1.69*12) @ BMS_SUM(V) -------------------
	test_start(tcid, seqno, 4)
	
	cellvolt = 1800
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(1000)
	
	LVPower_Volt(18)
	tas.wait(500)
	
	for i = 1, 3, 1 do
		for j = 1, 4, 1 do
			--local cell_sendvolt[i][j] = cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j)
			read_value = read_value + cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j)
		end
	end
	
	read_value = read_value/1000 -- convert voltage unit
	
	if read_value >= p_tol_min[4] and read_value <= p_tol_max[4] then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 4, read_value, result)
	
	------------------- 5. LV(18V),HV(54.12V=4.51*12) @ BMS_SUM(V) -------------------
	test_start(tcid, seqno, 5)
	
	cellvolt = 4400
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(1000)
	
	LVPower_Volt(18)
	tas.wait(500)
	
	for i = 1, 3, 1 do
		for j = 1, 4, 1 do
			--local cell_sendvolt[i][j] = cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j)
			read_value = read_value + cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j)
		end
	end
	
	read_value = read_value/1000 -- convert voltage unit
	
	if read_value >= p_tol_min[5] and read_value <= p_tol_max[5] then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 5, read_value, result)
	
	------------------- 6. LV(12V),HV(44.4V=3.7*12) @ READ.SELOUT -------------------
	test_start(tcid, seqno, 6)
	
	cellvolt = 3700
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	
	LVPower_Volt(12)
	tas.wait(500)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1) -- DMM SEL_OUT voltage measurement
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	if read_value >= p_tol_min[6] and read_value <= p_tol_max[6] then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	
	test_finish(tcid, seqno, 6, read_value, result)
end
--]]

declare "tc_geelyfe3hp_7_power_supply_test"
function tc_geelyfe3hp_7_power_supply_test(run, seqno)
	local tcid = 7
	local unit = "V"
	local strlst = {"LV(5V),HV(44.4V=3.7*12) @ BMS_SUM(V)", 
				"READ.SELOUT", 
				"LV(5V),HV(20.28V=1.69*12) @ BMS_SUM(V)", 
				"READ.SELOUT", 
				"LV(18V),HV(20.28V=1.69*12) @ BMS_SUM(V)",
				"READ.SELOUT", 
				"LV(18V),HV(54.12V=4.51*12) @ BMS_SUM(V)",
				"READ.SELOUT", 
				"LV(12V),HV(44.4V=3.7*12) @ READ.SELOUT"
				}
	
	-- default parameter
	local p_tol_min = {23.4, 	-0.1, 20.232, -0.1, 20.232, -0.1, 52.7, -0.1, 9.5}
	local p_tol_max = {55.9, 2.25, 20.328, 2.25, 20.328, 2.25, 52.9, 2.25, 10.5}
	
	-- local variable
	local read_value = 0
	local result = false
	local cellvolt = 0
	
	if run == false then
		local tcinfo = {tcid, "Power Supply Test_geelyfe3hp", "tc_geelyfe3hp_7_power_supply_test"}
		for substepidx = 1, 9, 1 do
			table.insert(tcinfo,
							{substepidx, strlst[substepidx], unit,
								{"Min", p_tol_min[substepidx], "Tolerance Min", "V"},
								{"Max", p_tol_max[substepidx], "Tolerance Max", "V"}		
							}
						)
		end
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1, 9, 1 do
		p_tol_min[idx] = get_param_egolf(seqno, idx, "Min", p_tol_min[idx])
		p_tol_max[idx] = get_param_egolf(seqno, idx, "Max", p_tol_max[idx])
	end
	
	------------------- 1. LV(5V),HV(44.4V=3.7*12) @ BMS_SUM(V) -------------------
	test_start(tcid, seqno, 1)
	
	-- cell simulator input
	cellvolt = 3700
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(1000)
	
	LVPower_Volt(3) -- TODO 5V일 때 살아있음.(울산 수입검사기 기준 확인 후 수정 필요)
	tas.wait(500)
	
	read_value = 0
	for i = 1, 3, 1 do
		for j = 1, 4, 1 do
			--local cell_sendvolt[i][j] = cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j)
			read_value = read_value + tonumber(cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j))
		end
	end
	
	read_value = read_value/1000 -- convert voltage unit
	
	if read_value >= p_tol_min[1] and read_value <= p_tol_max[1] then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	------------------- 2. READ.SELOUT -------------------
	test_start(tcid, seqno, 2)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1) -- DMM SEL_OUT voltage measurement
	tas.wait(1000)
	
	read_value = 0
	read_value = DMM_Set(DMM.ReadVolt)
	if read_value >= p_tol_min[2] and read_value <= p_tol_max[2] then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	
	test_finish(tcid, seqno, 2, read_value, result)
	
	------------------- 3. LV(5V),HV(20.28V=1.69*12) @ BMS_SUM(V) -------------------
	test_start(tcid, seqno, 3)
	
	cellvolt = 1690
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(1000)
	
	LVPower_Volt(5)
	tas.wait(500)
	
	read_value = 0
	for i = 1, 3, 1 do
		for j = 1, 4, 1 do
			--local cell_sendvolt[i][j] = cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j)
			read_value = read_value + tonumber(cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j))
		end
	end
	
	read_value = read_value/1000 -- convert voltage unit
	
	if read_value >= p_tol_min[3] and read_value <= p_tol_max[3] then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 3, read_value, result)
	
		------------------- 4. READ.SELOUT -------------------
	test_start(tcid, seqno, 4)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1) -- DMM SEL_OUT voltage measurement
	tas.wait(1000)
	
	read_value = 0
	read_value = DMM_Set(DMM.ReadVolt)
	if read_value >= p_tol_min[4] and read_value <= p_tol_max[4] then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	
	test_finish(tcid, seqno, 4, read_value, result)
	
	------------------- 5. LV(18V),HV(20.28V=1.69*12) @ BMS_SUM(V) -------------------
	test_start(tcid, seqno, 5)
	
	cellvolt = 1690
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(1000)
	
	LVPower_Volt(18)
	tas.wait(500)
	
	read_value = 0
	for i = 1, 3, 1 do
		for j = 1, 4, 1 do
			--local cell_sendvolt[i][j] = cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j)
			read_value = read_value + tonumber(cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j))
		end
	end
	
	read_value = read_value/1000 -- convert voltage unit
	
	if read_value >= p_tol_min[5] and read_value <= p_tol_max[5] then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 5, read_value, result)
	
		------------------- 6. READ.SELOUT -------------------
	test_start(tcid, seqno, 6)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1) -- DMM SEL_OUT voltage measurement
	tas.wait(1000)
	
	read_value = 0
	read_value = DMM_Set(DMM.ReadVolt)
	if read_value >= p_tol_min[6] and read_value <= p_tol_max[6] then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	
	test_finish(tcid, seqno, 6, read_value, result)
	
	------------------- 7. LV(18V),HV(52.8V=4.4*12) @ BMS_SUM(V)
	test_start(tcid, seqno, 7)
	
	cellvolt = 4400
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(1000)
	
	LVPower_Volt(18)
	tas.wait(500)
	
	read_value = 0
	for i = 1, 3, 1 do
		for j = 1, 4, 1 do
			--local cell_sendvolt[i][j] = cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j)
			read_value = read_value + tonumber(cs_can_read("CellSim"..i.."SendVoltage", "CellSim"..i.."SendVoltage"..j))
		end
	end
	
	read_value = read_value/1000 -- convert voltage unit
	
	if read_value >= p_tol_min[7] and read_value <= p_tol_max[7] then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 7, read_value, result)
	
		------------------- 8. READ.SELOUT -------------------
	test_start(tcid, seqno, 8)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1) -- DMM SEL_OUT voltage measurement
	tas.wait(1000)
	
	read_value = 0
	read_value = DMM_Set(DMM.ReadVolt)
	if read_value >= p_tol_min[8] and read_value <= p_tol_max[8] then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	
	test_finish(tcid, seqno, 8, read_value, result)
	
	------------------- 9. LV(12V),HV(44.4V=3.7*12) @ READ.SELOUT -------------------
	test_start(tcid, seqno, 9)
	
	cellvolt = 3700
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	
	LVPower_Volt(12)
	tas.wait(1000)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1) -- DMM SEL_OUT voltage measurement
	tas.wait(1000)
	
	read_value = 0
	read_value = DMM_Set(DMM.ReadVolt)
	if read_value >= p_tol_min[9] and read_value <= p_tol_max[9] then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	
	test_finish(tcid, seqno, 9, read_value, result)
end


-------------------------------------------------------------------------
--  8. Cell 1,3,5,7,9,11 current consumption(No balancing)-1
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_8_oddcell_no_balancing_current_consum"
function tc_geelyfe3hp_8_oddcell_no_balancing_current_consum(run, seqno)
	local tcid = 8
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
		local subseqlst = {}
		local tcinfo = {tcid, "Cell 1,3,5,7,9,11 current consumption(No balancing)-1_geelyfe3hp", "tc_geelyfe3hp_8_oddcell_no_balancing_current_consum"}
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
		
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1, 7, 1 do
		p_tol_min[idx] = get_param_geelyfe3hp(seqno, idx, "Min", p_tol_min[idx])
		p_tol_max[idx] = get_param_geelyfe3hp(seqno, idx, "Max", p_tol_max[idx])
	end
	
	------------------- 1. BMS_SUM(C) -------------------
	test_start(tcid, seqno, 1)
	
	--cmc_cell_balancing(CellBalMode.NoBalancing) -- no balancing
	local noBal = {false, false, false, false, false, false, false, false, false, false, false, false}
	manual_balancing_start_geelyfe3hp(1, noBal)
	tas.wait(1500)
	
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
		read_value = ((ReadCurrMean - 2) - ReadCurrLow)
		
		if read_value >= p_tol_min[idx+1] and read_value <= p_tol_max[idx+1] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, idx+1, read_value, result)
	end
	
end

-------------------------------------------------------------------------
--  9. Cell 1,3,5,7,9,11 balancing status
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_9_oddcell_balancing_status"
function tc_geelyfe3hp_9_oddcell_balancing_status(run, seqno)
	local tcid = 9
	local unit = ""
	local strlst = {"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"}
	
	
	-- default parameter
	local p_tol_med = {1,0,1,0,1,0,1,0,1,0,1,0}
	
	-- local variable
	local read_value = nil
	local result = false
	
	if run == false then
		local subseqlst = {}
		local tcinfo = {tcid, "Cell 1,3,5,7,9,11 balancing status_geelyfe3hp", "tc_geelyfe3hp_9_oddcell_balancing_status"}
		for substepidx = 1, 12, 1 do
			table.insert(tcinfo, 
							{substepidx, "CSC_01_BalState_" .. strlst[substepidx], unit, 
								{"Med", p_tol_med[substepidx], "Tolerance Med", ""}
							}
						)
		end
				
				
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	for idx=1,12,1 do
		p_tol_med[idx] = get_param_geelyfe3hp(seqno, idx, "Med", p_tol_med[idx])
	end
	
	local oddBal = {true, false, true, false, true, false, true, false, true, false, true, false}
	manual_balancing_start_geelyfe3hp(1, oddBal)
	tas.wait(3000)

	
	for idx=1,12,1 do
		test_start(tcid, seqno, idx)		
		read_value = cmc_can_read("CSC_01_08", "CSC_01_BalState_" .. strlst[idx])
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
--  10. Cell 1,3,5,7,9,11 balancing current
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_10_oddcell_balancing_current"
function tc_geelyfe3hp_10_oddcell_balancing_current(run, seqno)
	local tcid = 10
	local unit = "A"
	local unit_cell = "mA"
	
	-- default parameter
	local p_tol_min = {0.21, 35, 35, 35, 35, 35, 35}
	local p_tol_max = {0.39, 65, 65, 65, 65, 65, 65}
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
		local tcinfo = {tcid, "Cell 1,3,5,7,9,11 balancing current_geelyfe3hp", "tc_geelyfe3hp_10_oddcell_balancing_current"}
		table.insert(tcinfo, 
						{1, "BMS_SUM(C)", unit,
							{"Min", p_tol_min[1], "Tolerance Min", "A"},
							{"Max", p_tol_max[1], "Tolerance Max", "A"}
						}
					)
		for substepidx = 2, 7, 1 do
			table.insert(tcinfo,
							{substepidx, strlst[substepidx-1], unit_cell,
								{"Min", p_tol_min[substepidx], "Tolerance Min", "mA"},
								{"Max", p_tol_max[substepidx], "Tolerance Max", "mA"}
							}
						)
		end
		
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1, 7, 1 do
		p_tol_min[idx] = get_param_geelyfe3hp(seqno, idx, "Min", p_tol_min[idx])
		p_tol_max[idx] = get_param_geelyfe3hp(seqno, idx, "Max", p_tol_max[idx])
	end
	
	------------------- 1. BMS_SUM(C) -------------------
	test_start(tcid, seqno, 1)
	
	local ReadCurrMean = 0
	local ReadCurrLow = 0
	
	for i = 1,3,1 do
		for j = 1, 2, 1 do
			ReadCurrMean = ReadCurrMean + tonumber(cs_can_read("CellSim"..i.."SendCurrent", 
										"CellSim"..i.."SendCurrent"..((j - 1) * 2 + 1)))-- bms odd mean sum
			ReadCurrLow = ReadCurrLow + tonumber(cs_can_read("CellSim"..i.."SendCurrentLowMean", 
										"CellSim"..i.."SendCurrentLowMean"..((j - 1) * 2 + 1))) -- bms odd low mean sum
		end 
	end
	
	read_value = (ReadCurrMean - ReadCurrLow)/1000
	
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
		
		if read_value >= p_tol_min[idx+1] and read_value <= p_tol_max[idx+1] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, idx+1, read_value, result)
	end
end

-------------------------------------------------------------------------
--  11. Cell 2,4,6,8,10,12 current consumption(No balancing)
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_11_evencell_no_balancing_current_consum"
function tc_geelyfe3hp_11_evencell_no_balancing_current_consum(run, seqno)
	local tcid = 11
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
		local tcinfo = {tcid, "Cell 2,4,6,8,10,12 current consumption(No balancing)_geelyfe3hp", "tc_geelyfe3hp_11_evencell_no_balancing_current_consum"}
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
		
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1, 7, 1 do
		p_tol_min[idx] = get_param_geelyfe3hp(seqno, idx, "Min", p_tol_min[idx])
		p_tol_max[idx] = get_param_geelyfe3hp(seqno, idx, "Max", p_tol_max[idx])
	end
	
	------------------- 1. BMS_SUM(C) -------------------
	test_start(tcid, seqno, 1)
	
	--cmc_cell_balancing(CellBalMode.NoBalancing) -- no balancing
	local noBal = {false, false, false, false, false, false, false, false, false, false, false, false}
	manual_balancing_start_geelyfe3hp(1, noBal)
	tas.wait(1500)
	
	local ReadCurrMean = 0
	local ReadCurrLow = 0
	
	for i = 1,3,1 do
		for j = 1, 2, 1 do
			ReadCurrMean = ReadCurrMean + tonumber(cs_can_read("CellSim"..i.."SendCurrent", 
										"CellSim"..i.."SendCurrent"..(j * 2))) -- bms even mean sum
			ReadCurrLow = ReadCurrLow + tonumber(cs_can_read("CellSim"..i.."SendCurrentLowMean", 
										"CellSim"..i.."SendCurrentLowMean"..(j * 2))) -- bms even low mean sum
		end 
	end
	
	read_value = (ReadCurrMean - ReadCurrLow)/1000
	
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
		read_value = ((ReadCurrMean-2) - ReadCurrLow)
		
		if read_value >= p_tol_min[idx+1] and read_value <= p_tol_max[idx+1] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, idx+1, read_value, result)
	end
	
end

-------------------------------------------------------------------------
--  12. Cell 2,4,6,8,10,12 balancing status
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_12_evencell_balancing_status"
function tc_geelyfe3hp_12_evencell_balancing_status(run, seqno)
	local tcid = 12
	local unit = ""
	local strlst = {"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"}
	
	-- default parameter
	local p_tol_med = {0,1,0,1,0,1,0,1,0,1,0,1}
	
	-- local variable
	local read_value = nil
	local result = false
	
	if run == false then
		local tcinfo = {tcid, "Cell 2,4,6,8,10,12 balancing status_geelyfe3hp", "tc_geelyfe3hp_12_evencell_balancing_status"}
		for substepidx = 1, 12, 1 do
			table.insert(tcinfo, 
							{substepidx, "CSC_01_BalState_" .. strlst[substepidx], unit, 
								{"Med", p_tol_med[substepidx], "Tolerance Med", ""}
							}
						)
		end
				
				
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	for idx=1,12,1 do
		p_tol_med[idx] = get_param_geelyfe3hp(seqno, idx, "Med", p_tol_med[idx])
	end
	
	-- test_start(tcid, seqno, 1)
	
	-- test case here
	--cmc_cell_balancing(CellBalMode.EvenBalancing) -- odd balancing
	local evenBal = {false, true, false, true, false, true, false, true, false, true, false, true}
	manual_balancing_start_geelyfe3hp(1, evenBal)
	tas.wait(3000)

	
	for idx=1,12,1 do
		test_start(tcid, seqno, idx)		
		read_value = cmc_can_read("CSC_01_08", "CSC_01_BalState_" .. strlst[idx])
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
--  13. Cell 2,4,6,8,10,12 balancing current
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_13_evencell_balancing_current"
function tc_geelyfe3hp_13_evencell_balancing_current(run, seqno)
	local tcid = 13
	local unit = "A"
	local unit_cell = "mA"
	
	-- default parameter
	local p_tol_min = {0.21, 35, 35, 35, 35, 35, 35}
	local p_tol_max = {0.39, 65, 65, 65, 65, 65, 65}
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
		local tcinfo = {tcid, "Cell 2,4,6,8,10,12 balancing current_geelyfe3hp", "tc_geelyfe3hp_13_evencell_balancing_current"}
		table.insert(tcinfo, 
						{1, "BMS_SUM(C)", unit,
							{"Min", p_tol_min[1], "Tolerance Min", "A"},
							{"Max", p_tol_max[1], "Tolerance Max", "A"}
						}
					)
		for substepidx = 2, 7, 1 do
			table.insert(tcinfo,
							{substepidx, strlst[substepidx-1], unit_cell,
								{"Min", p_tol_min[substepidx], "Tolerance Min", "mA"},
								{"Max", p_tol_max[substepidx], "Tolerance Max", "mA"}
							}
						)
		end
		
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1, 7, 1 do
		p_tol_min[idx] = get_param_geelyfe3hp(seqno, idx, "Min", p_tol_min[idx])
		p_tol_max[idx] = get_param_geelyfe3hp(seqno, idx, "Max", p_tol_max[idx])
	end
	
	------------------- 1. BMS_SUM(C) -------------------
	test_start(tcid, seqno, 1)
	
	local ReadCurrMean = 0
	local ReadCurrLow = 0
	
	for i = 1,3,1 do
		for j = 1, 2, 1 do
			ReadCurrMean = ReadCurrMean + tonumber(cs_can_read("CellSim"..i.."SendCurrent", 
										"CellSim"..i.."SendCurrent"..(j * 2))) -- bms even mean sum
			ReadCurrLow = ReadCurrLow + tonumber(cs_can_read("CellSim"..i.."SendCurrentLowMean",
										"CellSim"..i.."SendCurrentLowMean"..(j * 2))) -- bms even low mean sum
		end 
	end
	
	read_value = (ReadCurrMean - ReadCurrLow)/1000
	
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
		
		if read_value >= p_tol_min[idx+1] and read_value <= p_tol_max[idx+1] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, idx+1, read_value, result)
	end
end

-------------------------------------------------------------------------
--  14. Cell 1,3,5,7,9,11 current consumption(No balancing)-2
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_14_oddcell_no_balancing_current_consum_2"
function tc_geelyfe3hp_14_oddcell_no_balancing_current_consum_2(run, seqno)
	local tcid = 14
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
		local tcinfo = {tcid, "Cell 1,3,5,7,9,11 current consumption(No balancing)-2_geelyfe3hp", "tc_geelyfe3hp_14_oddcell_no_balancing_current_consum_2"}
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
		
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1, 7, 1 do
		p_tol_min[idx] = get_param_geelyfe3hp(seqno, idx, "Min", p_tol_min[idx])
		p_tol_max[idx] = get_param_geelyfe3hp(seqno, idx, "Max", p_tol_max[idx])
	end
	
	------------------- 1. BMS_SUM(C) -------------------
	test_start(tcid, seqno, 1)
	
	--cmc_cell_balancing(CellBalMode.NoBalancing) -- no balancing
	local noBal = {false, false, false, false, false, false, false, false, false, false, false, false}
	manual_balancing_start_geelyfe3hp(1, noBal)
	tas.wait(1500)
	
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
		read_value = (ReadCurrMean-2) - ReadCurrLow
		
		if read_value >= p_tol_min[idx+1] and read_value <= p_tol_max[idx+1] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, idx+1, read_value, result)
	end
	
end

-------------------------------------------------------------------------
--  15. Autonomous Mode
-------------------------------------------------------------------------
--[[
declare "tc_geelyfe3hp_15_autonomous_mode_enter"
function tc_geelyfe3hp_15_autonomous_mode_enter(run, seqno)
	local tcid = 15
	local unit = "mA"
	
	-- default parameter
	local p_tol_min = 12
	local p_tol_max = 15
	
	-- local variable
	local read_value = 0
	local result = false
	local cellvolt = 0
	
	if run == false then
		local tcinfo = {tcid, "Enter autonomous mode (LV switch off_HV Current Consumption Measurement)_geelyfe3hp", "tc_geelyfe3hp_15_autonomous_mode_enter",
					{1, "34461A_DC_READ(mA)", unit,
						{"Min", p_tol_min, "Tolerance Min", "mA"},
						{"Max", p_tol_max, "Tolerance Max", "mA"}
					}
				}
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min = get_param_geelyfe3hp(seqno, 1, "Min", p_tol_min)
	p_tol_max = get_param_geelyfe3hp(seqno, 1, "Max", p_tol_max)
	
	test_start(tcid, seqno, 1)
	
	-- test case here
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM Relay reset
	CtrlBrd(RelaySet.DMMRly.HVPosCurrMeasOn, 1) -- DMM Hv Current measure mode on
	tas.wait(500)
	
	cmc_can_write("BMC_Anf_01", "CMC_KeepAwake", 0x01) -- set CMC autonomous mode request
	LVPower_Volt(0) -- LV Power off
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadCurr) -- HV current measure
	
	if read_value >= p_tol_min and read_value <= p_tol_max then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM relay reset
	cellvolt = 1800
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	tas.wait(3000)
	
	LVPower_Volt(12)
	tas.wait(2000)
	
	cellvolt = 3700
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt)
	end
	
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1)
	tas.wait(1000)
	
	test_finish(tcid, seqno, 1, read_value, result)
end

declare "tc_geelyfe3hp_16_component_failure_msg_check"
function tc_geelyfe3hp_16_component_failure_msg_check(run, seqno)
	local tcid = 16
	local unit = ""
	
	-- default parameter
	local p_tol_mid_selout = 9.5
	local p_tol_max_selout = 10.5
	local p_tol_med = {1,1,1,1,1,1,1,4,1}
	local strlst = {"2_01", "2_02", "2_03", "2_04", "2_05", "2_07", "2_13", "4_03", "4_04"}
	
	-- local variable
	local read_value = 0
	local result = false
	
	if run == false then
		local tcinfo = {tcid, "Component failure message check_geelyfe3hp", "tc_geelyfe3hp_16_component_failure_msg_check"}
		for substepidx = 1, 9, 1 do
			table.insert(tcinfo, 
							{substepidx, "CMC_01_KompFehlerModus" .. strlst[substepidx], unit, 
								{"Med", p_tol_med[substepidx], "Tolerance Med", ""}
							}
						)
		end	
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	for idx=1,9,1 do
		p_tol_med[idx] = get_param_geelyfe3hp(seqno, idx, "Med", p_tol_med[idx])
	end
	
	
	for i = 0,4,1 do
		local read_selout = DMM_Set(DMM.ReadVolt) -- Check if SEL_OUT voltage is high
		if read_selout >= p_tol_mid_selout and read_selout <= p_tol_max_selout then
			break
		else
			CtrlBrd(RelaySet.Power.LV_PWR_POS, 0)
			tas.wait(3000)
			CtrlBrd(RelaySet.Power.LV_PWR_POS, 1)
		end
	end
	
	for idx = 1,7,1 do
		test_start(tcid, seqno, idx)
		
		read_value = cmc_can_read("CMC_01_KompFehler_01", "CMC_01_KompFehlerModus"..strlst[idx])
		
		if read_value == p_tol_med[idx] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, idx, read_value, result)
	end
	
	for idx = 8,9,1 do
		test_start(tcid, seqno, idx)
		
		read_value = cmc_can_read("CMC_01_KompFehler_02", "CMC_01_KompFehlerModus"..strlst[idx])
		
		if read_value == p_tol_med[idx] then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, idx, read_value, result)
	end
	
end
--]]
-------------------------------------------------------------------------
--  17. Voltage(Over voltage, Under voltage check)
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_17_ovp_uvp"
function tc_geelyfe3hp_17_ovp_uvp(run, seqno)
	local tcid = 17
	local unit = "V"
	
	-- default parameter
	local p_tol_min_ov_normal = 9.5
	local p_tol_max_ov_normal = 10.5
	local p_tol_min_ov = -0.1
	local p_tol_max_ov = 2
	local p_tol_min_un_normal = 9.5
	local p_tol_max_un_normal = 10.5
	local p_tol_min_un = -0.1
	local p_tol_max_un = 2
	local OV_voltage = 4400
	local UN_voltage = 1800
	
	-- local variable
	local read_value = nil
	local result = false
	local Can_delay = 100
	local Cell_delay = 4800 
	local cellvolt = 0
	
	if run == false then
		local tcinfo = {tcid, "Voltage_geelyfe3hp", "tc_geelyfe3hp_17_ovp_uvp"}
		for substepidx = 1, 12, 1 do
			table.insert(tcinfo, 
							{((substepidx * 2) - 1), "Cell OV Normal Voltage "..substepidx.." @ READ.SELOUT" .. substepidx, unit, 
								{"Min", p_tol_min_ov_normal, "Tolerance Min", "V"},
								{"Max", p_tol_max_ov_normal, "Tolerance Max", "V"}
							}
						)
			table.insert(tcinfo, 
							{(substepidx * 2), "Cell Over Voltage "..substepidx.." @ READ.SELOUT" .. substepidx, unit, 
								{"Min", p_tol_min_ov, "Tolerance Min", "V"},
								{"Max", p_tol_max_ov, "Tolerance Max", "V"}
							}
						)						
		end
		for substepidx = 1, 12, 1 do
			table.insert(tcinfo, 
							{(((substepidx * 2) - 1) + 24), "Cell UN Normal Voltage "..substepidx.." @ READ.SELOUT" .. substepidx, unit, 
								{"Min", p_tol_min_un_normal, "Tolerance Min", "V"},
								{"Max", p_tol_max_un_normal, "Tolerance Max", "V"}
							}
						)
			table.insert(tcinfo, 
							{((substepidx * 2) + 24), "Cell Under Voltage "..substepidx.." @ READ.SELOUT" .. substepidx, unit, 
								{"Min", p_tol_min_un, "Tolerance Min", "V"},
								{"Max", p_tol_max_un, "Tolerance Max", "V"}
							}
						)
		end
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min_ov_normal = get_param_geelyfe3hp(seqno, 1, "Min", p_tol_min_ov_normal)
	p_tol_max_ov_normal = get_param_geelyfe3hp(seqno, 1, "Max", p_tol_max_ov_normal)
	p_tol_min_ov = get_param_geelyfe3hp(seqno, 2, "Min", p_tol_min_ov)
	p_tol_max_ov = get_param_geelyfe3hp(seqno, 2, "Max", p_tol_max_ov)
	p_tol_min_un_normal = get_param_geelyfe3hp(seqno, 25, "Min", p_tol_min_un_normal)
	p_tol_max_un_normal = get_param_geelyfe3hp(seqno, 25, "Max", p_tol_max_un_normal)
	p_tol_min_un = get_param_geelyfe3hp(seqno, 26, "Min", p_tol_min_un)
	p_tol_max_un = get_param_geelyfe3hp(seqno, 26, "Max", p_tol_max_un)

	-- test case here
	CtrlBrd(RelaySet.DMMRly.Reset, 1)
	tas.wait(500)
	
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1) -- DMM SEL_OUT voltage measurement
	tas.wait(500)
--[[	
	-- connect CCP Comm.
	local send_payload = {"01","72","00","00","00","00","00","00"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- SET MTA CCP Comm.
	send_payload = {"02","75","00","00","00","00","00","03"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- SET CCP Comm. and Response(no response check)
	send_payload = {"11","76","00","00","00","00","00","00"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change OV Parameter 1 Ch1
	send_payload = {"02","62","00","00","00","78","FC","4E"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change OV Parameter 2 Ch1
	send_payload = {"03","63","02","00","03","78","FC","4E"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change OV Parameter 1 Ch2
	send_payload = {"02","66","00","00","00","78","FC","50"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change OV Parameter 2 Ch2
	send_payload = {"03","67","02","00","03","78","FC","50"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change OV Parameter 1 Ch3
	send_payload = {"02","6A","00","00","00","78","FC","52"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change OV Parameter 2 Ch3
	send_payload = {"03","6B","02","00","03","78","FC","52"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change OV Parameter 1 Ch4
	send_payload = {"02","6E","00","00","00","78","FC","54"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change OV Parameter 2 Ch4
	send_payload = {"03","6F","02","00","03","78","FC","54"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change OV Parameter 1 Ch5
	send_payload = {"02","72","00","00","00","78","FC","56"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change OV Parameter 2 Ch5
	send_payload = {"03","73","02","00","03","78","FC","56"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change OV Parameter 1 Ch6
	send_payload = {"02","76","00","00","00","78","FC","58"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change OV Parameter 2 Ch6
	send_payload = {"03","77","02","00","03","78","FC","58"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change OV Parameter 1 Ch7
	send_payload = {"02","7A","00","00","00","78","FC","5A"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change OV Parameter 2 Ch7
	send_payload = {"03","7B","02","00","03","78","FC","5A"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change OV Parameter 1 Ch8
	send_payload = {"02","7E","00","00","00","78","FC","5C"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change OV Parameter 2 Ch8
	send_payload = {"03","7F","02","00","03","78","FC","5C"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change OV Parameter 1 Ch9
	send_payload = {"02","82","00","00","00","78","FC","5E"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change OV Parameter 2 Ch9
	send_payload = {"03","83","02","00","03","78","FC","5E"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change OV Parameter 1 Ch10
	send_payload = {"02","86","00","00","00","78","FC","60"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change OV Parameter 2 Ch10
	send_payload = {"03","87","02","00","03","78","FC","60"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change OV Parameter 1 Ch11
	send_payload = {"02","8A","00","00","00","78","FC","62"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change OV Parameter 2 Ch11
	send_payload = {"03","8B","02","00","03","78","FC","62"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change OV Parameter 1 Ch12
	send_payload = {"02","8E","00","00","00","78","FC","64"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change OV Parameter 2 Ch12
	send_payload = {"03","8B","02","00","03","78","FC","64"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change UV Parameter 1 Ch1
	send_payload = {"02","BE","00","00","00","78","FC","66"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change UV Parameter 2 Ch1
	send_payload = {"03","BF","02","00","03","78","FC","66"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change UV Parameter 1 Ch2
	send_payload = {"02","C2","00","00","00","78","FC","68"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change UV Parameter 2 Ch2
	send_payload = {"03","C3","02","00","03","78","FC","68"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change UV Parameter 1 Ch3
	send_payload = {"02","C6","00","00","00","78","FC","6A"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change UV Parameter 2 Ch3
	send_payload = {"03","C7","02","00","03","78","FC","6A"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change UV Parameter 1 Ch4
	send_payload = {"02","CA","00","00","00","78","FC","6C"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change UV Parameter 2 Ch4
	send_payload = {"03","CB","02","00","03","78","FC","6C"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change UV Parameter 1 Ch5
	send_payload = {"02","CE","00","00","00","78","FC","6E"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change UV Parameter 2 Ch5
	send_payload = {"03","CF","02","00","03","78","FC","6E"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change UV Parameter 1 Ch6
	send_payload = {"02","D2","00","00","00","78","FC","70"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change UV Parameter 2 Ch6
	send_payload = {"03","D3","02","00","03","78","FC","70"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change UV Parameter 1 Ch7
	send_payload = {"02","D6","00","00","00","78","FC","72"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change UV Parameter 2 Ch7
	send_payload = {"03","D7","02","00","03","78","FC","72"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change UV Parameter 1 Ch8
	send_payload = {"02","DA","00","00","00","78","FC","74"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change UV Parameter 2 Ch8
	send_payload = {"03","DB","02","00","03","78","FC","74"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change UV Parameter 1 Ch9
	send_payload = {"02","DE","00","00","00","78","FC","76"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change UV Parameter 2 Ch9
	send_payload = {"03","DF","02","00","03","78","FC","76"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change UV Parameter 1 Ch10
	send_payload = {"02","E2","00","00","00","78","FC","78"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change UV Parameter 2 Ch10
	send_payload = {"03","E3","02","00","03","78","FC","78"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change UV Parameter 1 Ch11
	send_payload = {"02","E6","00","00","00","78","FC","7A"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change UV Parameter 2 Ch11
	send_payload = {"03","E7","02","00","03","78","FC","7A"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Change UV Parameter 1 Ch12
	send_payload = {"02","BA","00","00","00","78","FC","7C"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	-- Change UV Parameter 2 Ch12
	send_payload = {"03","BB","02","00","03","78","FC","7C"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
--]]
	-- Check Cell OV Normal and Over Voltage
	for idx = 1, 12, 1 do
		test_start(tcid, seqno, ((idx * 2) - 1))
		
		-- set normal cell voltage
		cellvolt = 3700
		for brd_num = 1, 3, 1 do
			CellSimulator_Volt(brd_num, cellvolt, cellvolt, cellvolt, cellvolt)
		end
		
		tas.wait(Cell_delay)
		
		-- read selout voltage
		read_value = DMM_Set(DMM.ReadVolt)
		if read_value >= p_tol_min_ov_normal and read_value <= p_tol_max_ov_normal then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, ((idx * 2) - 1), read_value, result)
		
		--check over voltage-------------------------------------------------------------
		test_start(tcid, seqno, (idx * 2))
		
		--set over voltage
		can_write_cellsim_volt_set("CellSim"..math.floor((idx+3)/4).."VoltSet", "CellSim"..math.floor((idx+3)/4).."ValueSetVolt"..((idx-1)%4+1), OV_voltage)
		tas.wait(Cell_delay)
		
		-- read selout voltage
		read_value = DMM_Set(DMM.ReadVolt)
		if read_value >= p_tol_min_ov and read_value <= p_tol_max_ov then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, (idx * 2), read_value, result)
	end
	
	-- Check Cell UN Normal and Under Voltage
	for idx = 1, 12, 1 do
		test_start(tcid, seqno, (((idx * 2) - 1) + 24))
		
		-- set normal cell voltage
		cellvolt = 3700
		for brd_num = 1, 3, 1 do
			CellSimulator_Volt(brd_num, cellvolt, cellvolt, cellvolt, cellvolt)
		end
		
		tas.wait(Cell_delay)
		
		-- read selout voltage
		read_value = DMM_Set(DMM.ReadVolt)
		if read_value >= p_tol_min_un_normal and read_value <= p_tol_max_un_normal then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, (((idx * 2) - 1) + 24), read_value, result)
		
		--check under voltage-------------------------------------------------------------
		test_start(tcid, seqno, ((idx * 2) + 24))
		
		-- set under voltage
		can_write_cellsim_volt_set("CellSim"..math.floor((idx+3)/4).."VoltSet", "CellSim"..math.floor((idx+3)/4).."ValueSetVolt"..((idx-1)%4+1), UN_voltage)
		tas.wait(Cell_delay)
		
		-- read selout voltage
		read_value = DMM_Set(DMM.ReadVolt)
		if read_value >= p_tol_min_un and read_value <= p_tol_max_un then
			result = true
		else
			result = false
		end
		
		test_finish(tcid, seqno, ((idx * 2) + 24), read_value, result)
	end
--[[
	-- STOP CCP Comm.
	send_payload = {"08","FF","00","00","00","00","00","00"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
	
	-- Disconnect CCP Comm.(no response)
	send_payload = {"07","00","01","00","00","00","00","00"}
	cmc_can_write_msg(0x18FCD100, send_payload)
	tas.wait(Can_delay)
--]]
	CtrlBrd(RelaySet.DMMRly.Reset, 1)
	
end

-------------------------------------------------------------------------
--  18. Voltage accuracy measure
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_18_voltage_accuracy_3700"
function tc_geelyfe3hp_18_voltage_accuracy_3700(run, seqno)
	local tcid = 18
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
		local tcinfo = {tcid, "Cell Voltage(3.7V)_geelyfe3hp", "tc_geelyfe3hp_18_voltage_accuracy_3700"}
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
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min = get_param_geelyfe3hp(seqno, 1, "Min", p_tol_min)
	p_tol_max = get_param_geelyfe3hp(seqno, 1, "Max", p_tol_max)

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
		local can_data = cmc_can_read("CSC_01_0"..math.floor((idx+3)/4), "CSC_01_Vcell_"..strlst[idx])
		if idx%2 == 1 then
			read_value = tonumber(can_data) - DMM_Set(DMM.ReadVolt)*1000
		else
			read_value = tonumber(can_data) + DMM_Set(DMM.ReadVolt)*1000
		end
		
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

declare "tc_geelyfe3hp_19_voltage_accuracy_3400"
function tc_geelyfe3hp_19_voltage_accuracy_3400(run, seqno)
	local tcid = 19
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
		local tcinfo = {tcid, "Cell Voltage(3.4V)_geelyfe3hp", "tc_geelyfe3hp_19_voltage_accuracy_3400"}
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
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min = get_param_geelyfe3hp(seqno, 1, "Min", p_tol_min)
	p_tol_max = get_param_geelyfe3hp(seqno, 1, "Max", p_tol_max)

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
		local can_data = cmc_can_read("CSC_01_0"..math.floor((idx+3)/4), "CSC_01_Vcell_"..strlst[idx])
		if idx%2 == 1 then
			read_value = tonumber(can_data) - DMM_Set(DMM.ReadVolt)*1000
		else
			read_value = tonumber(can_data) + DMM_Set(DMM.ReadVolt)*1000
		end
		
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

declare "tc_geelyfe3hp_20_voltage_accuracy_4100"
function tc_geelyfe3hp_20_voltage_accuracy_4100(run, seqno)
	local tcid = 20
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
		local tcinfo = {tcid, "Cell Voltage(4.1V)_geelyfe3hp", "tc_geelyfe3hp_20_voltage_accuracy_4100"}
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
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min = get_param_geelyfe3hp(seqno, 1, "Min", p_tol_min)
	p_tol_max = get_param_geelyfe3hp(seqno, 1, "Max", p_tol_max)

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
		local can_data = cmc_can_read("CSC_01_0"..math.floor((idx+3)/4), "CSC_01_Vcell_"..strlst[idx])
		
		if idx%2 == 1 then
			read_value = tonumber(can_data) - DMM_Set(DMM.ReadVolt)*1000
		else
			read_value = tonumber(can_data) + DMM_Set(DMM.ReadVolt)*1000
		end
		
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
--  21. CVN value reading
-------------------------------------------------------------------------
--[[
declare "tc_geelyfe3hp_21_cvn_value_reading"
function tc_geelyfe3hp_21_cvn_value_reading(run, seqno)
	local tcid = 21
	local unit = ""
	local strlst = {"MUX M", "CVN_1 m0", "CVN_1 m1", "CVN_1 m2", "CVN_1 m3"}
	
	-- default parameter
	local mux0 = 168
	local mux1 = 71
	local mux2 = 19
	local mux3 = 45
	local p_tol_med = {0, mux0, mux0, mux0, mux0, 1, mux1, mux1, mux1, mux1, 2, mux2, mux2, mux2, mux2, 3, mux3, mux3, mux3, mux3}
		
	-- local variable
	local read_value = 0
	local result = false

	if run == false then
		local tcinfo = {tcid, "CVN value reading_geelyfe3hp", "tc_geelyfe3hp_21_cvn_value_reading"}
		for substepidx = 1, 20, 1 do
			table.insert(tcinfo, 
							{substepidx, "CVN value reading (MUX "..((math.floor((substepidx+4)/5))-1)..") @ CMC_01_"..strlst[(substepidx-1)%5+1], unit, 
								{"Med", p_tol_med[substepidx], "Tolerance Min", ""},
							}
						)
		end	
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	for idx = 1, 20, 1 do
		p_tol_med[idx] = get_param_geelyfe3hp(seqno, idx, "Med", p_tol_med[idx])
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
--  22. Alarm Line Check
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_22_alarm_line_check" -- TODO : SEL_OUT 정상, CAN Message FAIL(value : 0)출력
function tc_geelyfe3hp_22_alarm_line_check(run, seqno)
	local tcid = 22
	local unit = "V"
	
	-- default parameter
	local p_tol_min_normal_selout = 9.5
	local p_tol_max_normal_selout = 10.5
	local p_tol_min_open_selout = 10.5
	local p_tol_max_open_selout = 12
	local p_tol_min_short_selout = 11.5
	local p_tol_max_short_selout = 12.5
	local p_tol_min_off_selout = -0.1
	local p_tol_max_off_selout = 2.25
	local p_tol_med_selout_remove_status = 1
	local p_tol_med_selout_status = 3
		
	-- local variable
	local read_value = 0
	local result = false

	if run == false then
		local tcinfo = {tcid, "Alram Line Check_geelyfe3hp", "tc_geelyfe3hp_22_alarm_line_check",	
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
					{5, "Short BAT 1_READ.SELOUT", unit,
						{"Min", p_tol_min_short_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_short_selout, "Tolerance Max", "V"}
					},
					{6, "Short BAT Reverted 1_READ.SELOUT", unit,
						{"Min", p_tol_min_off_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_off_selout, "Tolerance Max", "V"}
					},
					{7, "SEL_IN Voltage (2.0V) 2_READ.SELOUT", unit,
						{"Min", p_tol_min_off_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_off_selout, "Tolerance Max", "V"}
					},
					{8, "SEL_IN Voltage (3.0V) 2_READ.SELOUT", unit,
						{"Min", p_tol_min_off_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_off_selout, "Tolerance Max", "V"}
					},
					{9, "SEL_IN Voltage (4.0V) 2_READ.SELOUT", unit,
						{"Min", p_tol_min_normal_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_normal_selout, "Tolerance Max", "V"}
					},
					-------------------------------------------------------------
					{10, "Short BAT 2_READ.SELOUT", unit,
						{"Min", p_tol_max_short_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_short_selout, "Tolerance Max", "V"}
					},
					{11, "Short BAT 2_CMC_01_KompFehlerModus2_11", "",
						{"Med", p_tol_med_selout_status, "Tolerance Med", ""},
					},
					-------------------------------------------------------------
					{12, "Short BAT Reverted 2_READ.SELOUT", unit,
						{"Min", p_tol_min_normal_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_normal_selout, "Tolerance Max", "V"}
					},
					{13, "Short BAT Reverted 2_CMC_01_KompFehlerModus2_11", unit,
						{"Med", p_tol_med_selout_remove_status, "Tolerance Med", ""},
					},
					-------------------------------------------------------------
					{14, "Short GND_READ.SELOUT", unit,
						{"Min", p_tol_min_off_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_off_selout, "Tolerance Max", "V"}
					},
					{15, "Short GND_CMC_01_KompFehlerModus2_11", unit,
						{"Med", p_tol_med_selout_status, "Tolerance Med", ""},
					},
					-------------------------------------------------------------
					{16, "Short GND Reverted_READ.SELOUT", unit,
						{"Min", p_tol_min_normal_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_normal_selout, "Tolerance Max", "V"}
					},
					{17, "Short GND Reverted_CMC_01_KompFehlerModus2_11", unit,
						{"Med", p_tol_med_selout_remove_status, "Tolerance Med", ""},
					},
					-------------------------------------------------------------
					{18, "SEL OUT OPEN_READ.SELOUT", unit,
						{"Min", p_tol_min_open_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_open_selout, "Tolerance Max", "V"}
					},
					{19, "SEL OUT OPEN_CMC_01_KompFehlerModus2_11", unit,
						{"Med", p_tol_med_selout_status, "Tolerance Med", ""},
					},
					-------------------------------------------------------------
					{20, "SEL OUT OPEN Reverted_READ.SELOUT", unit,
						{"Min", p_tol_min_normal_selout, "Tolerance Min", "V"},
						{"Max", p_tol_max_normal_selout, "Tolerance Max", "V"}
					},
					{21, "SEL OUT OPEN Reverted_CMC_01_KompFehlerModus2_11", unit,
						{"Med", p_tol_med_selout_remove_status, "Tolerance Med", ""},
					},
				}
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min_normal_selout = get_param_geelyfe3hp(seqno, 1, "Min", p_tol_min_normal_selout)
	p_tol_max_normal_selout = get_param_geelyfe3hp(seqno, 1, "Max", p_tol_max_normal_selout)
	p_tol_min_open_selout = get_param_geelyfe3hp(seqno, 17, "Min", p_tol_min_open_selout)
	p_tol_max_open_selout = get_param_geelyfe3hp(seqno, 17, "Max", p_tol_max_open_selout)
	p_tol_min_short_selout = get_param_geelyfe3hp(seqno, 5, "Min", p_tol_min_short_selout)
	p_tol_max_short_selout = get_param_geelyfe3hp(seqno, 5, "Max", p_tol_max_short_selout)
	p_tol_min_off_selout = get_param_geelyfe3hp(seqno, 4, "Min", p_tol_min_off_selout)
	p_tol_max_off_selout = get_param_geelyfe3hp(seqno, 4, "Max", p_tol_max_off_selout)
	p_tol_med_selout_remove_status = get_param_geelyfe3hp(seqno, 12, "Med", p_tol_med_selout_remove_status)
	p_tol_med_selout_status = get_param_geelyfe3hp(seqno, 11, "Med", p_tol_med_selout_status)

	
	--SEL_IN Voltage (4.5V) 1-----------------------------------------------------------
	test_start(tcid, seqno, 1)
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1)
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1)
	tas.wait(500)
	
	SELInPower_Volt(4.5)
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min_normal_selout and read_value <= p_tol_max_normal_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 1, read_value, result)
	
	
	--SEL_IN Voltage (4.0V) 1-----------------------------------------------------------
	test_start(tcid, seqno, 2)
	
	SELInPower_Volt(4)
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min_normal_selout and read_value <= p_tol_max_normal_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 2, read_value, result)
	
	
	--SEL_IN Voltage (3.0V) 1-----------------------------------------------------------
	test_start(tcid, seqno, 3)
	SELInPower_Volt(3)
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min_normal_selout and read_value <= p_tol_max_normal_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 3, read_value, result)
	
	
	--SEL_IN Voltage (2.0V) 1-----------------------------------------------------------
	test_start(tcid, seqno, 4)
	SELInPower_Volt(2)
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min_off_selout and read_value <= p_tol_max_off_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 4, read_value, result)
	
	
	--Short BAT 1-----------------------------------------------------------
	test_start(tcid, seqno, 5)
	
	CtrlBrd(RelaySet.Power.SELOut_Short_LVPwr, 1) -- SEL_OUT Short to battery
	CtrlBrd(RelaySet.Power.SELOut_3kohm, 1)
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min_short_selout and read_value <= p_tol_max_short_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 5, read_value, result)
	
	
	--Short BAT Reverted 1-----------------------------------------------------------
	test_start(tcid, seqno, 6)
	
	CtrlBrd(RelaySet.Power.SELOut_Short_LVPwr, 0) -- SEL_OUT Short to battery relay off
	CtrlBrd(RelaySet.Power.SELOut_3kohm, 1)
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min_off_selout and read_value <= p_tol_max_off_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 6, read_value, result)
	
	
	--SEL_IN Voltage (2.0V) 2-----------------------------------------------------------
	test_start(tcid, seqno, 7)
	
	SELInPower_Volt(2)
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min_off_selout and read_value <= p_tol_max_off_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 7, read_value, result)
	
	
	--SEL_IN Voltage (3.0V) 2-----------------------------------------------------------
	test_start(tcid, seqno, 8)
	
	SELInPower_Volt(3)
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min_off_selout and read_value <= p_tol_max_off_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 8, read_value, result)
	
	
	--SEL_IN Voltage (4.0V) 2-----------------------------------------------------------
	test_start(tcid, seqno, 9)
	
	SELInPower_Volt(4)
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min_normal_selout and read_value <= p_tol_max_normal_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 9, read_value, result)
	
	
	--Short BAT 2-----------------------------------------------------------
	test_start(tcid, seqno, 10)
	
	CtrlBrd(RelaySet.Power.SELOut_Short_LVPwr, 1) -- SEL_OUT Short to battery
	CtrlBrd(RelaySet.Power.SELOut_3kohm, 1)
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min_short_selout and read_value <= p_tol_max_short_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 10, read_value, result)

	test_start(tcid, seqno, 11)
	
	read_value = cmc_can_read("CSC_01_CompError_01", "CSC_01_CompErrorMode2_06")
	tas.wait(1000)
	
	if read_value == p_tol_med_selout_status then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 11, read_value, result)
	
	
	--Short BAT Reverted 2-----------------------------------------------------------
	test_start(tcid, seqno, 12)
	
	CtrlBrd(RelaySet.Power.SELOut_Short_LVPwr, 0) -- SEL_OUT Short to battery relay off
	CtrlBrd(RelaySet.Power.SELOut_3kohm, 1)
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min_normal_selout and read_value <= p_tol_max_normal_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 12, read_value, result)
	
	test_start(tcid, seqno, 13)
	
	read_value = cmc_can_read("CSC_01_CompError_01", "CSC_01_CompErrorMode2_06")
	tas.wait(1000)
	
	if read_value == p_tol_med_selout_remove_status then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 13, read_value, result)

	--Short GND-----------------------------------------------------------
	test_start(tcid, seqno, 14)

	CtrlBrd(RelaySet.Power.SELOut_10kohm, 1) -- SEL_OUT Short to ground relay on
	tas.wait(2000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min_off_selout and read_value <= p_tol_max_off_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 14, read_value, result)
	
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
	test_start(tcid, seqno, 16)
		
	CtrlBrd(RelaySet.Power.SELOut_10kohm, 0) -- SEL_OUT Short to ground relay on
	CtrlBrd(RelaySet.Power.SELOut_3kohm, 1)
	tas.wait(400)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min_normal_selout and read_value <= p_tol_max_normal_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 16, read_value, result)
	
	test_start(tcid, seqno, 17)
	
	read_value = cmc_can_read("CSC_01_CompError_01", "CSC_01_CompErrorMode2_06")
	tas.wait(400)
	
	if read_value == p_tol_med_selout_remove_status then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 17, read_value, result)
	
	
	--SEL OUT OPEN-----------------------------------------------------------
	test_start(tcid, seqno, 18)
	
	CtrlBrd(RelaySet.Power.SELOut_3kohm, 0) -- SEL_OUT open relay on
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min_open_selout and read_value <= p_tol_max_open_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 18, read_value, result)
	
	test_start(tcid, seqno, 19)
	
	read_value = cmc_can_read("CSC_01_CompError_01", "CSC_01_CompErrorMode2_06")
	tas.wait(1000)
	
	if read_value == p_tol_med_selout_status then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 19, read_value, result)
	
	
	--SEL OUT OPEN Reverted-----------------------------------------------------------
	test_start(tcid, seqno, 20)
	
	CtrlBrd(RelaySet.Power.SELOut_3kohm, 1) -- SEL_OUT open relay on
	tas.wait(1000)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min_normal_selout and read_value <= p_tol_max_normal_selout then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 20, read_value, result)
	
	test_start(tcid, seqno, 21)
	
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
	
	test_finish(tcid, seqno, 21, read_value, result)
end

-------------------------------------------------------------------------
--  23. Temperature Measurement
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_23_temp_measurement"
function tc_geelyfe3hp_23_temp_measurement(run, seqno)
	local tcid = 23
	local unit = "℃"
	
	-- default parameter
	local p_tol_min_0dgree = -2
	local p_tol_max_0dgree = 2
	local p_tol_min_25dgree = 23
	local p_tol_max_25dgree = 27
	local p_tol_min_50dgree = 48
	local p_tol_max_50dgree = 52
	
	-- local variable
	local result = false
	local read_value = 0

	local module_num = 0
	if run == false then
		local tcinfo = {tcid, "Cell temperature_geelyfe3hp", "tc_geelyfe3hp_23_temp_measurement"}
		for substepidx = 1, 3, 3 do
			module_num = module_num + 1
			table.insert(tcinfo,  
							{substepidx, "Cell temperature : module "..module_num.." (25℃)", unit, 
								{"Min", p_tol_min_25dgree, "Tolerance Min", unit},
								{"Max", p_tol_min_25dgree, "Tolerance Max", unit}
							}
						)
			table.insert(tcinfo,  
							{substepidx+1, "Cell temperature : module "..module_num.." (0℃)", unit, 
								{"Min", p_tol_min_0dgree, "Tolerance Min", unit},
								{"Max", p_tol_max_0dgree, "Tolerance Max", unit}
							}
							)
			table.insert(tcinfo,  
							{substepidx+2, "Cell temperature : module "..module_num.." (50℃)", unit, 
								{"Min", p_tol_min_50dgree, "Tolerance Min", unit},
								{"Max", p_tol_max_50dgree, "Tolerance Max", unit}
							}
							)
		end	
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min_25dgree = get_param_geelyfe3hp(seqno, 1, "Min", p_tol_min_25dgree)
	p_tol_max_25dgree = get_param_geelyfe3hp(seqno, 1, "Max", p_tol_max_25dgree)
	p_tol_min_0dgree = get_param_geelyfe3hp(seqno, 2, "Min", p_tol_min_0dgree)
	p_tol_max_0dgree = get_param_geelyfe3hp(seqno, 2, "Max", p_tol_max_0dgree)
	p_tol_min_50dgree = get_param_geelyfe3hp(seqno, 3, "Min", p_tol_min_50dgree)
	p_tol_max_50dgree = get_param_geelyfe3hp(seqno, 3, "Max", p_tol_max_50dgree)
	
	local ch_val = 6 -- variable of resistor board id number
	
	-- 25 dgree ------------------------------------------------------------------------------
	test_start(tcid, seqno, 1)
	
	ProgrammableResistor(ch_val, TemperatValue.dgree25, 0) -- programmable resistor board setting
	tas.wait(2000)
	
	read_value = cmc_can_read("CSC_01_05", "CSC_01_Temp_1") -- read can temperature value
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
	
	read_value = cmc_can_read("CSC_01_05", "CSC_01_Temp_1") -- read can temperature value
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
	
	read_value = cmc_can_read("CSC_01_05", "CSC_01_Temp_1") -- read can temperature value
	if read_value >= p_tol_min_50dgree and read_value <= p_tol_max_50dgree then
		result = true
	else
		result = false
	end
	
	test_finish(tcid, seqno, 3, read_value, result)
end

-------------------------------------------------------------------------
--  24. Openwire Detection
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_24_cell_openwire_detection" --TODO :  1~11 Open wire detected 안됨, 메뉴얼 테스트시에도 안됨
function tc_geelyfe3hp_24_cell_openwire_detection(run, seqno)
	local tcid = 24
	local unit = ""

	-- default parameter
	local p_tol_med_normal = 1
	local p_tol_med_fault = 3
	
	local tol_min_selout = 9.5
	local tol_max_selout = 10.5
	
	-- local variable
	local on_delay = 3000
	local off_delay = 3000
	local cellvolt = 3700
	local selout_value = 0
	local result = false
	local read_value = ""
	
	if run == false then
		local tcinfo = {tcid, "Cell voltage wire open_geelyfe3hp", "tc_geelyfe3hp_24_cell_openwire_detection"}
		table.insert(tcinfo, 
						{1, "Cell normal voltage input @ CMC_01_KompFehlerModus2_04", unit, 
							{"Med", p_tol_med_normal, "Tolerance Med", ""},
						}
					)
		for substepidx = 1, 12, 1 do
			table.insert(tcinfo, 
							{substepidx+1, "Cell voltage wire open(cell #"..(13-substepidx)..") @ CMC_01_KompFehlerModus2_04", unit, 
								{"Med", p_tol_med_fault, "Tolerance Med", ""},
							}
						)
		end	
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_med_normal = get_param_geelyfe3hp(seqno, 1, "Med", p_tol_med_normal)
	p_tol_med_fault = get_param_geelyfe3hp(seqno, 2, "Med", p_tol_med_fault)
	
	--normal state check------------------------------------------------------------------------
	test_start(tcid, seqno, 1)
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- Reset all dmm relay
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1) -- SEL_OUT Volt measure relay on
	
	cellvolt = 3700
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, cellvolt, cellvolt, cellvolt, cellvolt) -- cell simulator set
	end
	tas.wait(on_delay)
	
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 0)
	tas.wait(off_delay)
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 1)
	tas.wait(3000)
	
	read_value = cmc_can_read("CSC_01_CompError_01", "CSC_01_CompErrorMode2_04")
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
	tas.wait(on_delay) --TODO 새로운 버전 시료 테스트 후 변경 -> on_delay로 변경
		
	read_value = cmc_can_read("CSC_01_CompError_01", "CSC_01_CompErrorMode2_04")
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
		tas.wait(on_delay)
		
		read_value = cmc_can_read("CSC_01_CompError_01", "CSC_01_CompErrorMode2_04")
		if read_value == p_tol_med_fault then
			result = true
		else
			result = false
		end
		
		CtrlBrd(RelaySet.Cell.Cell12_CellSen12-(substepidx-1), 1) -- each cell normal
		tas.wait(1000)
		
		test_finish(tcid, seqno, substepidx+1, read_value, result)
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- Reset all dmm relay
		
end

-------------------------------------------------------------------------
--  25. All Power & Relay Off
-------------------------------------------------------------------------
declare "tc_geelyfe3hp_25_all_power_reset"
function tc_geelyfe3hp_25_all_power_reset(run, seqno)
	local tcid = 25
	local unit = ""
	
	local result = true

	if run == false then
		local tcinfo = {tcid, "Power All Off & End Test_geelyfe3hp", "tc_geelyfe3hp_25_all_power_reset",
					{1, "Power All Off & End Test", unit}
				}
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
		
	test_start(tcid, seqno, 1)
	
	-- power off
	CtrlBrd(RelaySet.Power.LV_PWR_POS, 0)
	CtrlBrd(RelaySet.Power.LV_PWR_NEG, 0)
	LVPower_Volt(0)
	LVPower_Onoff(0)
	tas.wait(500)
	
	CtrlBrd(RelaySet.Power.SELPwrPos_SELIn, 0)
	SELInPower_Volt(0)
	SELInPower_Onoff(0)
	tas.wait(500)	
	
	-- cell simulator init
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, 0, 0, 0, 0)
	end
	
	CtrlBrd(RelaySet.Power.All_Off, 1) -- Control Board Reset
	tas.wait(500)
	
	CtrlBrd(RelaySet.Model.geelyfe3hp, 0)

	result = true

	cmc_can_finish_geelyfe3hp()
	
	test_finish(tcid, seqno, 1, "", result)
	
end

declare "geelyfe3hp_voltage_accuracy_test"
function geelyfe3hp_voltage_accuracy_test(run, seqno)
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
		local tcinfo = {tcid, "Accuracy test", "geelyfe3hp_voltage_accuracy_test"}
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
							{15, "SEL_OUT Accuracy", "V",
								{"Min", 9.5, "Tolerance Min", "V"},
								{"Max", 10.5, "Tolerance Max", "V"}
							}
					)
		table.insert(tcinfo_table_geelyfe3hp, tcinfo)
		return
	end
	
	-- parameter loading
	p_tol_min = get_param_geelyfe3hp(seqno, 1, "Min", p_tol_min)
	p_tol_max = get_param_geelyfe3hp(seqno, 1, "Max", p_tol_max)

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
	p_tol_min = 12 - (12*0.01)
	p_tol_max = 12 + (12*0.01)

	test_start(tcid, seqno , 14)
	
	CtrlBrd(RelaySet.DMMRly.SELInVoltMeas, 1)
	tas.wait(500)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min and read_value <= p_tol_max then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM Init
	tas.wait(200)
	
	test_finish(tcid, seqno, 14, read_value, result)	
	
	--SEL_OUT Accuracy-----------------------------------------------------------------
	p_tol_min = 9.5
	p_tol_max = 10.5
	
	test_start(tcid, seqno , 15)
	
	CtrlBrd(RelaySet.DMMRly.SELOutVoltMeas, 1)
	tas.wait(500)
	
	read_value = DMM_Set(DMM.ReadVolt)
	
	if read_value >= p_tol_min and read_value <= p_tol_max then
		result = true
	else
		result = false
	end
	
	CtrlBrd(RelaySet.DMMRly.Reset, 1) -- DMM Init
	tas.wait(200)
	
	test_finish(tcid, seqno, 15, read_value, result)	
	
end


declare "get_tc_list_geelyfe3hp"
function get_tc_list_geelyfe3hp()
	tcinfo_table_geelyfe3hp = {}
	param_table_geelyfe3hp = {}
	tc_geelyfe3hp_1_init(false, 0)
	tc_geelyfe3hp_2_lv_side_power_trunon_reset_time(false, 0)
	tc_geelyfe3hp_3_operating_current_measure(false, 0)
	tc_geelyfe3hp_4_id_assign(false, 0)
	tc_geelyfe3hp_5_version_check(false, 0)
	tc_geelyfe3hp_6_lv_and_hv_current_measure(false, 0)
	tc_geelyfe3hp_7_power_supply_test(false, 0)
	tc_geelyfe3hp_8_oddcell_no_balancing_current_consum(false, 0)
	tc_geelyfe3hp_9_oddcell_balancing_status(false, 0)
	tc_geelyfe3hp_10_oddcell_balancing_current(false, 0)
	tc_geelyfe3hp_11_evencell_no_balancing_current_consum(false, 0)
	tc_geelyfe3hp_12_evencell_balancing_status(false, 0)
	tc_geelyfe3hp_13_evencell_balancing_current(false, 0)
	tc_geelyfe3hp_14_oddcell_no_balancing_current_consum_2(false, 0)
	--tc_geelyfe3hp_15_autonomous_mode_enter(false, 0)
	--tc_geelyfe3hp_16_component_failure_msg_check(false, 0)
	tc_geelyfe3hp_17_ovp_uvp(false, 0)
	tc_geelyfe3hp_18_voltage_accuracy_3700(false, 0)
	tc_geelyfe3hp_19_voltage_accuracy_3400(false, 0)
	tc_geelyfe3hp_20_voltage_accuracy_4100(false, 0)
	--tc_geelyfe3hp_21_cvn_value_reading(false, 0)
	tc_geelyfe3hp_22_alarm_line_check(false, 0)
	tc_geelyfe3hp_23_temp_measurement(false, 0)
	tc_geelyfe3hp_24_cell_openwire_detection(false, 0)
	tc_geelyfe3hp_25_all_power_reset(false, 0)
	geelyfe3hp_voltage_accuracy_test(false, 0)
end
get_tc_list_geelyfe3hp()

declare "geelyfe3hp_sequence_run"
function geelyfe3hp_sequence_run()
	tc_geelyfe3hp_1_init(true, 0)
	tc_geelyfe3hp_2_lv_side_power_trunon_reset_time(true, 1)
	tc_geelyfe3hp_3_operating_current_measure(true, 2)
	tc_geelyfe3hp_4_id_assign(true, 3)
	tc_geelyfe3hp_5_version_check(true, 4)
	tc_geelyfe3hp_6_lv_and_hv_current_measure(true, 5)
	tc_geelyfe3hp_7_power_supply_test(true, 6)
	tc_geelyfe3hp_8_oddcell_no_balancing_current_consum(true, 7)
	tc_geelyfe3hp_9_oddcell_balancing_status(true, 8)
	tc_geelyfe3hp_10_oddcell_balancing_current(true, 9)
	tc_geelyfe3hp_11_evencell_no_balancing_current_consum(true, 10)
	tc_geelyfe3hp_12_evencell_balancing_status(true, 11)
	tc_geelyfe3hp_13_evencell_balancing_current(true, 12)
	tc_geelyfe3hp_14_oddcell_no_balancing_current_consum_2(true, 13)
	--tc_geelyfe3hp_15_autonomous_mode_enter(true, 14)
	--tc_geelyfe3hp_16_component_failure_msg_check(true, 15)
	tc_geelyfe3hp_17_ovp_uvp(true, 16)
	tc_geelyfe3hp_18_voltage_accuracy_3700(true, 17)
	tc_geelyfe3hp_19_voltage_accuracy_3400(true, 18)
	tc_geelyfe3hp_20_voltage_accuracy_4100(true, 19)
	tc_geelyfe3hp_21_cvn_value_reading(true, 20)
	tc_geelyfe3hp_22_alarm_line_check(true, 21)
	tc_geelyfe3hp_23_temp_measurement(false, 22)
	tc_geelyfe3hp_24_cell_openwire_detection(false, 23)
	tc_geelyfe3hp_25_all_power_reset(false, 24)

end















