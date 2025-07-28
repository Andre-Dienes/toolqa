Class ToolQA.tool.BD.database Extends %Persistent [ ClassType = persistent, DdlAllowed, Final, ProcedureBlock, SqlRowIdPrivate, SqlTableName = database ]
{

Index IdxKeydatabase On data [ PrimaryKey ];

Property data As %String(MAXLEN = 10) [ SqlColumnNumber = 2 ];

Property latitude As %Decimal(SCALE = 4) [ SqlColumnNumber = 3 ];

Property longitude As %Decimal(SCALE = 4) [ SqlColumnNumber = 4 ];

Property elevation As %Decimal(SCALE = 4) [ SqlColumnNumber = 5 ];

Property generationtime As %Decimal(SCALE = 4) [ SqlColumnNumber = 6 ];

Property timezone As %String(MAXLEN = 50) [ SqlColumnNumber = 7 ];
}