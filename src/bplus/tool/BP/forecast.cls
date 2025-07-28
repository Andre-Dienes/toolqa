Class bplus.tool.BP.forecast Extends Ens.BusinessProcess
{
    Method OnRequest(pRequest As bplus.tool.msg.Req, Output pResponse As bplus.tool.msg.Resp) As %Status
{
    Set tSC = $$$OK
    Try {
        Set aRequest = ##Class(bplus.tool.msg.Req).%New()
        Set aRequest.startDate = "2025-07-20"
        Set aRequest.endDate = "2025-07-20"
        $$$THROWONERROR(tSC,..SendRequestSync("RequestForecast",aRequest,.aResponse))
        If $IsObject(aResponse)	{
            
            //save to database or process the response as needed
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}
}