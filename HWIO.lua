-- Incomming Test Bench TAS
-- Revision 2016.12.26

------------------------------------------------------------------------
-- Parameters
------------------------------------------------------------------------
-- Manual mode parameter
declare "jig_delay"
jig_delay = 1000
declare "gv_interlock_state"
gv_interlock_state = false
declare "gv_jig_mount_state"
gv_jig_mount_state = false
declare "gv_jig_miss_mount"
gv_jig_miss_mount = {0,0,0,0,0,0,0,0,0}
declare "using_debug_hwio"
using_debug_hwio = 0

-- DMM object name parameter
declare "dmm_name"
dmm_name = "DMM"

-- control board object parameter
declare "cmcbrd_name"
cmcbrd_name = "CMCBRD"

-- LV Power mode parameter
declare "LVPower"
LVPower = {}
LVPower = {Off = 0, On = 1}

-- SEL_IN Power mode parameter
declare "SELInPower"
SELInPower = {}
SELInPower = {Off = 0, On = 1}

-- Cell Balancing mode parameter
declare "CellBalMode"
CellBalMode = {}
CellBalMode = {NoBalancing = 0, OddBalancing = 1, EvenBalancing = 2}

-- DMM read mode parameter
declare "DMM"
DMM = {}
DMM = {ReadVolt = 0, ReadCurr = 1}

-- CMC Control Board mode parameter
declare "RelaySet"
RelaySet = {}
RelaySet["Power"] = {All_Off = 0,
					LV_PWR_POS = 1,
					LV_PWR_NEG = 2,
					SELPwrPos_SELIn = 3,
					A0_SELIn = 4,
					SELOut_3kohm = 5,
					SELOut_10kohm = 6,
					SELOut_Short_LVPwr = 7,
					SELOut_10kohm_LVPwr = 8,
					CAH_connect = 9
					}
RelaySet["Cell"] = {Cell_CellSenGND = 10,
					Cell1_CellSen1 = 11,
					Cell2_CellSen2 = 12,
					Cell3_CellSen3 = 13,
					Cell4_CellSen4 = 14,
					Cell5_CellSen5 = 15,
					Cell6_CellSen6 = 16,
					Cell7_CellSen7 = 17,
					Cell8_CellSen8 = 18,
					Cell9_CellSen9 = 19,
					Cell10_CellSen10 = 20,
					Cell11_CellSen11 = 21,
					Cell12_CellSen12 = 22,
					CellPOS_Cell8 = 23,
					CellPOS_Cell12 = 24,
					CellPOS_Cell13 = 25,
					HVPwr_cell = 26
					}
RelaySet["Model"] = {M12S1P = 27,
					M6S2P = 28,
					VW4S3P = 29,
					SAIC4S3P = 30
					}
RelaySet["DMMRly"] = {Reset = 31,
					VBATNegCurrMeasOn = 32,
					VBATNegCurrMeasOff = 33,
					HVPosCurrMeasOn = 34,
					VBATVoltMeas = 35,
					SELInVoltMeas = 36,
					SELOutVoltMeas = 37,
					Cell1VoltMeas = 38,
					Cell2VoltMeas = 39,
					Cell3VoltMeas = 40,
					Cell4VoltMeas = 41,
					Cell5VoltMeas = 42,
					Cell6VoltMeas = 43,
					Cell7VoltMeas = 44,
					Cell8VoltMeas = 45,
					Cell9VoltMeas = 46,
					Cell10VoltMeas = 47,
					Cell11VoltMeas = 48,
					Cell12VoltMeas = 49,
					Cell13VoltMeas = 50
					}

declare "TemperatValue"
TemperatValue = {}
TemperatValue = {dgree0 = 30000, dgree25 = 10740, dgree50 = 4410}

-- DBC Parameters

declare "dbc"
dbc = {msg_id_assign = "",
		sig_id_assign = {},
		msg_dev_tx = "",
		msg_dev_rx = 0,
		msg_version_tx = "",
		msg_version_rx = 0,
		msg_balancing = "",
		sig_balancing = "",
		msg_autonomous = "",
		sig_autonomous = "",
		msg_fault = "",
		sig_fault = "",
		msg_voltage = "",
		sig_voltage = "",
		msg_cvn = "",
		sig_cvn = {},
		msg_alram = "",
		sig_alram = "",
		msg_temp = "",
		sig_temp = "",
		msg_openwire = "",
		sig_openwire = ""
						
}

declare "dbc_load"
function dbc_load(model)	
	if model == 0 then --egolf
		dbc.msg_id_assign = "BMC_CMC_ID_Vergabe_01"
		dbc.sig_id_assign[1] = "DMREQ_Befehl"
		dbc.sig_id_assign[2] = "DMREQ_Daten1"
		dbc.sig_id_assign[3] = "DMREQ_Daten2"
		dbc.msg_dev_tx = "0x18FED100"
		dbc.msg_dev_rx = 0x18FED101
		dbc.msg_version_tx = "0x17FC16D1"
		dbc.msg_version_rx = 0x17FE16D1
		dbc.msg_balancing = "CMC_01_TZ_01"
		dbc.sig_balancing = "CMC_01_ZellBalStatus_"
		dbc.msg_autonomous = "BMC_Anf_01"
		dbc.sig_autonomous = "CMC_KeepAwake"
		dbc.msg_fault = "CMC_01_KompFehler_01"
		dbc.sig_fault = "CMC_01_KompFehlerModus"
		dbc.msg_voltage = "CMC_01_UZ_0"
		dbc.sig_voltage = "CMC_01_UZelle_"
		dbc.msg_cvn = "CMC_01_CALID_CVN"
		dbc.sig_cvn[1] = "CMC_01_CVN_1"
		dbc.sig_cvn[2] = "CMC_01_CVN_2"
		dbc.sig_cvn[3] = "CMC_01_CVN_3"
		dbc.sig_cvn[4] = "CMC_01_CVN_4"
		dbc.msg_alram = "CMC_01_KompFehler_01"
		dbc.sig_alram = "CMC_01_KompFehlerModus2_11"
		dbc.msg_temp = "CMC_01_TZ_01"
		dbc.sig_temp = "CMC_01_TModul_01"
		dbc.msg_openwire = "CMC_01_KompFehler_01"
		dbc.sig_openwire = "CMC_01_KompFehlerModus2_04"
		
	elseif model == 1 then -- vw12s1p
		dbc.msg_id_assign = ""
		dbc.sig_id_assign[1] = ""
		dbc.sig_id_assign[2] = ""
		dbc.sig_id_assign[3] = ""
		dbc.msg_dev_tx = ""
		dbc.msg_dev_rx = ""
		dbc.msg_version_tx = ""
		dbc.msg_version_rx = ""
		dbc.msg_balancing = ""
		dbc.sig_balancing = ""
		dbc.msg_autonomous = ""
		dbc.sig_autonomous = ""
		dbc.msg_fault = ""
		dbc.sig_fault = ""
		dbc.msg_voltage = ""
		dbc.sig_voltage = ""
		dbc.msg_cvn = ""
		dbc.sig_cvn[1] = ""
		dbc.sig_cvn[2] = ""
		dbc.sig_cvn[3] = ""
		dbc.sig_cvn[4] = ""
		dbc.msg_alram = ""
		dbc.sig_alram = ""
		dbc.msg_temp = "CMC_01_TZ_01"
		dbc.sig_temp = "CMC_01_TModul_01"
		dbc.msg_openwire = ""
		dbc.sig_openwire = ""
	
	elseif model == 2 then -- geely 114L
		dbc.msg_id_assign = "0x6C0"
		dbc.sig_id_assign[1] = ""
		dbc.sig_id_assign[2] = ""
		dbc.sig_id_assign[3] = ""
		dbc.msg_dev_tx = ""
		dbc.msg_dev_rx = ""
		dbc.msg_version_tx = ""
		dbc.msg_version_rx = ""
		dbc.msg_balancing = ""
		dbc.sig_balancing = ""
		dbc.msg_autonomous = ""
		dbc.sig_autonomous = ""
		dbc.msg_fault = ""
		dbc.sig_fault = ""
		dbc.msg_voltage = ""
		dbc.sig_voltage = ""
		dbc.msg_cvn = ""
		dbc.sig_cvn[1] = ""
		dbc.sig_cvn[2] = ""
		dbc.sig_cvn[3] = ""
		dbc.sig_cvn[4] = ""
		dbc.msg_alram = ""
		dbc.sig_alram = ""
		dbc.msg_temp = "BMM_01_05"
		dbc.sig_temp = "BMM_01_Temp_1"
		dbc.msg_openwire = ""
		dbc.sig_openwire = ""
		
	elseif model == 3 then -- geely FE3HP
		dbc.msg_id_assign = ""
		dbc.sig_id_assign[1] = ""
		dbc.sig_id_assign[2] = ""
		dbc.sig_id_assign[3] = ""
		dbc.msg_dev_tx = ""
		dbc.msg_dev_rx = ""
		dbc.msg_version_tx = ""
		dbc.msg_version_rx = ""
		dbc.msg_balancing = ""
		dbc.sig_balancing = ""
		dbc.msg_autonomous = ""
		dbc.sig_autonomous = ""
		dbc.msg_fault = ""
		dbc.sig_fault = ""
		dbc.msg_voltage = ""
		dbc.sig_voltage = ""
		dbc.msg_cvn = ""
		dbc.sig_cvn[1] = ""
		dbc.sig_cvn[2] = ""
		dbc.sig_cvn[3] = ""
		dbc.sig_cvn[4] = ""
		dbc.msg_alram = "CSC_01_CompError_01"
		dbc.sig_alram = "CSC_01_CompErrorMode2_06"
		dbc.msg_temp = "CSC_01_05"
		dbc.sig_temp = "CSC_01_Temp_1"
		dbc.msg_openwire = "CSC_01_CompError_01"
		dbc.sig_openwire = "CSC_01_CompErrorMode2_04"
		
	elseif model == 4 then -- NEXTEV
		dbc.msg_id_assign = ""
		dbc.sig_id_assign[1] = ""
		dbc.sig_id_assign[2] = ""
		dbc.sig_id_assign[3] = ""
		dbc.msg_dev_tx = ""
		dbc.msg_dev_rx = ""
		dbc.msg_version_tx = ""
		dbc.msg_version_rx = ""
		dbc.msg_balancing = ""
		dbc.sig_balancing = ""
		dbc.msg_autonomous = ""
		dbc.sig_autonomous = ""
		dbc.msg_fault = ""
		dbc.sig_fault = ""
		dbc.msg_voltage = ""
		dbc.sig_voltage = ""
		dbc.msg_cvn = ""
		dbc.sig_cvn[1] = ""
		dbc.sig_cvn[2] = ""
		dbc.sig_cvn[3] = ""
		dbc.sig_cvn[4] = ""
		dbc.msg_alram = ""
		dbc.sig_alram = ""
		dbc.msg_temp = "CSC_01_05"
		dbc.sig_temp = "CSC_01_Temp_1"
		dbc.msg_openwire = ""
		dbc.sig_openwire = ""
	end
end


------------------------------------------------------------------------
-- BASIC Function
------------------------------------------------------------------------
declare "DoESTOP"
function DoESTOP()

	--Power Off
	tas.write("lvpwr.volt", 0)
	tas.write("lvpwr.onoff", 0)
	tas.write("selin_pwr.volt", 0)
	tas.write("selin_pwr.onoff", 0)
	
	--Cell Simulator Off
	for idx = 1, 3, 1 do
		CellSimulator_Volt(idx, 0, 0, 0, 0)
		tas.wait(100)
	end
	
	tas.write("can1.onoff", 0)
	tas.write("can2.onoff", 0)

	CtrlBrd(RelaySet.Power.All_Off, 1)
	
	tas.runbackgroundstop(h_sync_task_egolf)
	tas.runbackgroundstop(h_sync_task_vw12s1p)

	tas.progress("E-STOP activated")

end

------- for timming check test---------
declare "list_iter"
function list_iter (t)
    local i = 0
    local n = #t
    return function ()
        i = i + 1
        if i <= n then return t[i] end
    end
end

declare "get_csv_file"
function get_csv_file(filename)
	local lines = {}
	local tbl = {}
	tas.read_all_lines_from_file(lines, filename)
	for line in list_iter(lines) do
		local fields = {}
		tas.split_string(fields, line, {','})
		table.insert(tbl, fields)
	end
	return tbl
end
----------------------------------------
declare "read_pwm_sel_out"
function read_pwm_sel_out()
	local threshold = 1.5
	
	tas.osc_reset("oscchart", 5000)
	tas.osc_pause_update("oscchart")
	tas.osc_add_series("oscchart", "sell_out", "ai_SEL_OUT", "Green")
	tas.osc_set_xrange("oscchart", 1)
	tas.osc_set_yrange("oscchart", -1, 15)
	tas.osc_resume_update("oscchart")
	
	tas.wait(100)
	tas.read("ai_SEL_OUT")
	
	tas.wait(2000)
	
	tas.osc_export_data_to_csv('oscchart', tas.get_logging_path() .. "\\..\\")
	local sel_out_tbl = get_csv_file(tas.get_logging_path() .. "\\..\\".."sell_out.csv")
	local sel_out_on_time = {}
	local sel_out_off_time = {}
	local onidx = 2500
	local offidx = 2500
	local on_time_sum = 0
	local off_time_sum = 0
	local on_time_mean
	local high_time = 0
	local low_time
	local sel_out_cycle
	local sel_out_freq
	local sel_out_duty
	local sel_out_max_volt = 0
	local sel_out_min_volt = 5
	local return_value = {}
	
	-- High Low Timming Check
	for freqidx = 1, 20, 1 do
		for i = offidx, #sel_out_tbl do
			if tonumber(sel_out_tbl[i][2]) > threshold then
				sel_out_on_time[freqidx] = tonumber(sel_out_tbl[i][1])
				onidx = i
				break
			end
		end
		
		for i = onidx, #sel_out_tbl do
			if tonumber(sel_out_tbl[i][2]) < threshold then
				sel_out_off_time[freqidx] = tonumber(sel_out_tbl[i][1])
				offidx = i
				break
			end
		end
	end
	
	-- High Low Voltage Measure
	for voltidx = 1250, #sel_out_tbl do
		if tonumber(sel_out_tbl[voltidx][2]) > sel_out_max_volt then
			sel_out_max_volt = tonumber(sel_out_tbl[voltidx][2])
		end
		if tonumber(sel_out_tbl[voltidx][2]) < sel_out_min_volt then
			sel_out_min_volt = tonumber(sel_out_tbl[voltidx][2])
		end
	end
	
	if #sel_out_on_time == 0 or #sel_out_on_time == 0 then -- Not PWM signal
		--for idx = 1, 2500 do
		--	sel_out_min_volt = sel_out_min_volt + tonumber(sel_out_tbl[idx + 750][2])
		--end
		sel_out_min_volt = (sel_out_max_volt + sel_out_min_volt)/2
		sel_out_max_volt = sel_out_min_volt
		sel_out_freq = 0
		sel_out_duty = 0
		tas.progress("not pwm") --TODO for Debug
		
	else -- PWM signal
		for idx = 10, 14, 1 do
			on_time_sum = on_time_sum + (sel_out_on_time[idx + 1] - sel_out_on_time[idx])
			high_time = high_time + (sel_out_off_time[idx] - sel_out_on_time[idx])
		end
		
		on_time_mean = on_time_sum/5
		high_time = high_time/5
		
		sel_out_cycle = on_time_mean/5000
		sel_out_freq = 1/sel_out_cycle
		sel_out_duty = high_time/on_time_mean
	end
	
	return_value[1] = sel_out_max_volt
	return_value[2] = sel_out_min_volt
	return_value[3] = sel_out_freq
	return_value[4] = sel_out_duty
	
	tas.osc_pause_update("oscchart")
	
	return return_value
end

declare "read_pwm_sel_in"
function read_pwm_sel_in()
	local threshold = 1.5
	
	tas.osc_reset("oscchart", 5000)
	tas.osc_pause_update("oscchart")
	tas.osc_add_series("oscchart", "sell_in", "ai_SEL_IN", "Green")
	tas.osc_set_xrange("oscchart", 1)
	tas.osc_set_yrange("oscchart", -1, 15)
	tas.osc_resume_update("oscchart")
	
	tas.wait(100)
	tas.read("ai_SEL_IN")
	
	tas.wait(2000)
	
	tas.osc_export_data_to_csv('oscchart', tas.get_logging_path() .. "\\..\\")
	local sel_out_tbl = get_csv_file(tas.get_logging_path() .. "\\..\\".."sell_in.csv")
	local sel_out_on_time = {}
	local sel_out_off_time = {}
	local onidx = 2500
	local offidx = 2500
	local on_time_sum = 0
	local off_time_sum = 0
	local on_time_mean
	local high_time = 0
	local low_time
	local sel_out_cycle
	local sel_out_freq
	local sel_out_duty
	local sel_out_max_volt = 0
	local sel_out_min_volt = 5
	local return_value = {}
	
	-- High Low Timming Check
	for freqidx = 1, 20, 1 do
		for i = offidx, #sel_out_tbl do
			if tonumber(sel_out_tbl[i][2]) > threshold then
				sel_out_on_time[freqidx] = tonumber(sel_out_tbl[i][1])
				onidx = i
				break
			end
		end
		
		for i = onidx, #sel_out_tbl do
			if tonumber(sel_out_tbl[i][2]) < threshold then
				sel_out_off_time[freqidx] = tonumber(sel_out_tbl[i][1])
				offidx = i
				break
			end
		end
	end
	
	-- High Low Voltage Measure
	for voltidx = 1250, #sel_out_tbl do
		if tonumber(sel_out_tbl[voltidx][2]) > sel_out_max_volt then
			sel_out_max_volt = tonumber(sel_out_tbl[voltidx][2])
		end
		if tonumber(sel_out_tbl[voltidx][2]) < sel_out_min_volt then
			sel_out_min_volt = tonumber(sel_out_tbl[voltidx][2])
		end
	end
	
	if #sel_out_on_time == 0 or #sel_out_on_time == 0 then -- Not PWM signal
		--for idx = 1, 2500 do
		--	sel_out_min_volt = sel_out_min_volt + tonumber(sel_out_tbl[idx + 750][2])
		--end
		sel_out_min_volt = (sel_out_max_volt + sel_out_min_volt)/2
		sel_out_max_volt = sel_out_min_volt
		sel_out_freq = 0
		sel_out_duty = 0
		tas.progress("not pwm") --TODO for Debug
		
	else -- PWM signal
		for idx = 10, 14, 1 do
			on_time_sum = on_time_sum + (sel_out_on_time[idx + 1] - sel_out_on_time[idx])
			high_time = high_time + (sel_out_off_time[idx] - sel_out_on_time[idx])
		end
		
		on_time_mean = on_time_sum/5
		high_time = high_time/5
		
		sel_out_cycle = on_time_mean/5000
		sel_out_freq = 1/sel_out_cycle
		sel_out_duty = high_time/on_time_mean
	end
	
	return_value[1] = sel_out_max_volt
	return_value[2] = sel_out_min_volt
	return_value[3] = sel_out_freq
	return_value[4] = sel_out_duty
	
	tas.osc_pause_update("oscchart")
	
	return return_value
end

declare "JIG"
JIG = {PAD = 0, FRT = 1, REAR = 2}
declare "cylinder"
function cylinder(jigch, module, onoff)
	if module > 2 then
		tas.fail("Invalid probe module number")
	else
		if gv_interlock_state == true then
			tas.writestring("share.light_curtain_state", 1)
		end
		
		if jigch == 3 and module == 2 then
			if onoff == 1 then
				tas.write("smartio.do2_1", 1)
				tas.wait(200)
				tas.write("smartio.do2_1", 0)
			else
				tas.write("smartio.do2_2", 1)
				tas.wait(200)
				tas.write("smartio.do2_2", 0)
			end
		else
			jigch = ((jigch - 1) * 6) + 1
			local doch = jigch + (module * 2)
			if onoff == 1 then
				tas.write("smartio.do1_"..doch, 1)
				tas.wait(200)
				tas.write("smartio.do1_"..doch, 0)
			else
				tas.write("smartio.do1_"..doch+1, 1)
				tas.wait(200)
				tas.write("smartio.do1_"..doch+1, 0)
			end
		end
		
		if gv_interlock_state == true then
			--tas.runbackgroundstop(h_task_critical_stop_check)
			tas.writestring("share.light_curtain_state", 0)
		end
	end
end

------------------------------------------------------------------------
-- Manual Function
------------------------------------------------------------------------
declare "cylinder_up"
function cylinder_up()
		cylinder(1, JIG.PAD, 0)
		cylinder(2, JIG.PAD, 0)
		cylinder(3, JIG.PAD, 0)
		tas.wait(1000)
		cylinder(1, JIG.FRT, 0)
		cylinder(2, JIG.FRT, 0)	
		cylinder(3, JIG.FRT, 0)
		tas.wait(1000)
		cylinder(1, JIG.REAR, 0)
		cylinder(2, JIG.REAR, 0)
		cylinder(3, JIG.REAR, 0)
end

declare "test_stop"
function test_stop()
	--TODO:테스트가 종료되었을때 호출되어져야 하는것. 추가적으로 필요한 로직이 있는지 항시 검토

	--CellSimulator off
	local volt = 0
	for idx = 1, 12, 1 do
		set_cell_volt(idx, volt)
	end

	--Power Off(LV, SELIN, CellSimualtor)
	LVPower_Volt(0)
	LVPower_Onoff(0)
	SELInPower_Volt(0)
	SELInPower_Onoff(0)

	--CMC Control Board Off
	CtrlBrd(RelaySet.Power.All_Off, 1)

	--DUT Select Board Off
	for dutidx = 1,9,1 do
		tas.write("smartio.do3_"..dutidx, 0)
	end
	
	--JIG Unlock
	cylinder_up()
	
	manual_stop_bmc_sync_vw12s1p()
	manual_stop_bmc_sync_egolf()
	
end

declare "set_cell_volt"
function set_cell_volt(chno, cell_volt_mv)
	local cs_brd_idx = math.floor((chno + 3)/4)
	local conv_cellsim_msg = "CellSim"..cs_brd_idx.."VoltSet"
	local conv_cellsim_sig = "CellSim"..cs_brd_idx.."ValueSetVolt"..((chno-1)%4+1)
	can_write_cellsim_volt_set(conv_cellsim_msg, conv_cellsim_sig, cell_volt_mv)
end

declare "manual_lvpwr_onoff"
function manual_lvpwr_onoff(onoff)
	LVPower_Onoff(onoff)
end

declare "manual_lvpwr_setvolt"
function manual_lvpwr_setvolt(v_volt)
	LVPower_Volt(v_volt)
end

declare "manual_selin_volt"
function manual_selin_volt(v_volt)
	--CtrlBrd(4,0) -- AO_relay_Off
	--CtrlBrd(3,1) -- SELPwr_relay_On
	if v_volt == 0 then
		SELInPower_Volt(0)
		SELInPower_Onoff(0)
	else
		SELInPower_Onoff(1)
		SELInPower_Volt(v_volt)
	end
end

declare "manual_selin_freq"
function manual_selin_freq(volt, freq)
	--CtrlBrd(3,0) -- SELPwr_relay_off
	--CtrlBrd(4,1) -- AO_relay_On	
	if volt == 0 then
		tas.write("ao_SEL_IN", 0)
	else
		tas.writestring("ao_SEL_IN.square", (volt/4)..", "..(volt/4)..", "..freq..", 0.5")
	end
end

declare "manual_set_temp_r"
function manual_set_temp_r(chno, resistance) -- TODO: 모델마다 적용되도록 변경 필요
	local read_temp = ""
	ProgrammableResistor(6, resistance, 0) -- mode normal
	tas.wait(2000)
	read_temp = cmc_can_read(dbc.msg_temp, dbc.sig_temp)
	tas.writestring("share.cmc_temp_feed", read_temp.."")
end

declare "manual_ionizer_onoff"
function manual_ionizer_onoff(onoff)
	if onoff == true then
		onoff = 1
	else
		onoff = 0
	end
	tas.write("smartio.do2_3", onoff)
	tas.write("smartio.do2_4", onoff)
	tas.write("smartio.do2_5", onoff)
	tas.write("smartio.do2_6", onoff)
end

declare "functest_wait_test_start_button"
function functest_wait_test_start_button()
	--테스트 시작 버튼이 눌러져서, 테스트가 실행가능한 상태일때까지 기다리는 함수. 테스트가 실행가능하면 return을 수행

	while true do -- 양수버튼 누르기
		if	((tas.read("smartio.di_1") == 1 and tas.read("smartio.di_2") == 1)) or tas.readstring("share.sw_start_button") == "1" then
			break
		end

		if gv_interlock_state == true then
			-- TODO Light curtain이 감지되는지 확인 후, 감지되면 에러메시지 띄워주는 로직 필요
			send_alert("Light curtain detected! Please JIG check and clear.")
		end
		tas.wait(100)
	end

	return
end

declare "h_task_lightcurtain_check"
declare "functest_cylinder_auto_on"
function functest_cylinder_auto_on(ch_onoff_lst)
	local jig_enable = {nil, nil, nil, nil, nil, nil, nil, nil, nil}
	local opti_enable = {nil, nil, nil, nil, nil, nil, nil, nil, nil}
	local active_jig = {0, 0, 0}
	gv_jig_miss_mount = {} -- Jig miss mount state initialize
	
	-- Check selected jig	
	for jigidx = 1,#ch_onoff_lst,1 do
		if ch_onoff_lst[jigidx] == true then
			break
		end
		if jigidx == #ch_onoff_lst then
			send_critical_stop("JIG was not selected")
			return
		end
	end
	
	-- active enable check
	for idx = 1, #ch_onoff_lst, 1 do
		-- JIG activate check
		if ch_onoff_lst[idx] == true then
			jig_enable[idx] = true
		else
			jig_enable[idx] = false
		end
		
		-- JIG optical senseor check
		if tas.read("smartio.di_"..(32-(idx-1)*2)) == 1 and tas.read("smartio.di_"..(31-(idx-1)*2)) == 1 then
			opti_enable[idx] = true
		elseif tas.read("smartio.di_"..(32-(idx-1)*2)) == 0 and tas.read("smartio.di_"..(31-(idx-1)*2)) == 0 then
			opti_enable[idx] = false
		else -- JIG miss mounting(한 개의 센서만 체크 된 경우)
			opti_enable[idx] = false
			gv_jig_miss_mount[idx] = 1
			--send_critical_stop("JIG"..idx.." miss mounting!")
			--break
		end
	end
	
	for idx = 1,9,3 do
		if jig_enable[idx] == true or jig_enable[idx+1] == true or jig_enable[idx+2] == true then -- If test DUT was selected in software
			if opti_enable[idx] == true or opti_enable[idx+1] == true or opti_enable[idx+2] == true then -- and optical sensor was ok, then test start
				active_jig[(idx+2)/3] = 1
			end
		end
	end
	
	-- jig action
	for probeidx = 0,2,1 do
		for jigidx = 1,3,1 do
			if active_jig[jigidx] == 1 then -- active check된 JIG만 동작
--				if gv_jig_miss_mount[(jigidx - 1) * 3 + 1] == 1 then
--					send_critical_stop("JIG"..((jigidx - 1) * 3 + 1).." miss mounting!")
--				elseif gv_jig_miss_mount[(jigidx - 1) * 3 + 2] == 1 then
--					send_critical_stop("JIG"..((jigidx - 1) * 3 + 2).." miss mounting!")
--				elseif gv_jig_miss_mount[(jigidx - 1) * 3 + 3] == 1 then
--					send_critical_stop("JIG"..((jigidx - 1) * 3 + 3).." miss mounting!")
--				else
					cylinder(jigidx, probeidx, active_jig[jigidx])
					gv_jig_miss_mount = {} -- Jig miss mount state initialize
--				end
			end
		end
		
		tas.wait(1000)
	end
	
	local no_mount_state = {0, 0, 0}
	if active_jig == no_mount_state then -- update jig mount state
		gv_jig_mount_state = false
	else
		gv_jig_mount_state = true
	end
	
	return true
end

declare "jig_select"
function jig_select(jig_no)
	for selbrdidx = 1,9,1 do -- initializing dut select board
		tas.write("smartio.do3_"..selbrdidx, 0)
	end
	tas.wait(500)
	tas.progress("JIG No."..jig_no.." Test Start")
	tas.write("smartio.do3_"..jig_no, 1)
end

declare "functest_interlock_onoff"
function functest_interlock_onoff(onoff)
	gv_interlock_state = onoff
end

------------------------------------------------------------------------
-- CMC Control Board
------------------------------------------------------------------------
declare "set_cmc_ctr_brd"
function set_cmc_ctr_brd(ch, onoff)
	local ch_10 = math.floor(ch/10)
	local ch_1 = ch%10
	tas.writestring(cmcbrd_name,"SET,"..ch_10..ch_1..","..onoff..";")
end
declare "set_cmc_ctr_brd_analog"
function set_cmc_ctr_brd_analog(ch, onoff)
	local ch_10 = math.floor(ch/10)
	local ch_1 = ch%10
	tas.writestring(cmcbrd_name,"SET,A"..ch_10..ch_1..","..onoff..";")
end

declare "LV_DMM_CON"
function LV_DMM_CON(onoff)
	set_cmc_ctr_brd_analog(15, onoff)
end
declare "LV_PWR_POS"
function LV_PWR_POS(onoff)
	set_cmc_ctr_brd_analog(14, onoff)
end
declare "SELOUT_DMM_POS"
function SELOUT_DMM_POS(onoff)
	set_cmc_ctr_brd_analog(13, onoff)
end
declare "SELOUT_short_GND"
function SELOUT_short_GND(onoff)
	set_cmc_ctr_brd_analog(12, onoff)
end
declare "SELOUT_3kohm_GND"
function SELOUT_3kohm_GND(onoff)
	set_cmc_ctr_brd_analog(11, onoff)
end
declare "SELOUT_short_LV"
function SELOUT_short_LV(onoff)
	set_cmc_ctr_brd_analog(10, onoff)
end
declare "LV_DMM_CURR"
function LV_DMM_CURR(onoff)
	set_cmc_ctr_brd_analog(9, onoff)
end
declare "LV_PWR_NEG"
function LV_PWR_NEG(onoff)
	set_cmc_ctr_brd_analog(8, onoff)
end
declare "CELL_DMM_NEG"
function CELL_DMM_NEG(onoff)
	set_cmc_ctr_brd_analog(7, onoff)
end
declare "CELL_DMM_POS"
function CELL_DMM_POS(onoff)
	set_cmc_ctr_brd_analog(6, onoff)
end
declare "SELOUT_10kohm_LV"
function SELOUT_10kohm_LV(onoff)
	set_cmc_ctr_brd_analog(5, onoff)
end
declare "HV_PWR_POS"
function HV_PWR_POS(onoff)
	set_cmc_ctr_brd_analog(4, onoff)
end
declare "CAN_CON"
function CAN_CON(onoff)
	set_cmc_ctr_brd_analog(3, onoff)
end
declare "SELIN_DMM_POS"
function SELIN_DMM_POS(onoff)
	set_cmc_ctr_brd_analog(2, onoff)
end
declare "SELIN_PWR"
function SELIN_PWR(onoff)
	set_cmc_ctr_brd_analog(1, onoff)
end
declare "SELIN_a0"
function SELIN_a0(onoff)
	set_cmc_ctr_brd_analog(0, onoff)
end
declare "CELL_GND"
function CELL_GND(onoff)
	set_cmc_ctr_brd(53, onoff)
end
declare "HV_PWR_NEG"
function HV_PWR_NEG(onoff)
	set_cmc_ctr_brd(52, onoff)
end
declare "CELL1_CELL_SEN1"
function CELL1_CELL_SEN1(onoff)
	set_cmc_ctr_brd(51, onoff)
end
declare "CELL2_CELL_SEN2"
function CELL2_CELL_SEN2(onoff)
	set_cmc_ctr_brd(50, onoff)
end
declare "CELL3_CELL_SEN3"
function CELL3_CELL_SEN3(onoff)
	set_cmc_ctr_brd(49, onoff)
end
declare "CELL4_CELL_SEN4"
function CELL4_CELL_SEN4(onoff)
	set_cmc_ctr_brd(48, onoff)
end
declare "CELL5_CELL_SEN5"
function CELL5_CELL_SEN5(onoff)
	set_cmc_ctr_brd(47, onoff)
end
declare "CELL6_CELL_SEN6"
function CELL6_CELL_SEN6(onoff)
	set_cmc_ctr_brd(46, onoff)
end
declare "CELL7_CELL_SEN7"
function CELL7_CELL_SEN7(onoff)
	set_cmc_ctr_brd(45, onoff)
end
declare "CELL8_CELL_SEN8"
function CELL8_CELL_SEN8(onoff)
	set_cmc_ctr_brd(44, onoff)
end
declare "CELL9_CELL_SEN9"
function CELL9_CELL_SEN9(onoff)
	set_cmc_ctr_brd(43, onoff)
end
declare "CELL10_CELL_SEN10"
function CELL10_CELL_SEN10(onoff)
	set_cmc_ctr_brd(42, onoff)
end
declare "CELL11_CELL_SEN11"
function CELL11_CELL_SEN11(onoff)
	set_cmc_ctr_brd(41, onoff)
end
declare "CELL12_CELL_SEN12"
function CELL12_CELL_SEN12(onoff)
	set_cmc_ctr_brd(40, onoff)
end
declare "CELL8_9_STACK"
function CELL8_9_STACK(onoff)
	set_cmc_ctr_brd(39, onoff)
end
declare "CELL12_13_STACK"
function CELL12_13_STACK(onoff)
	set_cmc_ctr_brd(38, onoff)
end
declare "DMM_CELL1"
function DMM_CELL1(onoff)
	set_cmc_ctr_brd(37, onoff)
end
declare "DMM_CELL2"
function DMM_CELL2(onoff)
	set_cmc_ctr_brd(36, onoff)
end
declare "DMM_CELL3"
function DMM_CELL3(onoff)
	set_cmc_ctr_brd(35, onoff)
end
declare "DMM_CELL4"
function DMM_CELL4(onoff)
	set_cmc_ctr_brd(34, onoff)
end
declare "DMM_CELL5"
function DMM_CELL5(onoff)
	set_cmc_ctr_brd(33, onoff)
end
declare "DMM_CELL6"
function DMM_CELL6(onoff)
	set_cmc_ctr_brd(32, onoff)
end
declare "DMM_CELL7"
function DMM_CELL7(onoff)
	set_cmc_ctr_brd(31, onoff)
end
declare "DMM_CELL8"
function DMM_CELL8(onoff)
	set_cmc_ctr_brd(30, onoff)
end
declare "DMM_CELL9"
function DMM_CELL9(onoff)
	set_cmc_ctr_brd(29, onoff)
end
declare "DMM_CELL10"
function DMM_CELL10(onoff)
	set_cmc_ctr_brd(28, onoff)
end
declare "DMM_CELL11"
function DMM_CELL11(onoff)
	set_cmc_ctr_brd(27, onoff)
end
declare "DMM_CELL12"
function DMM_CELL12(onoff)
	set_cmc_ctr_brd(26, onoff)
end
declare "DMM_CELLGND"
function DMM_CELLGND(onoff)
	set_cmc_ctr_brd(25, onoff)
end
declare "cap1_enable_sig"
function cap1_enable_sig(onoff)
	set_cmc_ctr_brd(24, onoff)
end
declare "cap2_enable_sig"
function cap2_enable_sig(onoff)
	set_cmc_ctr_brd(23, onoff)
end
declare "cap3_enable_sig"
function cap3_enable_sig(onoff)
	set_cmc_ctr_brd(22, onoff)
end
declare "TEMP_CON1"
function TEMP_CON1(onoff)
	set_cmc_ctr_brd(13, onoff)
end
declare "CELL13_POS"
function CELL13_POS(onoff)
	set_cmc_ctr_brd(12, onoff)
end
declare "CELL12_POS"
function CELL12_POS(onoff)
	set_cmc_ctr_brd(11, onoff)
end
declare "CELL8_POS"
function CELL8_POS(onoff)
	set_cmc_ctr_brd(10, onoff)
end
declare "CELL_POS_CONNECT"
function CELL_POS_CONNECT(onoff)
	set_cmc_ctr_brd(9, onoff)
end
declare "CELL_POS_DMM_CURR"
function CELL_POS_DMM_CURR(onoff)
	set_cmc_ctr_brd(8, onoff)
end
declare "CELL5_6_layer_rear"
function CELL5_6_layer_rear(onoff)
	set_cmc_ctr_brd(7, onoff)
end
declare "CELL7_8_layer"
function CELL7_8_layer(onoff)
	set_cmc_ctr_brd(6, onoff)
end
declare "CELL5_6_layer_front"
function CELL5_6_layer_front(onoff)
	set_cmc_ctr_brd(5, onoff)
end
declare "CELL2_4_layer"
function CELL2_4_layer(onoff)
	set_cmc_ctr_brd(4, onoff)
end
declare "CELL2_12_layer"
function CELL2_12_layer(onoff)
	set_cmc_ctr_brd(3, onoff)
end
declare "CELL1_layer"
function CELL1_layer(onoff)
	set_cmc_ctr_brd(2, onoff)
end

declare "CtrlBrd"
function CtrlBrd(mode, onoff)
	if mode == 0 then -- Power.All_Off
		for idx=0,15,1 do
			set_cmc_ctr_brd_analog(idx,0)
		end
		for idx=2,13,1 do
			set_cmc_ctr_brd(idx,0)
		end
		for idx=22,53,1 do
			set_cmc_ctr_brd(idx,0)
		end
		
	elseif mode == 1 then -- Power.LV_PWR_POS
		LV_PWR_POS(onoff)

	elseif mode == 2 then -- Power.LV_PWR_NEG
		--LV_DMM_CURR(0)
		LV_PWR_NEG(onoff)

	elseif mode == 3 then -- Power.SELPwrPos_SELIn
		SELIN_a0(0)
		SELIN_PWR(onoff)

	elseif mode == 4 then -- Power.A0_SELIn
		--SELIN_PWR(0)
		SELIN_a0(onoff)		

	elseif mode == 5 then -- Power.SELOut_3kohm
		SELOUT_short_GND(0)
--		SELOUT_short_LV(0)
		SELOUT_3kohm_GND(onoff)

	elseif mode == 6 then -- Power.SELOut_10kohm
		SELOUT_10kohm_LV(0)
		SELOUT_3kohm_GND(0)
		SELOUT_short_LV(0)
		SELOUT_short_GND(onoff)

	elseif mode == 7 then -- Power.SELOut_Short_LVPwr
		SELOUT_10kohm_LV(0)
--		SELOUT_3kohm_GND(0)
		SELOUT_short_GND(0)
		SELOUT_short_LV(onoff)

	elseif mode == 8 then -- Power.SELOut_10kohm_LVPwr
		SELOUT_short_LV(0)
		SELOUT_short_GND(0)
		SELOUT_10kohm_LV(onoff)

	elseif mode == 9 then -- CAN.CAN_connect
		CAN_CON(onoff)

	elseif mode == 10 then -- Cell.Cell_CellSenGND
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL_GND(onoff)

	elseif mode == 11 then -- Cell.Cell1_CellSen1
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL1_CELL_SEN1(onoff)
	
	elseif mode == 12 then -- Cell.Cell2_CellSen2
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL2_CELL_SEN2(onoff)
	
	elseif mode == 13 then -- Cell.Cell3_CellSen3
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL3_CELL_SEN3(onoff)
	
	elseif mode == 14 then -- Cell.Cell4_CellSen4
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL4_CELL_SEN4(onoff)
	
	elseif mode == 15 then -- Cell.Cell5_CellSen5
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL5_CELL_SEN5(onoff)
	
	elseif mode == 16 then -- Cell.Cell6_CellSen6
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL6_CELL_SEN6(onoff)
	
	elseif mode == 17 then -- Cell.Cell7_CellSen7
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL7_CELL_SEN7(onoff)
	
	elseif mode == 18 then -- Cell.Cell8_CellSen8
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL8_CELL_SEN8(onoff)
	
	elseif mode == 19 then -- Cell.Cell9_CellSen9
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL9_CELL_SEN9(onoff)
	
	elseif mode == 20 then -- Cell.Cell10_CellSen10
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL10_CELL_SEN10(onoff)
	
	elseif mode == 21 then -- Cell.Cell11_CellSen11
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL11_CELL_SEN11(onoff)
	
	elseif mode == 22 then -- Cell.Cell12_CellSen12
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL12_CELL_SEN12(onoff)
	
	elseif mode == 23 then -- Cell.CellPOS_Cell8
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL8_9_STACK(0)
		CELL12_13_STACK(0)
		CELL9_CELL_SEN9(0)
		CELL10_CELL_SEN10(0)
		CELL11_CELL_SEN11(0)
		CELL12_CELL_SEN12(0)
		CELL13_POS(0)
		CELL12_POS(0)
		CELL_POS_DMM_CURR(0)
		CELL_POS_CONNECT(onoff)
		CELL8_POS(onoff)		
	
	elseif mode == 24 then -- Cell.CellPOS_Cell12
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL12_13_STACK(0)
		CELL13_POS(0)
		CELL8_POS(0)
		CELL_POS_DMM_CURR(0)
		CELL8_9_STACK(onoff)
		CELL_POS_CONNECT(onoff)
		CELL12_POS(onoff)

	elseif mode == 25 then -- Cell.CellPOS_Cell13
		HV_PWR_POS(0)
		HV_PWR_NEG(0)
		CELL12_POS(0)
		CELL8_POS(0)
		CELL_POS_DMM_CURR(0)
		CELL8_9_STACK(onoff)
		CELL12_13_STACK(onoff)
		CELL_POS_CONNECT(onoff)
		CELL13_POS(onoff)		

	elseif mode == 26 then -- Cell.HVPwr_Cell
		CELL_GND(0)
		CELL1_CELL_SEN1(0)
		CELL2_CELL_SEN2(0)
		CELL3_CELL_SEN3(0)
		CELL4_CELL_SEN4(0)
		CELL5_CELL_SEN5(0)
		CELL6_CELL_SEN6(0)
		CELL7_CELL_SEN7(0)
		CELL8_CELL_SEN8(0)
		CELL9_CELL_SEN9(0)
		CELL10_CELL_SEN10(0)
		CELL11_CELL_SEN11(0)
		CELL12_CELL_SEN12(0)
		CELL8_9_STACK(0)
		CELL12_13_STACK(0)
		HV_PWR_POS(onoff)
		HV_PWR_NEG(onoff)

	elseif mode == 27 then -- Model.M12S1P
		CELL5_6_layer_front(0)
		CELL7_8_layer(0)
		CELL5_6_layer_rear(0)
		CELL2_4_layer(0)
		CELL2_12_layer(0)
		CELL1_layer(0)

	elseif mode == 28 then -- Model.M6S2P
		CELL7_8_layer(0)
		CELL5_6_layer_rear(0)
		CELL1_layer(0)
		CELL2_12_layer(onoff)
		CELL5_6_layer_front(onoff)
		CELL2_4_layer(onoff)

	elseif mode == 29 then -- Model.VW4S3P
		CELL7_8_layer(0)
		CELL5_6_layer_rear(0)
		CELL5_6_layer_front(0)
		CELL2_4_layer(0)
		CELL2_12_layer(onoff)
		CELL1_layer(onoff)

	elseif mode == 30 then -- Model.SAIC4S3P
		CELL2_4_layer(0)
		CELL5_6_layer_front(onoff)
		CELL7_8_layer(onoff)
		CELL5_6_layer_rear(onoff)
		CELL2_12_layer(onoff)
		CELL1_layer(onoff)	

	elseif mode == 31 then -- DMMRly.Reset
		LV_DMM_CON(0)
		SELOUT_DMM_POS(0)
		LV_DMM_CURR(0)
		CELL_DMM_NEG(0)
		CELL_DMM_POS(0)
		SELIN_DMM_POS(0)
		DMM_CELLGND(0)
		DMM_CELL1(0)
		DMM_CELL2(0)
		DMM_CELL3(0)
		DMM_CELL4(0)
		DMM_CELL5(0)
		DMM_CELL6(0)
		DMM_CELL7(0)
		DMM_CELL8(0)
		DMM_CELL9(0)
		DMM_CELL10(0)
		DMM_CELL11(0)
		DMM_CELL12(0)
		CELL_POS_DMM_CURR(0)
	
	elseif mode == 32 then -- DMMRly.VBATNegCurrMeasOn
		LV_DMM_CON(0)
		SELOUT_DMM_POS(0)
		CELL_DMM_NEG(0)
		CELL_DMM_POS(0)
		SELIN_DMM_POS(0)
		DMM_CELL1(0)
		DMM_CELL2(0)
		DMM_CELL3(0)
		DMM_CELL4(0)
		DMM_CELL5(0)
		DMM_CELL6(0)
		DMM_CELL7(0)
		DMM_CELL8(0)
		DMM_CELL9(0)
		DMM_CELL10(0)
		DMM_CELL11(0)
		DMM_CELL12(0)
		CELL_POS_DMM_CURR(0)
		LV_DMM_CURR(onoff)
		LV_PWR_NEG(0)

	elseif mode == 33 then -- DMMRly.VBATNegCurrMeasOff
		LV_DMM_CURR(0)
	
	elseif mode == 34 then -- DMMRly.HVPosCurrMeasOn
		CELL_POS_DMM_CURR(onoff)
		CELL_POS_CONNECT(0)

	elseif mode == 35 then -- DMMRly.VBATVoltMeas
		LV_DMM_CON(onoff)

	elseif mode == 36 then -- DMMRly.SELInVoltMeas
		SELIN_DMM_POS(onoff)

	elseif mode == 37 then -- DMMRly.SELOutVoltMeas
		SELOUT_DMM_POS(onoff)
		
	elseif mode == 38 then -- DMMRly.Cell1VoltMeas
		DMM_CELLGND(onoff)
		DMM_CELL1(onoff)
		
	elseif mode == 39 then -- DMMRly.Cell2VoltMeas
		DMM_CELL1(onoff)
		DMM_CELL2(onoff)
	
	elseif mode == 40 then -- DMMRly.Cell3VoltMeas
		DMM_CELL2(onoff)
		DMM_CELL3(onoff)
	
	elseif mode == 41 then -- DMMRly.Cell4VoltMeas
		DMM_CELL3(onoff)
		DMM_CELL4(onoff)
	
	elseif mode == 42 then -- DMMRly.Cell5VoltMeas
		DMM_CELL4(onoff)
		DMM_CELL5(onoff)
	
	elseif mode == 43 then -- DMMRly.Cell6VoltMeas
		DMM_CELL5(onoff)
		DMM_CELL6(onoff)
	
	elseif mode == 44 then -- DMMRly.Cell7VoltMeas
		DMM_CELL6(onoff)
		DMM_CELL7(onoff)
	
	elseif mode == 45 then -- DMMRly.Cell8VoltMeas
		DMM_CELL7(onoff)
		DMM_CELL8(onoff)
	
	elseif mode == 46 then -- DMMRly.Cell9VoltMeas
		DMM_CELL8(onoff)
		DMM_CELL9(onoff)
	
	elseif mode == 47 then -- DMMRly.Cell10VoltMeas
		DMM_CELL9(onoff)
		DMM_CELL10(onoff)
	
	elseif mode == 48 then -- DMMRly.Cell11VoltMeas
		DMM_CELL10(onoff)
		DMM_CELL11(onoff)
	
	elseif mode == 49 then -- DMMRly.Cell12VoltMeas
		DMM_CELL11(onoff)
		DMM_CELL12(onoff)
	
	elseif mode == 50 then -- DMMRly.Cell13VoltMeas
		DMM_CELL12(onoff)
		CELL_DMM_POS(onoff)
	end
end

------------------------------------------------------------------------
-- Programmable resistor Board
------------------------------------------------------------------------
declare "resbrd_name"
resbrd_name = "RESBRD"

declare "calc_res"
function calc_res(setValue)
	local temp_res = {}
	local resArr = {200000, 100000,
					40000, 30000, 20000, 10000,
					4000, 3000, 2000, 1000,
					400, 300, 200, 100,
					40, 30, 20, 10,
					4, 3, 2, 1
					}
	for idx = 1,22,1 do
		if setValue >= resArr[idx] then
			setValue = setValue - resArr[idx]
			table.insert(temp_res, 1)
		else
			table.insert(temp_res, 0)
		end
	end
	return temp_res
end

declare "ProgrammableResistor" --TODO Mode 확인
function ProgrammableResistor(ch, value, mode)
	local resArr = {}
	local arr_1 = ""
	local arr_2 = ""
	local arr_3 = ""
	local arr_mode = ""
	local onoff = 0
	resArr = calc_res(value)
	
	for idx = 6, 1, -1 do
		arr_1 = arr_1..resArr[idx]
	end
	
	for idx = 8, 1, -1 do
		arr_2 = arr_2..resArr[idx + 6]
		arr_3 = arr_3..resArr[idx + 14]
	end
	
	if mode == 0 then
		onoff = "11"
		arr_mode = "0000" -- Normal
		

	elseif mode == 1 then
		arr_mode = "0000" -- Open
		onoff = "00"

	elseif mode == 2 then
		arr_mode = "0000" -- Short to BAT

	else
		arr_mode = "0000" -- Short to GND
	end
	
	local cmd_ch = math.floor((ch + 1)/2)
	local ch_10 = math.floor(cmd_ch/10)
	local ch_1 = cmd_ch%10
	
	
	if (ch%2) ~= 0 then
		tas.writestring(resbrd_name, ":ID"..ch_10..ch_1..",OPH,A"..arr_3.."B"..arr_2.."C"..arr_1..onoff.."D"..arr_mode.."xxxx;")
	else
		tas.writestring(resbrd_name, ":ID"..ch_10..ch_1..",OPH,AxxxxxxxxBxxxxxxxxCxxxxxxxxDxxxx"..arr_mode..";")
		tas.writestring(resbrd_name, ":ID"..ch_10..ch_1..",OPL,A"..arr_3.."B"..arr_2.."C"..arr_1..onoff..";")
	end
	
	arr_1 = ""
	arr_2 = ""
	arr_3 = ""
	arr_mode = ""
end

------------------------------------------------------------------------
-- Power Function
------------------------------------------------------------------------
declare "LVPower_Onoff"
function LVPower_Onoff(onoff)
	tas.write("lvpwr.onoff", onoff)
	return
end

declare "LVPower_Volt"
function LVPower_Volt(volt)
	tas.write("lvpwr.volt", volt)
	return
end

declare "LVPower_Curr"
function LVPower_Curr(curr)
	tas.write("lvpwr.curr", curr)
	return
end

declare "SELInPower_Onoff"
function SELInPower_Onoff(onoff)
	tas.write("selin_pwr.onoff", onoff)
	return
end

declare "SELInPower_Volt"
function SELInPower_Volt(volt)
	tas.write("selin_pwr.volt", volt)
	return
end

declare "SELInPower_Curr"
function SELInPower_Curr(curr)
	tas.write("selin_pwr.curr", curr)
	return
end

------------------------------------------------------------------------
-- NI CAN and DAQ Function
------------------------------------------------------------------------
declare "daq_read_LVPower"
function daq_read_LVPower()
	return tas.read("ai_LV_PWR_POS")
end

declare "daq_read_SELOUTPower"
function daq_read_SELOUTPower()
	return tas.read("ai_SEL_OUT")
end

-- NI CAN Function(CAN1: Vehicle, CAN2: CellSimulator)
declare "can_read"
function can_read(canno, message, signal)
	local can_obj = "can"..canno.."."..message.."/"..signal
	local val = tas.read(can_obj)
	if val ~= nil then		--- 잘못된 경우 1.300009 
		return val
	else
		return false
	end
end

declare "can_write"
function can_write(canno, message, signal, val)
	local can_obj = "can"..canno.."."..message.."/"..signal
	tas.write(can_obj, val)
end

------------------------------------------------------------------------
-- CMC CAN Function
------------------------------------------------------------------------
declare "read_dev_msg"
function read_dev_msg(msg)
	local _diag_res_timeout_ms = 1000
	local res_data_str = ""
	local frame_list = {}
	local byte_data = {}
	local byte_len = 0
	local frame_len = 0
	local byte_str = ""
	local start_time = tas.time_msec()

	while true do
		local readmessage = tas.readstring("can1.@frame:"..msg) --tas.read("can1.@frame:0x18FED101")
		if readmessage ~= "" and readmessage ~= nil then
			res_data_str = readmessage
			break
		end
		
		if tas.time_msec() - start_time > _diag_res_timeout_ms then
			--tas.fail(msg .. ": fail to read dev-response (timeout)")			
			tas.progress(msg .. ": fail to read dev-response (timeout)")
			return ""
		end
		
		tas.wait(10)
	end
	
	frame_list = string.sub(res_data_str, 1, 16)
	for frame = 1,8,1 do
		byte_data[frame] = string.sub(frame_list, ((frame*2)-1), (frame*2))
	end
	
	return byte_data
end

declare "cmc_can_write"
function cmc_can_write(message, signal, val)
	local can_obj = "can1."..message.."/"..signal
	tas.write(can_obj, val)
end

declare "cmc_can_write_msg"
function cmc_can_write_msg(message_id, val)
	local add_value = ""
	for i = 1,8,1 do
		add_value = add_value..val[i]
	end
	tas.writestring("can1.@frame:"..message_id, add_value)
end

declare "cmc_can_read"
function cmc_can_read(message, signal)
	local can_obj = "can1."..message.."/"..signal
	return tas.read(can_obj)
end

------------------------------------------------------------------------
-- CellSimulator Function
------------------------------------------------------------------------
declare "cs_can_write"
function cs_can_write(message, signal, val)
	local can_obj = "can2."..message.."/"..signal
	tas.write(can_obj, val)
end

declare "cs_can_read"
function cs_can_read(message, signal)
	local can_obj = "can2."..message.."/"..signal
	return tas.read(can_obj)
end

declare "can_write_cellsim_volt_set"
function can_write_cellsim_volt_set(message, signal, val)

	if val > 5000 and val < 0 then
		tas.fail("Cell Simulator set voltage error.(range 0-5000)")
		return
	end
	
	local can_obj = "can2".."."..message.."/"..signal
	tas.write(can_obj, val)
end

declare "CellSimulator_Volt"
function CellSimulator_Volt(CellSimNo, Ch1Volt, Ch2Volt, Ch3Volt, Ch4Volt)
	-- CellSimulator Board 1ea당 4개의 Channel을 가지고 있으므로 Cell Simulator 번호와 각 채널의 전압을 받아온다.
	local conv_cellsim_msg = "CellSim"..CellSimNo.."VoltSet"
	local conv_cellsim_sig1 = "CellSim"..CellSimNo.."ValueSetVolt1"
	local conv_cellsim_sig2 = "CellSim"..CellSimNo.."ValueSetVolt2"
	local conv_cellsim_sig3 = "CellSim"..CellSimNo.."ValueSetVolt3"
	local conv_cellsim_sig4 = "CellSim"..CellSimNo.."ValueSetVolt4"
	can_write_cellsim_volt_set(conv_cellsim_msg, conv_cellsim_sig1, Ch1Volt)
	tas.wait(100)
	can_write_cellsim_volt_set(conv_cellsim_msg, conv_cellsim_sig2, Ch2Volt)
	tas.wait(100)
	can_write_cellsim_volt_set(conv_cellsim_msg, conv_cellsim_sig3, Ch3Volt)
	tas.wait(100)
	can_write_cellsim_volt_set(conv_cellsim_msg, conv_cellsim_sig4, Ch4Volt)
	tas.wait(100)
end

declare "CellSimulator_Volt_All"
function CellSimulator_Volt_All(CellVolt)
	for i = 1, 3 do
		CellSimulator_Volt(i, CellVolt, CellVolt, CellVolt, CellVolt)
	end
end
	
declare "CellSimulator_Relay"
function CellSimulator_Relay(CellSimNo, Ch1Rly, Ch2Rly, Ch3Rly, Ch4Rly)
	local conv_cellsim_msg = "CellSim"..CellSimNo.."Relay"
	local conv_cellsim_sig1 = "CellSim"..CellSimNo.."RelayOperation1"
	local conv_cellsim_sig2 = "CellSim"..CellSimNo.."RelayOperation2"
	local conv_cellsim_sig3 = "CellSim"..CellSimNo.."RelayOperation3"
	local conv_cellsim_sig4 = "CellSim"..CellSimNo.."RelayOperation4"
	can_write_cellsim_volt_set(conv_cellsim_msg, conv_cellsim_sig1, Ch1Rly)
	can_write_cellsim_volt_set(conv_cellsim_msg, conv_cellsim_sig2, Ch2Rly)
	can_write_cellsim_volt_set(conv_cellsim_msg, conv_cellsim_sig3, Ch3Rly)
	can_write_cellsim_volt_set(conv_cellsim_msg, conv_cellsim_sig4, Ch4Rly)
end

declare "CellSimulator_CAN"
function CellSimulator_CAN(mode, onoff)
	if mode == 0 then --Cellsimulator can on/off
		cs_can_write("SysFunc", "SysFuncAllOff", onoff)
	elseif mode == 1 then
		-- fill another cellsimulator function can message
	end
end
-----------------------------------------------------------------------
-- TAS Interaction/Callback/Feedback Functions
-- TestStart/Finish Feedback to UI
-----------------------------------------------------------------------
declare "test_start"
function test_start(tcid, seqid, subseqid)

if using_debug_hwio == 1 then
	tas.progress("TestCase No: "..tcid.." Sequence ID: "..seqid.." SubSequence ID: "..subseqid)
end

	local send_msg = tcid .. "," .. seqid .. "," .. subseqid
	tas.ExtCtr_SendMessage("TEST_STEP_START", send_msg)
end

declare "test_finish"
function test_finish(tcid, seqid, subseqid, read_value, result)
	local result_str = ""
	local result_int = 0
	if result == true then
		result_str = "True"
		result_int = 1
	else
		result_str = "False"
		result_int = 0
	end

if using_debug_hwio == 1 then
	tas.progress("TestCase No: "..tcid.." Sequence ID: "..seqid.." SubSequence ID: "..subseqid.." ReadValue: "..read_value.." Result:"..result_str)
end

	local send_msg = tcid .. "," .. seqid .. "," .. subseqid .. "," .. result_int .. "," .. read_value
	tas.ExtCtr_SendMessage("TEST_STEP_FINISH", send_msg)
end

-- UI에 창으로 뜨고, 5초후 사라짐
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

------------------------------------------------------------------------
-- Batch Task
------------------------------------------------------------------------
declare "h_task_chk_barcode"
declare "h_task_critical_stop_check"
declare "start_background_task"
function start_background_task()
	h_task_chk_barcode = tas.runbackground("task_check_barcode_and_send_to_ui()") --TODO 
	h_task_critical_stop_check = tas.runbackground("task_critical_stop_check()")
end
declare "stop_background_task"
function stop_background_task()
	tas.runbackgroundstop(h_task_chk_barcode) --TODO
	tas.runbackgroundstop(h_task_critical_stop_check)
end

start_background_task()

------------------------------------------------------------------------
-- LS Smart IO Function
------------------------------------------------------------------------



------------------------------------------------------------------------
-- DMM
------------------------------------------------------------------------
declare "DMM_Set"
function DMM_Set(mode)
	local temp = 0
	if mode == 0 then
		temp = tas.read(dmm_name..".dcvolt")
		
	elseif mode == 1 then
		temp = tas.read(dmm_name..".dccurr")
	end
	return temp
end
