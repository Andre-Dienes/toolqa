Class ToolQA.tool.producao Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="ToolQA.tool.producao" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="OpenMeteo" Category="" ClassName="ToolQA.tool.BO.OpenMeteoAPI" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="Forecast" Category="" ClassName="ToolQA.tool.BP.forecast" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item><Item Name="Tool" Category="" ClassName="ToolQA.tool.BP.Tool" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
</Production>
}

}
