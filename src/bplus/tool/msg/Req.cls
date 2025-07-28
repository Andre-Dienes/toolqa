Class bplus.tool.msg.Req Extends Ens.Request
{

Property startDate As %String;

Property endDate As %String;

Storage Default
{
<Data name="ReqDefaultData">
<Subscript>"Req"</Subscript>
<Value name="1">
<Value>startDate</Value>
</Value>
<Value name="2">
<Value>endDate</Value>
</Value>
</Data>
<DefaultData>ReqDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
