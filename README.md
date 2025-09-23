🧪 IRIS Automated Test Generator

This project provides an ObjectScript class with Embedded Python that automatically generates and runs test classes for InterSystems IRIS classes.

It allows you to:

Inspect an existing IRIS class (%Dictionary.ClassDefinition)

Generate a Python-based test class dynamically

Save the test class in /tmp

Run the tests and see a success/failure report

📂 Class Structure

The main entrypoint is:

Class ToolQA.tool.BP.Tool


It exposes two class methods:

GenerateTestForClass(apiClassName As %String)

Reads the methods of the given IRIS class

Generates a new Python test file under /tmp

Each public class method is tested with fake arguments and validations

Prints out a summary of total tests, successes, and failures

RunTest(testClassName As %String)

Loads the generated Python test module from /tmp

Executes the test runner (.run()) method

Prints the test results and returns 1 (success) or 0 (failure)

⚙️ How It Works

Written as an IRIS ObjectScript class, but with methods implemented in Python ([ Language = python ])

Uses IRIS Embedded Python (import iris) to query the system dictionary and introspect classes

Dynamically builds Python code for the test class and writes it into /tmp/ToolQA_tool_QA_<ClassName>Test.py

Fake values are generated automatically for method parameters (strings, integers, floats, dates, etc.)

Tests validate arguments against schema properties (%Dictionary.CompiledPropertyDefinition) when available

A final report is printed showing:

------------------------------------------
Resume Tests:
  Total tests: 5
  Success: 4
  Fails: 1
  Success rate: 80.00%

▶️ Running the Tool
1. Generate Tests

From an IRIS session, run:

do ##class(ToolQA.tool.BP.Tool).GenerateTestForClass("ToolQA.tool.BP.forecast")


Output:

✅ Python test class saved in: /tmp/ToolQA_tool_QA_forecastTest.py

2. Run Tests

Now run the generated test:

do ##class(ToolQA.tool.BP.Tool).RunTest("ToolQA.tool.QA.forecastTest")


Output:

▶ Running ToolQA.tool.QA.forecastTest...
Starting tests for: ToolQA.tool.BP.forecast
--------------------------------------------------
✓ Method OnRequest executed with success
--------------------------------------------------
Resume Tests:
  Total tests: 1
  Success: 1
  Fails: 0
  Success rate: 100.00%

⚡ Quick Example with a Business Process

Let’s use your API Business Process:

Class ToolQA.tool.BP.forecast Extends Ens.BusinessProcess
{

Method OnRequest(pRequest As ToolQA.tool.msg.Req, Output pResponse As ToolQA.tool.msg.Resp) As %Status
{
    Set tSC = $$$OK
    Try {
        Set aRequest = ##Class(ToolQA.tool.msg.Req).%New()
        Set aRequest.startDate = "2025-07-20"
        Set aRequest.endDate   = "2025-07-20"
        $$$THROWONERROR(tSC,..SendRequestSync("OpenMeteo",aRequest,.aResponse))
        
        If $IsObject(aResponse) {
            // save to database or process the response as needed
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}
}

Step 1: Generate the Test
do ##class(ToolQA.tool.BP.Tool).GenerateTestForClass("ToolQA.tool.BP.forecast")


This will inspect the OnRequest method and generate a test with fake ToolQA.tool.msg.Req request data.

Step 2: Run the Test
do ##class(ToolQA.tool.BP.Tool).RunTest("ToolQA.tool.QA.forecastTest")


Expected output:

Starting tests for: ToolQA.tool.BP.forecast
--------------------------------------------------
✓ Method OnRequest executed with success
--------------------------------------------------
Resume Tests:
  Total tests: 1
  Success: 1
  Fails: 0
  Success rate: 100.00%

📌 Notes

Generated Python files are stored in /tmp.

Method arguments are filled with fake values depending on parameter type:

%String → "test_string"

%Integer → 123

%Double/%Float → 123.45

%Boolean → True

%Date → "2024-01-01"

%Time → "12:00:00"

%Timestamp → "2024-01-01 12:00:00"

Validation checks against IRIS schema definitions when available.

Works with public class methods only (ClassMethod and not Private).

✅ Requirements

InterSystems IRIS 2022.1+ with Embedded Python enabled

Write permissions to /tmp for saving generated Python files