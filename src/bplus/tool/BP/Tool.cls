Class bplus.tool.BP.Tool Extends Ens.BusinessProcess
{
ClassMethod GenerateTestForClass(apiClassName As %String) As %Status
{
    Try {
        Set classDef = ##class(%Dictionary.ClassDefinition).%OpenId(apiClassName)
        If classDef = "" Quit $$$ERROR($$$GeneralError, "class não encontrada")

        Set testClassName = "AXS.QA.Tests."_$$LastPiece(apiClassName,".")_"Test"
        Set code = ""
        Set line1 = "Class "_testClassName_" {"
        Set line2 = "ClassMethod Run() As %Status"
        Set line3 = "{"
        Set line4 = "    Write ""Starting tests for: "_apiClassName_""",!"

        Set code = line1 _ $C(13,10) _ line2 _ $C(13,10) _ line3 _ $C(13,10) _ line4 _ $C(13,10)

        Set methodList = classDef.Methods
        For i=1:1:methodList.Count() {
            Set method = methodList.GetAt(i)
            If method.ClassMethod && method.Public {
                Set mName = method.Name
                Set line5 = "    // Testing method "_mName
                Set line6 = "    Try {"

                Set argsCode = "", argList = ""
                For j=1:1:method.FormalSpec.Count() {
                    Set param = method.FormalSpec.GetAt(j)
                    Set pName = param.Name
                    Set pType = param.Type
                    Set testValue = ..CreateFakeValue(pType)

                    Set argsCode = argsCode _ "        Set "_pName_" = "_testValue _ $C(13,10)

                    Set schemaclass = ..ClassBank(pName)
                    If schemaclass'="" {
                        Set argsCode = argsCode _ "        Set sc = ##class(toolqa.src.bplus.tool.BP.Tool).ValidateValueField("""_schemaclass_""", """_pName_""", "_pName_")" _ $C(13,10)
                        Set argsCode = argsCode _ "        If $$$ISERR(sc) Quit sc" _ $C(13,10)
                    }

                    Set argList = $S(argList="":pName, 1:argList_","_pName)
                }

                Set line7 = "        Set sc = ##class("_apiClassName_")."_mName_"("_argList_")"
                Set line8 = "        If $$$ISERR(sc) Write ""Erro: "", sc,!"
                Set line9 = "    } Catch ex { Write ""Excepcion: "", ex.DisplayString(),! }"

                Set code = code _ line5 _ $C(13,10) _ line6 _ $C(13,10) _ argsCode _ line7 _ $C(13,10) _ line8 _ $C(13,10) _ line9 _ $C(13,10)
            }
        }

        Set code = code _ "    Quit $$$OK" _ $C(13,10)
        Set code = code _ "}" _ $C(13,10)
        Set code = code _ "}" _ $C(13,10)

        Do ..Gravarclass(testClassName, code)
        Write "Generate class: ", testClassName,!
        Quit $$$OK
    } Catch ex {
        Write "Erro: ", ex.DisplayString(),!
        Quit ex.AsStatus()
    }
}
