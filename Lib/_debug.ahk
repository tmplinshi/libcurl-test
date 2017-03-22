_debug(Text) {
	static dbg
	if !dbg {
		dbg := New _debug
	}
	dbg.LogText(Text)
}

class _debug
{
	__New() {
		this.CreateGUI()
	}

	CreateGUI() {
		defGUI := A_DefaultGui

		Gui, New, +HwndGuiHwnd +Resize +Label__DebugGui_On
		Gui, Margin, 0, 0
		Gui, Add, ListView, Grid w800 r20 +HwndLvHwnd, #|Text
		Gui, Show, NA x0 y0, Debug - %A_ScriptName%

		this.LvCount := 0
		this.GuiHwnd := GuiHwnd

		Gui, %defGUI%:Default
		return
	}

	LogText(Text) {
		defGUI := A_DefaultGui
		Gui, % this.GuiHwnd ":Default"

		LV_Add("", ++this.LvCount, Text)
		LV_Modify(this.LvCount, "Vis")

		Gui, %defGUI%:Default
	}
}