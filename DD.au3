
#cs
	Copyright (c) 2020 TarreTarreTarre <tarre.islam@gmail.com>
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
#ce
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w 7
#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: DD
; Description ...: Displays useful information about a variable or object in the console
; Syntax ........: DD($any[, $exit = True])
; Parameters ....: $any                 - anything.
;                  $exit                - [optional] an boolean value. Default is True.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func DD($any, $exit = True)
	ConsoleWrite(@LF)
	__DD($any, 0)
	ConsoleWrite(@LF)
	If $exit Then Exit
EndFunc   ;==>DD

#Region Internals
Func __DD($any, $depth)

	Switch VarGetType($any)
		Case "Array"
			__DD_Array($any, $depth)
		Case "Object" And ObjName($any) == "Dictionary"
			ConsoleWrite("- ")
			__DD_ScriptingDictionary($any, $depth)
		Case Else
			ConsoleWrite(IsObj($any) ? '! ' : '> ')
			__DD_Other($any)
	EndSwitch

EndFunc   ;==>__DD

Func __DD_Array($array, $depth, $curI = Null, $curJ = Null, $ignoreTabs = False)

	Local Const $rows = UBound($array)
	Local Const $cols = UBound($array, 2)
	Local $cur, $oInfo, $cwColor

	If $cols == 0 Then
		$curI = VarGetType($curI) == "Int32" ? StringFormat("[%d] => ", $curI) : ""

		ConsoleWrite(">" & __GetTabs($depth, $ignoreTabs) & StringFormat('%s(Array:%d) [', $curI, $rows) & @LF)

		For $i = 0 To $rows - 1
			$cur = $array[$i]
			$oInfo = __GetDataInfo($cur)
			$cwColor = IsObj($cur) ? (ObjName($cur) == "Dictionary" ? '-' : '!') : '>'

			If IsArray($cur) Then
				__DD_Array($cur, $depth + 1, $i)
				;ConsoleWrite("> " & $sTabs & "]" & @LF)
			ElseIf IsObj($cur) And ObjName($cur) == "Dictionary" Then
				ConsoleWrite("- " & __GetTabs($depth + 1) & StringFormat('[%d] => ', $i))
				__DD_ScriptingDictionary($cur, $depth + 1, True)
			Else
				ConsoleWrite($cwColor & " " & __GetTabs($depth + 1) & StringFormat('[%d] (%s:%s) => "%s"', $i, $oInfo.item("type"), $oInfo.item("length"), $oInfo.item("value")) & @LF)
			EndIf

		Next
	Else
		$curI = VarGetType($curI) == "Int32" ? ($depth == 1 ? StringFormat("[%d] => ", $curI) : StringFormat("[%d][%d] => ", $curI, $curJ)) : ""

		ConsoleWrite(">" & __GetTabs($depth, $ignoreTabs) & StringFormat('%s(Array:%d:%d) [', $curI, $rows, $cols) & @LF)

		For $i = 0 To $rows - 1
			For $j = 0 To $cols - 1
				$cur = $array[$i][$j]
				$oInfo = __GetDataInfo($cur)
				$cwColor = IsObj($cur) ? (ObjName($cur) == "Dictionary" ? '-' : '!') : '>'


				If IsArray($cur) Then
					__DD_Array($cur, $depth + 1, $i, $j)
				ElseIf IsObj($cur) And ObjName($cur) == "Dictionary" Then
					ConsoleWrite("- " & __GetTabs($depth + 1) & StringFormat('[%d][%d] => ', $i, $j))
					__DD_ScriptingDictionary($cur, $depth + 1, True)
				Else
					ConsoleWrite($cwColor & " " & __GetTabs($depth + 1) & StringFormat('[%d][%d] (%s:%s) => "%s"', $i, $j, $oInfo.item("type"), $oInfo.item("length"), $oInfo.item("value")) & @LF)
				EndIf

			Next
		Next

	EndIf

	ConsoleWrite("> " & __GetTabs($depth) & "]" & @LF)
EndFunc   ;==>__DD_Array

Func __DD_ScriptingDictionary($object, $depth, $ignoreTabs = False)

	ConsoleWrite(__GetTabs($depth, $ignoreTabs) & StringFormat('(Scripting.Dictionary:%d) {', $object.count()) & @LF)

	For $item In $object
		Local $key = $item
		Local $value = $object.item($key)
		Local $oInfo = __GetDataInfo($value)

		If IsObj($value) And ObjName($value) == "Dictionary" Then
			ConsoleWrite(StringFormat("- " & __GetTabs($depth + 1) & "[%s] => ", $key))
			__DD_ScriptingDictionary($value, $depth + 1, True)
		ElseIf IsArray($value) Then
			ConsoleWrite("> " & __GetTabs($depth + 1) & StringFormat('[%s] => ', $key))
			__DD_Array($value, $depth + 1, Null, Null, True)
		Else
			ConsoleWrite("- " & __GetTabs($depth + 1) & StringFormat('[%s] (%s:%s) => "%s"', $key, $oInfo.item("type"), $oInfo.item("length"), $oInfo.item("value")) & @LF)
		EndIf

	Next

	ConsoleWrite("- " & __GetTabs($depth) & "}" & @LF)

EndFunc   ;==>__DD_ScriptingDictionary

Func __DD_Other($any)
	Local Const $oInfo = __GetDataInfo($any)

	ConsoleWrite(StringFormat('(%s:%s) "%s"', $oInfo.item("type"), $oInfo.item("length"), $oInfo.item("value")) & @LF)
EndFunc   ;==>__DD_Other

Func __GetDataInfo($any)
	Local Const $oRet = ObjCreate("Scripting.Dictionary")
	Local $type = VarGetType($any)
	Local $value = $any
	Local $length = StringLen($any)

	Switch $type
		Case "UserFunction"
			ContinueCase
		Case "Function"
			$value = FuncName($any)
			$length = StringLen($value)
		Case "Object"
			$type = ObjName($any)
			$length = ObjName($any, 2) ; Descriptobn
			$value = ObjName($any, 6) ; Clisid
		Case "String"
			Local $str = $any
			$str = StringReplace($str, @LF, "\LF")
			$str = StringReplace($str, @CR, "\CR")
			$str = StringReplace($str, @CRLF, "\CRLF")
			$str = StringReplace($str, @TAB, "\TAB")
			$value = $str
		Case "Binary"
			$value = BinaryLen($any)
		Case "Keyword" And $length == 0
			$value = "NULL"
	EndSwitch

	$oRet.add("type", $type)
	$oRet.add("length", $length)
	$oRet.add("value", $value)

	Return $oRet
EndFunc   ;==>__GetDataInfo

Func __GetTabs($depth, $ignoreTabs = False)
	If $ignoreTabs Then Return ""
	Local $sTabs
	For $i = 0 To $depth - 1
		$sTabs &= @TAB
	Next

	Return $sTabs
EndFunc   ;==>__GetTabs
#EndRegion Internals
