Class ToolQA.tool.BP.forecast Extends Ens.BusinessProcess
{
    Method OnRequest(pRequest As ToolQA.tool.msg.Req, Output pResponse As ToolQA.tool.msg.Resp) As %Status
{
    Set tSC = $$$OK
    Try {
        Set aRequest = ##Class(ToolQA.tool.msg.Req).%New()
        Set aRequest.startDate = "2025-07-20"
        Set aRequest.endDate = "2025-07-20"
        $$$THROWONERROR(tSC,..SendRequestSync("OpenMeteo",aRequest,.aResponse))
        If $IsObject(aResponse)	{
            
            //save to database or process the response as needed
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}
}