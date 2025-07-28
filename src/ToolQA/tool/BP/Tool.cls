Class ToolQA.tool.BP.Tool Extends Ens.BusinessProcess
{
ClassMethod GenerateTestForClass(apiClassName As %String) As %Status
{
    Try {
        Set classDef = ##class(%Dictionary.ClassDefinition).%OpenId(apiClassName)
        If classDef = "" Quit $$$ERROR($$$GeneralError, "class not found")

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
                        Set argsCode = argsCode _ "        Set sc = ##class(ToolQA.tool.BP.Tool).ValidateValueField("""_schemaclass_""", """_pName_""", "_pName_")" _ $C(13,10)
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

        Do ..SaveClass(testClassName, code)
        Write "Generate class: ", testClassName,!
        Quit $$$OK
    } Catch ex {
        Write "Erro: ", ex.DisplayString(),!
        Quit ex.AsStatus()
    }
}
ClassMethod ClassBank(field As %String) As %String
{
    Set namespace = $Namespace
    Set list = ##class(%Library.Routine).Listclasss()
    While list.AtEnd() '= 1 {
        Set cls = list.GetNext()
        If cls["AXS.Model." {
            Set prop = ##class(%Dictionary.CompiledPropertyDefinition).%ExistsId(cls_"||"_field)
            If prop {
                Quit
            }
        }
    }
    Quit ""
}
ClassMethod ValidateValueField(class As %String, field As %String, value) As %Status
{
    Try {
        Set propId = class_"||"_field
        Set prop = ##class(%Dictionary.CompiledPropertyDefinition).%OpenId(propId)
        If '$IsObject(prop) Quit $$$ERROR($$$GeneralError, "field "_field_" not found in "_class)

        Set tipo = prop.Type
        Set maxlen = prop.MaxLen
        Set minval = prop.MinVal
        Set maxval = prop.MaxVal

        If tipo = "%Integer" {
            If '$ZIsInteger(value) Quit $$$ERROR($$$GeneralError, field_": Expect Integer, received '"_value_"'")
        } ElseIf tipo = "%Double" {
            If '$ZIsNumeric(value) Quit $$$ERROR($$$GeneralError, field_": Expect Float, received '"_value_"'")
        } ElseIf tipo = "%String" {
            If (maxlen > 0) && ($Length(value) > maxlen) Quit $$$ERROR($$$GeneralError, field_": String exceeds limit "_maxlen)
        }

        If (tipo = "%Integer" || tipo = "%Double") {
            If minval'="", value < minval Quit $$$ERROR($$$GeneralError, field_": less than the minimum allowed")
            If maxval'="", value > maxval Quit $$$ERROR($$$GeneralError, field_": greater than the maximum allowed")
        }

        Quit $$$OK
    } Catch ex {
        Quit ex.AsStatus()
    }
}

ClassMethod CreateFakeValue(tipo As %String) As %String
{
    Set tipo = $ZStrip(tipo, "<>")
    If tipo = "%String" Quit """test"""
    If tipo = "%Integer" Quit "123"
    If tipo = "%Double" Quit "123.45"
    If tipo = "%Boolean" Quit "1"
    Quit """default"""
}
ClassMethod SaveClass(nomeclass As %String, conteudo As %String) As %Status
{
    Set file = nomeclass_".cls"
    Set f = ##class(%Stream.FileCharacter).%New()
    Set f.Filename = file
    Do f.Write(conteudo)
    Do f.%Save()
    Quit $System.OBJ.Load(file, "ck")
}

ClassMethod LastPiece(str As %String, delim As %String) As %String
{
    Quit $Piece(str, delim, * )
}
}
