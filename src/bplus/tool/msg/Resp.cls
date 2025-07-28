Class bplus.tool.msg.Resp Extends Ens.Response
{

Property content As %String(MAXLEN = 100000);

Storage Default
{
<Data name="RespDefaultData">
<Subscript>"Resp"</Subscript>
<Value name="1">
<Value>content</Value>
</Value>
</Data>
<DefaultData>RespDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
