Scriptname WetFunctionNGMCM extends Quest
{Legacy script name retained for save compatibility. This is not an MCM: configuration is native through
 SKSE Menu Framework. The script forwards SexLab / SexLab P+ scene data that is exposed through Papyrus and the
 mod events other mods send to WetFunction (Bathing in Skyrim, Afterglow / SLACS).}

Event OnInit()
	RegisterEvents()
EndEvent

Function RegisterEvents()
	UnregisterForAllModEvents()
	RegisterForModEvent("AnimationStart", "OnSexLabScene")
	RegisterForModEvent("ActorChangeStart", "OnSexLabScene")
	RegisterForModEvent("ActorChangeEnd", "OnSexLabScene")
	RegisterForModEvent("AnimationEnd", "OnSexLabScene")
	RegisterForModEvent("StageStart", "OnSexLabScene")
	RegisterForModEvent("SexLabOrgasm", "OnSexLabOrgasm")
	; Bathing in Skyrim: the wash is over -> wet; dirt re-applied to every actor after a load -> repaint
	RegisterForModEvent("BiS_WashActorFinish", "OnBiSWashActorFinish")
	RegisterForModEvent("BiS_UpdateActorsAll", "OnBiSUpdateActorsAll")
	; Afterglow (SLACS) and the Dewpoint-era WFR patch: sent after a face 3D rebuild
	RegisterForModEvent("WetFunction_ForceHeadRefresh", "OnForceHeadRefresh")
EndFunction

Event OnSexLabScene(String asEvent, String asThread, Float afValue, Form akSender)
	sslThreadController thread = akSender as sslThreadController
	If thread == None
		Return
	EndIf
	Int phase = 1
	If asEvent == "AnimationStart" || asEvent == "ActorChangeEnd"
		phase = 0
	ElseIf asEvent == "AnimationEnd" || asEvent == "ActorChangeStart"
		phase = 2
	EndIf
	Actor[] positions = thread.GetPositions()
	Int count = positions.Length
	Float[] enjoyment = Utility.CreateFloatArray(count)
	Float[] pain = Utility.CreateFloatArray(count)
	If phase == 1
		Int i = 0
		While i < count
			If positions[i]
				enjoyment[i] = thread.GetEnjoyment(positions[i]) as Float
				pain[i] = thread.GetPain(positions[i]) as Float
			EndIf
			i += 1
		EndWhile
	EndIf
	WetFunctionNG.SexLabUpdate(akSender, positions, enjoyment, pain, phase)
EndEvent

Event OnSexLabOrgasm(Form akActor, Int aiEnjoyment, Int aiOrgasms)
	WetFunctionNG.SexLabOrgasm(akActor as Actor)
EndEvent

Event OnBiSWashActorFinish(Form akBathingActor, Form akWashProp, Bool abUsingSoap)
	Actor bather = akBathingActor as Actor
	If bather
		WetFunctionNG.Bathed(bather)
	EndIf
EndEvent

Event OnBiSUpdateActorsAll()
	WetFunctionNG.RefreshVisuals()
EndEvent

Event OnForceHeadRefresh(String asEvent, String asArg, Float afValue, Form akSender)
	WetFunctionNG.RefreshVisuals()
EndEvent
