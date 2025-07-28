Class ToolQA.Setup Extends %RegisteredObject
{

ClassMethod Init() As %Status
{
    Set tSC = $$$OK
    Try {
        Do $System.OBJ.LoadDir("/home/irisowner/dev/src","ck",,1)

        Write !, "Starting production..."
        $$$ThrowOnError(..StartProduction())
    } Catch ex {
        Set tSC=ex.AsStatus()
    }
    Return tSC
}

ClassMethod StartProduction()
{
    Set prodClass = "ToolQA.tool.producao"
    Do ##class(%EnsembleMgr).SetAutoStart($namespace, prodClass)
    Job ##class(Ens.Director).StartProduction(prodClass)
}

}
