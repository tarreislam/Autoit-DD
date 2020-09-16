#include "DD.AU3"
Global $coreFn = MsgBox, $udf = udf, $obj = ObjCreate("shell.application")

; *************************
; * Single values
; *************************

ConsoleWrite("+ Single values " & @LF)

DD(123, False)
DD("string", False)
DD($coreFn, False)
DD($udf, False)
DD($obj, False)

; *************************
; * Single Arrays
; *************************

ConsoleWrite("+ Single arrays " & @LF)

Global $testArr = ["tarre", "hello", 1337, 25, 0x1000]
DD($testArr, False)

; *************************
; * Multi dim arrays
; *************************

ConsoleWrite("+ Multi dim arrays " & @LF)

Global $testArr[3][3]
DD($testArr, False)

; *************************
; * Scripting Dictionaries
; *************************

ConsoleWrite("+ Scripting dictionaries " & @LF)

Global $testObj = ObjCreate("Scripting.Dictionary")
$testObj.add("name", @UserName)
$testObj.add("age", 55)

DD($testObj, False)

; *************************
; * Nested arrays
; *************************

ConsoleWrite("+ Nested arrays " & @LF)

Global $testArr1 = ["tarre", "hello", 1337, 25, 0x1000]
Global $testArr2 = [1,2,3, $testArr1, 5, 6, 7]

DD($testArr2, False)

; *************************
; * Nested Scripting Dictionaries
; *************************

ConsoleWrite("+ Nested Scripting Dictionaries " & @LF)

Global $testObj1 = ObjCreate("Scripting.Dictionary")
$testObj1.add("name", @UserName)
$testObj1.add("age", 55)

Global $testObj2 = ObjCreate("Scripting.Dictionary")
$testObj2.add("rank", 5)
$testObj2.add("personalInfo", $testObj1)
$testObj2.add("email", "etc@abc.com")

DD($testObj2, False)

; *************************
; * Array of Scripting Dictionaries
; *************************

ConsoleWrite("+ Array of Scripting Dictionaries" & @LF)

Global $person1 = ObjCreate("Scripting.Dictionary")
$person1.add("name", "Tarre")
$person1.add("age", 25)

Global $person2 = ObjCreate("Scripting.Dictionary")
$person2.add("name", "Edward")
$person2.add("age", 66)

Global $person3 = ObjCreate("Scripting.Dictionary")
$person3.add("name", "Malte")
$person3.add("age", 45)

Global $array = [$person1, $person2, $person3]

DD($array, False)

; *************************
; * Mix of everything above
; *************************

ConsoleWrite("+ Mix of everything above" & @LF)

Global $testarrB = [6, 7, $testObj2, false, True, Null]
Global $multiDIm[3][3]
$multiDIm[1][2] = $person1
$multiDIm[2][2] = $person2
$multiDIm[1][2] = $obj
$multiDIm[1][0] = $testObj
Global $testArr = [10, 0x50, $udf, $coreFn, $obj, $multiDIm, $testarrB]

DD($testArr)

Func udf()
EndFunc