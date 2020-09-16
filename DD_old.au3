
Global $__DD_OBJ_RECUR_LIMIT = 100
Func DD($any = Default, $abort = True); Dump any data into the current console
	ConsoleWrite(@LF & "! ~ " & "Begin" & @LF)

	Switch VarGetType($any)
		Case "Array"
			__DD_Array($any)
		Case "Object"
			__DD_Object($any)
		Case Else
			__DD_Else($any)
	EndSwitch

	ConsoleWrite("! ~ " & "End" & @LF)
	If $abort Then Exit
EndFunc   ;==>DD

Func DD_TRANSCRIBE($any); An extended VarGetType.
	Local $aTmp = __DD_VarGetDataInfo($any)
	Return StringFormat('(%s) "%s"', $aTmp[1], $aTmp[2])
EndFunc

Func _DD_Macro($sKey, $sType, $sVal); Create a macro for DD() to parse
	Return StringFormat("\DD:%s:%s:%s\", $sKey, $sType, $sVal)
EndFunc

Func _DD_SET_RECUR_LIMIT($nLimit = 100); Object nesting can be referenced forever, DD will stop checking for objects when this limit is reached.
	$__DD_OBJ_RECUR_LIMIT = $nLimit
EndFunc

Func __DD_Else($any)
	Local $aVarInfo = __DD_VarGetDataInfo($any)
	ConsoleWrite(StringFormat('(%s) "%s"', $aVarInfo[1], $aVarInfo[2]) & @LF)
EndFunc   ;==>__DD_Else

Func __DD_VarGetDataInfo($any, $sKey = Default)
	Local $aRet = [$sKey, "Keyword", "Null"]
	If $any == Null Then Return $aRet
	Local Const $VarGetType = VarGetType($any)

	; DD Macro \DD:Key:Type:Value
	Local $DD = StringRegExp($sKey, "^\\[D]{2}\:(.*)\:(.*)\:(.*)\\$", 1)

	if IsArray($DD) Then
			Dim $aRet = [$DD[0], $DD[1], $DD[2]]
			Return $aRet
	EndIf

	Switch $VarGetType
		Case "UserFunction"
			ContinueCase
		Case "Function"
			Dim $aRet = [$sKey, $VarGetType, FuncName($any)]
		Case Else
			Dim $aRet = [$sKey, $VarGetType, StringReplace(StringReplace(String($any), @LF, "\r"), @CR, "\r")]; To make it look nicer
	EndSwitch

	Return $aRet
EndFunc   ;==>__DD_VarGetDataByType

Func __DD_Array($array, $iDepth = 0, $curI = Null, $curJ = Null, $ignoreTabs = False)
	Local $sTabs = "", $sTabs_original = ""
	For $i = 1 To $iDepth
		$sTabs &= @TAB
	Next

	Local $iRows = UBound($array)
	Local $iCols = UBound($array, 2)
	Local $cur, $aVarInfo

	$sTabs_original = $sTabs
	$sTabs &= @TAB

	Local $tabs = $ignoreTabs ? "" : "> " & $sTabs_original

	If $iCols == 0 Then
		$curI = VarGetType($curI) == "Int32" ? StringFormat("[%d] => ", $curI) : ""

		ConsoleWrite($tabs & StringFormat('%s(Array:%d) [', $curI, $iRows) & @LF)

		For $i = 0 To $iRows - 1
			$cur = $array[$i]
			$aVarInfo = __DD_VarGetDataInfo($cur)

			If IsArray($cur) Then
				__DD_Array($cur, $iDepth + 1, $i)
				;ConsoleWrite("> " & $sTabs & "]" & @LF)
			ElseIf IsObj($cur) Then
				ConsoleWrite("- " & $sTabs & StringFormat('[%d] => ', $i))
				__DD_Object($cur, $iDepth + 1, Null, True)
			Else
				ConsoleWrite("> " & $sTabs & StringFormat('[%d] (%s) => "%s"', $i, $aVarInfo[1], $aVarInfo[2]) & @LF)
			EndIf

		Next
	Else

		$curI = VarGetType($curI) == "Int32" ? ($iDepth == 1 ? StringFormat("[%d] => ", $curI)  : StringFormat("[%d][%d] => ", $curI, $curJ) ): "" ;
		ConsoleWrite($tabs & StringFormat('%s(Array:%d:%d) [', $curI, $iRows, $iCols) & @LF)

		For $i = 0 To $iRows - 1
			For $j = 0 To $iCols - 1
				$cur = $array[$i][$j]
				$aVarInfo = __DD_VarGetDataInfo($cur)

				If IsArray($cur) Then
					__DD_Array($cur, $iDepth + 1, $i, $j)
				ElseIf IsObj($cur) Then
					ConsoleWrite("- " & $sTabs & StringFormat('[%d][%d] => ', $i, $j))
					__DD_Object($cur, $iDepth + 1, Null, True)
				Else
					ConsoleWrite("> " & $sTabs & StringFormat('[%d][%d] (%s) => "%s"', $i, $j, $aVarInfo[1], $aVarInfo[2]) & @LF)
				EndIf

			Next
		Next
	EndIf

	ConsoleWrite("> " & $sTabs_original & "]" & @LF)

EndFunc   ;==>__DD_Array

Func __DD_Object($oObj, $iDepth = 0, $psName = Null, $ignoreTabs = False)
	Local $sTabs = "", $sTabs_original = ""

	For $i = 1 To $iDepth
		$sTabs &= @TAB
	Next

	$sTabs_original = $sTabs
	$sTabs &= @TAB
	Local $tabs = $ignoreTabs ? "" : $sTabs_original
	If Not Execute("isArray($oObj.__attr__)") Then
		Local $sObjInfo = "(" & ObjName($oObj, 1)  & ') "' & ObjName($oObj, 2) & '"'

		If Not $psName Then; In this case. we probably come from an array
			ConsoleWrite($sObjInfo & @LF)
		ElseIf Not ObjName($oObj, 1) Then; If we can not recognize wassup
			ConsoleWrite("-" & $tabs & "[" & $psName & "] => " & '(Object:0) {}'  & @LF)
		Else
			ConsoleWrite("!" & $tabs & "[" & $psName & "] => " & $sObjInfo  & @LF)
		EndIf
		Return
	EndIf

	$tabs  = '- ' & $tabs

	Local $aARgs = $oObj.__attr__
	Local Const $aArgsSize = UBound($aARgs)

	$psName = $psName ? "[" & $psName & "] => " : ""
	ConsoleWrite($tabs & StringFormat('%s(Object:%d) {', $psName, $aArgsSize) & @LF)

	For $i = 0 To $aArgsSize - 1
		Local $sName = $aARgs[$i]
		Local $xData = Execute("$oObj." & $sName)
		Local $aVarInfo = __DD_VarGetDataInfo($xData, $sName)

		If IsObj($xData) Then
			__DD_Object($xData, $iDepth + 1, $sName)
		ElseIf IsArray($xData) Then
			ConsoleWrite("> " & $sTabs & StringFormat('[%s] => ', $sName))
			__DD_Array($xData, $iDepth + 1, Null, Null, True)
		Else
			ConsoleWrite("- " & $sTabs & StringFormat('[%s] (%s) => "%s"', $aVarInfo[0], $aVarInfo[1], $aVarInfo[2]) & @LF)
		EndIf
	Next

	ConsoleWrite("- " & $sTabs_original & "}" & @LF)

EndFunc   ;==>__DD_Object
